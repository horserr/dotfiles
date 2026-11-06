# Aliases only, grouped by topic.
# Functions live in functions.sh; chezmoi helpers in chezmoi.sh.
# tip: use the `alias` command to print all aliases.

# --- shell ------------------------------------------------------------------
alias reload="source ~/.bashrc"
# fix user group mismatch when returning from a rooted container
alias remap-user='sudo chown -R $(id -u):$(id -g) .'
alias edit-token='$EDITOR $TOKEN_FILE'
alias cd-dotfiles='cd $DOTFILES'

# --- viewing ----------------------------------------------------------------
alias v='less -RFX'
alias umasks='umask -S'
alias vpath='printf "%s\n" ${PATH//:/ } | v'
alias valias='alias | v'

# Add an "alert" alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# --- editor / pager ---------------------------------------------------------
command -v "vim" &>/dev/null && alias vi='vim'

if command -v "bat" &>/dev/null; then
	alias c='bat'
elif command -v "batcat" &>/dev/null; then
	alias c='batcat'
else
	alias c='cat'
fi

command -v "tldr" &>/dev/null && alias m='tldr'

# --- proxy ------------------------------------------------------------------
alias setproxy="export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 all_proxy=http://127.0.0.1:7890 ALL_PROXY=http://127.0.0.1:7890"
alias unsetproxy="unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY"

# --- listing ----------------------------------------------------------------
# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

if command -v "eza" &>/dev/null; then
	# basic replacement
	alias ls="eza --icons=always"
	# long list, group view
	alias ll="eza -lg --git --group-directories-first --icons=always"
	# list all
	alias la="eza -a --icons=always"
	# ultimate detailed view
	alias lla="eza -lag --git --group-directories-first --icons=always"
	# tree view
	alias lt="eza --tree --level=2 --icons=always"
else
	alias ls='ls --color=auto'
	alias ll='ls -alF'
	alias la='ls -A'
	alias l='ls -CF'
fi

# --- network ----------------------------------------------------------------
if command -v "curl" &>/dev/null; then
	alias connection="curl -I google.com"
	alias cipinfo="curl ipinfo.io"
	alias cifconfig="curl -4 ifconfig.me"
fi

# --- tools ------------------------------------------------------------------
if command -v "git" &>/dev/null; then
	alias g='git'
fi

if command -v "docker" &>/dev/null; then
	alias dockerp="docker run --rm -it --privileged -v /:/host"
fi

if command -v "btop" &>/dev/null; then
	alias top='btop'
fi

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
	alias coder='code -r'
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
