# Shell completion. Loaded after PATH so `command -v` sees installed tools.

# system bash-completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# git completion: path varies with the Git distribution (mingw64 / ucrt64 / usr)
if command -v "git" &>/dev/null; then
	for _git_completion in \
		"$(dirname "$(git --exec-path)")/../share/git/completion/git-completion.bash" \
		/mingw64/share/git/completion/git-completion.bash \
		/usr/share/git/completion/git-completion.bash \
		/c/Program\ Files/Git/ucrt64/share/git/completion/git-completion.bash; do
		if [ -f "$_git_completion" ]; then
			. "$_git_completion"
			break
		fi
	done
	unset _git_completion
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if command -v "carapace" &>/dev/null; then
	# link: https://carapace-sh.github.io/carapace-bin/setup.html#bash
	export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
	source <(carapace _carapace)
fi

# pixi completions
if [ -d "$HOME/.pixi/completions/bash" ]; then
	for _pixi_completion in "$HOME"/.pixi/completions/bash/*; do
		[ -e "$_pixi_completion" ] && source "$_pixi_completion"
	done
	unset _pixi_completion
fi

# custom completions in ~/completions, only for commands that are installed
if [ -d "$HOME/completions" ]; then
	for _completion_file in "$HOME"/completions/*.bash; do
		[ -f "$_completion_file" ] || continue
		_completion_cmd=$(basename "$_completion_file" .bash)
		if command -v "$_completion_cmd" &>/dev/null; then
			source "$_completion_file"
		fi
	done
	unset _completion_file _completion_cmd
fi

# vscode shell integration
if [ "$TERM_PROGRAM" = "vscode" ] && command -v "code" &>/dev/null; then
	. "$(code --locate-shell-integration-path bash)"
fi
