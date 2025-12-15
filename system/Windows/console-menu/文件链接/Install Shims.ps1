if (-not $env:DOTFILES) {
    throw 'Environment variable $env:DOTFILES is not set'
}

& python $env:DOTFILES\system\Windows\install-shims.py
