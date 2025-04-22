# 给 Windows Terminal 写的 PowerShell 配置文件
# 适合 PowerShell 7.0 以上版本

# 关于如何优化，这里贴一些文章
# 只在交互式终端中加载 oh-my-posh 等重模块，同时教你使用 PSProfiler 来分析瓶颈点
# https://devblogs.microsoft.com/powershell/optimizing-your-profile/
# 异步加载模块到全局 SessionState
# https://www.reddit.com/r/PowerShell/comments/180cp1y/how_i_got_my_profile_to_load_in_100ms_with/
# 教你使用 Profiler 来分析瓶颈点
# https://blog.danskingdom.com/Easily-profile-your-PowerShell-code-with-the-Profiler-module/

#------------------------------- Setup Early Exit OPEN -------------------------------
# 这里是特殊运行环境跳过加载的设置

# if sourced by nektos/act, force UTF-8 and skip custom profile
# since its not possible to force -NoProfile for egor-tensin/vs-shell@v2 action
if ($env:ACT -eq 'true') {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    return
}
#------------------------------- Setup Early Exit DONE -------------------------------

#------------------------------- Setup Runtime OPEN -------------------------------
# 这些是所有会话都需要的设置

# 个人配置保存在这个目录，脚本以这为基础
$env:DOTFILES = "$HOME\.dotfiles"

# 设置终端字符集
. $env:DOTFILES\shell\pwsh\PSHelper_Encoding.ps1
# 注入环境变量
. $env:DOTFILES\shell\pwsh\PSHelper_Environment.ps1
#------------------------------- Setup Runtime DONE -------------------------------


#------------------------------- Setup Interactive OPEN -------------------------------
# 这些是获取一个交互式终端最基础的设置，必须在 global session state 中执行

$script:_pwshInteractive = $false
function prompt {
    if ($script:_pwshInteractive) {
        return
    }
    # 被 PSHelper_OhMyPosh.ps1 直接引用，加速加载过程
    $env:POSH_THEME = "$HOME\.config\oh-my-posh\enihsyou.omp.toml"
    $script:_ompExecutable = "$HOME\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe"
    $script:_pwshInteractive = $true

    # 初始化交互终端用到的模块
    . $env:DOTFILES\shell\pwsh\PSHelper_Interactive.ps1

    # 调用由 oh-my-posh 重写的函数
    prompt
}
#------------------------------- Setup Interactive DONE -------------------------------
