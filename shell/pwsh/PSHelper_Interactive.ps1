# 本文件只在交互式 shell 中加载，向当前的 shell 环境中添加功能

# PoweShell 默认已经加载过了
# Import-Module -Name PSReadLine

# bootup oh-my-posh
# https://ohmyposh.dev/docs/installation/prompt
# 需要放在 PSReadLine 之后，才能启用 Transient Prompt
# 添加 --print 参数直达最终要执行的表达式，让 proxy 能工作
# Invoke-Expression $(oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\enihsyou.omp.toml" --print | Out-String)
# 现在替换成精简版的初始化脚本
. $env:DOTFILES\shell\pwsh\PSHelper_OhMyPosh.ps1

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

$AsyncProfile = {
    . $env:DOTFILES\shell\pwsh\PSHelper_Alias.ps1
    . $env:DOTFILES\shell\pwsh\PSHelper_Completion.ps1
    . $env:DOTFILES\shell\pwsh\PSHelper_PSReadLine.ps1

    # #f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
    Import-Module -Name Microsoft.WinGet.CommandNotFound
    # #f45873b3-b655-43a6-b217-97c00aa0db58
}

# 使用异步加载模块的方式来加速启动
# https://github.com/fsackur/ProfileAsync
if (Import-Module ProfileAsync -PassThru -ea Ignore) {
    Import-ProfileAsync $AsyncProfile
} else {
    . $AsyncProfile
}
