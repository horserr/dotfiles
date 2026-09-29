if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "You need Administrator privilege." -ForegroundColor Red
  Exit
}

$jsonConfig = '{"custom_shortcuts":[{"command":"new_tab","custom_shortcut":"Ctrl+Alt+N"},{"command":"help_page","custom_shortcut":"disabled"}]}'

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

if (-not (Test-Path $registryPath)) {
  New-Item -Path $registryPath -Force | Out-Null
}

Set-ItemProperty -Path $registryPath -Name "ConfigureKeyboardShortcuts" -Value $jsonConfig -Type String

Write-Host "Edge shortcut policy set successfully! Restart Edge or reload policies at edge://policy." -ForegroundColor Green
