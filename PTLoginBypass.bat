@echo off
setlocal EnableExtensions
title PTLoginBypassPlus

:: ==========================================
:: RILEVAMENTO LINGUA WINDOWS
:: ==========================================

set "UI_LANG=EN"

for /f "delims=" %%L in ('powershell -NoProfile -Command "(Get-UICulture).TwoLetterISOLanguageName"') do (
    if /i "%%L"=="it" (
        set "UI_LANG=IT"
    )
)

:: ==========================================
:: MESSAGGI ITALIANO / INGLESE
:: ==========================================

if "%UI_LANG%"=="IT" (

    set "MSG_ERROR=ERRORE"
    set "MSG_UNSUPPORTED=Sistema operativo non supportato."
    set "MSG_REQUIRED=E' richiesto Windows 10 o Windows 11."

    set "MSG_NOT_INSTALLED=Cisco Packet Tracer non risulta installato."
    set "MSG_CANNOT_PROCEED=Impossibile procedere."
    set "MSG_PATH_NOT_FOUND=Installazione rilevata, ma eseguibile non individuato."
    set "MSG_VERIFY_PATH=Verificare il percorso di installazione."

    set "MSG_ADMIN=Richiesta dei privilegi di amministratore..."

    set "MSG_SHORTCUT=Collegamento a Packet Tracer non trovato."

    set "MSG_SELECT=Seleziona un'opzione:"
    set "MSG_CHOICE=Scelta"

    set "MSG_ENABLE=Attiva bypass login"
    set "MSG_REMOVE=Rimuovi bypass login"
    set "MSG_EXIT=Esci"

    set "MSG_ACTIVATION=Attivazione bypass..."
    set "MSG_ACTIVATED=Bypass attivato per Cisco Packet Tracer."

    set "MSG_REMOVAL=Rimozione bypass..."
    set "MSG_REMOVED=Bypass rimosso per Cisco Packet Tracer."

    set "MSG_INVALID=Scelta non valida. Inserire 0, 1 oppure 2."

    set "MSG_CLOSING=Chiusura di PTLoginBypassPlus..."

    set "MSG_OPERATION_UNAVAILABLE=Operazione non implementata in questa versione."

) else (

    set "MSG_ERROR=ERROR"
    set "MSG_UNSUPPORTED=Unsupported operating system."
    set "MSG_REQUIRED=Windows 10 or Windows 11 is required."

    set "MSG_NOT_INSTALLED=Cisco Packet Tracer is not installed."
    set "MSG_CANNOT_PROCEED=Unable to proceed."
    set "MSG_PATH_NOT_FOUND=Installation detected, but executable not found."
    set "MSG_VERIFY_PATH=Please verify the installation path."

    set "MSG_ADMIN=Requesting administrator privileges..."

    set "MSG_SHORTCUT=Packet Tracer shortcut not found."

    set "MSG_SELECT=Select an option:"
    set "MSG_CHOICE=Choice"

    set "MSG_ENABLE=Enable login bypass"
    set "MSG_REMOVE=Remove login bypass"
    set "MSG_EXIT=Exit"

    set "MSG_ACTIVATION=Bypass activation..."
    set "MSG_ACTIVATED=Bypass enabled for Cisco Packet Tracer."

    set "MSG_REMOVAL=Bypass removal..."
    set "MSG_REMOVED=Bypass removed for Cisco Packet Tracer."

    set "MSG_INVALID=Invalid choice. Please enter 0, 1 or 2."

    set "MSG_CLOSING=Closing PTLoginBypassPlus..."

    set "MSG_OPERATION_UNAVAILABLE=Operation not implemented in this version."

)

:: ==========================================
:: CONTROLLO SISTEMA OPERATIVO
:: ==========================================

for /f "tokens=4-5 delims=. " %%a in ('ver') do (
    set "WINVER=%%a"
)

if not "%WINVER%"=="10" if not "%WINVER%"=="11" (
    echo.
    echo [%MSG_ERROR%] %MSG_UNSUPPORTED%
    echo %MSG_REQUIRED%
    pause
    exit /b 1
)

:: ==========================================
:: CONTROLLO INSTALLAZIONE PACKET TRACER
:: ==========================================

set "PT_PATH="
set "PT_FOUND=0"

for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "Packet Tracer"') do (
    set "PT_FOUND=1"
)

for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "Packet Tracer"') do (
    set "PT_FOUND=1"
)

if exist "%ProgramFiles%\Cisco Packet Tracer\bin\PacketTracer.exe" (
    set "PT_PATH=%ProgramFiles%\Cisco Packet Tracer\bin\PacketTracer.exe"
)

if exist "%ProgramFiles(x86)%\Cisco Packet Tracer\bin\PacketTracer.exe" (
    set "PT_PATH=%ProgramFiles(x86)%\Cisco Packet Tracer\bin\PacketTracer.exe"
)

