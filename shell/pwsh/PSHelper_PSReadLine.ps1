# 本文件用于设置 PSReadLine 的选项和主题

#------------------------------- Set Options OPEN -------------------------------

if (-not ($env:TERM_PROGRAM -eq 'WarpTerminal' -and $env:PS_PROFILE_ASYNC -eq '1')) {
    # WarpTerminal 和 ProfileAsync 有冲突，一旦设置了 EditMode 会把历史的最后一个命令
    # 作为当前命令行的内容，以看不见的方式插入到命令行中，在 Enter 执行时才会发现
    Set-PSReadLineOption -EditMode Emacs
}
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -TerminateOrphanedConsoleApps
# 使用 Ctrl+x Ctrl+e 调用 ViEditVisually 在编辑器里使用 Vim 模式修改当前命令
Set-PSReadLineOption -ViModeIndicator Cursor
#------------------------------- Set Options OPEN -------------------------------


#------------------------------- Set Hot-keys OPEN -------------------------------
# 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Chord UpArrow -Function HistorySearchBackward
# 设置向下键为前向搜索历史记录
Set-PSReadLineKeyHandler -Chord DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Enter -Function ValidateAndAcceptLine
# explicit set Ctrl+v (lowercase) to make paste in VSCode works without holding Shift
Set-PSReadLineKeyHandler -Chord Ctrl+v -Function Paste
# Provides intuitive, Windows like cursor actions.
Set-PSReadLineKeyHandler -Chord Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord
#------------------------------- Set Hot-keys DONE -------------------------------


#------------------------------- Set Themes OPEN -------------------------------
# 环境变量来自 AutoDarkMode 应用的自定义脚本
if ($env:AUTODARKMODE -eq 'light') {
    Set-PSReadLineOption -Colors @{
        #     Command                  = $PSStyle.Foreground.FromRGB(0x23974A)
        #     Comment                  = $PSStyle.Foreground.FromRGB(0x006400)
        ContinuationPrompt     = $PSStyle.Foreground.FromRGB(0x808080)
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
#------------------------------- Set Themes DONE -------------------------------
