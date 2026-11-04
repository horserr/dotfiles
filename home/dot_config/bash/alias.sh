# tip: use `alias` command to print all aliases
# fix user group mismatch when returning from a rooted container
alias reload="source ~/.bashrc"
alias remap-user="sudo chown -R $(id -u):$(id -g) ."
alias edit-token="$EDITOR $TOKEN_FILE"
alias cd-dotfiles="cd $DOTFILES"

# view
alias v='less -RFX'

# umask symbol
alias umasks='umask -S'

# view path
alias vpath='printf "%s\n" ${PATH//:/ } | v'
alias valias='alias | v'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias setproxy="export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 all_proxy=http://127.0.0.1:7890 ALL_PROXY=http://127.0.0.1:7890"
alias unsetproxy="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

if command -v "bat" &>/dev/null; then
	alias c='bat'
elif command -v "batcat" &>/dev/null; then
	alias c='batcat'
else
	alias c='cat'
fi

if command -v "tldr" &>/dev/null; then
	alias m='tldr'
fi

if command -v "eza" &>/dev/null; then
	# 基础替换（不带长列表，仅替换普通 ls）
	alias ls="eza --icons=always"

	# long list, group view
	alias ll="eza -lg --git --group-directories-first --icons=always"
	# list all
	alias la="eza -a --icons=always"
	# ultimate detailed view
	alias lla="eza -lag --git --group-directories-first --icons=always"

	# list tree
	alias lt="eza --tree --level=2 --icons=always"
else
	alias ls='ls --color=auto'
	alias ll='ls -alF'
	alias la='ls -A'
	alias l='ls -CF'
fi

# remove all files and folder under current folder
rm-() {
	# 如果没有输入路径，默认清空当前目录
	local target_dir="${1:-.}"

	# 检查目标是否确实是一个文件夹
	if [ ! -d "$target_dir" ]; then
		echo "Error: '$target_dir' is not a dir!" >&2
		return 1
	fi

	# 使用 find 命令安全地只删除内部内容，不会误伤当前目录
	echo "removing: $(realpath "$target_dir") "
	find "$target_dir" -mindepth 1 -delete
}

if command -v "curl" &>/dev/null; then
	alias connection="curl -I google.com"
	alias cipinfo="curl ipinfo.io"
	alias cifconfig="curl -4 ifconfig.me"
fi

if command -v "docker" &>/dev/null; then
	alias dockerp="docker run --rm -it --privildged -v /:/host"
fi

if command -v "git" &>/dev/null; then
	alias g='git'
fi

if command -v "btop" &>/dev/null; then
	alias top='btop'
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
	alias coder='code -r'
fi

