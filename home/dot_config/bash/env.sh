export DOTFILES="$HOME/.config/.dotfiles"

if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

if [ -f "$HOME/.config/bash/tokenenv.sh" ]; then
    source "$HOME/.config/bash/tokenenv.sh"
fi

if [ -d "$DOTFILES/scripts/install" ]; then
    export PATH="$DOTFILES/scripts/install:$PATH"
fi

# export RUSTUP_DIST_SERVER="https://rsproxy.cn"
# export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "$HOME/.pixi/bin" ]; then
    export PATH="$HOME/.pixi/bin:$PATH"
fi
