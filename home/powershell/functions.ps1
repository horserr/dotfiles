# 带参数的别名（需封装成函数，因为Set-Alias不支持参数）
function ll {
  if (!(Get-Module Terminal-Icons)) { Import-Module Terminal-Icons }
  Get-ChildItem -Force -Path $args[0]
}

function cd.. { Set-Location .. }                    # cd.. 快速回退目录
function conf {
  & code (Split-Path -Parent $PSScriptRoot)
}
function util {
  $command = "Invoke-RestMethod https://christitus.com/win | Invoke-Expression"
  powershell -NoProfile -Command $command
}
function myip { curl ifconfig.me }
function v { $Input | nvim - }                  # Get-Process | v

function Get-BitLockerSummary {
  <#
  .SYNOPSIS
  显示所有驱动器的 BitLocker 状态看板
  #>
  $volumes = Get-BitLockerVolume
  Write-Host "`n[ BitLocker 状态看板 ]" -ForegroundColor Cyan
  $volumes | Select-Object MountPoint,
  @{Name = "状态"; Expression = { $_.ProtectionStatus } },
  @{Name = "加密率"; Expression = { "{0}%" -f $_.EncryptionPercentage } },
  @{Name = "锁定"; Expression = { $_.LockStatus } } | Format-Table -AutoSize

  $svc = Get-Service BDESVC
  $color = if ($svc.Status -eq "Running") { "Green" } else { "Red" }
  Write-Host "服务状态 (BDESVC): " -NoNewline
  Write-Host $svc.Status -ForegroundColor $color
}


function proxy-on {
  $env:HTTP_PROXY = "http://localhost:7897"
  $env:HTTPS_PROXY = "http://localhost:7897"
}

function set-title {
  # set windows terminal tab title
  param([string]$Title)
  $host.UI.RawUI.WindowTitle = $Title
}

function loading {
  # link: https://learn.microsoft.com/en-us/windows/terminal/tutorials/progress-bar-sequences
  Write-Host "`e]9;4;3;50`e\"
}

function edit-history {
  nvim (Get-PSReadLineOption).HistorySavePath
}

function startRclone {
  proxy-on
  Start-Process "rclone" -ArgumentList "mount od_drive:/ Z: --vfs-cache-mode full --vfs-read-chunk-size 64M --vfs-read-chunk-size-limit 256M --buffer-size 32M --transfers 16 --network-mode --vfs-cache-max-age 24h --vfs-cache-max-size 30G --vfs-write-back 5s --links"
}

function e {
  Get-ChildItem . -Recurse -Attributes !Directory | `
    Invoke-Fzf | `
    ForEach-Object { nvim $_ }
}

function edit {
  Get-ChildItem . -Recurse -Attributes !Directory | `
    Invoke-Fzf | `
    ForEach-Object { code $_ }
}

function ex {
  param( [string]$Path = [Environment]::GetFolderPath('Desktop'))
  explorer.exe $Path
}

function env {
  rundll32 sysdm.cpl, EditEnvironmentVariables
}

function eventvwr {
  mmc.exe eventvwr.msc
}

function bios {
  Write-Host "You are going to restart computer and enter BIOS"
  Pause
  shutdown /r /fw /f /t 0
}

function winre {
  Write-Host "You are going to restart computer and enter Windows Recovery Environment"
  Pause
  shutdown /r /o /f /t 0
}

function quickshutdown {
  write-host "You are going to shutdown computer immediately"
  Pause
  shutdown /s /t 0
}

function download {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$m3u8link,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$output
  )
  yt-dlp.exe --downloader aria2c --downloader-args "aria2c: -x 16 -s 16 -k 1M" $m3u8link -o $output
}

function Get-AllSpecialPaths {
  param(
    [Parameter(Position = 0)]
    [string]$Name
  )

  # 1. 采集 .NET SpecialFolders (NET_Special)
  $specialFolders = [Environment+SpecialFolder]::GetValues([Environment+SpecialFolder])
  $netList = foreach ($folder in $specialFolders) {
    $path = [Environment]::GetFolderPath($folder)
    if (-not [string]::IsNullOrWhiteSpace($path)) {
      [PSCustomObject]@{
        Name = $folder.ToString()
        Path = $path
      }
    }
  }

  # 2. 采集 CMD 风格的环境变量 (Env_Variable)
  # 过滤掉非路径变量，只保留以盘符或网络路径开头的
  $envList = Get-ChildItem Env: | Where-Object {
    $_.Value -match '^[a-zA-Z]:\\' -or $_.Value -like '\\*'
  } | ForEach-Object {
    [PSCustomObject]@{
      Name = $_.Name
      Path = $_.Value
    }
  }

  # 3. 逻辑处理：搜索与打开
  if (-not [string]::IsNullOrWhiteSpace($Name)) {
    $cleanName = $Name.Replace("%", "")
    # 在两个列表里同时查找
    $target = ($netList + $envList) | Where-Object { $_.Name -ieq $cleanName } | Select-Object -First 1

    if ($target) {
      Write-Host "正在打开路径: $($target.Path)" -ForegroundColor Cyan
      explorer.exe $target.Path
    }
    else {
      Write-Error "未找到名为 '$Name' 的路径。"
    }
    return
  }

  # 4. 分组美化展示
  Write-Host "`n==== [1] .NET Special Folders (PowerShell 特有) ====" -ForegroundColor Cyan
  $netList | Sort-Object Name | Format-Table -AutoSize

  Write-Host "==== [2] Environment Variables (CMD/系统环境变量) ====" -ForegroundColor Yellow
  $envList | Sort-Object Name | Format-Table -AutoSize

  Write-Host "提示: 使用 'special <Name>' 直接打开文件夹 (不区分大小写)。" -ForegroundColor DarkMagenta
}

