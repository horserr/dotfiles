#!/bin/bash
set -e

# installation script reference: https://www.chezmoi.io/install/#one-line-binary-install

sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b $HOME/.local/bin

chezmoi init --source=~/.config/.dotfiles --apply $GITHUB_USERNAME
