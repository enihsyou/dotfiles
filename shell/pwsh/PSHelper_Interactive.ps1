# 本文件只在交互式 shell 中加载，向当前的 shell 环境中添加功能

# PoweShell 默认已经加载过了
# Import-Module -Name PSReadLine

# bootup oh-my-posh
# https://ohmyposh.dev/docs/installation/prompt
# 需要放在 PSReadLine 之后，才能启用 Transient Prompt
# 添加 --print 参数直达最终要执行的表达式，让 proxy 能工作
# Invoke-Expression $(oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\enihsyou.omp.toml" --print | Out-String)
# 现在替换成精简版的初始化脚本
# 下面的值被 PSHelper_OhMyPosh.ps1 直接引用
$env:POSH_THEME = "$HOME\.dotfiles\cli-app\oh-my-posh\enihsyou.omp.toml"
# . $env:DOTFILES\shell\pwsh\PSHelper_OhMyPosh.ps1
# version 26.24.0 之后有缓存了，直接加载速度相差 10ms 也还行，使用这个测速
# hyperfine 'pwsh -noprofile -c exit' 'pwsh -c exit'
oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\enihsyou.omp.toml" | Invoke-Expression

# 初始化 vfox
# https://vfox.dev/zh-hans/guides/quick-start.html
# 但是 '回滚' 脚本中对终端编码的修改
# https://github.com/version-fox/vfox/pull/117
# 暂时禁用，只用 vfox 的 shims 层
# try {
#     $origInputEncoding = [Console]::InputEncoding
#     $origOutputEncoding = [Console]::OutputEncoding
#     if (-not $env:__VFOX_PID) {
#         Invoke-Expression (vfox activate pwsh | Out-String)
#     }
# }
# finally {
#     [Console]::InputEncoding = $origInputEncoding
#     [Console]::OutputEncoding = $origOutputEncoding
#     Remove-Variable -Name origInputEncoding, origOutputEncoding
#     Remove-Variable -Name OutputEncoding -ErrorAction Ignore
# }

# 使用异步加载模块的方式来加速启动
$local:__asyncScript = {
    . "$env:DOTFILES\shell\pwsh\PSHelper_InteractiveAsync.ps1"
}

if ($env:VSCODE_INJECTION -or $env:TERM_PROGRAM -eq 'WarpTerminal') {
    # VSCode shell integration 脚本会重写 PSConsoleHostReadLine
    # 其实其他任何重写了这个函数都会导致 ProfileAsync 执行在
    # 非 Global Scope 中。目前遇到这问题只有放弃异步加载
    # 而且改了 PSConsoleHostReadLine 会导致在 VSCode 以外的环境
    # 加载 shellIntegration.ps1 无限死循环打印 prompt
    #
    # Warp Terminal 会触发 System.InvalidOperationException: Stack empty.
    # 错误瞬间暴毙
    . $__asyncScript
}
else {
    # 如果遇到 cmdlet not found 的错误，并且调大 Delay 也没有用
    # 比如如果不加载 oh-my-posh, 会提示 Get-Location 找不到
    # 那就在 Async 之前 Import-Module / 调用 cmdlet 来触发模块加载
    # 似乎因为在异步流程中向 ExecutionContext 加载的模块无法读取到
    # https://github.com/fsackur/ProfileAsync
    Import-Module $env:DOTFILES\shell\pwsh\Modules\ProfileAsync.psm1
    Import-ProfileAsync -Delay 200 $__asyncScript
}
Remove-Variable -Name __asyncScript
