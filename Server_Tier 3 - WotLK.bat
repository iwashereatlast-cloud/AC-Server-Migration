@echo off
title AzerothCore - Tier 3 WotLK / Level 80

echo ==========================================
echo   AZEROTHCORE - TIER 3: WOTLK / LEVEL 80
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
copy /Y "%WORLD%" "%WORLD%.tier3.bak.%TIMESTAMP%"
copy /Y "%BOTS%" "%BOTS%.tier3.bak.%TIMESTAMP%"

:: Update worldserver.conf
echo.
echo Setting Expansion to 2 and MaxPlayerLevel to 80...
powershell -NoProfile -Command "$file = '%WORLD%'; $content = Get-Content $file; $content = $content -replace '^\s*Expansion\s*=\s*.*', 'Expansion = 2'; $content = $content -replace '^\s*MaxPlayerLevel\s*=\s*.*', 'MaxPlayerLevel = 80'; $content | Set-Content $file"
if errorlevel 1 (
    echo ERROR: Failed to update worldserver.conf
    pause
    exit /b 1
)

:: Update playerbots.conf
echo Setting playerbots.conf for Tier 3 (WotLK / Level 80)...
powershell -NoProfile -Command "$file = '%BOTS%'; $content = Get-Content $file; $content = $content -replace '^\s*AiPlayerbot\.RandomBotMaxLevel\s*=\s*.*', 'AiPlayerbot.RandomBotMaxLevel = 80'; $content = $content -replace '^\s*AiPlayerbot\.LimitTalentsExpansion\s*=\s*.*', 'AiPlayerbot.LimitTalentsExpansion = 0'; $content = $content -replace '^\s*AiPlayerbot\.RandomBotMaps\s*=\s*.*', 'AiPlayerbot.RandomBotMaps = 0,1,530,571'; $content = $content -replace '^\s*AiPlayerbot\.LimitEnchantExpansion\s*=\s*.*', 'AiPlayerbot.LimitEnchantExpansion = 1'; $content = $content -replace '^\s*AiPlayerbot\.LimitGearExpansion\s*=\s*.*', 'AiPlayerbot.LimitGearExpansion = 1'; $content | Set-Content $file"
if errorlevel 1 (
    echo ERROR: Failed to update playerbots.conf
    pause
    exit /b 1
)

:: Apply SQL
echo.
echo Restoring Northrend boats and NPCs...
set /p MYSQL_PASSWORD=Enter MySQL password for root:
mysql -u root -p%MYSQL_PASSWORD% acore_world < "%SQL%"
if errorlevel 1 (
    echo.
    echo ERROR: SQL import failed!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo TIER 3 COMPLETE
echo ==========================================
pause