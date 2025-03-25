Write-Output "Download RefreshEnv.cmd from Chocolate"
Invoke-WebRequest `
   -Uri "https://raw.githubusercontent.com/chocolatey/choco/refs/heads/master/src/chocolatey.resources/redirects/RefreshEnv.cmd" `
   -OutFile "$HOME/.local/bin/RefreshEnv.cmd"
