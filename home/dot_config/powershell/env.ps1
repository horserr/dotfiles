# [Environment]::SetEnvironmentVariable($Name, $Value, "User")

$global:PS_CACHE_ROOT = Join-Path $env:TEMP "pwsh_cache"
$env:PS_CACHE_ROOT = $global:PS_CACHE_ROOT # 同时存入环境变量，方便 Job 访问
if (!(Test-Path $global:PS_CACHE_ROOT)) { New-Item -ItemType Directory -Path $global:PS_CACHE_ROOT | Out-Null }

$env:EDITOR = "$env:ProgramFiles\Git\usr\bin\vim"

# 扩展 PATH
$extendPath = @(
  "C:\path",
  "$env:ProgramFilesX86\Microsoft\Edge\Application",
  "$env:ProgramFiles\7-Zip",
  "$env:ProgramFiles\Everything 1.5a"
  # "$env:ProgramFiles\Git\usr\bin"
  "$env:ProgramFiles\Git"
)
$env:Path = ($extendPath + $env:Path.Split(';')) -join ';'

# FZF 配置
$env:FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border=rounded --preview 'bat --color=always --line-range :500 {}'"
$env:_ZO_FZF_OPTS = "--height 50% --border=rounded --layout=reverse --info=inline"


# Starship 初始化
Invoke-Expression (&starship init powershell)
# link: https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#powershell-with-starship

##########################

$PostStartTask = {
  Import-Module Terminal-Icons
  # link: https://direnv.net/docs/hook.html#powershell
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $PostStartTask | Out-Null