:: RICERCA INSTALLAZIONI PERSONALIZZATE

for /f "usebackq delims=" %%P in (`powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$ErrorActionPreference='SilentlyContinue'; $roots=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'); $found=@(); foreach($root in $roots){ foreach($key in (Get-ChildItem -LiteralPath $root -ErrorAction SilentlyContinue)){ try { $item=Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction Stop; if($item.DisplayName -match 'Packet\s*Tracer'){ $paths=@(); if($item.InstallLocation){ $paths+=($item.InstallLocation.Trim().Trim('""')) }; if($item.DisplayIcon){ $icon=$item.DisplayIcon -replace ',\s*-?\d+$',''; $paths+=($icon.Trim().Trim('""')) }; foreach($p in $paths){ if(Test-Path -LiteralPath $p -PathType Leaf){ if((Split-Path -Leaf $p) -ieq 'PacketTracer.exe'){ $found+=$p } }; if(Test-Path -LiteralPath $p -PathType Container){ foreach($f in @((Join-Path $p 'PacketTracer.exe'),(Join-Path $p 'bin\PacketTracer.exe'))){ if(Test-Path -LiteralPath $f -PathType Leaf){ $found+=$f } } } } } } catch {} } }; $found | Sort-Object -Unique | Select-Object -First 1"`) do (
    if not defined PT_PATH set "PT_PATH=%%P"
)

set "PT_PATH=%PT_PATH%"

if "%PT_FOUND%"=="0" if not defined PT_PATH (
    echo.
    echo [%MSG_ERROR%] %MSG_NOT_INSTALLED%
    echo %MSG_CANNOT_PROCEED%
    pause
    exit /b 1
)

if not defined PT_PATH (
    echo.
    echo [%MSG_ERROR%] %MSG_PATH_NOT_FOUND%
    echo %MSG_VERIFY_PATH%
    pause
    exit /b 1
)

:: ==========================================
:: CONTROLLO PRIVILEGI AMMINISTRATORE
:: ==========================================

net session >nul 2>&1

if %errorLevel% NEQ 0 (
    echo %MSG_ADMIN%
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ==========================================
:: IMPOSTAZIONI DEI PERCORSI
:: ==========================================

:start

set "app_name=ByPass Cisco Packet Tracer Login"

set "ShortcutPath1=%ProgramData%\Microsoft\Windows\Start Menu\Programs\Cisco Packet Tracer\Cisco Packet Tracer.lnk"

set "ShortcutPath2=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Cisco Packet Tracer\Cisco Packet Tracer.lnk"

set "FinalTargetPath="

if exist "%ShortcutPath1%" (
    for /f "delims=" %%i in ('powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).CreateShortcut('%ShortcutPath1%').TargetPath"') do set "FinalTargetPath=%%i"
)

if not defined FinalTargetPath if exist "%ShortcutPath2%" (
    for /f "delims=" %%i in ('powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).CreateShortcut('%ShortcutPath2%').TargetPath"') do set "FinalTargetPath=%%i"
)

if not defined FinalTargetPath (
    echo.
    echo [%MSG_ERROR%] %MSG_SHORTCUT%
    pause
    exit /b 1
)

:: ==========================================
:: MENU PRINCIPALE
:: ==========================================

:MENU

cls
echo ==========================================
echo       PTLoginBypassPlus
echo ==========================================
echo.
echo Cisco Packet Tracer:
echo %PT_PATH%
echo.
echo %MSG_SELECT%
echo.
echo 1. %MSG_ENABLE%
echo 2. %MSG_REMOVE%
echo 0. %MSG_EXIT%
echo.

set "choice="
set /p "choice=%MSG_CHOICE%: "

if "%choice%"=="0" (
    goto EXIT
) else if "%choice%"=="1" (
    goto ENABLE
) else if "%choice%"=="2" (
    goto REMOVE
) else (
    cls
    echo [%MSG_ERROR%] %MSG_INVALID%
    echo.
    pause
    goto MENU
)

:: ==========================================
:: ATTIVAZIONE BYPASS
:: ==========================================

:ENABLE

echo.
echo %MSG_ACTIVATION%

powershell -NoProfile -Command "New-NetFirewallRule -DisplayName '%app_name%' -Program '%FinalTargetPath%' -Action Block -Direction Outbound -ErrorAction SilentlyContinue"
echo %MSG_ACTIVATED%

echo.
pause
goto MENU

:: ==========================================
:: RIMOZIONE BYPASS
:: ==========================================

:REMOVE

echo.
echo %MSG_REMOVAL%

powershell -NoProfile -Command "Remove-NetFirewallRule -DisplayName '%app_name%' -ErrorAction SilentlyContinue"
echo %MSG_REMOVED%

echo.
pause
goto MENU

:: ==========================================
:: USCITA
:: ==========================================

:EXIT

echo.
echo %MSG_CLOSING%
timeout /t 2 >nul
exit /b 0
