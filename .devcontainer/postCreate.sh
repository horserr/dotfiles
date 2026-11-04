#!/bin/bash
set -euo pipefail

# chezmoi downloads externals (e.g. .vim/autoload/plug.vim) through its cache dir, so
# ~/.cache must be writable by the current user. It is not when a previous image/volume
# created it as root, which surfaces as:
#   chezmoi: .vim/autoload/plug.vim: mkdir /home/vscode/.cache/chezmoi: permission denied
# Fixing the owner is idempotent, so it is safe to run on every creation.
chown -f "$(id -u):$(id -g)" "$HOME/.cache" "$HOME/.cache/rattler" 2>/dev/null ||
  sudo -n chown "$(id -u):$(id -g)" "$HOME/.cache" "$HOME/.cache/rattler" 2>/dev/null || true

# installation script reference: https://www.chezmoi.io/install/#one-line-binary-install

sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME"/.local/bin

# --one-shot is the equivalent of --apply, --depth=1, --force, --purge, and --purge-binary. It attempts to install your dotfiles with chezmoi and then remove all traces of chezmoi from the system. This is useful for setting up temporary environments (e.g. Docker containers).
chezmoi init --source=~/.config/.dotfiles --depth 1 --apply "$GITHUB_USERNAME"
