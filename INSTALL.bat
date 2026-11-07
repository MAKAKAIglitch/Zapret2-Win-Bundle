@echo off
setlocal EnableExtensions
chcp 65001 >nul

if /i "%~1"=="--profile" exit /b 0

set "ROOT=%~dp0"
set "INSTALLER=%ROOT%utils\install-runtime.ps1"

if not exist "%INSTALLER%" (
    echo [ERROR] Runtime installer is missing:
    echo %INSTALLER%
    pause
    exit /b 1
)

echo.
echo Zapret 2 Win Bundle - runtime setup
echo Downloads only required files from the official upstream repository.
echo Every file is hash-verified before it is installed.
echo No executable is launched during this setup.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%INSTALLER%"
set "RESULT=%ERRORLEVEL%"

echo.
if not "%RESULT%"=="0" (
    echo [ERROR] Runtime setup failed. See the message above.
    pause
    exit /b %RESULT%
)

echo Runtime is ready.
echo Run service.bat as Administrator to manage Zapret 2.
pause
exit /b 0
