Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function setEnv {
  param(
    [Parameter(Mandatory)][string]$name,
    [Parameter(Mandatory)][string]$value,
    [ValidateSet("Process", "User", "Machine")][string]$target = "User"
  )

  [Environment]::SetEnvironmentVariable($name, $value, $target)
}

function optionCreate() {
  param([string]$folder)
  if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder | Out-Null
  }
}
# ------------------------
$dotFilesPath = "$env:USERPROFILE\.config\.dotfiles"
setEnv -name "DOTFILES_PATH" -value $dotFilesPath -target "User"

# $devDrive = (Resolve-Path -Path "D:\").Path
# $cacheFolder = "$devDrive\DevCache"
# optionCreate -folder $cacheFolder
# $cacheFolder = (Resolve-Path -Path $cacheFolder).Path

# ------------------------
# LLVM
# ------------------------
# $systemPathVariable = [Environment]::GetEnvironmentVariable("PATH", "Machine")
# $LLVMPath = (Resolve-Path -Path "$env:ProgramFiles\LLVM\bin").Path
# setEnv -name "PATH" -value ($systemPathVariable + ";" + $LLVMPath) -target "Machine"

# ------------------------
# huggingface endpoint
# ------------------------
setEnv -name "HF_ENDPOINT" -value "https://hf-mirror.com" -target "User"
# setEnv -name "MODEL_ENDPOINT" -value "https://www.modelscope.cn/" -target "User"

# ------------------------
# rustup
# ------------------------
# $rustupServer = "https://rsproxy.cn"
# $rustupRoot = "https://rsproxy.cn/rustup"
# setEnv -name "RUSTUP_DIST_SERVER" -value $rustupServer -target "User"
# setEnv -name "RUSTUP_UPDATE_ROOT" -value $rustupRoot -target "User"

# ------------------------
# bun
# ------------------------
# $targetBun = "$cacheFolder\.bun"
# optionCreate -folder $targetBun
# $targetBun = (Resolve-Path -Path $targetBun).Path
# $targetBunCache = "$targetBun\cache"
# optionCreate -folder $targetBunCache

# setEnv -name "BUN_INSTALL" -value $targetBun -target "User"
# setEnv -name "BUN_INSTALL_CACHE" -value $targetBunCache -target "User"

# ------------------------
# Winget Links
# ------------------------

$winget_links = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"

setEnv -name "WINGET_LINKS" -value $winget_links -target "User"

# ------------------------
# CMD prompt setting
# link: https:\\learn.microsoft.com\en-us\windows\terminal\tutorials\new-tab-same-directory#command-prompt-cmdexe
# ------------------------
setEnv -name "PROMPT" -value '$e]133;D$e\$e]133;A$e\$e]9;9;$P$e\$P$G$e]133;B$e\' -target "User"
