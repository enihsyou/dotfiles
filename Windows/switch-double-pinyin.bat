@REM 切换全拼/双拼
@REM 来自 https://answers.microsoft.com/zh-hans/windows/forum/all/%E5%BE%AE%E8%BD%AF%E6%8B%BC%E9%9F%B3%E8%BE%93/9d516d61-98d6-42d3-bda9-5980e56fec43
@REM 需要保存为 GB18030 编码的文本文件，避免 msg 乱码
@echo off

set Mainkey=HKCU\SOFTWARE\Microsoft\InputMethod\Settings\CHS
for /f %%i in ('reg query %MainKey% /v "Enable Double Pinyin" ^| findstr /i "0x1"') do (set flg=%%i)
if not defined flg (
    reg add %MainKey% /v "Enable Double Pinyin" /t REG_DWORD /d 0x1 /f
    echo 已经切换到双拼
    (echo 已经切换到双拼
    echo 2秒后自动关闭)|msg %username% /time:2
) else (
    reg add %MainKey% /v "Enable Double Pinyin" /t REG_DWORD /d 0x0 /f
    (echo 已经切换到全拼
    echo 2秒后自动关闭)|msg %username% /time:2
)