@echo off
setlocal EnableExtensions
chcp 65001 >nul

if /i "%~1"=="--profile" exit /b 0

set "ROOT=%~dp0"
set "SCRIPT=%ROOT%utils\install-runtime.ps1"

if not exist "%SCRIPT%" (
    echo [ERROR] Runtime setup script is missing:
    echo %SCRIPT%
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
set "RESULT=%ERRORLEVEL%"

if /i not "%~1"=="--quiet" (
    echo.
    if not "%RESULT%"=="0" (
        echo Runtime setup failed. Review the error above.
    ) else (
        echo Runtime setup completed successfully.
    )
    pause
)
exit /b %RESULT%
