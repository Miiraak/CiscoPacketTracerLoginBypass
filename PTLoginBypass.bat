@echo off
:: Verify if the script is launched as Administrator.
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    :: If not, restart with elevation
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:start
set app_name=ByPass Cisco Packet Tracer Login
set ShortcutPaths="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Cisco Packet Tracer\Cisco Packet Tracer.lnk";"%APPDATA%\Microsoft\Windows\Start Menu\Programs\Cisco Packet Tracer\Cisco Packet Tracer.lnk"
set FinalTargetPath=""

for %%p in (%ShortcutPaths%) do (
    for /f "delims=" %%i in ('powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).CreateShortcut('%%~p').TargetPath"') do set "FinalTargetPath=%%i"

    if exist "%FinalTargetPath%" (
        goto :fin
    )
)

:fin
echo ___ Packet Tracer Login bypass ___
echo.
echo Choose an option :
echo 1. Enable login bypass.
echo 2. Remove login bypass.
set /p choice=Your choice : 

if "%choice%"=="1" (
    	echo Bypass activation...
    	powershell -Command "New-NetFirewallRule -DisplayName '%app_name%' -Program '%FinalTargetPath%' -Action Block -Direction Outbound"
    	echo Bypass enabled for Cisco Packet Tracer.
) else if "%choice%"=="2" (
    	echo Bypass removal...
    	powershell -Command "Remove-NetFirewallRule -DisplayName '%app_name%'"
    	echo Bypass removed for Cisco Packet Tracer.
) else (
	cls
    	echo Invalid choice, please enter 1 or 2.
	echo.
	goto :fin
)

pause
