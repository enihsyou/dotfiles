# 本文件放置环境启动器和按需加载器。

Function msys2_launcher {
    # 调用函数传递的或者从上层通过 @args 传来的多个参数作为 "$args" 整体调用
    param([string]$Shell)
    if ($args.Count -eq 0) {
        & "C:\msys64\msys2_shell.cmd" -defterm -here -no-start -$Shell
    }
    else {
        & "C:\msys64\msys2_shell.cmd" -defterm -here -no-start -$Shell -c "$args"
    }
}
Function msys2 { & msys2_launcher -Shell msys2 @args }
Function ucrt64 { & msys2_launcher -Shell ucrt64 @args }
Function mingw64 { & msys2_launcher -Shell mingw64 @args }
Function clang64 { & msys2_launcher -Shell clang64 @args }

function x {
    Write-Host "🚨 x not loaded! Loading now..."
    Write-Host
    Remove-Item -Path "Function:x"

    Import-Module -Name "$env:DOTFILES\shell\pwsh\Modules\X-CMD.psm1" -Force -DisableNameChecking

    x @args
}

function vfox {
    Write-Host "🚨 vfox not loaded! Loading now..."
    Write-Host

    $bin = (Get-Command "vfox" -CommandType Application -TotalCount 1).Path

    # 绕过 vfox activate pwsh 对 prompt 的修改, 因为在 Async 加载中不生效
    $env:__VFOX_INITIALIZED = '1'
    Invoke-Expression "$(& $bin activate pwsh)"

    $script:vfoxEnvWrapper = {
        & $bin @args
        # 替代 vfox 手动注入环境变量
        if ($args.Count -gt 0 -and $args[0] -match '^(use)$') {
            Invoke-Expression "$(& $bin env -s pwsh)"
        }
    }.GetNewClosure()

    Set-Item -Path "Function:vfox" -Value $script:vfoxEnvWrapper
    & $script:vfoxEnvWrapper @args
}
