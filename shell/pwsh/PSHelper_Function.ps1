# Deprecated: 建议使用 Install-Module Profiler, PSProfiler, hyperfine
# https://blog.danskingdom.com/Easily-profile-your-PowerShell-code-with-the-Profiler-module/
# https://devblogs.microsoft.com/powershell/optimizing-your-profile/

#--------------------------------- Helper Utility Functions OPEN -------------------------------

# 有需要就给导入模块计时
Function Proxy-Import-Module {
    $cmdToRun = $args
    if (-not $env:PROFILE_DEBUG) {
        Import-Module @cmdToRun
        return
    }

    $timeCost = Measure-Command -Expression {
        Import-Module @cmdToRun
    }
    Write-Host "Import-Module $cmdToRun in $($timeCost.TotalMilliseconds) ms"
}

# 调用时参数直接当字符串跟在后面，不要加括号
# Proxy-Invoke-Expression  vfox activate pwsh  是正确的
# Proxy-Invoke-Expression "vfox activate pwsh" 是可行的
# Proxy-Invoke-Expression (vfox activate pwsh) 是错误的
Function Proxy-Invoke-Expression {
    $cmdToRun = $args
    if (-not $env:PROFILE_DEBUG) {
        Invoke-Expression (Invoke-Expression "$cmdToRun" | Out-String)
        return
    }

    $timeCost = Measure-Command -Expression {
        Invoke-Expression (Invoke-Expression "$cmdToRun" | Out-String)
    }
    Write-Host "Invoke-Expression $cmdToRun in $($timeCost.TotalMilliseconds) ms"
}
#--------------------------------- Helper Utility Functions DONE -------------------------------
