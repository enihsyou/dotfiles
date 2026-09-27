. $env:DOTFILES\shell\pwsh\PSHelper_Encoding.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Function.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Helper.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Loader.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Enhancement.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Alias.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_Completion.ps1
. $env:DOTFILES\shell\pwsh\PSHelper_PSReadLine.ps1

# https://github.com/ajeetdsouza/zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# [not working in async context] Bring autocomplete to Git
# better do it manually when auto completion is needed.
# Import-Module -Name posh-git

# Reverse Search Through PSReadline History
Set-PSReadlineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
    Write-Host "🚨 PSFzf not loaded! Loading now..."
    # 不兼容 ProfileAsync.psm1 的异步上下文，选用按需加载
    # 否则会有错误 Object reference not set to an instance of an object.
    Import-Module PSFzf
    # 会替换当前的 Ctrl+r 绑定
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
    # 触发当前的调用
    # 使用这个而不是 Invoke-History 以避免首次调用时无法触发执行动作
    Invoke-FzfPsReadlineHandlerHistory
}

# 会在创建 System.Management.Automation.PowerShell 时间接创建一个未关闭的 Runspace
# #f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound
# #f45873b3-b655-43a6-b217-97c00aa0db58
