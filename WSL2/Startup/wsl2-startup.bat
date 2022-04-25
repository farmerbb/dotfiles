@echo off

wsl -- sudo service ssh start
wsl -- sudo service cron start
wsl -- sudo service apache2 start

powershell -executionPolicy bypass -file "D:\Other Stuff\Linux\WSL2\Startup\wsl2-network.ps1"
exit
