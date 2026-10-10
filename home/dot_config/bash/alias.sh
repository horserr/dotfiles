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

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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


alias setproxy="export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890"
alias unsetproxy="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY"

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

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    alias coder='code -r'
fi

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
