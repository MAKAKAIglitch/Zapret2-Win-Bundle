@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "ROOT=%~dp0"
set "BIN_DIR=%ROOT%bin"
set "ENGINE=%BIN_DIR%\winws2.exe"
set "STRATEGY_DIR=%ROOT%strategies"
set "SERVICE_NAME=Zapret2WinBundle"
set "SERVICE_DISPLAY=Zapret 2 Win Bundle"
set "PROFILE_STATE=%ROOT%data\selected-profile.txt"
set "SELECTED_PROFILE=general.strategy.cmd"
if exist "%PROFILE_STATE%" set /p "SELECTED_PROFILE="<"%PROFILE_STATE%"
if not exist "%STRATEGY_DIR%\%SELECTED_PROFILE%" set "SELECTED_PROFILE=general.strategy.cmd"

rem The service manager needs elevated rights for Windows service operations.
if /i not "%~1"=="--elevated" (
    fltmc >nul 2>&1
    if errorlevel 1 (
        echo Запрашиваются права администратора...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -Verb RunAs -ArgumentList '/d /c ""%~f0"" --elevated'"
        exit /b
    )
)

:menu
call :load_profile
call :get_service_state
cls
title Zapret 2 Win Bundle - Service Manager

echo.
echo  ==================================================
echo                 ZAPRET 2 WIN BUNDLE
echo                   SERVICE MANAGER
echo  ==================================================
echo.
echo    Служба:        %SERVICE_NAME%
echo    Статус:        !SERVICE_STATE!
echo    Для установки: !PROFILE_TITLE!
echo.
echo  --------------------------------------------------
echo    1. Выбрать стратегию
echo    2. Установить / обновить службу
echo    3. Запустить службу
echo    4. Остановить службу
echo    5. Удалить службу
echo    6. Проверить компоненты
echo.
echo    0. Выход
echo  --------------------------------------------------
echo.
set "MENU_CHOICE="
set /p "MENU_CHOICE=   Выберите действие: "

if "!MENU_CHOICE!"=="1" (
    call :select_strategy
    goto menu
)
if "!MENU_CHOICE!"=="2" (
    call :install_service
    goto menu
)
if "!MENU_CHOICE!"=="3" (
    call :start_service
    goto menu
)
if "!MENU_CHOICE!"=="4" (
    call :stop_service
    goto menu
)
if "!MENU_CHOICE!"=="5" (
    call :remove_service
    goto menu
)
if "!MENU_CHOICE!"=="6" (
    call :check_components
    pause
    goto menu
)
if "!MENU_CHOICE!"=="0" exit /b 0

echo.
echo Неверный пункт меню.
timeout /t 2 >nul
goto menu


:load_profile
set "PROFILE_TITLE="
set "PROFILE_DESCRIPTION="
set "PROFILE_ARGS="
set "PROFILE_NEEDS_GENERAL_ASSETS=0"
set "PROFILE_NEEDS_AUTO_LUA=0"

if not exist "%STRATEGY_DIR%\%SELECTED_PROFILE%" (
    echo [ОШИБКА] Профиль не найден: %SELECTED_PROFILE%
    exit /b 1
)

call "%STRATEGY_DIR%\%SELECTED_PROFILE%"
if not defined PROFILE_ARGS (
    echo [ОШИБКА] В профиле отсутствует PROFILE_ARGS.
    exit /b 1
)
exit /b 0


:get_service_state
set "SERVICE_STATE=NOT INSTALLED"
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if not errorlevel 1 (
    set "SERVICE_STATE=STOPPED"
    for /f "tokens=3 delims=: " %%S in ('sc.exe query "%SERVICE_NAME%" ^| findstr /i "STATE"') do set "SERVICE_STATE=%%S"
)
exit /b 0


:select_strategy
cls
echo.
echo  ================ ВЫБОР СТРАТЕГИИ =================
echo.
set /a COUNT=0

for %%F in ("%STRATEGY_DIR%\*.strategy.cmd") do (
    if exist "%%~fF" (
        set "PROFILE_TITLE="
        set "PROFILE_DESCRIPTION="
        set "PROFILE_ARGS="
        call "%%~fF"
        set /a COUNT+=1
        set "ITEM_!COUNT!=%%~nxF"
        echo    !COUNT!. !PROFILE_TITLE!
        if defined PROFILE_DESCRIPTION echo       !PROFILE_DESCRIPTION!
    )
)

echo.
echo    0. Назад
echo.
if "!COUNT!"=="0" (
    echo В папке strategies нет файлов *.strategy.cmd.
    pause
    exit /b 1
)

set "PICK="
set /p "PICK=Выберите стратегию: "
if "!PICK!"=="0" exit /b 0

set "NEW_PROFILE="
for /l %%N in (1,1,!COUNT!) do (
    if "!PICK!"=="%%N" set "NEW_PROFILE=!ITEM_%%N!"
)

if not defined NEW_PROFILE (
    echo Неверный номер стратегии.
    pause
    exit /b 1
)

set "SELECTED_PROFILE=!NEW_PROFILE!"
if not exist "%ROOT%data" mkdir "%ROOT%data" >nul 2>&1
> "%PROFILE_STATE%" echo !SELECTED_PROFILE!
call :load_profile
echo.
echo Выбрана стратегия: !PROFILE_TITLE!
pause
exit /b 0


