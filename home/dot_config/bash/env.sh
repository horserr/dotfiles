# Environment variables shared by every interactive shell.
# PATH is managed separately in path.sh.

# 快速启动纯净版 nvim 编辑命令（保留基础高亮和语法）
if command -v nvim >/dev/null 2>&1; then
	export FCEDIT="nvim -u NORC"
elif command -v vim >/dev/null 2>&1; then
	export FCEDIT="vim -u NORC"
else
	export FCEDIT="nano"
fi

export EDITOR=$(command -v nvim || command -v vim || echo "nano")
export VISUAL=$EDITOR
# if [ "$TERM_PROGRAM" = "vscode" ] && command -v "code" &>/dev/null; then
# 	export VISUAL="code --wait"
# fi

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
