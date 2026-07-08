Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================================
# 辅助函数
# ============================================================================

function Ensure-Directory {
    <#
    .SYNOPSIS
        确保目录存在，不存在则创建
    #>
    param([string]$Path)

    if (!(Test-Path $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Ensure-Symlink {
    <#
    .SYNOPSIS
        安全地创建或更新符号链接

    .DESCRIPTION
        逻辑：
        1. 如果目标已是指向正确源的链接 → 跳过
        2. 如果目标是其他链接 → 删除后重建
        3. 如果目标是普通文件/目录 → 报错，不覆盖
        4. 如果目标不存在 → 创建链接
    #>
    param(
        [string]$LinkPath,
        [string]$TargetPath,
        [string]$Description = ""
    )

    $descStr = if ($Description) { " ($Description)" } else { "" }

    # 规范化路径
    $LinkPath = [System.IO.Path]::GetFullPath($LinkPath)
    $TargetPath = [System.IO.Path]::GetFullPath($TargetPath)

    # 验证目标存在
    if (!(Test-Path $TargetPath)) {
        Write-Error "❌ 目标不存在: $TargetPath$descStr"
        return $false
    }

    # 如果链接已存在
    if (Test-Path $LinkPath) {
        $item = Get-Item -Path $LinkPath -Force

        # 是符号链接
        if ($item.LinkType -eq "SymbolicLink") {
            $currentTarget = $item.Target
            # 去掉可能的 '\', 规范化比较
            $currentTargetNorm = $currentTarget -replace '\\$' , ''
            $targetNorm = $TargetPath -replace '\\$', ''

            if ($currentTargetNorm -eq $targetNorm) {
                Write-Host "⏭️  跳过 (已正确指向): $LinkPath$descStr"
                return $true
            } else {
                Write-Host "🔄 更新链接: $LinkPath → $TargetPath$descStr"
                Remove-Item -Path $LinkPath -Force
            }
        } else {
            # 是普通文件或目录，不覆盖
            Write-Error "❌ 路径已存在但不是符号链接 (类型: $($item.PSTypeNames[0])): $LinkPath$descStr`n   请手动处理或删除此路径"
            return $false
        }
    } else {
        Write-Host "➕ 创建链接: $LinkPath → $TargetPath$descStr"
    }

    # 创建符号链接
    try {
        # 对于文件和目录采用不同的 ItemType
        $targetItem = Get-Item -Path $TargetPath -Force

        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null

        # 验证创建成功
        if ((Test-Path $LinkPath) -and ((Get-Item -Path $LinkPath -Force).LinkType -eq "SymbolicLink")) {
            Write-Host "✅ 成功: $LinkPath$descStr" -ForegroundColor Green
            return $true
        } else {
            Write-Error "❌ 创建符号链接失败（原因未知）: $LinkPath$descStr"
            return $false
        }
    }
    catch {
        Write-Error "❌ 创建符号链接异常: $LinkPath$descStr`n   $($_.Exception.Message)"
        return $false
    }
}

# ============================================================================

# ============================================================================

$scoopPath = "$env:USERPROFILE\scoop"
$scoopPersistPath = "$scoopPath\persist"
$dotConfigPath = "$env:USERPROFILE\.config"
$documentPath = [Environment]::GetFolderPath("MyDocuments")

# 定义映射关系：$映射[链接路径] = 目标路径
$mappings = @{
  # PowerShell Profile
  "$documentPath\PowerShell\Microsoft.PowerShell_profile.ps1" = @{
    target = "$dotConfigPath\powershell\Microsoft.PowerShell_profile.ps1"
    desc   = "PowerShell Profile"
  }

  # Windows Terminal Preview
  (
    "$env:LOCALAPPDATA\Packages\" +
    "Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\" +
    "LocalState\settings.json"
  ) = @{
    target = "$dotConfigPath\windows-terminal.jsonc"
    desc   = "Windows Terminal Preview"
  }

  # nushell
  (
    "$env:APPDATA\nushell"
  ) = @{
    target = "$dotConfigPath\nushell"
    desc   = "nushell"
  }

  # Microsoft Word Template
  "$env:APPDATA\Microsoft\Templates\normal.dotm" = @{
    target = "$env:OneDrive\Resource\Other\Office\Word\Normal.dotm"
    desc   = "Word Normal.dotm"
  }

  # SumatraPDF
  "$scoopPersistPath\sumatrapdf\SumatraPDF-settings.txt" = @{
    target = "$dotConfigPath\sumatrapdf\settings.txt"
    desc   = "SumatraPDF Settings"
  }

  # VSCode Settings
  "$env:APPDATA\Code\User\settings.json" = @{
    target = "$dotConfigPath\vscode\settings.json"
    desc   = "VSCode Settings"
  }
  # VSCode Keybindings
  "$env:APPDATA\Code\User\keybindings.json" = @{
    target = "$dotConfigPath\vscode\keybindings.json"
    desc   = "VSCode Keybindings"
  }
  # VSCode snippets
  "$env:APPDATA\Code\User\snippets" = @{
    target = "$dotConfigPath\vscode\snippets"
    desc   = "VSCode snippets"
  }
  # VSCode prompts
  "$env:APPDATA\Code\User\prompts" = @{
    target = "$dotConfigPath\vscode\prompts"
    desc   = "VSCode prompts"
  }
  # VSCode tasks
  "$env:APPDATA\Code\User\tasks.json" = @{
    target = "$dotConfigPath\vscode\tasks.json"
    desc   = "VSCode tasks"
  }
}

# ============================================================================
# 创建所有链接
# ============================================================================

Write-Host "`n🔗 即将建立符号链接..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"

$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($linkPath in $mappings.Keys) {
  $config = $mappings[$linkPath]
  $targetPath = $config.target
  $description = $config.desc

  # 确保父目录存在
  $linkDirPath = Split-Path $linkPath -Parent
  Ensure-Directory $linkDirPath

  # 创建或校验链接
  if (Ensure-Symlink -LinkPath $linkPath -TargetPath $targetPath -Description $description) {
    if (Test-Path $linkPath) {
      $item = Get-Item -Path $linkPath -Force
      if ($item.LinkType -eq "SymbolicLink" -and (Get-Item -Path $linkPath -Force).Target -eq $targetPath) {
        $successCount++
      } else {
        $skipCount++
      }
    }
  } else {
    $failCount++
  }
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "📊 结果统计"
Write-Host "  ✅ 成功/新建: $successCount"
Write-Host "  ⏭️  已跳过: $skipCount"
Write-Host "  ❌ 失败: $failCount"
Write-Host ""

if ($failCount -gt 0) {
  Write-Error "❌ 有 $failCount 个链接创建失败"
  exit 1
}

Write-Host "✅ 所有符号链接处理完成`n" -ForegroundColor Green
