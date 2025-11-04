@echo off
setlocal enabledelayedexpansion

:: === Figure out root folder (this script’s directory) ===
set "rootDir=%~dp0"

:: === Ask for parameters ===
set /p configName=Enter config name (e.g. Lynx1):
set /p linkIp=Enter link IP (e.g. 192.168.2.101):
set /p camIp=Enter camera IP (e.g. 192.168.2.102):
set /p shortcutDir=Enter folder where shortcut should be placed (Leave empty for default: Desktop):

:: === Set default shortcut directory if blank ===
if "%shortcutDir%"=="" (
    set "shortcutDir=%USERPROFILE%\Desktop"
    echo No folder specified. Using default: "%shortcutDir%"
)

if not exist "%shortcutDir%" mkdir "%shortcutDir%"

:: === Paths ===
set "template=%rootDir%Termit QGroundControl Daily_Template.ini"
set "outputDir=%rootDir%Generated"
set "outputFile=%outputDir%\Termit QGroundControl Daily_%configName%.ini"
set "selectorScript=%rootDir%QGC_Config_Selector_main.bat"
set "launcherFile=%outputDir%\Run_%configName%.bat"
set "shortcutScript=%rootDir%CreateShortcut.ps1"
:: TODO think about cool icons 
:: set "iconPath=%rootDir%icon\drone.ico"

echo Generating "%outputFile%" from template...

if not exist "%template%" (
    echo [ERROR] Template not found: "%template%"
    pause
    exit /b 1
)

if not exist "%outputDir%" mkdir "%outputDir%"

:: === Create file with replacements (preserves blank lines) ===
> "%outputFile%" (
  for /f "usebackq tokens=1,* delims=:" %%A in (`findstr /n "^" "%template%"`) do (
    set "line=%%B"
    if defined line (
        :: If the line exactly equals the template name line, replace whole line
        if /i "!line!"=="Link0\name=Template" (
            echo Link0\name=%configName%
        ) else (
            :: Otherwise replace placeholders (use CALL to ensure proper expansion)
            call set "line=%%line:{{LINK_IP}}=%linkIp%%%"
            call set "line=%%line:{{CAMERA_IP}}=%camIp%%%"
            echo(!line!
        )
    ) else (
        echo.
    )
  )
)

echo INI created: "%outputFile%"
echo.

:: === Create launcher BAT ===
echo Creating launcher: "%launcherFile%"...

(
  echo @echo off
  echo echo Starting config "%configName%"...
  echo call "%selectorScript%" "%outputFile%"
) > "%launcherFile%"

echo Launcher created: "%launcherFile%"
echo.

:: === Create shortcut ===
powershell -ExecutionPolicy Bypass -File "%shortcutScript%" "%launcherFile%" "%shortcutDir%" -RunAsAdmin

if %errorlevel% neq 0 (
    echo Failed to create shortcut.
) else (
    echo Shortcut created successfully.
)
echo.

pause
