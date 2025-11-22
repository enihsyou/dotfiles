# 本文件用于设置 PSReadLine 的选项和主题

#------------------------------- Set Hot-keys OPEN -------------------------------
# 注册 Emacs 键位绑定的函数
# 修改 EditMode 会重置 KeyHandler，切换模式后记得调用
function Register-PSReadLineEmacsKeyHandlers
{
    # 在 Emacs 模式下注册需要的键位绑定
    # 设置向上键为后向搜索历史记录
    Set-PSReadLineKeyHandler -Chord UpArrow -Function HistorySearchBackward
    # 设置向下键为前向搜索历史记录
    Set-PSReadLineKeyHandler -Chord DownArrow -Function HistorySearchForward
    # 默认是 AcceptLine，这里加个验证再执行
    Set-PSReadLineKeyHandler -Chord Enter -Function ValidateAndAcceptLine
    # explicit set Ctrl+v (lowercase) to make paste in VSCode works without holding Shift
    Set-PSReadLineKeyHandler -Chord Ctrl+v -Function Paste
    # Provides intuitive, Windows like cursor actions.
    Set-PSReadLineKeyHandler -Chord Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Chord F5 -ScriptBlock { Switch-PSReadLineEditMode }
    # when carapace is enabled, Tab should bind to MenuComplete instead of Complete
    # https://github.com/carapace-sh/carapace/issues/997
    Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
}

# 注册 Vi 键位绑定的函数
function Register-PSReadLineViKeyHandlers
{
    # Vi 模式下的键位绑定预留（按需添加）
    # 例如:
    # Set-PSReadLineKeyHandler -Chord <...> -Function <...>
    Set-PSReadLineKeyHandler -Chord F5 -ScriptBlock { Switch-PSReadLineEditMode }
}

# 切换 EditMode
function Switch-PSReadLineEditMode
{
    $currentMode = (Get-PSReadLineOption).EditMode
    if ($currentMode -eq 'Emacs')
    {
        Enter-PSReadLineEmacsMode
    } else
    {
        Enter-PSReadLineViMode
    }
}
#------------------------------- Set Hot-keys DONE -------------------------------

#------------------------------- Set Options OPEN -------------------------------

function Enter-PSReadLineEmacsMode
{
    Set-PSReadLineOption -EditMode Emacs
    Register-PSReadLineEmacsKeyHandlers
}

function Enter-PSReadLineViMode
{
    Set-PSReadLineOption -EditMode Vi
    Register-PSReadLineViKeyHandlers
}

if (-not ($env:TERM_PROGRAM -eq 'WarpTerminal' -and $env:PS_PROFILE_ASYNC -eq '1'))
{
    # WarpTerminal 和 ProfileAsync 有冲突，一旦设置了 EditMode 会把历史的最后一个命令
    # 作为当前命令行的内容，以看不见的方式插入到命令行中，在 Enter 执行时才会发现
    Enter-PSReadLineEmacsMode
}
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -TerminateOrphanedConsoleApps
# 使用 Ctrl+x Ctrl+e 调用 ViEditVisually 在编辑器里使用 Vim 模式修改当前命令
Set-PSReadLineOption -ViModeIndicator Cursor
#------------------------------- Set Options OPEN -------------------------------

#------------------------------- Set Themes OPEN -------------------------------

function Test-IsSystemLightTheme {
    <#
    .SYNOPSIS
        检测当前 Windows 系统是否处于“浅色应用模式”。
    .DESCRIPTION
        读取注册表 AppsUseLightTheme 键值。
        返回 $true 代表亮色模式，返回 $false 代表暗色模式（或检测失败）。
    #>
    try {
        $themePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        # ErrorAction Stop 确保如果键值不存在直接跳到 catch
        $themeData = Get-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -ErrorAction Stop

        # 1 代表亮色，0 代表暗色
        return $themeData.AppsUseLightTheme -eq 1
    } catch {
        # 如果读取失败（例如键值不存在），为了保护眼睛，默认认为不是亮色模式
        return $false
    }
}

# 环境变量来自 AutoDarkMode 应用的自定义脚本
if (Test-IsSystemLightTheme)
{
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
        Selection              = $PSStyle.Reverse # 让信息凸显，特别是与 carapace 配合
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
