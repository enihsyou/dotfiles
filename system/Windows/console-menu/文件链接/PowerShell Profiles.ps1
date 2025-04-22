# Symlink PowerShell Profiles

$DOTFILES = $(Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName

$Ps1Profile="Microsoft.PowerShell_profile.ps1"
$LinkTarget="$DOTFILES/shell/pwsh/$Ps1Profile"
$LinkReside="$([Environment]::GetFolderPath('MyDocuments'))\PowerShell\$Ps1Profile"
New-Item -ItemType SymbolicLink -Path "$LinkReside" -Target "$LinkTarget" -Force
