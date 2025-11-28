@echo off
chcp 65001 >nul
echo 正在运行脚本...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0B.ps1"

if %errorlevel% neq 0 (
    echo.
    echo [错误] 脚本执行出错，错误代码: %errorlevel%
    pause
    exit /b %errorlevel%
)

echo.
echo 脚本执行完毕！
pause