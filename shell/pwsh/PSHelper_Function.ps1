# 本文件放置一些在 profile 中使用的函数，避免 profile 文件过长

# 还原 profile 修改 PSModulePath 前保存的值
Function Restore-PSModulePath {
    if (-not (Test-Path Variable:Global:__DotfilesOriginalPSModulePath)) {
        Write-Warning '没有找到 PSModulePath 的备份值。'
        return
    }

    $Env:PSModulePath = $global:__DotfilesOriginalPSModulePath
}
