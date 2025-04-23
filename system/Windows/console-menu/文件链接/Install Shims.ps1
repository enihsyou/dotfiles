if (-not $env:DOTFILES) {
    throw 'Environment variable $env:DOTFILES is not set'
}

& $env:DOTFILES\system\Windows\install-shims.ps1
