# TODO

fix windows terminal config reload diff

add apm and install skill

bookmark, and fix claude code in root

learn claude code
use spare time to dive deep into cuda and system

learn tmux: <https://www.trmn.sh/guides/tmux-persistent-sessions>
learn intputrc bash keybindings and how to avoid conflict with terminal

learn claude code terminal setting:
<https://code.claude.com/docs/en/terminal-config>

also with vscode setting:
<https://code.claude.com/docs/en/vs-code>

add ntfy to claude code

systemd, journalctl

lastlog
dmesg
lastb
last

understand gpu programming

core dump
ssh 剪切板
tssh

ssh private keys backup using bitwarden

fix wsl using ssh agent on windows

learn rsync

free server

mihomo and mousemaster servy control

remote display forwarding

bookmark extension

python debugpy cli

remote explorer view

use overbinding and conditional contribute to the global vspace commands

reference view:
{
  "key": "shift+alt+h",
  "command": "references-view.showCallHierarchy",
  "when": "editorHasCallHierarchyProvider"
}
{
  "key": "",
  "command": "references-view.showIncomingCalls"
}
{
  "key": "",
  "command": "references-view.showOutgoingCalls"
}

vscode problem panel

windows start ssh agent service

ssh add environment and remote command
send env and set env
~/.ssh/environment

git remote set-head
git remote set-head origin -a
git branch -u origin/新分支名

git remote set-url

https://gist.github.com/laispace/666dd7b27e9116faece6

vscode http https proxy
bit warden 如何保存 ssh key?
try linux gui x forwarding on windows

potplayer 设置

sudo systemctl status ssh or sudo systemctl status sshd

```pwsh
# 1. 将 ssh-agent 服务设置为自动启动
Set-Service -Name ssh-agent -StartupType Automatic

# 2. 立即启动该服务
Start-Service ssh-agent
```

// note: sshd should allow AllowStreamLocalForwarding

try nix and devbox

了解 ssh server configuration

use cloud init to create wsl profile

remote explorer view commands
github codespace
ssh wsl tunnel commands and settings

add setting sync and cloud change

fzf, yazi

vscode debug

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

通过 yazi 来管理文件
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

install mise

```sh
curl https://mise.run | sh
```

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

# Termux

termux-setup-storage
termux-change-repo

need to auto start sshd

unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY

curl -I https://www.google.com

pkg install vim
pkg install tur-repo code-server

vim .config/code-server/config.yml

sshd
code-server --bind-addr 127.0.0.1:8080 --auth none

---

ssh -N -L 8080:127.0.0.1:8080
