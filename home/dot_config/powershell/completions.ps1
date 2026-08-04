# link: https://carapace-sh.github.io/carapace-bin/setup.html#powershell
$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
#  todo
carapace _carapace | Out-String | Invoke-Expression


# $modules = @("WSLTabCompletion", "DockerCompletion", "posh-cargo")

# $CompletionCacheTtl = [TimeSpan]::FromDays(1)

# function Update-CompletionCache {
#   param(
#     [string]$CmdName,
#     [string[]]$ArgsList,
#     [bool]$needRefresh = $false
#   )

#   $CacheFile = Join-Path $global:PS_CACHE_ROOT "completion_$CmdName.ps1"

#   $needRefresh = -not (Test-Path $CacheFile)
#   if (-not $needRefresh) {
#     $lastWrite = (Get-Item $CacheFile).LastWriteTimeUtc
#     $expiry = $lastWrite + $CompletionCacheTtl
#     if ((Get-Date).ToUniversalTime() -gt $expiry) {
#       $needRefresh = $true
#     }
#   }

#   if ($needRefresh -and (Get-Command $CmdName -ErrorAction SilentlyContinue)) {
#     try {
#       & $CmdName @ArgsList | Out-File $CacheFile -Encoding utf8
#     }
#     catch {
#       Write-Error "Failed to refresh completion for ${CmdName}: $_"
#     }
#   }

#   return $CacheFile
# }

# function Import-Completion {
#   param(
#     [string]$CmdName,
#     [string[]]$ArgsList
#   )

#   $cacheFile = Update-CompletionCache -CmdName $CmdName -ArgsList $ArgsList
#   if (Test-Path $cacheFile) {
#     . $cacheFile
#   }
# }

#   # 3.
#   Get-ChildItem -Path "$PSScriptRoot/scripts/" -Filter "*_completion.ps1" | ForEach-Object {
#     . $_.FullName
#   }
# }

# # 注册一个引擎事件：在提示符准备就绪后运行
# Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $PostStartTask | Out-Null

Get-ChildItem -Path "$env:USERPROFILE/completions/" -Filter "*.ps1" | ForEach-Object {
  . $_.FullName
}
