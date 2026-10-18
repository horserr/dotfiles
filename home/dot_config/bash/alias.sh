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

if command -v "bat" &> /dev/null; then
    alias c='bat'
elif command -v "batcat" &> /dev/null; then
    alias c='batcat'
else
    alias c='cat'
fi

if command -v "tldr" &> /dev/null; then
    alias m='tldr'
fi

if command -v "eza" &> /dev/null; then
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

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias setproxy="P=http://127.0.0.1:7897; export http_proxy=$P https_proxy=$p HTTP_PROXY=$p HTTPS_PROXY=$p all_proxy=$p ALL_PROXY=$p"
alias unsetproxy="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY"

if command -v "curl" &> /dev/null; then
    alias connection="curl -I google.com"
    alias cipinfo="curl ipinfo.io"
    alias cifconfig="curl -4 ifconfig.me"
fi

if command -v "docker" &> /dev/null; then
    alias dockerp="docker run --rm -it --privildged -v /:/host"
fi

if command -v "git" &> /dev/null; then
    alias g='git'
fi

if command -v "btop" &> /dev/null; then
    alias top='btop'
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    alias coder='code -r'
fi

if command -v "yazi" &> /dev/null; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
    }
fi

if command -v "tmux" &> /dev/null; then
    alias t="tmux new-session"
    alias tt="tmux new-session -s"
    alias ta="tmux attach"
    alias tls="tmux list-sessions"
    alias tk="tmux kill-session -t"
    alias tkill="tmux kill-server"
    alias tmv="tmux move-window -s -t"
    alias tlsk="tmux list-keys -N"
fi
