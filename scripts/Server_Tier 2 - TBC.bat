@echo off
title AzerothCore - Tier 2 TBC / Level 70

echo ==========================================
echo   AZEROTHCORE - TIER 2: TBC / LEVEL 70
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
set "SQL1=E:\Server Build\classic-mode.down.sql"
set "SQL2=E:\Server Build\classic-wotlk-mode.down.sql"

:: Check if SQL files exist
if not exist "%SQL1%" (
    echo ERROR: SQL file "%SQL1%" not found!
    pause
    exit /b 1
)
if not exist "%SQL2%" (
    echo ERROR: SQL file "%SQL2%" not found!
    pause
    exit /b 1
)

:: Backup configs with timestamp
set "TIMESTAMP=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
echo.
echo Backing up configuration files...
copy /Y "%WORLD%" "%WORLD%.tier2.bak.%TIMESTAMP%"
copy /Y "%BOTS%" "%BOTS%.tier2.bak.%TIMESTAMP%"

:: Update worldserver.conf
echo.
echo Setting Expansion to 2 and MaxPlayerLevel to 70...
powershell -NoProfile -Command "$file = '%WORLD%'; $content = Get-Content $file; $content = $content -replace '^\s*Expansion\s*=\s*.*', 'Expansion = 2'; $content = $content -replace '^\s*MaxPlayerLevel\s*=\s*.*', 'MaxPlayerLevel = 70'; $content | Set-Content $file"
if errorlevel 1 (
    echo ERROR: Failed to update worldserver.conf
    pause
    exit /b 1
)

:: Update playerbots.conf
echo Setting playerbots.conf for Tier 2 (TBC / Level 70)...
powershell -NoProfile -Command "$file = '%BOTS%'; $content = Get-Content $file; $content = $content -replace '^\s*AiPlayerbot\.RandomBotMaxLevel\s*=\s*.*', 'AiPlayerbot.RandomBotMaxLevel = 70'; $content = $content -replace '^\s*AiPlayerbot\.LimitTalentsExpansion\s*=\s*.*', 'AiPlayerbot.LimitTalentsExpansion = 0'; $content = $content -replace '^\s*AiPlayerbot\.RandomBotMaps\s*=\s*.*', 'AiPlayerbot.RandomBotMaps = 0,1,530'; $content = $content -replace '^\s*AiPlayerbot\.LimitEnchantExpansion\s*=\s*.*', 'AiPlayerbot.LimitEnchantExpansion = 1'; $content = $content -replace '^\s*AiPlayerbot\.LimitGearExpansion\s*=\s*.*', 'AiPlayerbot.LimitGearExpansion = 1'; $content | Set-Content $file"
if errorlevel 1 (
    echo ERROR: Failed to update playerbots.conf
    pause
    exit /b 1
)

:: Apply SQL
echo.
echo Restoring Dark Portal AND Northrend...
set /p MYSQL_PASSWORD=Enter MySQL password for root:
mysql -u root -p%MYSQL_PASSWORD% acore_world < "%SQL1%"
if errorlevel 1 (
    echo.
    echo ERROR: First SQL import failed!
    pause
    exit /b 1
)

echo.
echo Re-disabling Northrend while leaving Dark Portal open...
mysql -u root -p%MYSQL_PASSWORD% acore_world < "%SQL2%"
if errorlevel 1 (
    echo.
    echo ERROR: Second SQL import failed!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo TIER 2 COMPLETE
echo ==========================================
pause