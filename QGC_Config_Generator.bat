@echo off
setlocal enabledelayedexpansion

:: === Ask for parameters ===
set /p configName=Enter config name (e.g. Lynx1):
set /p linkIp=Enter host IP (e.g. 192.168.2.101):
set /p camIp=Enter camera IP (e.g. 192.168.2.102):

:: === Paths ===
set "template=C:\QGC_Config_Helper\Termit QGroundControl Daily_Template.ini"
set "outputDir=C:\QGC_Config_Helper\Generated"
set "outputFile=%outputDir%\Termit QGroundControl Daily_%configName%.ini"
set "selectorScript=C:\QGC_Config_Helper\QGC_Config_Selector_main.bat"
set "launcherFile=%outputDir%\Run_%configName%.bat"

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
pause
