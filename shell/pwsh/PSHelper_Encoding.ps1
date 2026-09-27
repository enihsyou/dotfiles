# 当前结论：不在 profile 中全局切换 UTF-8，只在需要时调用 utf8。
# 全局修改 Console.OutputEncoding 会让 jq 等 UTF-8 工具正常显示，但 ping、route
# 等 Windows 程序可能切换到英文输出，因此保留系统默认代码页更兼容。
#
# 探索记录：
# - PowerShell 7.4 起，原生命令使用 `>` 时保留其字节流；`| Out-File` 仍按
#   PowerShell 的默认编码（utf8NoBOM）写入。
# - `nslookup example.com | nali --gbk` 这类管道需要让后一个程序按 Windows
#   内建程序的输出编码读取。
# - Python 可临时使用 `-X utf8`；旧版本可用 PYTHONIOENCODING，新版本推荐
#   PYTHONUTF8。本机已在系统环境变量中启用 PYTHONUTF8。
# - jq 的原始 UTF-8 输出在代码页 936 下可能乱码，此时再临时调用 utf8。
#
# 参考：
# https://superuser.com/a/1558446/2170973
# https://github.com/PowerShell/PowerShell/issues/17523#issuecomment-1154271811
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding
# https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/vscode/understanding-file-encoding

# 切换到 UTF-8 输出编码，避免 pipeline 乱码
function utf8 {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}
