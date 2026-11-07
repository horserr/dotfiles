# ubuntu on WSL: https://ubuntu.com/wsl/docs/stable/

# wsl commands https://learn.microsoft.com/en-us/windows/wsl/basic-commands

# wsl network setting
# https://learn.microsoft.com/en-us/windows/wsl/networking#identify-ip-address
#
# Identify IP address
# wsl hostname -I: Returns the IP address of your Linux distribution installed via WSL 2 (the WSL 2 VM address)
# ip route show | grep -i default | awk '{ print $3}': Returns the IP address of the Windows machine as seen from WSL 2 (the WSL 2 VM)
# For a more detailed explanation, see Accessing network applications with WSL: Identify IP Address.

# alias quick reference: alias -> raw command -> what it does
# wsll    wsl --list --verbose            distros with state and WSL version
# wslv    wsl --version                   WSL / kernel / component versions
# wsls    wsl --status                    default distro and default version
# wslip   wsl hostname -I                 WSL 2 VM address (default distro only;
#                                         other distros share the same VM IP)
# wslt    wsl --terminate <distro>        stop one distro (wslt Ubuntu-24.04)
# wslT    wsl --shutdown                  stop all distros and the utility VM
# wslD    wsl --unregister <distro>       delete a distro and its vhdx -- irreversible
# wslif   wsl --install --from-file <f>   install from a custom tar/vhdx
# wslex   wsl --export <distro> <out>     snapshot to a tar, e.g. wslex dev D:\dev.tar
# wslim   wsl --import <name> <dir> <t>   import at a custom location (--version 2)
# wslimip wsl --import-in-place <n> <v>   attach an existing ext4.vhdx as a distro
# wslm    wsl --mount <disk> [--vhd]      mount a physical disk or vhd
# wslum   wsl --unmount [<disk>]          detach one disk, or all when omitted

# function quick reference: helper -> what it does
# wsl-size [distro]            vhdx path + size on disk, optional distro filter
# wsl-path [distro]            vhdx paths only, for scripts / diskpart / backups
# wsl-df [distro]              ext4 usage inside the distro (what the vhdx holds);
#                              vhdx bytes >> used means "run wsl-compact"
# wsl-compact <distro>         give freed blocks back to Windows: --set-sparse true,
#                              falling back to diskpart compact (needs admin)
# wsl-resize <distro> <size>   grow vhdx + ext4 in one step (e.g. 200GB, 2TB)
#
# wsl-df defaults to $WSL_DISTRO_NAME, else WSL's default distro
# internals: _wsl_lxss (registry -> name/path/bytes), _wsl_human (bytes -> GiB)

alias wsll="wsl --list --verbose"
alias wslv="wsl --version"
alias wsls="wsl --status"
alias wslip="wsl hostname -I"
alias wslt="wsl --terminate"
alias wslD="wsl --unregister"
alias wslT="wsl --shutdown"
alias wslif="wsl --install --from-file"

# export / import (point the archive at a data drive if C: is tight)
# wsl --export Ubuntu-24.04 D:\wsl\ubuntu.tar
# wsl --import Ubuntu-24.04 D:\wsl\Ubuntu-24.04 D:\wsl\ubuntu.tar --version 2
# wsl --import-in-place Ubuntu-24.04 D:\wsl\Ubuntu-24.04\ext4.vhdx
alias wslex="wsl --export"
alias wslim="wsl --import"
alias wslimip="wsl --import-in-place"

# https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk
alias wslm="wsl --mount"
alias wslum="wsl --unmount"

# https://learn.microsoft.com/en-us/windows/wsl/build-custom-distro
# https://ubuntu.com/wsl/docs/stable/howto/custom-ubuntu-distro/#howto-custom-distro
# custom build

# --- disk location & usage --------------------------------------------------
# docs: https://learn.microsoft.com/en-us/windows/wsl/disk-space
#
# every WSL 2 distro is one vhd: <BasePath>\ext4.vhdx
# BasePath is registered per distro under
# HKCU\Software\Microsoft\Windows\CurrentVersion\Lxss  (WSL 1 has no vhd)
#
# caveat: the vhdx grows on demand but never shrinks by itself, so after
# deleting files inside the distro use wsl-compact to give the blocks back
# to Windows. WSL_UTF8=1 keeps wsl.exe output readable when it is piped.

