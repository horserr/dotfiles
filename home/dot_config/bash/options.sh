# Shell behavior: umask, bash options, history.
# Readline settings (editing mode, completion-ignore-case, ...) belong in ~/.inputrc.

# ultimate private
# umask 077
umask 027

# set -e          # exit on any failed command
# set -u          # error on undefined variables
set -o pipefail # a pipeline fails if any of its commands fails

# append to the history file, don't overwrite it
shopt -s histappend

# "**" in a pathname expansion matches all files and zero or more directories
shopt -s globstar

# check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# don't put duplicate lines or lines starting with space in the history
# 忽略重复命令和以空格开头的命令
HISTCONTROL=ignoreboth:erasedups

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# 关闭终端软件流控，释放 Ctrl+s / Ctrl+q
[[ -t 0 ]] && stty -ixon

# 历史展开后先显示命令，而不是直接执行
shopt -s histverify

# 多行命令历史记录
shopt -s cmdhist
shopt -s lithist
