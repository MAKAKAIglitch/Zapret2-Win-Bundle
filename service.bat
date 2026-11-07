@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "ROOT=%~dp0"
set "BIN=%ROOT%bin"
set "LISTS=%ROOT%lists"
set "STATE=%ROOT%data\selected-profile.txt"
set "ENGINE=%BIN%\winws2.exe"
set "SERVICE_NAME=Zapret2WinBundle"
set "SERVICE_DISPLAY=Zapret 2 Win Bundle"
set "SELECTED_PROFILE=general (AUTO).bat"

if exist "%STATE%" set /p "SELECTED_PROFILE="<"%STATE%"
if not exist "%ROOT%%SELECTED_PROFILE%" set "SELECTED_PROFILE=general (AUTO).bat"

if /i not "%~1"=="--admin" (
    fltmc >nul 2>&1
    if errorlevel 1 (
        echo Requesting administrator rights...
        powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/d /c \"\"%~f0\" --admin\"' -Verb RunAs"
        exit /b
    )
)

:menu
call :load_profile
call :service_state
cls
title Zapret 2 Win Bundle - Service Manager

echo.
echo  ============================================================
echo                    ZAPRET 2 WIN BUNDLE
echo                      SERVICE MANAGER
echo  ============================================================
echo.
echo    Service:    %SERVICE_NAME%
echo    Status:     !SERVICE_STATUS!
echo    Profile:    !PROFILE_TITLE!
echo.
echo  ------------------------------------------------------------
echo    1. Select strategy
echo    2. Install / update service
echo    3. Start service
echo    4. Stop service
echo    5. Remove service
echo    6. Check runtime and lists
echo.
echo    0. Exit
echo  ------------------------------------------------------------
echo.
set "CHOICE="
set /p "CHOICE=   Select option: "

if "!CHOICE!"=="1" (
    call :select_profile
    goto menu
)
if "!CHOICE!"=="2" (
    call :install_service
    goto menu
)
if "!CHOICE!"=="3" (
    call :start_service
    goto menu
)
if "!CHOICE!"=="4" (
    call :stop_service
    goto menu
)
if "!CHOICE!"=="5" (
    call :remove_service
    goto menu
)
if "!CHOICE!"=="6" (
    call :check_runtime
    pause
    goto menu
)
if "!CHOICE!"=="0" exit /b 0

echo Invalid option.
timeout /t 2 >nul
goto menu


:load_profile
set "PROFILE_TITLE="
set "PROFILE_DESCRIPTION="
set "PROFILE_ARGS="
set "PROFILE_NEEDS_AUTO_LUA=0"
set "PROFILE_NEEDS_LISTS=0"
set "PROFILE_NEEDS_IPSET=0"
call "%ROOT%%SELECTED_PROFILE%" --profile
if not defined PROFILE_ARGS set "PROFILE_TITLE=Profile load error"
exit /b 0


:service_state
set "SERVICE_STATUS=NOT INSTALLED"
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if not errorlevel 1 (
    set "SERVICE_STATUS=STOPPED"
    for /f "tokens=3 delims=: " %%S in ('sc.exe query "%SERVICE_NAME%" ^| findstr /i "STATE"') do set "SERVICE_STATUS=%%S"
)
exit /b 0


:select_profile
cls
echo.
echo  ================== AVAILABLE STRATEGIES ==================
echo.
set /a COUNT=0

for %%F in ("%ROOT%*.bat") do (
    if /i not "%%~nxF"=="service.bat" (
        set "PROFILE_TITLE="
        set "PROFILE_DESCRIPTION="
        set "PROFILE_ARGS="
        set "PROFILE_NEEDS_AUTO_LUA=0"
        set "PROFILE_NEEDS_LISTS=0"
        set "PROFILE_NEEDS_IPSET=0"
        call "%%~fF" --profile
        if defined PROFILE_ARGS (
            set /a COUNT+=1
            set "PROFILE_FILE_!COUNT!=%%~nxF"
            echo    !COUNT!. !PROFILE_TITLE!
            if defined PROFILE_DESCRIPTION echo       !PROFILE_DESCRIPTION!
        )
    )
)

echo.
echo    0. Back
echo.
if "!COUNT!"=="0" (
    echo No strategy files were found in the repository root.
    pause
    exit /b 1
)

set "PICK="
set /p "PICK=Choose strategy: "
if "!PICK!"=="0" exit /b 0

set "NEW_PROFILE="
for /l %%N in (1,1,!COUNT!) do (
    if "!PICK!"=="%%N" set "NEW_PROFILE=!PROFILE_FILE_%%N!"
)

if not defined NEW_PROFILE (
    echo Invalid selection.
    pause
    exit /b 1
)

set "SELECTED_PROFILE=!NEW_PROFILE!"
if not exist "%ROOT%data" mkdir "%ROOT%data" >nul 2>&1
> "%STATE%" echo !SELECTED_PROFILE!
call :load_profile
echo.
echo Selected: !PROFILE_TITLE!
pause
exit /b 0


