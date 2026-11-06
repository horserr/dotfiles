# Horserr's dotfiles config

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

## Install on the local machine

### 1. Installer one-liner (chezmoi + init + apply)

```sh
mkdir -p ~/.local/bin
cd ~/.local/bin

sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --source=~/.config/.dotfiles --apply horserr

cd -
```

### 2. Native command

```sh
bash <(curl -sL "https://raw.githubusercontent.com/horserr/dotfiles/refs/heads/main/scripts/install/l-chezmoi.sh")
```

### 3. Manual clone + install script

```sh
dotfiles_dir="$HOME/.config/.dotfiles"
git clone https://github.com/horserr/dotfiles "$dotfiles_dir"
"$dotfiles_dir/scripts/install/l-chezmoi.sh"
```

> [!NOTE]
> Inside a container or another ephemeral environment:
>
> - add `--one-shot` to remove the cloned repo and chezmoi itself without leaving a trace;
> - add `--data isPersonal=true` to skip the interactive prompts.

## Install on a remote Linux host

`scripts/install/remote.sh` installs a single-file `chezmoi` binary on a remote machine that may
have no `curl` / `wget` / `git`, then initializes and applies this repo.

How it works:

1. probe the remote once (`uname -m` plus `ldd` / `getconf` / `/etc/os-release` / `ld-musl*`) and pick
   the matching release asset (glibc vs musl, `amd64` / `arm64` / `armv6` / `i386` / `loong64` / ...);
2. download the tarball, verify its SHA-256 and unpack `chezmoi` **locally**;
3. stream the binary over `ssh` into `~/.local/bin/chezmoi`, `chmod 755` and check `--version`;
4. run `chezmoi init --apply` — or `chezmoi apply` when the remote is already initialized.

```sh
# 1. SSH config alias (port / key / jump host all handled by ssh)
./scripts/install/remote.sh myserver

# 2. explicit user + version
./scripts/install/remote.sh myserver deploy 2.74.0

# 3. user@host or bare IP
./scripts/install/remote.sh root@192.168.1.10
./scripts/install/remote.sh 192.168.1.10 root

# 4. install the binary only, skip init/apply
./scripts/install/remote.sh --no-apply myserver

# 5. verify
ssh myserver '~/.local/bin/chezmoi --version'
```

| Variable         | Default                               | Description                                                               |
| ---------------- | ------------------------------------- | ------------------------------------------------------------------------- |
| `REMOTE_BIN_DIR` | `.local/bin`                          | install directory, relative to the remote `$HOME`                         |
| `CHEZMOI_REPO`   | `https://github.com/horserr/dotfiles` | repo used by `chezmoi init --apply`                                       |
| `CHEZMOI_ARGS`   | _(empty)_                             | extra arguments for `init` / `apply`, e.g. `--dry-run`                    |
| `SSH_OPTS`       | _(empty)_                             | extra `ssh` flags, e.g. `-o ControlMaster=auto -o ControlPath=/tmp/cm-%C` |

> [!NOTE]
> The whole run makes **3 ssh connections** (probe / upload / init+apply), so a password is asked
> at most 3 times; `--no-apply` cuts that to 2. Use `ssh-copy-id <host>` (or enable connection
> reuse through `SSH_OPTS`) for a password-free run.
>
> On Windows, run it as `bash scripts/install/remote.sh ...` (or `chmod +x` first) if you hit
> `Permission denied`.

## Windows

### Install scoop

In PowerShell:

```pwsh
irm get.scoop.sh | iex
```

After installing:

- add the GitHub token

  ```pwsh
  scoop config gh_token ghp_...
  ```

- add the extras bucket

  ```pwsh
  scoop bucket add extras
  ```

### Compress the Docker data vhdx

```pwsh
Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\DockerDesktopWSL\disk\docker_data.vhdx" -Mode Full
```

## Tips

### Convert CRLF to LF

Either with git or with dos2unix.

```sh
# first commit .gitattributes
git add .
git commit

git rm --cached -r .
git reset --hard
```

```sh
sudo find . -type f -not -path '*/.git/*' -exec dos2unix {} \;
```

### Create a URL protocol with URLProtocol.exe (cat-catch)

- [Guide](https://o2bmm.gitbook.io/cat-catch/docs/m3u8dl)
- protocol name: `m3u8dl`

### Test git commit signing

```sh
git log --show-signature -1
```
