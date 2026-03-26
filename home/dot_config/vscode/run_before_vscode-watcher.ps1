<#
.SYNOPSIS
    一个可以感知自身变化并更新 Hash 记录的脚本。
    HashStore: 7192C7F196C9B365440F47A9D82F567946924823467F66D608F7E04C497B0669
#>

$ScriptPath = $MyInvocation.MyCommand.Path
# 1. 读取脚本全文
$Content = Get-Content $ScriptPath -Raw

# 2. 提取脚本中保存的旧 Hash (定位 HashStore: 后面那串字符)
$OldHashMatch = [regex]::Match($Content, "(?<=HashStore:\s*)[A-F0-9]{64}")
$OldHash = $OldHashMatch.Value

# 3. 临时清除脚本中的 Hash 记录来计算“真实”的当前 Hash
# (否则每次更新 Hash 后，文件内容变了，Hash 也会变，陷入死循环)
$TempContent = $Content -replace "(?<=HashStore:\s*)[A-F0-9]{64}", ""
$TempFilePath = "$ScriptPath.tmp"
$TempContent | Out-File $TempFilePath -Encoding UTF8
$CurrentHash = (Get-FileHash $TempFilePath -Algorithm SHA256).Hash
Remove-Item $TempFilePath

# 4. 逻辑对比
if ($OldHash -eq $CurrentHash) {
    Write-Host "验证通过：脚本未被篡改，执行正常逻辑..." -ForegroundColor Green
    # 在这里编写你的核心业务代码
} else {
    Write-Warning "检测到脚本内容变更！正在更新 Hash 记录..."

    # 将新的 Hash 写入内容并保存回文件
    $NewContent = $Content -replace "(?<=HashStore:\s*)[A-F0-9]{64}", $CurrentHash
    $NewContent | Set-Content $ScriptPath -Encoding UTF8

    Write-Host "新 Hash 已写入：$CurrentHash" -ForegroundColor Cyan
    Write-Host "请重新运行脚本以生效。"
    exit
}

# --- 业务逻辑开始 ---
# Write-Host "Hello World!"