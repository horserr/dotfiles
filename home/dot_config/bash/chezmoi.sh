# chezmoi aliases and helpers.

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
