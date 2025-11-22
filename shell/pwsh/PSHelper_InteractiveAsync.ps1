. $env:DOTFILES\shell\pwsh\PSHelper_Alias.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Completion.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_PSReadLine.ps1

# 会在创建 System.Management.Automation.PowerShell 时间接创建一个未关闭的 Runspace
# #f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound
# #f45873b3-b655-43a6-b217-97c00aa0db58

# https://github.com/ajeetdsouza/zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# [not working in async context] Bring autocomplete to Git
# better do it manually when auto completion is needed.
# Import-Module -Name posh-git

# Reverse Search Through PSReadline History
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                -PSReadlineChordReverseHistory 'Ctrl+r'

# https://yazi-rs.github.io/docs/quick-start
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

function x {
    Write-Host "🚨 x not loaded! Loading now..."
    Write-Host
    Remove-Item -Path "Function:x"

    Import-Module -Name "$env:DOTFILES\shell\pwsh\Modules\X-CMD.psm1" -Force -DisableNameChecking

    x @args
}