function summary {
  &sudo.exe pwsh -NoExit -Command "& { . $PROFILE; Get-BitLockerSummary }"
}

function which {
  param([string]$Path)
  Get-Command $Path | Select-Object source
}

# Update all ps resource
function up-all {
  Write-Host "正在全面更新 PowerShell 模块..." -ForegroundColor Yellow
  Update-PSResource -Force -AcceptLicense
  Write-Host "更新完成！" -ForegroundColor Green
}

function memo {
  Write-Host @"
  trip: trippy
  exhyperv

  robocopy C:\Source D:\Destination /MIR /Z /XA:H /W:5 /R:3

  Get-AppxPackage -Name *terminal*
  (Get-MpPreference).ExclusionPath

  Add-MpPreference -ExclusionPath "C:\MyFolder"
  Remove-MpPreference -ExclusionPath "C:\MyFolder"

  git rm --cached file.txt  ; # 从 Git 索引中移除但保留工作区文件
  git restore --staged file.txt ; # 将暂存区的文件恢复到工作区

  ssh-keygen -t ed25519 -f ~\.ssh\id_ed25519_signing
  ssh-add ~\.ssh\id_ed25519_signing

  !!! bitlocker
  manage-bde -status
  manage-bde -off C:

  Set-Service BDESVC -StartupType Disabled
  Stop-Service BDESVC -Force
  Set-Service BDESVC -StartupType Manual
  Start-Service BDESVC
"@
}

<#
.SYNOPSIS
    将 Windows 上的 SSH 公钥同步到 WSL 或远程 Linux 服务器。

.DESCRIPTION
    该函数会自动扫描 $HOME\.ssh 目录下的所有 .pub 文件，并弹出 GUI 窗口供用户选择。
    支持两种模式：
    1. 远程模式：将公钥追加到远程主机的 ~/.ssh/authorized_keys 中（用于免密登录）。
    2. WSL 模式：将公钥文件直接复制到 WSL 实例的 ~/.ssh/ 目录下（用于 SSH 签名或标识）。

.PARAMETER Target
    远程模式：格式为 user@hostname 或 SSH Config 中的别名。
    WSL 模式：可选，指定特定的 WSL 发行版名称（如 'Ubuntu-22.04'）。若不填则使用默认分发版。

.PARAMETER ToWSL
    开关参数。若启用，则执行 WSL 同步逻辑而非远程 SSH 发送。

.PARAMETER AdditionalArgs
    传递给 ssh 命令的额外参数，例如 -p 2222（仅在远程模式下有效）。

.EXAMPLE
    ssh-copy-id user@192.168.1.10
    弹出选择框，选择公钥并发送到远程服务器进行授权。

.EXAMPLE
    ssh-copy-id -ToWSL
    弹出选择框，将公钥同步到默认 WSL 分发版的 ~/.ssh 目录。

.EXAMPLE
    ssh-copy-id Ubuntu-22.04 -ToWSL
    同步公钥到名为 Ubuntu-22.04 的特定实例。
#>
function ssh-copy-id {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Target,

    [Parameter(Mandatory = $false)]
    [switch]$ToWSL,

    [Parameter(ValueFromRemainingArguments = $true)]
    $AdditionalArgs
  )

  # 1. 扫描并选择公钥
  $sshDir = "$HOME\.ssh"
  if (-not (Test-Path $sshDir)) {
    Write-Error "错误: 未找到 $sshDir 目录。"
    return
  }

  $pubFiles = Get-ChildItem -Path $sshDir -Filter "*.pub" | Select-Object -ExpandProperty Name
  if ($pubFiles.Count -eq 0) {
    Write-Error "错误: 在 $sshDir 下未找到任何 .pub 文件。"
    return
  }

  $selectedKeys = $pubFiles | Out-GridView -Title "请选择要发送的公钥 (支持多选)" -OutputMode Multiple
  if (-not $selectedKeys) { Write-Warning "操作已取消"; return }

  foreach ($keyName in $selectedKeys) {
    $pubPath = Join-Path $sshDir $keyName
    $pubContent = Get-Content $pubPath -Raw

    if ($ToWSL) {
      # --- 分支 A: 复制到 WSL ---
      Write-Host "正在同步 $keyName 到 WSL..." -ForegroundColor Cyan

      # 构建 WSL 基础命令，修复空 -d 逻辑
      $wslArgs = @()
      if (-not [string]::IsNullOrWhiteSpace($Target)) {
        $wslArgs += "-d"
        $wslArgs += $Target
      }
      $wslArgs += "sh"
      $wslArgs += "-c"
      $wslArgs += "mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/$keyName; chmod 644 ~/.ssh/$keyName"

      # 执行 wsl 调用
      $pubContent | & wsl.exe $wslArgs

      if ($LASTEXITCODE -eq 0) {
        Write-Host "成功同步至 WSL: ~/.ssh/$keyName" -ForegroundColor Green
      }
    }
    else {
      # --- 分支 B: 复制到远程服务器 ---
      if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Error "远程模式下必须提供 Target (user@host 或别名)。"
        return
      }
      Write-Host "正在发送 $keyName 到远程 $Target..." -ForegroundColor Cyan
      $remoteCmd = "mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys"

      $pubContent | ssh $AdditionalArgs $Target $remoteCmd

      if ($LASTEXITCODE -eq 0) {
        Write-Host "成功发送至 $Target 的 authorized_keys。" -ForegroundColor Green
      }
    }
  }
}