$DOTFILES = $(Get-Item $PSScriptRoot).Parent.Parent.Parent.FullName

& "$DOTFILES/cli-app/aria2/install-aria2-as-service.ps1"