:check_components
echo.
echo Проверка компонентов Zapret 2...
echo.
set /a MISSING=0

for %%F in (winws2.exe WinDivert.dll WinDivert64.sys cygwin1.dll) do (
    if not exist "%BIN_DIR%\%%F" (
        echo [ОТСУТСТВУЕТ] bin\%%F
        set /a MISSING+=1
    ) else (
        echo [OK] bin\%%F
    )
)

for %%F in (zapret-lib.lua zapret-antidpi.lua) do (
    if not exist "%BIN_DIR%\lua\%%F" (
        echo [ОТСУТСТВУЕТ] bin\lua\%%F
        set /a MISSING+=1
    ) else (
        echo [OK] bin\lua\%%F
    )
)

if "!PROFILE_NEEDS_AUTO_LUA!"=="1" (
    if not exist "%BIN_DIR%\lua\zapret-auto.lua" (
        echo [ОТСУТСТВУЕТ] bin\lua\zapret-auto.lua
        set /a MISSING+=1
    ) else (
        echo [OK] bin\lua\zapret-auto.lua
    )
)

if "!PROFILE_NEEDS_GENERAL_ASSETS!"=="1" (
    if not exist "%BIN_DIR%\files\list-youtube.txt" (
        echo [ОТСУТСТВУЕТ] bin\files\list-youtube.txt
        set /a MISSING+=1
    ) else (
        echo [OK] bin\files\list-youtube.txt
    )
    if not exist "%BIN_DIR%\files\quic_initial_www_google_com.bin" (
        echo [ОТСУТСТВУЕТ] bin\files\quic_initial_www_google_com.bin
        set /a MISSING+=1
    ) else (
        echo [OK] bin\files\quic_initial_www_google_com.bin
    )
    for %%F in (discord_media stun wireguard quic_initial_ietf) do (
        if not exist "%BIN_DIR%\windivert.filter\windivert_part.%%F.txt" (
            echo [ОТСУТСТВУЕТ] bin\windivert.filter\windivert_part.%%F.txt
            set /a MISSING+=1
        ) else (
            echo [OK] bin\windivert.filter\windivert_part.%%F.txt
        )
    )
) else (
    if not exist "%BIN_DIR%\windivert.filter\windivert_part.wireguard.txt" (
        echo [ОТСУТСТВУЕТ] bin\windivert.filter\windivert_part.wireguard.txt
        set /a MISSING+=1
    ) else (
        echo [OK] bin\windivert.filter\windivert_part.wireguard.txt
    )
)

echo.
if "!MISSING!"=="0" (
    echo Все необходимые для выбранной стратегии файлы найдены.
    exit /b 0
)

echo Не найдено файлов: !MISSING!
echo Скопируйте содержимое папки zapret-winws из официального Windows-бандла в папку bin.
exit /b 1


:install_service
call :load_profile
if errorlevel 1 (
    pause
    exit /b 1
)

call :check_components
if errorlevel 1 (
    pause
    exit /b 1
)

echo.
echo Будет установлена служба Windows:
echo   Имя:       %SERVICE_NAME%
echo   Стратегия: !PROFILE_TITLE!
echo   Запуск:    автоматически при старте Windows
echo.
echo ВНИМАНИЕ: режим службы Zapret 2 помечен upstream-проектом
echo как требующий ручной настройки. Установка выполняется
echo только после явного подтверждения.
echo.
set "CONFIRM="
set /p "CONFIRM=Для продолжения введите INSTALL: "
if /i not "!CONFIRM!"=="INSTALL" (
    echo Установка отменена.
    pause
    exit /b 0
)

sc.exe query "%SERVICE_NAME%" >nul 2>&1
if not errorlevel 1 (
    echo Останавливается и заменяется существующая служба...
    sc.exe stop "%SERVICE_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
    sc.exe delete "%SERVICE_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
)

echo.
echo Создание службы...
sc.exe create "%SERVICE_NAME%" binPath= "\"%ENGINE%\" !PROFILE_ARGS!" DisplayName= "%SERVICE_DISPLAY%" start= auto
if errorlevel 1 (
    echo.
    echo [ОШИБКА] Не удалось создать службу.
    pause
    exit /b 1
)

sc.exe description "%SERVICE_NAME%" "Zapret 2 Windows bundle"
echo.
echo Запуск службы...
sc.exe start "%SERVICE_NAME%"
echo.
pause
exit /b 0


:start_service
call :load_profile
call :check_components
if errorlevel 1 (
    pause
    exit /b 1
)
sc.exe start "%SERVICE_NAME%"
echo.
pause
exit /b 0


:stop_service
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
    echo Служба не установлена.
) else (
    sc.exe stop "%SERVICE_NAME%"
)
echo.
pause
exit /b 0


:remove_service
sc.exe query "%SERVICE_NAME%" >nul 2>&1
if errorlevel 1 (
    echo Служба не установлена.
    pause
    exit /b 0
)
echo.
set "CONFIRM="
set /p "CONFIRM=Для удаления службы введите REMOVE: "
if /i not "!CONFIRM!"=="REMOVE" (
    echo Удаление отменено.
    pause
    exit /b 0
)
sc.exe stop "%SERVICE_NAME%" >nul 2>&1
timeout /t 2 /nobreak >nul
sc.exe delete "%SERVICE_NAME%"
echo.
pause
exit /b 0
