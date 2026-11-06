# PATH management.
# Entries are added only when the directory exists and is not already on PATH.

_path_has() {
	case ":$PATH:" in
	*":$1:"*) return 0 ;;
	*) return 1 ;;
	esac
}

_path_prepend() {
	[ -d "$1" ] || return 0
	_path_has "$1" || PATH="$1:$PATH"
}

_path_append() {
	[ -d "$1" ] || return 0
	_path_has "$1" || PATH="$PATH:$1"
}

# scripts shipped with the dotfiles (install helpers take priority)
_path_prepend "$DOTFILES/scripts"
_path_prepend "$DOTFILES/scripts/install"

_path_append "$HOME/.local/bin"

# pixi global binaries
_path_prepend "$HOME/.pixi/bin"

# pnpm global binaries
if command -v "pnpm" &>/dev/null; then
	_path_prepend "$HOME/.local/share/pnpm/bin"
fi

export PATH

unset -f _path_has _path_prepend _path_append
