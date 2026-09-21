@echo off
title AzerothCore - Tier 1 Vanilla / Level 60

echo ==========================================
echo   AZEROTHCORE - TIER 1: VANILLA / LEVEL 60
echo ==========================================
echo.
echo Make sure worldserver is STOPPED.
echo.

:: Check if worldserver is running
tasklist | find "worldserver.exe" >nul
if not errorlevel 1 (
    echo ERROR: worldserver is still running! Stop it first.
    pause
    exit /b 1
)

:: Set paths
set "WORLD=E:\Server Build\Build\bin\Release\configs\worldserver.conf"
set "BOTS=E:\Server Build\Build\bin\Release\configs\modules\playerbots.conf"
set "SQL=E:\Server Build\classic-mode.up.sql"

:: Check if SQL file exists
if not exist "%SQL%" (
    echo ERROR: SQL file "%SQL%" not found!
    pause
    exit /b 1
)

:: Backup configs with timestamp
set "TIMESTAMP=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
echo.
echo Backing up configuration files...
copy /Y "%WORLD%" "%WORLD%.tier1.bak.%TIMESTAMP%"
copy /Y "%BOTS%" "%BOTS%.tier1.bak.%TIMESTAMP%"

:: Update worldserver.conf
echo.
echo Setting MaxPlayerLevel to 60...
powershell -NoProfile -Command "(Get-Content '%WORLD%') -replace '^\s*MaxPlayerLevel\s*=\s*.*','MaxPlayerLevel = 60' | Set-Content '%WORLD%'"
if errorlevel 1 (
    echo ERROR: Failed to update MaxPlayerLevel in worldserver.conf
    pause
    exit /b 1
)

:: Update playerbots.conf
echo Setting playerbots.conf for Tier 1 (Vanilla / Level 60)...
powershell -NoProfile -Command "$file = '%BOTS%'; $content = Get-Content $file; $content = $content -replace '^\s*AiPlayerbot\.RandomBotMaxLevel\s*=\s*.*', 'AiPlayerbot.RandomBotMaxLevel = 60'; $content = $content -replace '^\s*AiPlayerbot\.LimitTalentsExpansion\s*=\s*.*', 'AiPlayerbot.LimitTalentsExpansion = 0'; $content = $content -replace '^\s*AiPlayerbot\.RandomBotMaps\s*=\s*.*', 'AiPlayerbot.RandomBotMaps = 0,1'; $content = $content -replace '^\s*AiPlayerbot\.LimitEnchantExpansion\s*=\s*.*', 'AiPlayerbot.LimitEnchantExpansion = 1'; $content = $content -replace '^\s*AiPlayerbot\.LimitGearExpansion\s*=\s*.*', 'AiPlayerbot.LimitGearExpansion = 1'; $content | Set-Content $file"
if errorlevel 1 (
    echo ERROR: Failed to update playerbots.conf
    pause
    exit /b 1
)

echo.
echo Configuration updated successfully for Tier 1 (Vanilla / Level 60)!
pause