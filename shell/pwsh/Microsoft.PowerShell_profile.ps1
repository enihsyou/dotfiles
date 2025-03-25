# 给 Windows Terminal 写的 PowerShell 配置文件

# if sourced by nektos/act, force UTF-8 and skip custom profile
# since its not possible to force -NoProfile for egor-tensin/vs-shell@v2 action
if ($env:ACT -eq 'true') {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    return
}

$env:DOTFILES = "$env:USERPROFILE\.dotfiles"

# 从 PowerShell 7.4 开始，重定向操作符 `>` 和 `| Out-File` 之间的行为出现差异
# 现在 `command > file` 会直接传递二进制数据，并以命令输出的原始编码（在中文系统上通常是 GBK）写入文件
# 不过 `command | Out-File file` 则会使用默认编码（即 utf8NoBOM）写入
# 想让管道工作，最好的办法是让输出程序以已知的编码输出，给输入程序指定编码

# 对于 `nslookup example.com | nali --gbk`
# 前面是 Windows 内建程序，会以 [Console]::OutputEncoding（GB2312）输出，后面需要指定以兼容编码读取

# 对于 `python -c "print('你好')" | Out-File file.txt`
# 前面默认会以系统编码输出（GB2312），后面则会以 UTF-8 写入
# 有三种方法可以让 Python 输出 UTF-8
# 1. python -X utf8
#    适合为单个命令临时设置
# 2. $env:PYTHONIOENCODING = 'utf-8'
#    python3.7 之前的版本用这个调整 stdout stdin 的编码
# 3. $env:PYTHONUTF8 = 1
#    新版本建议直接启用 UTF-8 模式，不再需要上面的，我添加到系统环境变量中了

# 对于 `jq -r` 会按原样输出，如果原文是 UTF-8 但终端环境是 936 则会乱码，此时需要
# 修改 OutputEncoding，但设置后如 ping, route 等系统命令会退回英文界面

# 参考信息
# https://superuser.com/a/1558446/2170973
# https://github.com/PowerShell/PowerShell/issues/17523#issuecomment-1154271811
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.5#changing-the-default-encoding
# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# [Console]::InputEncoding = [System.Text.Encoding]::UTF8
# $PSDefaultParameterValues['*:Encoding'] = 'utf8'
# $OutputEncoding is default to UTF8 by now


# f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module
Import-Module -Name Microsoft.WinGet.CommandNotFound
# f45873b3-b655-43a6-b217-97c00aa0db58

# https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1
# with some comment removed, refer to source file for more information
Import-Module -Name PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -TerminateOrphanedConsoleApps
Set-PSReadLineOption -ViModeIndicator Prompt
Set-PSReadLineKeyHandler -Chord UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Enter -Function ValidateAndAcceptLine
# explicit set Ctrl+v (lowercase) to make paste in VSCode works without holding Shift
Set-PSReadLineKeyHandler -Chord Ctrl+v -Function Paste

