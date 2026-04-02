# Horserr's dotfiles config on Windows

[Chezmoi Home Page](https://www.chezmoi.io/)

This repo is adapted from: [twpayne's dotfiles](https://github.com/twpayne/dotfiles)

## set WSL network mode to `mirrored`

link: https://learn.microsoft.com/en-us/windows/wsl/networking#mirrored-mode-networking

powershell admin:

```pwsh
Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow
```

## VSpaceCode

those settings is largely adapted from https://gist.github.com/macintacos/d63b7057cee0638e7ccfcdd6d1b7f662

### error: CreateInstance/CreateVm/ConfigureNetworking/0x8007054f

solution:[link](https://github.com/microsoft/WSL/issues/12351#issuecomment-3938183381)

powershell admin

```pwsh
wsl --shutdown
# wait for at least 8 seconds

# restart HNS services
net stop hns
net start hns

# reset WSL network configurations
netsh winsock reset
netsh int ip reset

# restart Windows machine, and set WSL network to ``mirrored'' mode.
# can use ip route show to check whether being successful.
```

## chezmoi usage

- 查看可用数据：chezmoi data
- 测试模板渲染：chezmoi execute-template < 文件名.tmpl
- 查看差异：chezmoi diff

## git

`git checkout --orphan main`

`git update-index --chmod=+x <file>`
如果你想看看当前 Git 记录里，哪些文件是可执行的，可以运行：

```sh
git ls-files --stage
```

to fix end of line encoding

```sh
git add --renormalize .
```

to update staged files

```sh
git add -u
```

to remove file from history
```sh
uvx git-filter-repo --path <file path> --invert-paths
```

在输出列表中，权限位以 100755 开头的文件就是 Git 认为的可执行文件。

## MAC OS sound resource

dowload: [textClassic Mac OS Sounds](https://alxwntr.com/classic-mac-os-sounds/#)