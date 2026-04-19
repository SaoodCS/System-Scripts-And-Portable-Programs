#TODO: first update customize.ps1 to how you want -> then run this file to add the path to customize.ps1 to the PowerShell profile
$customScript = Join-Path $PSScriptRoot 'customize.ps1'
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
Set-Content -Path $PROFILE -Value ". `"$customScript`""