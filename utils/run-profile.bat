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

echo.
echo Checking required runtime files...
set /a MISSING=0

for %%F in (winws2.exe WinDivert.dll WinDivert64.sys cygwin1.dll) do (
    if not exist "%ROOT%bin\%%F" (
        echo [MISSING] bin\%%F
        set /a MISSING+=1
    )
)

for %%F in (zapret-lib.lua zapret-antidpi.lua) do (
    if not exist "%ROOT%bin\lua\%%F" (
        echo [MISSING] bin\lua\%%F
        set /a MISSING+=1
    )
)

if "!PROFILE_NEEDS_AUTO_LUA!"=="1" (
    if not exist "%ROOT%bin\lua\zapret-auto.lua" (
        echo [MISSING] bin\lua\zapret-auto.lua
        set /a MISSING+=1
    )
)

if "!PROFILE_NEEDS_LISTS!"=="1" (
    for %%F in (list-general.txt list-general-user.txt list-google.txt list-exclude.txt list-exclude-user.txt ipset-exclude.txt ipset-exclude-user.txt) do (
        if not exist "%ROOT%lists\%%F" (
            echo [MISSING] lists\%%F
            set /a MISSING+=1
        )
    )
)

if "!PROFILE_NEEDS_IPSET!"=="1" (
    for %%F in (ipset-all.txt ipset-exclude.txt ipset-exclude-user.txt) do (
        if not exist "%ROOT%lists\%%F" (
            echo [MISSING] lists\%%F
            set /a MISSING+=1
        )
    )
)

if not exist "%ROOT%bin\files\quic_initial_www_google_com.bin" (
    echo [MISSING] bin\files\quic_initial_www_google_com.bin
    set /a MISSING+=1
)

for %%F in (discord_media stun wireguard quic_initial_ietf) do (
    if not exist "%ROOT%bin\windivert.filter\windivert_part.%%F.txt" (
        echo [MISSING] bin\windivert.filter\windivert_part.%%F.txt
        set /a MISSING+=1
    )
)

if not "!MISSING!"=="0" (
    echo.
    echo Missing required files: !MISSING!
    echo Copy the contents of upstream zapret-winws into this repository's bin folder.
    pause
    exit /b 1
)

tasklist /FI "IMAGENAME eq winws2.exe" | find /I "winws2.exe" >nul
if not errorlevel 1 (
    echo.
    echo [ERROR] winws2.exe is already running.
    echo Stop the existing standalone process or Zapret2WinBundle service first.
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
