@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "PROFILE_FILE=%~1"
set "RUN_MODE=%~2"
for %%I in ("%~dp0..") do set "ROOT=%%~fI\"

if not exist "%PROFILE_FILE%" (
    echo [ERROR] Strategy file was not found.
    pause
    exit /b 1
)

set "PROFILE_TITLE="
set "PROFILE_DESCRIPTION="
set "PROFILE_ARGS="
set "PROFILE_NEEDS_AUTO_LUA=0"
set "PROFILE_NEEDS_LISTS=0"
set "PROFILE_NEEDS_IPSET=0"
call "%PROFILE_FILE%" --profile

if not defined PROFILE_ARGS (
    echo [ERROR] Could not load strategy parameters.
    pause
    exit /b 1
)

if not exist "%ROOT%bin\winws2.exe" (
    echo [ERROR] bin\winws2.exe is missing.
    echo Copy the contents of upstream zapret-winws into bin.
    pause
    exit /b 1
)

if /i not "%RUN_MODE%"=="--elevated" (
    fltmc >nul 2>&1
    if errorlevel 1 (
        echo Requesting administrator rights...
        powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/d /c \"\"%PROFILE_FILE%\" --elevated\"' -Verb RunAs"
        exit /b
    )
)

echo Starting: !PROFILE_TITLE!
start "!PROFILE_TITLE!" /min "%ROOT%bin\winws2.exe" !PROFILE_ARGS!
if errorlevel 1 (
    echo [ERROR] Failed to start winws2.exe.
    pause
    exit /b 1
)
exit /b 0
