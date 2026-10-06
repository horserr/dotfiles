if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# export RUSTUP_DIST_SERVER="https://rsproxy.cn"
# export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "$HOME/.pixi/bin" ]; then
    export PATH="$HOME/.pixi/bin:$PATH"
fi
