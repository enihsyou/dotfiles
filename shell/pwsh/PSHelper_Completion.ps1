# 本文件用于设置 PowerShell 的命令行补全

#------------------------------- Set Completion OPEN ---------------------------
#$env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
# 使用 Ctrl+Spacebar (MenuComplete) 触发
# 跳过设置 PATH 的第一行，它的生成了错误的内容，没有指向 winget 目录
carapace _carapace | Select-Object -Skip 1 | Out-String | Invoke-Expression
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
