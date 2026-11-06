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
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000
