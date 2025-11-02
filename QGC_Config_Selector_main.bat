@echo off
:: ==========================================
:: QGroundControl Config Switcher (with checks)
:: ==========================================
:: Usage: Config_Selector.bat "D:\Configs\QGroundControl_droneA.ini"
:: ==========================================

setlocal

:: --- Input check ---
set "TARGET=%~1"
if "%TARGET%"=="" (
    echo Usage: QGC_Config_Selector.bat "D:\Configs\QGroundControl_droneA.ini"
    exit /b 1
)

:: --- Expand variables ---
set "APPDATA_PATH=%APPDATA%\tencore.org"
set "LINK=%APPDATA_PATH%\Termit QGroundControl Daily.ini"
set "QGC_EXE=C:\Program Files\NRK QGroundControl\QGroundControl.exe"

:: --- Normalize path (remove quotes) ---
for %%A in ("%TARGET%") do set "TARGET=%%~fA"

:: --- Check if target config exists ---
if not exist "%TARGET%" (
    echo [ERROR] Target config not found: "%TARGET%"
    exit /b 1
)

:: --- Check if running as Administrator ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    echo Please approve the UAC prompt.
    echo.
    :: Relaunch itself as admin using built-in runas
    runas /savecred /user:%USERNAME% "cmd /c \"\"%~f0\" %*\""
    exit /b
)


:: --- Admin mode: recreate symlink safely ---
cd /d "%APPDATA_PATH%"
if exist "%LINK%" (
    echo Found existing QGroundControl.ini
    del "%LINK%"
)

echo Creating symlink:
echo   %LINK%
echo   → %TARGET%
mklink "%LINK%" "%TARGET%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create symlink. You must run as admin.
    pause
    exit /b 1
)
echo ✅ Symlink created successfully.

:: --- Verify both link and target ---
if exist "%LINK%" (
    echo [OK] Link exists: "%LINK%"
) else (
    echo [WARNING] Link missing!
)
if exist "%TARGET%" (
    echo [OK] Target exists: "%TARGET%"
) else (
    echo [WARNING] Target missing!
)

:: --- Run QGroundControl as normal user ---
echo Launching QGroundControl...
runas /trustlevel:0x20000 "\"%QGC_EXE%\""
exit /b 0