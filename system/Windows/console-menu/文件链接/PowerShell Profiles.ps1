# Symlink PowerShell Profiles

if (-not $env:DOTFILES) {
    throw 'Environment variable $env:DOTFILES is not set'
}

$Ps1Profile = "Microsoft.PowerShell_profile.ps1"
$LinkTarget = "$env:DOTFILES/shell/pwsh/$Ps1Profile"
$LinkReside = "$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\$Ps1Profile"
New-Item -ItemType SymbolicLink -Path "$LinkReside" -Target "$LinkTarget" -Force

$Ps1Profile = "Microsoft.PowerShell_profile.ps1"
$LinkTarget = "$env:DOTFILES/shell/pwsh5/$Ps1Profile"
$LinkReside = "$([Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\$Ps1Profile"
New-Item -ItemType SymbolicLink -Path "$LinkReside" -Target "$LinkTarget" -Force
