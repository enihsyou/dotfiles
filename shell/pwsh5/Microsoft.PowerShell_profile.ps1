# NOTE: 这个文件是给 Windows Powershell 5.1 用的，PowerShell 7+ 不需要这个
# 只包含 PowerShell 7+ 中在 Windows PowerShell 5.1 中的配置，所以没什么注释
# filepath: $([Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -ViModeIndicator Prompt
Set-PSReadLineKeyHandler -Chord UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Enter -Function ValidateAndAcceptLine
Set-PSReadLineKeyHandler -Chord Ctrl+v -Function Paste
Set-PSReadLineKeyHandler -Chord Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord

# 环境变量来自 AutoDarkMode 应用的自定义脚本
if ($env:AUTODARKMODE -eq 'light') {
    Set-PSReadLineOption -Colors @{
        ContinuationPrompt = "#0000FF"
        Default            = "#383A42"
        Member             = "#362C24"
        Number             = "#800080"
        Operator           = "#757575"
        Parameter          = "#000080"
        String             = "#40826D"
        Type               = "#008080"
        Variable           = "#0818A8"
    }
}

$env:DOTFILES = "$env:USERPROFILE\.dotfiles"
$env:HF_ENDPOINT = "https://hf-mirror.com"
$env:PAGER = 'less.exe'

# oh-my-posh init pwsh --config "$HOME/.config/oh-my-posh/enihsyou.omp.toml" | Invoke-Expression
$env:POSH_THEME = "$HOME\.config\oh-my-posh\enihsyou.omp.toml"
. $env:DOTFILES\shell\pwsh\PSHelper_OhMyPosh.ps1

if (Test-Path "$HOME\.x-cmd.root\local\data\pwsh\_index.ps1") {
    . "$HOME\.x-cmd.root\local\data\pwsh\_index.ps1"
}; # boot up x-cmd.
