Function which_GetCommand_SourceOnly {
    # similar to `which` in Linux
    param([string]$Name)
    if ($null -eq $Name -or $Name -eq '') {
        return 'Usage: which <command>'
    }
    $command = Get-Command -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source.Replace('\','/')
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
Function mingw64 { & msys2_launcher -Shell mingw64 @args }
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
# 若遭遇输出编码，需调用 utf8 函数切换编码
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

# dig as DNS client on Windows
function dig { doggo --strategy=random --time @args }

# rg with vscode hyperlink format
function rgv { rg --hyperlink-format=vscode @args }

# rsync from MSYS2 will need '-e /usr/bin/ssh' to specify ssh client within MSYS2
# to function correctly.
function rsync { rsync.exe -e /usr/bin/ssh @args }

# ls 继续保持使用 Get-ChildItem
function ll { eza --long --icons @args }

# 切换电源模式
function powermode {
    param([string]$Mode)

    if ([string]::IsNullOrWhiteSpace($Mode)) {
        Write-Host 'Usage: powermode <1|2|3>'
        Write-Host '  1 = 节能'
        Write-Host '  2 = 平衡'
        Write-Host '  3 = 高性能'
        powercfg /l
        return
    }

    $guids = @{
        '1' = 'a1841308-3541-4fab-bc81-f71556f20b4a' # 节能
        '2' = '381b4222-f694-41f0-9685-ff5bb260df2e' # 平衡
        '3' = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' # 高性能
    }

    powercfg /s $guids[$Mode]
    powercfg /l
}
