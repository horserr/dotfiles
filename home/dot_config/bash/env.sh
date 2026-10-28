export EDITOR="vim"
export DOTFILES="$HOME/.config/.dotfiles"
export TOKEN_FILE="$HOME/.config/bash/tokenenv.sh"

if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

if [ -f "$HOME/.config/bash/tokenenv.sh" ]; then
    source "$HOME/.config/bash/tokenenv.sh"
fi

# add scripts dotfiles
if [ -d "$DOTFILES/scripts" ]; then
    export PATH="$DOTFILES/scripts:$PATH"
    if [ -d "$DOTFILES/scripts/install" ]; then
        export PATH="$DOTFILES/scripts/install:$PATH"
    fi
fi

# export RUSTUP_DIST_SERVER="https://rsproxy.cn"
# export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# pixi global binary
if [ -d "$HOME/.pixi/bin" ]; then
    export PATH="$HOME/.pixi/bin:$PATH"
fi

# pnpm global binary
if [ -d "$HOME/.local/share/pnpm/bin" ]; then
    export PATH="$HOME/.local/share/pnpm/bin:$PATH"
fi