:check_runtime
call :load_profile
echo.
echo Checking Zapret 2 runtime...
echo.
set /a MISSING=0

for %%F in (winws2.exe WinDivert.dll WinDivert64.sys cygwin1.dll) do (
    if not exist "%BIN%\%%F" (
        echo [MISSING] bin\%%F
        set /a MISSING+=1
    ) else (
        echo [OK] bin\%%F
    )
)

for %%F in (zapret-lib.lua zapret-antidpi.lua) do (
    if not exist "%BIN%\lua\%%F" (
        echo [MISSING] bin\lua\%%F
        set /a MISSING+=1
    ) else (
        echo [OK] bin\lua\%%F
    )
)

if "!PROFILE_NEEDS_AUTO_LUA!"=="1" (
    if not exist "%BIN%\lua\zapret-auto.lua" (
        echo [MISSING] bin\lua\zapret-auto.lua
        set /a MISSING+=1
    ) else (
        echo [OK] bin\lua\zapret-auto.lua
    )
)

if "!PROFILE_NEEDS_LISTS!"=="1" (
    for %%F in (list-general.txt list-general-user.txt list-google.txt list-exclude.txt list-exclude-user.txt ipset-exclude.txt ipset-exclude-user.txt) do (
        if not exist "%LISTS%\%%F" (
            echo [MISSING] lists\%%F
            set /a MISSING+=1
        ) else (
            echo [OK] lists\%%F
        )
    )
)

if "!PROFILE_NEEDS_IPSET!"=="1" (
    if not exist "%LISTS%\ipset-all.txt" (
        echo [MISSING] lists\ipset-all.txt
        set /a MISSING+=1
    ) else (
        echo [OK] lists\ipset-all.txt
    )
)

if not exist "%BIN%\files\quic_initial_www_google_com.bin" (
    echo [MISSING] bin\files\quic_initial_www_google_com.bin
    set /a MISSING+=1
) else (
    echo [OK] bin\files\quic_initial_www_google_com.bin
)

for %%F in (discord_media stun wireguard quic_initial_ietf) do (
    if not exist "%BIN%\windivert.filter\windivert_part.%%F.txt" (
        echo [MISSING] bin\windivert.filter\windivert_part.%%F.txt
        set /a MISSING+=1
    ) else (
        echo [OK] bin\windivert.filter\windivert_part.%%F.txt
    )
)

echo.
if "!MISSING!"=="0" (
    echo All required files for the selected profile are present.
    exit /b 0
)
echo Missing files: !MISSING!
echo Copy the contents of upstream zapret-winws into this repository's bin folder.
exit /b 1


:install_service
call :load_profile
if not defined PROFILE_ARGS (
    echo Profile could not be loaded.
    pause
    exit /b 1
)
call :check_runtime
if errorlevel 1 (
    pause
    exit /b 1
)

echo.
echo Service:  %SERVICE_NAME%
echo Profile:  !PROFILE_TITLE!
echo Startup:  Automatic with Windows
echo.
echo Zapret 2 Windows service mode is experimental in the upstream bundle.
echo Installation will replace only this project's dedicated service.
echo.
set "CONFIRM="
set /p "CONFIRM=Type INSTALL to continue: "
if /i not "!CONFIRM!"=="INSTALL" (
    echo Installation cancelled.
    pause
    exit /b 0
)

sc.exe query "%SERVICE_NAME%" >nul 2>&1
if not errorlevel 1 (
    sc.exe stop "%SERVICE_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
    sc.exe delete "%SERVICE_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo.
echo Creating service...
sc.exe create "%SERVICE_NAME%" binPath= "\"%ENGINE%\" !PROFILE_ARGS!" DisplayName= "%SERVICE_DISPLAY%" start= auto
if errorlevel 1 (
    echo [ERROR] Service creation failed.
    pause
    exit /b 1
)
sc.exe description "%SERVICE_NAME%" "Zapret 2 Win Bundle"
echo.
echo Starting service...
sc.exe start "%SERVICE_NAME%"
echo.
pause
exit /b 0


:start_service
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
    echo Service is not installed. Install it first.
) else (
    sc.exe start "%SERVICE_NAME%"
)
echo.
pause
exit /b 0


:stop_service
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
    echo Service is not installed.
) else (
    sc.exe stop "%SERVICE_NAME%"
)
echo.
pause
exit /b 0


:remove_service
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
    echo Service is not installed.
    pause
    exit /b 0
)
echo.
set "CONFIRM="
set /p "CONFIRM=Type REMOVE to delete this project's service: "
if /i not "!CONFIRM!"=="REMOVE" (
    echo Removal cancelled.
    pause
    exit /b 0
)
sc.exe stop "%SERVICE_NAME%" >nul 2>&1
timeout /t 2 /nobreak >nul
sc.exe delete "%SERVICE_NAME%"
echo.
pause
exit /b 0
