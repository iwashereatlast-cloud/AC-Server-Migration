@echo off
:: Use PowerShell to send the shutdown command to the server window
powershell -NoProfile -Command "$wsh = New-Object -ComObject WScript.Shell; $wsh.AppActivate('World Server Daemon'); Start-Sleep -Milliseconds 500; $wsh.SendKeys('.server shutdown 1{ENTER}')"

:: Wait 2 minutes for cleanup
timeout /t 20 /nobreak >nul