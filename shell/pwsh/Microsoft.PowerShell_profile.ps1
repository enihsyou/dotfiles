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
#
# 性能测速：在未设置 PWSH_PROFILE_FORCE_INTERACTIVE 的 PowerShell 中运行。
# hyperfine --warmup=5 `
#   'pwsh -NoLogo -NonInteractive -NoProfile -Command exit' `
#   'pwsh -NoLogo -NonInteractive -Command exit' `
#   'set PWSH_PROFILE_FORCE_INTERACTIVE=1&&pwsh -NoLogo -NonInteractive -Command exit'
# 三项依次测量无 profile、默认非交互分支、用 cmd 的 set 强制加载交互配置分支。
# 这里测的是整个子进程耗时；强制加载不会让 -Command 会话变成真正的交互终端，
# 因而不包含交互终端预加载 PSReadLine、绘制提示符等耗时；异步脚本也可能尚未执行完。
# 2026-09-27 hyperfine 结果（依次对应上面三条命令；耗时单位 ms）：
#   路径               平均值 ± 标准差     最小值–最大值     次数    CPU User/System
#   无 profile         214.9 ± 8.0       209.0–233.3        13      178.7/119.8
#   默认非交互分支     375.3 ± 9.7       366.3–398.1        10      317.5/168.8
#   强制交互配置分支   727.3 ± 8.3       710.6–734.2        10      545.6/301.6
# 无 profile 分别比默认非交互分支、强制交互配置分支快 1.75 ± 0.08、3.38 ± 0.13 倍。
#
# 2026-09-27 交互式 pwsh 分段计时（PowerShell 7.6.6，伪终端，Stopwatch.GetTimestamp）：
# 临时将同一批模块改为同步加载时，profile 结束耗时 665–680 ms；
# 使用 ProfileAsync 时为 346–364 ms，同步阻塞缩短约 301–334 ms（约 45–49%）。
# 异步模块全部完成发生在 profile 开始后 923–941 ms，其中包含 200 ms 异步延迟。
# 异步路径各阶段耗时（ms，取多次启动的范围）：
#   profile 前段（含 PSModulePath 过滤）44–52；环境设置 10–12；oh-my-posh 197–217；
#   ProfileAsync 导入及派发 83–86；Encoding/Function/Helper/Loader/Enhancement/Alias 合计 35–38；
#   Carapace 158–162；PSReadLine 设置 24–26；zoxide 29–30；
#   Microsoft.WinGet.CommandNotFound 118–123。
# 上述计时始于 profile 脚本内，不包含进程创建和首个提示符绘制；异步阶段可与终端使用重叠。

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
# 只在首次加载 profile 时保存，避免重复加载时把已经过滤过的值覆盖掉
if (-not (Test-Path Variable:Global:__DotfilesOriginalPSModulePath)) {
    $global:__DotfilesOriginalPSModulePath = $Env:PSModulePath
}

$Env:PSModulePath = ($Env:PSModulePath -split ';').Where({ $_ -notmatch 'WindowsPowerShell' }) -join ';'

# 注入环境变量
. $env:DOTFILES\shell\pwsh\PSHelper_Environment.ps1
#------------------------------- Setup Runtime DONE -------------------------------


#------------------------------- Setup Interactive OPEN -------------------------------
# 这些是获取一个交互式终端最基础的设置，必须在 global session state 中执行

# PowerShell 会在 Interactive Session 中自动提前加载 PSReadLine 模块
# 只要自己不再加载一遍，就可以根据模块情况来确定是可交互终端
# 相比修改 global:prompt , 与 VSCode shell integration 兼容性更好
# 判断条件部分归功于 https://github.com/MatejKafka/PowerShellProfile
# 测速时可用环境变量强制非交互命令加载此分支
if ([runspace]::DefaultRunspace.InitialSessionState.Modules -or $env:PWSH_PROFILE_FORCE_INTERACTIVE -eq '1') {
    # 初始化交互终端用到的模块
    . $env:DOTFILES\shell\pwsh\PSHelper_Interactive.ps1
}
#------------------------------- Setup Interactive DONE -------------------------------
