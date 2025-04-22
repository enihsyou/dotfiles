@REM 切换全拼/双拼
@REM 来自 https://answers.microsoft.com/zh-hans/windows/forum/all/%E5%BE%AE%E8%BD%AF%E6%8B%BC%E9%9F%B3%E8%BE%93/9d516d61-98d6-42d3-bda9-5980e56fec43
@REM 需要保存为 GB18030 编码并以 CRLF 换行的文本文件，避免 msg 乱码
@echo off

set Mainkey=HKCU\SOFTWARE\Microsoft\InputMethod\Settings\CHS
set KeyName=Enable Double Pinyin

for /f %%i in ('reg query "%MainKey%" /v "%KeyName%" ^| findstr /i "0x1"') do (set flg=%%i)
if not defined flg (
    set flg=0x1
    set other=双拼
) else (
    set flg=0x0
    set other=全拼
)

reg add "%MainKey%" /v "%KeyName%" /t REG_DWORD /d %flg% /f >nul
echo.
echo.
echo  ========================================================
echo.
echo                       已经切换到 %other%
echo.
echo  ========================================================
echo.
echo   窗口将在 2 秒后自动关闭...
echo.
timeout /t 2 >nul