# 环境变量来自 AutoDarkMode 应用的自定义脚本
if ($env:AUTODARKMODE -eq 'light') {
    Set-PSReadLineOption -Colors @{
        #     Command                  = $PSStyle.Foreground.FromRGB(0x23974A)
        #     Comment                  = $PSStyle.Foreground.FromRGB(0x006400)
        ContinuationPrompt     = $PSStyle.Foreground.FromRGB(0x0000FF)
        Default                = $PSStyle.Foreground.FromRGB(0x383A42)
        #     Emphasis                 = $PSStyle.Foreground.FromRGB(0x287BF0)
        #     Error                    = $PSStyle.Foreground.FromRGB(0xD52753)
        #     InlinePrediction         = $PSStyle.Foreground.FromRGB(0x93A1A1)
        #     Keyword                  = $PSStyle.Foreground.FromRGB(0x00008b)
        #     ListPrediction           = $PSStyle.Foreground.FromRGB(0x2da44e)
        Member                 = $PSStyle.Foreground.FromRGB(0x362C24)
        Number                 = $PSStyle.Foreground.FromRGB(0x800080)
        Operator               = $PSStyle.Foreground.FromRGB(0x757575)
        Parameter              = $PSStyle.Foreground.FromRGB(0x000080)
        String                 = $PSStyle.Foreground.FromRGB(0x40826D)
        Type                   = $PSStyle.Foreground.FromRGB(0x008080)
        Variable               = $PSStyle.Foreground.FromRGB(0x0818A8)
        ListPredictionSelected = $PSStyle.Background.FromRGB(0x93A1A1)
        Selection              = $PSStyle.Background.FromRGB(0x275FE4)
    }
    # $PSStyle.Formatting.FormatAccent       = $PSStyle.Foreground.FromRgb(0x00FF00) 
    # $PSStyle.Formatting.TableHeader        = $PSStyle.Foreground.FromRgb(0x00FF00) 
    # $PSStyle.Formatting.ErrorAccent        = $PSStyle.Foreground.FromRgb(0x00FFFF) 
    # $PSStyle.Formatting.Error              = $PSStyle.Foreground.FromRgb(0xFF0000) 
    # $PSStyle.Formatting.Warning            = $PSStyle.Foreground.FromRgb(0xFFFF00) 
    # $PSStyle.Formatting.Verbose            = $PSStyle.Foreground.FromRgb(0xFFFF00) 
    # $PSStyle.Formatting.Debug              = $PSStyle.Foreground.FromRgb(0xFFFF00) 
    # $PSStyle.Progress.Style                = $PSStyle.Foreground.FromRgb(0xFFFF00) 
    
    $PSStyle.FileInfo.Directory = $PSStyle.Background.FromRgb(0x0F52BA) + $PSStyle.Foreground.FromRgb(0xE4E5ED)
    # $PSStyle.FileInfo.SymbolicLink         = $PSStyle.Foreground.FromRgb(0x00FFFF)
    # $PSStyle.FileInfo.Executable           = $PSStyle.Foreground.FromRgb(0xFF5FFF)
    # $PSStyle.FileInfo.Extension['.ps1']    = $PSStyle.Foreground.FromRgb(0x00FFFF)
    # $PSStyle.FileInfo.Extension['.psd1']   = $PSStyle.Foreground.FromRgb(0x00FFFF)
    # $PSStyle.FileInfo.Extension['.ps1xml'] = $PSStyle.Foreground.FromRgb(0x00FFFF)
    # $PSStyle.FileInfo.Extension['.psm1']   = $PSStyle.Foreground.FromRgb(0x00FFFF)
}


# bootup oh-my-posh
# 需要放在 PSReadLine 之后，以启用 Transient Prompt
# https://ohmyposh.dev/docs/installation/prompt
oh-my-posh init pwsh --config "~/.config/oh-my-posh/enihsyou.omp.toml" | Invoke-Expression

$env:HF_ENDPOINT = "https://hf-mirror.com"
$env:PAGER = 'less.exe'

Function which_GetCommand_SourceOnly {
    # similar to `which` in Linux
    param([string]$Name)
    $command = Get-Command -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }
    return ''
}
Function help_ShowWindow {
    # I'd like to see help content in a separate window
    param([string]$Name)
    Get-Help -ShowWindow -Name $Name
}
Set-Alias -Name which -Value which_GetCommand_SourceOnly
Set-Alias -Name help -Value help_ShowWindow
Set-Alias -Name open -Value explorer
Set-Alias -Name np -Value pnpm

# enable goup functionality on shell
# https://github.com/owenthereal/goup/
$env:PATH += ";$env:USERPROFILE\.go\current\bin"

# enable fnm functionality on shell
# https://github.com/Schniz/fnm?tab=readme-ov-file#powershell
Invoke-Expression (fnm env --shell powershell | Out-String)

# setup completions
# GitHub CLI https://cli.github.com/manual/gh_completion
Invoke-Expression (gh completion -s powershell | Out-String)
# fnm
Invoke-Expression (fnm completions --shell powershell | Out-String)
# goup
Invoke-Expression (goup completion powershell | Out-String)
