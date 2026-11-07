@echo off
setlocal EnableExtensions
chcp 65001 >nul

set "ROOT=%~dp0"
set "SCRIPT=%ROOT%utils\setup-runtime.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] Runtime setup script is missing:
    echo         %SCRIPT%
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RESULT=%ERRORLEVEL%"

echo.
if not "%RESULT%"=="0" (
    echo Runtime setup failed. Review the error above.
) else (
    echo Runtime setup completed.
)

pause
exit /b %RESULT%
