@echo off

title "WSL2 Startup"
"Z:\Other Stuff\Utilities\NirCmd\nircmd.exe" win hide ititle "WSL2 Startup"

wsl -- sudo service ssh start
wsl -- sudo service cron start
wsl -- sudo service apache2 start

powershell -executionPolicy bypass -file "Z:\Other Stuff\Linux\WSL2\Startup\wsl2-network.ps1"
exit
