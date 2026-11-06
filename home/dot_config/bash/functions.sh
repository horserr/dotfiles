# General-purpose shell functions.
# Tool-specific helpers live next to their tool (chezmoi.sh, windows/ssh.sh, ...).

# remove all files and folders under a directory (default: current directory)
rm-() {
	local target_dir="${1:-.}"

	if [ ! -d "$target_dir" ]; then
		echo "Error: '$target_dir' is not a dir!" >&2
		return 1
	fi

	# delete the contents only, never the directory itself
	echo "removing: $(realpath "$target_dir") "
	find "$target_dir" -mindepth 1 -delete
}

# yazi: quit and cd to the directory yazi was browsing
if command -v "yazi" &>/dev/null; then
	y() {
		local tmp cwd
		tmp=$(mktemp -t "yazi-cwd.XXXXXX") || return 1
		command yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd <"$tmp"
		rm -f -- "$tmp"

		if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ]; then
			builtin cd -- "$cwd" || return 1
		fi
	}
fi
