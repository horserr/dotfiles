Set-StrictMode -Version Latest
; $ErrorActionPreference = "Stop"
$ErrorActionPreference = "Continue"

# get powershell physical path
# 获取当前执行脚本的路径（哪怕它是软链接）
$currentPath = $MyInvocation.MyCommand.Path

# 强制解析出符号链接对应的真实物理文件对象
$fileInfo = New-Object -TypeName System.IO.FileInfo -ArgumentList $currentPath

# 获取真实的物理目录
$powershellRoot = $fileInfo.LinkTarget ? (Split-Path $fileInfo.LinkTarget) : $PSScriptRoot

# 2. 依次加载所有模块化配置（快速初始化）
. "$powershellRoot\env.ps1"         # 加载环境变量
. "$powershellRoot\alias.ps1"       # 加载别名
. "$powershellRoot\functions.ps1"   # 加载自定义函数
. "$powershellRoot\keybindings.ps1" # 加载按键绑定
. "$powershellRoot\completions.ps1"

# 加载脚本目录
$ScriptsPath = Join-Path -Path $powershellRoot -ChildPath "scripts"
if (Test-Path $ScriptsPath) {
  Get-ChildItem "$ScriptsPath\*.ps1" | ForEach-Object { . $_.FullName }
}

Write-Host "✨ Dotfiles PowerShell 环境加载完成" -ForegroundColor Cyan
