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
> Add `--data isPersonal=true` to skip interaction.

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

## compress docker date vhdx

```pwsh
Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\DockerDesktopWSL\disk\docker_data.vhdx" -Mode Full
```

## crlf to lf EOL encoding

```sh
sudo find . -type f -not -path '*/.git/*' -exec dos2unix {} \;
```

## use URLProtocol.exe to create url protocol for cat catch

- [link](https://o2bmm.gitbook.io/cat-catch/docs/m3u8dl)
- protocol name: m3u8dl
