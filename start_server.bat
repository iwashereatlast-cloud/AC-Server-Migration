@echo off
:: Change to the directory containing worldserver.exe and configs
cd /d "E:\Server Build\Build\bin\Release\"

:: Launch the server in a new cmd window with a unique title
start "World Server Daemon" cmd /c "worldserver.exe"