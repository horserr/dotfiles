#!/bin/bash
set -e

apt update

sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --source=~/.config/.dotfiles --apply horserr
