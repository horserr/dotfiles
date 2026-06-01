if $nu.is-interactive {
  alias reload = exec nu
  alias g = git

  if (which eza | is-empty ) {
    alias ll = ls -l
  } else {
    alias ll = eza -l --icons --git
    alias lt = eza --tree --level=2 --icons
  }
}

