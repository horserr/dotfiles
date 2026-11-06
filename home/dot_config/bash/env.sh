# Environment variables shared by every interactive shell.
# PATH is managed separately in path.sh.

export EDITOR="vim"
export DOTFILES="$HOME/.config/.dotfiles"
export TOKEN_FILE="$HOME/.config/bash/tokenenv.sh"

# uv
if [ -f "$HOME/.local/bin/env" ]; then
	. "$HOME/.local/bin/env"
fi

# secrets written by `scripts/ds`
if [ -f "$TOKEN_FILE" ]; then
	source "$TOKEN_FILE"
fi

# export RUSTUP_DIST_SERVER="https://rsproxy.cn"
# export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

# set man pager
if command -v "bat" &>/dev/null; then
	export MANPAGER="bat --language=man --style=plain --paging=never --strip-ansi=always"
elif command -v "batcat" &>/dev/null; then
	export MANPAGER="batcat --language=man --style=plain --paging=never --strip-ansi=always"
fi
