# Horserr's dotfiles config

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

## Initiation

There are two ways to initialize:

1. ```sh
   sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --source=~/.config/.dotfiles --apply $GITHUB_USERNAME
   ```
2. ```sh
    dotfile_path="~/.config/.dotfiles"
    git clone $THIS_REPO $dotfile_path
    $dotfile_path/install.sh
   ```

> [!NOTE]
> Inside container or other ephemeral environment
> Add `--one-shot` to remove cloned repo and chezmoi itself without leaving trace.

### install scoop on Windows

in powershell:

```pwsh
irm get.scoop.sh | iex
```

after installing

- add github token

  ```pwsh
  scoop config gh_token ghp_...
  ```

- add extras bucket
  ```pwsh
  scoop bucket add extras
  ```

## change apt source

### Ubuntu 24 之前的方式，直接修改 `/etc/apt/source.list`

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo vim /etc/apt/sources.list
```

## use URLProtocol.exe to create url protocol for cat catch

- [link](https://o2bmm.gitbook.io/cat-catch/docs/m3u8dl)
- protocol name: m3u8dl
