# Horserr's dotfiles config

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

> [!CAUTION]
>
> only tested on Windows and Ubuntu24.04 LTS

## Initiation

`git` should be installed

1. create local share folder if needed

   ```sh
   mkdir -p ~/.local/share
   cd ~/.local/share
   ```

2. clone the repo

   ```sh
   git clone --depth 1 https://github.com/horserr/dotfiles.git chezmoi
   cd ./chezmoi/start
   ```

3. use scripts to install apps
   - on linux:

     ```bash
     ./main.sh
     ```

   - on windows:

     todo add set-executionpolicy

     ```pwsh
     ./main.ps1
     ```

4. reopen terminal

5. (recommend) to use `neovim`, install `treesitter` beforehand

   ```sh
   sudo apt update
   sudo apt install llvm-dev libclang-dev clang
   cargo install tree-sitter-cli
   ```
   reopen the terminal and then enter `nvim`

6. (recommend) install `nodejs` with `nvm`

   ```sh
   nvm install --lts
   ```

7. (recommend) install `fzf-fish` for fish shell

   ```bash
   # ensure_installed 'fisher' "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
   fisher install PatrickF1/fzf.fish
   ```

## (note) change apt source

### Ubuntu 24 之前的方式，直接修改 `/etc/apt/source.list`

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo vim /etc/apt/sources.list
```

替换全部内容

```
# 阿里云源（推荐国内用户）
deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
```

```bash
sudo apt update
```

### Ubuntu 24.04 LTS 之后的方式

```bash
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
sudo vim /etc/apt/sources.list.d/ubuntu.sources
```

将文件中所有 URLs替换为其中一个镜像源（包括 security 部分）
镜像站名称 URIs 地址
| 名称 | 源 |
| :------- | :------------------------------------------- |
| 南京大学 | https://mirrors.nju.edu.cn/ubuntu/ |
| 清华大学 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ |
| 阿里云 | https://mirrors.aliyun.com/ubuntu/ |
| 腾讯云 | https://mirrors.cloud.tencent.com/ubuntu/ |
| 华为云 | https://mirrors.huaweicloud.com/ubuntu/ |

```bash
sudo apt update
```

## chezmoi usage

- 查看可用数据：chezmoi data
- 测试模板渲染：chezmoi execute-template < 文件名.tmpl
- 查看差异：chezmoi diff

## git

`git checkout --orphan main`

`git update-index --chmod=+x <file>`
如果你想看看当前 Git 记录里，哪些文件是可执行的，可以运行：

```bash
git ls-files --stage
```

在输出列表中，权限位以 100755 开头的文件就是 Git 认为的可执行文件。
