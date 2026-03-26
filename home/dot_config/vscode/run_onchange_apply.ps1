<#
.SYNOPSIS
    合并 VS Code settings 分片文件为完整 settings.jsonc

.DESCRIPTION
    扫描 {SettingsDir} 目录下的 *.jsonc 文件，按照文件名排序，
    去除 JSONC 注释后合并，后加载的文件路径覆盖前面的相同键。

    合并策略：浅层键覆盖（适合 VS Code settings）

.PARAMETER SettingsDir
    存放 settings 分片文件的目录（默认: $PSScriptRoot/../../dot_config/vscode/settings）

.PARAMETER OutputFile
    输出最终 settings.jsonc 的路径（默认: $PSScriptRoot/../../dot_config/vscode/settings.jsonc）

.EXAMPLE
    # 默认路径
    .\Merge-VSCodeSettings.ps1

    # 自定义路径
    .\Merge-VSCodeSettings.ps1 -SettingsDir "C:\tmp\settings" -OutputFile "C:\tmp\settings.jsonc"

settings hash:

keybindings hash:
#>

param(
    [string]$SettingsDir,
    [string]$OutputFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================================
# 定义路径
# ============================================================================

if ([string]::IsNullOrWhiteSpace($SettingsDir)) {
    $SettingsDir = Join-Path (Split-Path $PSScriptRoot -Parent) "dot_config\vscode\settings"
}

if ([string]::IsNullOrWhiteSpace($OutputFile)) {
    $OutputFile = Join-Path (Split-Path $SettingsDir -Parent) "settings.jsonc"
}

Write-Verbose "SettingsDir: $SettingsDir"
Write-Verbose "OutputFile: $OutputFile"

# ============================================================================
# 辅助函数
# ============================================================================

function Remove-JsonComments {
    <#
    .SYNOPSIS
        移除 JSONC 中的注释（// 和 /* */）
        逐字符解析，正确处理字符串和转义序列
    #>
    param([string]$JsoncText)

    $result = @()
    $i = 0
    $length = $JsoncText.Length
    $inString = $false
    $stringChar = $null

    while ($i -lt $length) {
        $char = $JsoncText[$i]

        # 处理字符串
        if ($inString) {
            $result += $char

            # 检查转义序列
            if ($char -eq '\' -and $i + 1 -lt $length) {
                $i++
                $result += $JsoncText[$i]
            }
            # 检查字符串结尾
            elseif ($char -eq $stringChar) {
                $inString = $false
            }

            $i++
            continue
        }

        # 检查字符串开始
        if ($char -eq '"') {
            $inString = $true
            $stringChar = '"'
            $result += $char
            $i++
            continue
        }

        # 不在字符串中，检查注释
        if ($i + 1 -lt $length) {
            $twoChars = $JsoncText.Substring($i, 2)

            # /* */ 多行注释
            if ($twoChars -eq '/*') {
                $end = $JsoncText.IndexOf('*/', $i + 2)
                if ($end -ne -1) {
                    # 保留注释占位的行数，避免行号错误
                    $commentBlock = $JsoncText.Substring($i, $end - $i + 2)
                    $newlines = [regex]::Matches($commentBlock, "`n").Count
                    for ($j = 0; $j -lt $newlines; $j++) {
                        $result += "`n"
                    }
                    $i = $end + 2
                    continue
                }
            }

            # // 单行注释
            if ($twoChars -eq '//') {
                $end = $JsoncText.IndexOf("`n", $i)
                if ($end -ne -1) {
                    $result += "`n"
                    $i = $end + 1
                } else {
                    $i = $length
                }
                continue
            }
        }

        $result += $char
        $i++
    }

    return [string]::Join('', $result)
}

function Merge-JsonObjects {
    <#
    .SYNOPSIS
        浅层合并两个 PSObject，$source 的键覆盖 $base
    #>
    param(
        [PSObject]$base,
        [PSObject]$source
    )

    if ($null -eq $base) { return $source }
    if ($null -eq $source) { return $base }

    $merged = $base | ConvertTo-Json -Depth 100 | ConvertFrom-Json

    # 遍历 $source 的所有属性
    $source.PSObject.Properties | ForEach-Object {
        $propertyName = $_.Name
        $propertyValue = $_.Value

        # 添加或覆盖属性
        $merged | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyValue -Force
    }

    return $merged
}

# ============================================================================
# 主逻辑
# ============================================================================

# 验证目录存在
if (!(Test-Path $SettingsDir -PathType Container)) {
    Write-Error "Settings 目录不存在: $SettingsDir"
    exit 1
}

# 获取分片文件并排序
$fragments = @(Get-ChildItem -Path $SettingsDir -Filter "*.jsonc" | Sort-Object Name)

if ($fragments.Count -eq 0) {
    Write-Warning "未找到任何 *.jsonc 文件在 $SettingsDir"
    exit 1
}

Write-Verbose "找到 $($fragments.Count) 个分片文件，将按以下顺序合并："
$fragments | ForEach-Object { Write-Verbose "  - $($_.Name)" }

# 合并所有分片
$merged = $null

foreach ($fragment in $fragments) {
    Write-Verbose "处理: $($fragment.Name)"

    try {
        $content = Get-Content -Path $fragment.FullName -Raw -Encoding UTF8
        $cleaned = Remove-JsonComments -JsoncText $content

        # 重要：删除尾部可能的逗号（某些编辑器可能留下）
        $cleaned = $cleaned -replace ',(\s*[\}\]])', '$1'

        $obj = $cleaned | ConvertFrom-Json -ErrorAction Stop

        if ($null -eq $merged) {
            $merged = $obj
        } else {
            $merged = Merge-JsonObjects -base $merged -source $obj
        }

        Write-Verbose "  ✓ 成功合并"
    }
    catch {
        Write-Error "解析分片文件失败: $($fragment.Name) `n$_"
        Write-Verbose "调试信息 - 清理后的前200字符: $($cleaned.Substring(0, [Math]::Min(200, $cleaned.Length)))"
        exit 1
    }
}

if ($null -eq $merged) {
    Write-Error "合并后的配置对象为空"
    exit 1
}

# ============================================================================
# 产出最终文件
# ============================================================================

$outputDir = Split-Path $OutputFile -Parent
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# 转换为有格式的 JSON（带缩进，便于阅读），然后包装为 JSONC
$jsonOutput = $merged | ConvertTo-Json -Depth 100 -Compress:$false

# 添加文件头（标记为自动生成）
$header = @(
    "// ============================================================================"
    "// AUTO-GENERATED BY Merge-VSCodeSettings.ps1"
    "// DO NOT EDIT DIRECTLY - modify files in ./settings/ instead"
    "// ============================================================================"
    ""
) -join "`n"

$finalContent = $header + $jsonOutput

# 写入文件
try {
    Set-Content -Path $OutputFile -Value $finalContent -Encoding UTF8 -NoNewline -ErrorAction Stop
    Write-Host "✅ 成功生成: $OutputFile" -ForegroundColor Green
    Write-Verbose "文件大小: $((Get-Item $OutputFile).Length) bytes"
}
catch {
    Write-Error "写入输出文件失败: $OutputFile `n$_"
    exit 1
}

exit 0