# bytes -> human readable, awk so it works in git bash and inside wsl alike
_wsl_human() {
	awk -v b="${1:-0}" 'BEGIN {
		split("B KiB MiB GiB TiB", unit, " ")
		i = 1
		while (b >= 1024 && i < 5) { b /= 1024; i++ }
		printf "%.2f %s", b, unit[i]
	}'
}

# internal: "<distro>\t<vhdx path>\t<bytes>" per distro (bytes empty on WSL 1)
_wsl_lxss() {
	# shellcheck disable=SC2016
	powershell.exe -NoProfile -NonInteractive -Command '
		$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
		Get-ChildItem $key | ForEach-Object {
			$name = $_.GetValue("DistributionName")
			$base = $_.GetValue("BasePath")
			# skip orphan registry keys (no name / no path)
			if (-not $name -or -not $base) { return }
			# some distros store an extended-length path (\\?\C:\...);
			# Join-Path chokes on it, plain concatenation does not
			$base = $base.TrimEnd("\")
			$vhd = $base + "\ext4.vhdx"
			$show = $vhd -replace "^\\\\\?\\", ""
			if (Test-Path -LiteralPath $vhd) {
				$len = (Get-Item -LiteralPath $vhd -Force).Length
				"{0}`t{1}`t{2}" -f $name, $show, $len
			} else {
				"{0}`t{1}`t{2}" -f $name, $show, ""
			}
		}' 2>/dev/null | tr -d '\r'
}

# storage location + size on disk of every distro
# optional arg filters by distro name: wsl-size Ubuntu-24.04
wsl-size() {
	local filter="${1:-}" name path bytes size
	printf '%-24s %10s  %s\n' NAME SIZE PATH
	while IFS=$'\t' read -r name path bytes; do
		[ -n "$filter" ] && [ "$name" != "$filter" ] && continue
		if [ -n "$bytes" ]; then size=$(_wsl_human "$bytes"); else size='-'; fi
		printf '%-24s %10s  %s\n' "$name" "$size" "$path"
	done < <(_wsl_lxss)
}

# only the vhdx paths, for scripting / diskpart / backups
wsl-path() {
	local filter="${1:-}" name path bytes
	while IFS=$'\t' read -r name path bytes; do
		[ -n "$filter" ] && [ "$name" != "$filter" ] && continue
		printf '%s\n' "$path"
	done < <(_wsl_lxss)
}

# free / used space *inside* the distro's ext4 filesystem, i.e. what the vhdx
# really holds (compare with wsl-size: vhdx bytes >> used means "run wsl-compact")
# default distro: $WSL_DISTRO_NAME when running inside WSL, else WSL's default
# MSYS_NO_PATHCONV stops git bash from rewriting "/" into "C:/Program Files/Git/"
wsl-df() {
	local distro="${1:-${WSL_DISTRO_NAME:-}}"
	if [ -n "$distro" ]; then
		MSYS_NO_PATHCONV=1 WSL_UTF8=1 wsl.exe -d "$distro" -- df -h /
	else
		MSYS_NO_PATHCONV=1 WSL_UTF8=1 wsl.exe -- df -h /
	fi
}

# shrink the vhdx on disk (WSL 2.2+: sparse mode, else diskpart, needs admin)
wsl-compact() {
	if [ $# -lt 1 ]; then
		echo "usage: wsl-compact <distro>" >&2
		return 1
	fi

	local distro="$1" vhd tmp script
	vhd=$(wsl-path "$distro")
	[ -n "$vhd" ] || {
		echo "unknown distro: $distro" >&2
		return 1
	}

	wsl.exe --shutdown

	if wsl.exe --manage "$distro" --set-sparse true; then
		echo "sparse mode enabled; trimming happens in the background"
		return 0
	fi

	echo "falling back to offline compact via diskpart (needs an elevated shell)" >&2
	tmp=$(mktemp)
	{
		printf 'select vdisk file="%s"\n' "$vhd"
		printf 'attach vdisk readonly\ncompact vdisk\ndetach vdisk\nexit\n'
	} >"$tmp"
	if command -v cygpath &>/dev/null; then script=$(cygpath -w "$tmp"); else script=$tmp; fi
	MSYS_NO_PATHCONV=1 diskpart /s "$script"
	rm -f "$tmp"
}

# grow the vhdx and the ext4 filesystem in one step: wsl-resize <distro> 2TB
wsl-resize() {
	if [ $# -lt 2 ]; then
		echo "usage: wsl-resize <distro> <size>" >&2
		return 1
	fi

	wsl.exe --shutdown
	wsl.exe --manage "$1" --resize "$2"
}
