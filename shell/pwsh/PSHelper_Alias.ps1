Function which_GetCommand_SourceOnly {
    # similar to `which` in Linux
    param([string]$Name)
    $command = Get-Command -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }
    return ''
}
Function help_ShowWindow {
    # I'd like to see help content in a separate window
    param([string]$Name)
    Get-Help -ShowWindow -Name $Name
}

# msys2 alias
Function msys2_launcher {
    # 调用函数传递的或者从上层通过 @args 传来的多个参数作为 "$args" 整体调用
    param([string]$Shell)
    if ($args.Count -eq 0) {
        & "C:\msys64\msys2_shell.cmd" -defterm -here -no-start -$Shell
    } else {
        & "C:\msys64\msys2_shell.cmd" -defterm -here -no-start -$Shell -c "$args"
    }
}
Function msys2 { & msys2_launcher -Shell msys2 @args }
Function ucrt64 { & msys2_launcher -Shell ucrt64 @args }
Function clang64 { & msys2_launcher -Shell clang64 @args }

# some linux like alias
# which 和 touch 在 x-cmd 中有更好的实现，如果 source 了它会覆盖掉这里
Set-Alias -Name which -Value which_GetCommand_SourceOnly
Set-Alias -Name touch -Value New-Item
Set-Alias -Name help -Value help_ShowWindow
Set-Alias -Name open -Value explorer

# pnpm alias
Set-Alias -Name np -Value pnpm
Function nx { & pnpm dlx @args }

# Since I always forget I am on Windows not macOS.
Set-Alias -Name brew -Value winget -Description "Alias to winget, for macOS users"

# 删除默认指向 Where-Object 的别名，转而调用 where.exe
Remove-Alias -Name where -Force -ErrorAction Ignore

# rg with vscode hyperlink format
function rgv { rg --hyperlink-format=vscode @args }

function x-cmd {
    . "$HOME\.x-cmd.root\local\data\pwsh\_index.ps1"
}