if command -v "yazi" &>/dev/null; then
	function y() {
		local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
		command yazi "$@" --cwd-file="$tmp"
		IFS= read -r -d '' cwd <"$tmp"
		[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || exit
		rm -f -- "$tmp"
	}
fi

if command -v "chezmoi" &>/dev/null; then
	alias ch="chezmoi"
	alias chcd="chezmoi cd"
	alias cha="chezmoi apply"
	alias chc="chezmoi cat"
	alias che="chezmoi edit"
	alias chs="chezmoi status"

	# link: https://www.chezmoi.io/reference/commands/diff/
	alias chdiff="chezmoi diff"

	alias chx="chezmoi execute-template -f"
	alias chup="chezmoi update"

	# link: https://www.chezmoi.io/reference/commands/dump/
	# display file permission
	alias chdump="chezmoi dump"
	alias chreset="chezmoi git fetch && chezmoi git -- reset --hard /origin/main"

	# link: https://www.chezmoi.io/reference/commands/merge/
	alias chmerge="chezmoi merge"
	alias chverify="chezmoi verify"

	# normalize a path: forward slashes, no duplicate/trailing separator
	_chstat_norm() {
		local p=$1

		# ${p//模式/替换} 是 bash 的"全部替换"语法
		p=${p//\\//}

		while [[ $p == *//* ]]; do p=${p//\/\//\/}; done

		# 含义：从变量值的末尾，删除最短匹配「模式」的部分。
		# % → 从结尾删（记忆：键盘上 % 在 $ 左边，表示"后面/尾部"）
		# %% → 从结尾删，但匹配最长的
		# # → 从开头删最短
		# ## → 从开头删最长
		[[ $p == "/" ]] || p=${p%/}

		printf '%s' "$p"
	}

	# absolute path in a form chezmoi understands (C:/... on Windows, /... elsewhere)
	_chstat_abs() {
		local p=$1 tmp
		case $p in
		/* | [A-Za-z]:*)
			;;
		*)
			# relative path, prepend pwd
			p="$PWD/$p"
			;;
		esac

		# -m flag (missing) tells realpath to work even if the file or directory doesn't actually exist on the disk yet
		if tmp=$(realpath -m -- "$p" 2>/dev/null) && [ -n "$tmp" ]; then
			p=$tmp
		fi

		if command -v cygpath &>/dev/null; then
			if tmp=$(cygpath -m -- "$p" 2>/dev/null) && [ -n "$tmp" ]; then
				p=$tmp
			fi
		fi
		_chstat_norm "$p"
	}

	# lowercase
	# for windows and macos path compatibility
	_chstat_lc() {
		# Syntax	Operator	What it does	Example (var="Hello World")
		# ${var,,}	,,	Converts everything to lowercase	hello world
		# ${var,}	,	Converts only the first letter to lowercase	hello World
		# ${var^^}	^^	Converts everything to uppercase	HELLO WORLD
		# ${var^}	^	Converts only the first letter to uppercase	Hello World
		echo -n "${1,,}"

		# printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
	}

	# $1: absolute target path, stdin: output of `chezmoi ignored`
	# true if the target (or one of its parents) is ignored
	_chstat_match_ignored() {
		local target home rel ig
		home=$(_chstat_lc "$(_chstat_abs "$HOME")")
		target=$(_chstat_lc "$(_chstat_abs "$1")")
		case $target in
		"$home") rel=. ;;
		"$home"/*) rel=${target#"$home"/} ;;
		*) return 1 ;;
		esac
		while IFS= read -r ig; do
			[ -z "$ig" ] && continue
			ig=$(_chstat_lc "$(_chstat_norm "$ig")")
			if [ "$rel" = "$ig" ] || [[ $rel == "$ig"/* ]]; then
				return 0
			fi
		done
		return 1
	}

	# octal permission of the target state
	# `chezmoi dump` reports the raw mode: dir 0777, file 0666, private_ 0600
	_chstat_perm() {
		local out dec
		out=$(chezmoi dump --format=json -- "$1" 2>/dev/null) || return 1
		dec=$(printf '%s\n' "$out" | sed -n 's/.*"perm": *\([0-9][0-9]*\).*/\1/p' | head -n 1)
		[ -n "$dec" ] || return 1
		printf '%04o' "$dec"
	}

	# show the chezmoi source/target mapping of a file
	#   chstat [path]      # default: current directory
	#   source file  -> target path + target-state permission (or "ignore")
	#   target file  -> source path (or "ignore")
	chstat() {
		local path=${1:-.} abs srcdir home ignored ign_rc rc tgt perm out
		local lc_abs lc_src lc_home

		abs=$(_chstat_abs "$path")
		srcdir=$(_chstat_abs "$(chezmoi source-path 2>/dev/null)")
		home=$(_chstat_abs "$HOME")
		lc_abs=$(_chstat_lc "$abs")
		lc_src=$(_chstat_lc "$srcdir")
		lc_home=$(_chstat_lc "$home")

		ignored=$(chezmoi ignored 2>/dev/null)
		ign_rc=$?

		# file lives in the source dir -> show its target
		if [ "$lc_abs" = "$lc_src" ] || [[ $lc_abs == "$lc_src"/* ]]; then
			tgt=$(_chstat_norm "$(chezmoi target-path -- "$abs" 2>/dev/null)")
			printf '%-7s %s\n' source "$abs"
			if [ -z "$tgt" ]; then
				printf '%-7s %s\n' target 'unknown (not in source state)'
				return 1
			fi
			if [ "$ign_rc" -eq 0 ] && printf '%s\n' "$ignored" | _chstat_match_ignored "$tgt"; then
				printf '%-7s %s\n' target ignore
				return 0
			fi
			printf '%-7s %s\n' target "$tgt"
			if perm=$(_chstat_perm "$tgt"); then
				printf '%-7s %s\n' perm "$perm"
			else
				printf '%-7s %s\n' perm 'unknown (not in target state)'
			fi
			return 0
		fi

		# file lives in the destination dir -> show its source
		if [ "$lc_abs" = "$lc_home" ] || [[ $lc_abs == "$lc_home"/* ]]; then
			printf '%-7s %s\n' target "$abs"
			out=$(chezmoi source-path -- "$abs" 2>&1)
			rc=$?
			if [ "$rc" -eq 0 ]; then
				printf '%-7s %s\n' source "$(_chstat_norm "$out")"
			elif [ "$ign_rc" -eq 0 ] && printf '%s\n' "$ignored" | _chstat_match_ignored "$abs"; then
				printf '%-7s %s\n' source ignore
			elif [[ $out == *'not managed'* ]]; then
				printf '%-7s %s\n' source 'not managed by chezmoi'
			else
				printf '%-7s %s\n' source "unknown (${out#chezmoi: })"
			fi
			return 0
		fi

		printf 'chstat: %s is not under %s or %s\n' "$abs" "$srcdir" "$home" >&2
		return 1
	}
fi

if command -v "tmux" &>/dev/null; then
	alias t="tmux new-session"
	alias tt="tmux new-session -s"
	alias ta="tmux attach"
	alias tls="tmux list-sessions"
	alias tk="tmux kill-session -t"
	alias tkill="tmux kill-server"
	alias tmv="tmux move-window -s -t"
	alias tlsk="tmux list-keys -N"
fi
