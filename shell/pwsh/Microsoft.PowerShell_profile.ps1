# 给 Windows Terminal 写的 PowerShell 配置文件
# 适合 PowerShell 7.0 以上版本
# filepath: $([Environment]::GetFolderPath('MyDocuments'))\PowerShell\Microsoft.PowerShell_profile.ps1

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

# 去掉由 WindowsPowerShell 在系统环境变量种加入的模块路径，pwsh7 用不上这些，节约 16ms
# 如果实在需要可以单独启动 WindowsPowerShell 去使用那些列在这里的功能 https://learn.microsoft.com/en-us/powershell/windows/get-started
$Env:PSModulePath=@(
    $Env:PSModulePath -split ';' |
    Where-Object { $_ -notmatch 'WindowsPowerShell' }
) -Join ';'

# 设置终端字符集
# 文件目前没内容，注释掉少加载一个文件节约 2ms
#. $env:DOTFILES\shell\pwsh\PSHelper_Encoding.ps1
# 注入环境变量
. $env:DOTFILES\shell\pwsh\PSHelper_Environment.ps1
#------------------------------- Setup Runtime DONE -------------------------------


#------------------------------- Setup Interactive OPEN -------------------------------
# 这些是获取一个交互式终端最基础的设置，必须在 global session state 中执行

# PowerShell 会在 Interactive Session 中自动提前加载 PSReadLine 模块
# 只要自己不再加载一遍，就可以根据模块情况来确定是可交互终端
# 相比修改 global:prompt , 与 VSCode shell integration 兼容性更好
# 判断条件部分归功于 https://github.com/MatejKafka/PowerShellProfile
if ([runspace]::DefaultRunspace.InitialSessionState.Modules) {
    # 初始化交互终端用到的模块
    . $env:DOTFILES\shell\pwsh\PSHelper_Interactive.ps1
}
#------------------------------- Setup Interactive DONE -------------------------------
