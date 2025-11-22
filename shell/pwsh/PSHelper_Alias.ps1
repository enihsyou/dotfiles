Function which_GetCommand_SourceOnly {
    # similar to `which` in Linux
    param([string]$Name)
    if ($null -eq $Name -or $Name -eq '') {
        return 'Usage: which <command>'
    }
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
Set-Alias -Name msys -Value ucrt64

# some linux like alias
# which 和 touch 在 x-cmd 中有更好的实现，如果 source 了它会覆盖掉这里
Set-Alias -Name which -Value which_GetCommand_SourceOnly
Set-Alias -Name touch -Value New-Item
Set-Alias -Name help -Value help_ShowWindow
Set-Alias -Name open -Value explorer

# findstr 不好用，既然要换就换好的
# https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#how-do-i-create-an-alias-for-ripgrep-on-windows
function grep {
    $count = @($input).Count
    $input.Reset()

    if ($count) {
        $input | rg.exe --hidden $args
    }
    else {
        rg.exe --hidden $args
    }
}

# pnpm alias
Set-Alias -Name np -Value pnpm
Function nx { & pnpm dlx @args }

# bun alias
# winget install bun 不会把 bunx.exe 添加到 PATH 中
Function bunx { bun x @args }

# Since I always forget I am on Windows not macOS.
Set-Alias -Name brew -Value winget -Description "Alias to winget, for macOS users"

# HTTPie 启动耗时太慢，换成 Rust 版
Set-Alias -Name http -Value xh -Description "a Rust version of HTTPie"

# 删除默认指向 Where-Object 的别名，转而调用 where.exe
Remove-Alias -Name where -Force -ErrorAction Ignore

# rg with vscode hyperlink format
function rgv { rg --hyperlink-format=vscode @args }

# rsync from MSYS2 will need '-e /usr/bin/ssh' to specify ssh client within MSYS2
# to function correctly.
function rsync { rsync.exe -e /usr/bin/ssh @args }
