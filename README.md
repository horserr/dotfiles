# Horserr's dotfiles config

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

## Initiation

set up in container

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --one-shot horserr/dotfiles-linux
```

## change apt source

### Ubuntu 24 之前的方式，直接修改 `/etc/apt/source.list`

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo vim /etc/apt/sources.list
```
