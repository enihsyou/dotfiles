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
$env:POSH_THEME = "$HOME\.config\oh-my-posh\enihsyou.omp.toml"
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

# 使用异步加载模块的方式来加速启动
# https://github.com/fsackur/ProfileAsync
Import-Module $env:DOTFILES\shell\pwsh\Modules\ProfileAsync.psm1
Import-ProfileAsync -Delay 200 {
    . "$env:DOTFILES\shell\pwsh\PSHelper_InteractiveAsync.ps1"
}
