if command -v "carapace" &> /dev/null; then
    # link: https://carapace-sh.github.io/carapace-bin/setup.html#bash
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
    source <(carapace _carapace)
fi

if [ -d ~/completions ]; then
  for file in ~/completions/*.bash; do
    if [ -f "$file" ]; then
      # extract cmd name
      cmd=$(basename "$file" .bash)

      if command -v "$cmd" &> /dev/null; then
        source "$file"
      fi
    fi
  done
fi

# vscode shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"
