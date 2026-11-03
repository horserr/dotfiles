#!/bin/bash
# Runs on every container start (as the remote user).
#
# Why this exists:
#   * Docker creates the missing parent directories of a mount target as root, and a
#     named volume freezes the ownership it was first created with — so ~/.cache can
#     end up root-owned even though the Containerfile created it for vscode.
#   * updateRemoteUserUID remaps the container user at *start* time, so ownership
#     baked into the image at build time (UID 1000) no longer matches the runtime UID.
#   * chezmoi downloads externals (e.g. .vim/autoload/plug.vim) via
#     `mkdir ~/.cache/chezmoi`, so a non-writable ~/.cache breaks `chezmoi init/apply`
#     with "mkdir /home/vscode/.cache/chezmoi: permission denied".
#
# Only the directory itself is re-chowned (not -R): it is enough for creating new
# entries and keeps startup fast. Drop the pixi-cache volume to also reset its
# contents: `docker volume rm pixi-cache`.
set -uo pipefail

fix_owner() {
  local dir="$1"
  [ -e "$dir" ] || return 0
  [ "$(stat -c %u "$dir")" = "$(id -u)" ] && return 0
  sudo chown "$(id -u):$(id -g)" "$dir" ||
    echo "warning: could not chown $dir" >&2
}

fix_owner "$HOME/.cache"
fix_owner "$HOME/.cache/rattler" # named volume mount point (pixi/rattler cache)

service ssh start
