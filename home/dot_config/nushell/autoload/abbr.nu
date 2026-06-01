if $nu.is-interactive {
  if not (which tmux | is-empty ) {
    alias t = tmux new-session
    alias tt = tmux new-session -s
    alias ta = tmux attach
    alias tls = tmux list-sessions
    alias tk = tmux kill-session -t
    alias tkill = tmux kill-server
    alias tmv = tmux move-window -s -t
    alias tlsk = tmux list-keys -N
  }
}
