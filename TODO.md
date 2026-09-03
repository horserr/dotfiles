# TODO

chezmoi age add ssh key settings

remote explorer

rebuild wsl and config ssh
ssh -G to print out everything for the config
`ssh -G work`

use chezmoi to manage ssh public and private key

try using vscode ssh forwarding without explicitly setting ssh agent forwarding
try to use reverse tunnel to push git repo

try linux gui x forwarding on windows

ssh keygen
ssh-keygen -R hostname

ssh add

那怎么通过 ssh 在远程电脑上推送代码到托管平台上，我知道可以通过 agent forward 来实现

```ini
Host my-remote-server
    HostName 192.168.1.50
    User ubuntu
    # Forward remote port 2222 to GitHub's SSH port 22 via your laptop
    RemoteForward 2222 github.com:22
```

```console
# 1. SSH into your server
ssh my-remote-server

# 2. Go to your project folder
cd /path/to/remote/repo

# 3. Change the git remote URL to point to the forwarded port
git remote set-url origin ssh://git@127.0.0.1:2222/username/repo.git

# 4. Push your code safely
git push origin main
```

windows start ssh agent service

sudo systemctl status ssh or sudo systemctl status sshd

```pwsh
# 1. 将 ssh-agent 服务设置为自动启动
Set-Service -Name ssh-agent -StartupType Automatic

# 2. 立即启动该服务
Start-Service ssh-agent
```

// note: sshd should allow AllowStreamLocalForwarding

ssh settings and sftp, sshfs

fix ssh key error and ssh file permission
try nix and devbox

了解 ssh server configuration

use cloud init to create wsl profile

remote explorer view commands
github codespace
ssh wsl tunnel commands and settings

where is sumatrapdf?

add bookmark extensions

add setting sync and cloud change

fzf, yazi

vscode debug

ports
add clash verge configuration
如何区分vscode 创建的 dev container 名称

learn bash

- how to organize bashrc
  devcontainer to test chezmoi in docker

- fzf menu completion
- chat commands

- find all reference view, rename symbol
- custom ui with css and js
- script cat to create scripts for open vscode dev or vscode clone from source graph web

- add chrome, edge browser policy
- [vscode cli](https://code.visualstudio.com/docs/configure/command-line)
- [windows virtual desktop](https://github.com/FuPeiJiang/VD.ahk)

remote explorer
github actions automatically add star for better search.

learn jq to sort and extract json file

配置latex wsl 搭建
通过 yazi 来管理文件
之后删除 wsl。再尝试安装并使用 latex
使用 git submodule 添加 uia 和 vd 库
了解：https://github.com/GorvGoyl/Autohotkey-Scripts-Windows，尝试添加几个
了解 GitHub actions 和 codespace，尝试创建 my awesome list

servy to manage services

ssh reverse tunnel
ZMODEM (sz 命令） 回传

移除recent items "C:\Users\ASUSCosmos\AppData\Roaming\Microsoft\Windows\Recent"

theme folder
C:\Users\ASUSCosmos\AppData\Roaming\Microsoft\Windows\Themes

word templates
C:\Users\ASUSCosmos\AppData\Roaming\Microsoft\Templates

```js
(function () {
  // Wait for the Webview DOM to load completely
  window.addEventListener("DOMContentLoaded", () => {
    window.addEventListener(
      "keydown",
      (event) => {
        // Ignore shortcuts if the user is typing in an input box inside the webview
        if (
          event.target.tagName === "INPUT" ||
          event.target.tagName === "TEXTAREA" ||
          event.target.isContentEditable
        ) {
          return;
        }

        const scrollStep = 50; // Pixels to scroll

        switch (event.key.toLowerCase()) {
          case "j":
            window.scrollBy({ top: scrollStep, behavior: "auto" });
            event.preventDefault();
            break;
          case "k":
            window.scrollBy({ top: -scrollStep, behavior: "auto" });
            event.preventDefault();
            break;
          case "h":
            window.scrollBy({ left: -scrollStep, behavior: "auto" });
            event.preventDefault();
            break;
          case "l":
            window.scrollBy({ left: scrollStep, behavior: "auto" });
            event.preventDefault();
            break;
          case "d":
            window.scrollBy({
              top: window.innerHeight * 0.5,
              behavior: "auto",
            });
            event.preventDefault();
            break;
          case "u":
            window.scrollBy({
              top: -window.innerHeight * 0.5,
              behavior: "auto",
            });
            event.preventDefault();
            break;
        }
      },
      true,
    ); // Use capturing phase to intercept events early
  });
})();
```

---

1. wsl 中需要安装 socat 来配合 windows 上的 npiperelay
2. 根据是否在国外进行换源操作
3. 配置 age 来 签名
4. 设置 windows 上的 gpg key 用于 git commit 签名。
5. 使用 pre-commit 配合 chezmoi verify

## install apps

1. fix the path
2. only output error message

```pwsh
$installationFile = Join-Path -Path $PSScriptRoot -ChildPath "app.json"
$data = Get-Content $installationFile | ConvertFrom-Json

$packages = $data.Sources.Packages
# 使用 PowerShell 7 的并行功能，同时安装 3 个包
$packages | ForEach-Object -Parallel {
  winget install --id $_.PackageIdentifier --silent --accept-source-agreements --accept-package-agreements
} -ThrottleLimit 3
```

## install fonts

```pwsh
# 'lxgw/LxgwZhenKai'
# 'googlefonts/comfortaa'
# 'lxgw/LxgwMarkerGothic'
# 'atelier-anchor/smiley-sans'
# 'lxgw/yozai-font'
# 'lxgw/LxgwNeoXiHei'

# 7z e .\FiraCode.zip -o"$env:TEMP/fonts" "*.otf" -r

Install-PSResource -Name NerdFonts

$NerdFonts = @(
  '0xProto', '3270' , 'FiraCode',
  'FiraMono', 'Hack', 'Hurmit',
  'SauceCodePro', 'InconsolataGo',
  'JetBrainsMono', 'RecMono',
  'ProggyClean', 'Terminess', 'UbuntuMono'
)
$NerdFonts | Foreach-Object -ThrottleLimit 5 -Parallel {
  Install-NerdFont -Name $PSItem
}

# Get-ChildItem -Recurse | Where-Object { $_.Extension -in '.ttf', '.otf' } | Install-Font
```

## start wsl and hyperv platform

open in administrator terminal:

```cmd
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all
```

OR

```pwsh
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux,VirtualMachinePlatform
```

## set WSL network mode to `mirrored`

link: https://learn.microsoft.com/en-us/windows/wsl/networking#mirrored-mode-networking

powershell admin:

```pwsh
Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow
```

## 与 wsl 共享 ssh/gpg key

[Sharing Git credentials with your container](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials)

## 修复 windows sandbox 无法链接 或 其中的 Microsoft Edge 浏览器可以开启但无法显示问题

Open gpedit.msc
Navigate to Computer Configuration > Administrative Templates > Windows Components > Windows Sandbox
Disable "Allow vGPU sharing for Windows Sandbox"

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

## MAC OS sound resource

dowload: [textClassic Mac OS Sounds](https://alxwntr.com/classic-mac-os-sounds/#)

# External download scripts

安装 azure cli

```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

安装 nix

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

安装 pixi

```sh
curl -fsSL https://pixi.sh/install.sh | bash
```
