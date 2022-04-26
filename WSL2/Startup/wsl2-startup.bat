@echo off

title "WSL2 Startup"
"D:\Other Stuff\Utilities\NirCmd\nircmd.exe" win hide ititle "WSL2 Startup"

wsl -- sudo service ssh start
wsl -- sudo service cron start
wsl -- sudo service apache2 start

powershell -executionPolicy bypass -file "D:\Other Stuff\Linux\WSL2\Startup\wsl2-network.ps1"
exit
