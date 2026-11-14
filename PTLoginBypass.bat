@echo off
setlocal EnableExtensions
title PTLoginBypass

:: ==========================================
:: WINDOWS LANGUAGE DETECTION

for /f "delims=" %%L in ('powershell -NoProfile -Command "(Get-UICulture).TwoLetterISOLanguageName"') do (
    if /i "%%L"=="it" (
        set "UI_LANG=IT"
    ) else if /i "%%L"=="fr" (
        set "UI_LANG=FR"
    ) else (
        set "UI_LANG=EN"
    )
)


:: ==========================================
:: LOCALIZED MESSAGES

if "%UI_LANG%"=="IT" (

    set "MSG_ERROR=ERRORE"
    set "MSG_UNSUPPORTED=Sistema operativo non supportato."
    set "MSG_REQUIRED=E' richiesto Windows 10 o Windows 11."

    set "MSG_PATH_NOT_FOUND=Installazione rilevata, ma eseguibile non individuato."
    set "MSG_VERIFY_PATH=Verificare l'installazione di vostro Cisco Packet Tracer."

    set "MSG_ADMIN=Richiesta dei privilegi di amministratore..."

    set "MSG_EXE_PATH=Percorso dell'eseguibile :"

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

    set "MSG_CLOSING=Chiusura di PTLoginBypass..."

) else if "%UI_LANG%"=="FR" (
    
    set "MSG_ERROR=ERREUR"
    set "MSG_UNSUPPORTED=Systeme d'exploitation non pris en charge."
    set "MSG_REQUIRED=Windows 10 ou Windows 11 est requis."

    set "MSG_PATH_NOT_FOUND=Installation detectee, mais executable introuvable."
    set "MSG_VERIFY_PATH=Veuillez verifier l'installation de votre Cisco Packet Tracer."

    set "MSG_ADMIN=Demande des privileges administrateur..."

    set "MSG_EXE_PATH=Chemin de l'executable :"

    set "MSG_SELECT=Selectionnez une option :"
    set "MSG_CHOICE=Choix"

    set "MSG_ENABLE=Activer le bypass de connexion"
    set "MSG_REMOVE=Supprimer le bypass de connexion"
    set "MSG_EXIT=Quitter"

    set "MSG_ACTIVATION=Activation du bypass..."
    set "MSG_ACTIVATED=Bypass active pour Cisco Packet Tracer."

    set "MSG_REMOVAL=Suppression du bypass..."
    set "MSG_REMOVED=Bypass supprime pour Cisco Packet Tracer."

    set "MSG_INVALID=Choix invalide. Veuillez entrer 0, 1 ou 2."

    set "MSG_CLOSING=Fermeture de PTLoginBypass..."

) else (

    set "MSG_ERROR=ERROR"
    set "MSG_UNSUPPORTED=Unsupported operating system."
    set "MSG_REQUIRED=Windows 10 or Windows 11 is required."

    set "MSG_PATH_NOT_FOUND=Installation detected, but executable not found."
    set "MSG_VERIFY_PATH=Please verify the installation of your Cisco Packet Tracer."

    set "MSG_ADMIN=Requesting administrator privileges..."

    set "MSG_EXE_PATH=Executable path:"

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

    set "MSG_CLOSING=Closing PTLoginBypass..."
)


:: ==========================================
:: ADMINISTRATOR PRIVILEGES CHECK

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo %MSG_ADMIN%
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)


:: ==========================================
:: OPERATING SYSTEM CHECK

for /f "tokens=6-7 delims=. " %%a in ('ver') do (
    set "WINVER=%%a"
)

if not "%WINVER%" geq "10240" (
    echo.
    echo [%MSG_ERROR%] %MSG_UNSUPPORTED%
    echo %MSG_REQUIRED%
    pause
    exit /b 1
)


:: ==========================================
:: PACKET TRACER INSTALLATION CHECK

set "PT_PATH="

for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v InstallLocation 2^>nul ^| findstr /i "Packet Tracer"') do (
    set "PT_PATH=%%B"
)

for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v InstallLocation 2^>nul ^| findstr /i "Packet Tracer"') do (
    set "PT_PATH=%%B"
)

if not defined PT_PATH (
    echo.
    echo [%MSG_ERROR%] %MSG_PATH_NOT_FOUND%
    echo %MSG_VERIFY_PATH%
    pause
    exit /b 1
) else (
    set "FinalTargetPath=%PT_PATH%bin\PacketTracer.exe"
)


:: ==========================================
:MENU
cls
echo ==========================================
echo      Cisco Packet Tracer Login Bypass
echo ==========================================
echo.
echo %MSG_EXE_PATH%
echo %FinalTargetPath%
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
    goto ENABLE_BYPASS
) else if "%choice%"=="2" (
    goto REMOVE_BYPASS
) else (
    cls
    echo [%MSG_ERROR%] %MSG_INVALID%
    echo.
    pause
    goto MENU
)


:: ==========================================
:ENABLE_BYPASS
echo.
echo %MSG_ACTIVATION%

powershell -NoProfile -Command "New-NetFirewallRule -DisplayName 'ByPass Cisco Packet Tracer Login' -Program '%FinalTargetPath%' -Action Block -Direction Outbound"
echo %MSG_ACTIVATED%
echo.
pause
goto MENU


:: ==========================================
:REMOVE_BYPASS
echo.
echo %MSG_REMOVAL%

powershell -NoProfile -Command "Remove-NetFirewallRule -DisplayName 'ByPass Cisco Packet Tracer Login'"
echo %MSG_REMOVED%
echo.
pause
goto MENU


:: ==========================================
:EXIT
echo.
echo %MSG_CLOSING%
timeout /t 2 >nul
exit /b 0
