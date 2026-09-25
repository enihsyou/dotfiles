# 本文件用于设置 PowerShell 的命令行补全

#------------------------------- Set Completion OPEN ---------------------------
# 无法补全 ~ 路径是 bug，一种方式是把会传路径的常用工具排除掉
# $env:CARAPACE_EXCLUDES = 'code,vim'
# 但目前以 fork + patch 的方式解决 https://github.com/enihsyou/carapace
carapace _carapace | Out-String | Invoke-Expression
# As carapace have battery included, so things like gh, rg, pnpm, task is not needed to setup again.
# listed in https://carapace-sh.github.io/carapace-bin/completers.html
#------------------------------- Set Completion DONE ---------------------------

# https://github.com/microsoft/winget-cli/blob/master/doc/Completion.md
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
