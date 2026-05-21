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

# TODO

1. wsl中需要安装socat来配合windows上的npiperelay
2. 根据是否在国外进行换源操作
3. 配置 age 来 签名
4. 设置windows上的gpg key用于 git commit 签名。

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

## 与wsl共享 ssh/gpg key

[Sharing Git credentials with your container](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials)

## 修复 windows sandbox 无法链接 或 其中的 Microsoft Edge 浏览器可以开启但无法显示问题

Open gpedit.msc
Navigate to Computer Configuration > Administrative Templates > Windows Components > Windows Sandbox
Disable "Allow vGPU sharing for Windows Sandbox"

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

## MAC OS sound resource

dowload: [textClassic Mac OS Sounds](https://alxwntr.com/classic-mac-os-sounds/#)
