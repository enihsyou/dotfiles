# 本文件用于设置 PowerShell 的命令行补全

#------------------------------- Set Completion OPEN ---------------------------
# 无法补全 ~ 路径是 bug，一种方式是把会传路径的常用工具排除掉
# $env:CARAPACE_EXCLUDES = 'code,vim'
# 但目前以 fork + patch 的方式解决 https://github.com/enihsyou/carapace
carapace _carapace | Out-String | Invoke-Expression
# As carapace have battery included, so things like gh, rg, pnpm, task and winget do not need separate setup.
# listed in https://carapace-sh.github.io/carapace-bin/completers.html
#------------------------------- Set Completion DONE ---------------------------
