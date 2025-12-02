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
# 但神奇的是 ping 界面虽然是英文，但按 Ctrl+C 中断会输出中文

# 参考信息
# https://superuser.com/a/1558446/2170973
# https://github.com/PowerShell/PowerShell/issues/17523#issuecomment-1154271811
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding
# https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/vscode/understanding-file-encoding

# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# [Console]::InputEncoding = [System.Text.Encoding]::UTF8
# $PSDefaultParameterValues['*:Encoding'] = 'utf8'
# $OutputEncoding is default to UTF8 by now

# 下面这段是从 WindowsPowerShell\Microsoft.PowerShell_profile.ps1 复制过来的
# 设置字符集到 UTF-8 以支持 PATH 中包含中文
# https://stackoverflow.com/questions/57131654/using-utf-8-encoding-chcp-65001-in-command-prompt-windows-powershell-window
# 不过在 Windows 11 上可以启用 使用 Unicode UTF-8 作为代码页的 Beta 设置，这样就不用每次启动 PowerShell 时都设置了
# 但这样做会导致兼容性问题 比如 AIDA64 显示错误, 所以这里还是用老办法
# https://ohmyposh.dev/docs/faq#powershell-the-term-oh-my-poshexe-is-not-recognized-as-a-name-of-a-cmdlet
# 对应 chcp 65001

# 切换到 UTF-8 输出编码，避免 pipeline 乱码
function utf8 {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}
