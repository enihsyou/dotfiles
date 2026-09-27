# 本文件只设置别名；对应的函数由 Helper、Loader 和 Enhancement 脚本提供。

# some linux like alias
# which 和 touch 在 x-cmd 中有更好的实现，如果 source 了它会覆盖掉这里
Set-Alias -Name which -Value which_GetCommand_SourceOnly
Set-Alias -Name touch -Value New-Item
Set-Alias -Name open -Value explorer
Set-Alias -Name msys -Value ucrt64

# package managers
Set-Alias -Name np -Value pnpm
Set-Alias -Name brew -Value winget -Description "Alias to winget, for macOS users"

# HTTPie 启动耗时太慢，换成 Rust 版
Set-Alias -Name http -Value xh -Description "a Rust version of HTTPie"

# 删除默认指向 Where-Object 的别名，转而调用 where.exe
Remove-Alias -Name where -Force -ErrorAction Ignore

Set-Alias -Name lss -Value eza -Description "a modern replacement for ls"
