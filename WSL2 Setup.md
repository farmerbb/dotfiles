**Enable passwordless sudo:**  

```
/mnt/d/Other\ Stuff/Linux/Scripts/passwordless-sudo
```

**Install essential programs:**

```
sudo apt update
sudo apt install ssh cron apache2 rsync rclone fuse3 curl cifs-utils smem bsdmainutils daemonize jdupes duperemove
```

**Set up SSH authorized_keys:**  

```
mkdir -p ~/.ssh
echo "(paste key here)" > ~/.ssh/authorized_keys
```

**Set up WSL2 autostart script:**

* Go to D:\\Other Stuff\\Linux\\WSL2\\Startup, and follow steps in Instructions.txt

* Run wsl2-startup.bat as administrator (or just reboot PC) 

**Set up bash config:**  

```
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
echo '' >> ~/.bashrc
echo 'for i in linux-generic wsl2; do' >> ~/.bashrc
echo '  source /mnt/d/Other\ Stuff/Linux/Bash\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc
```

**Set up OneDrive mount via rclone:**  

```
mkdir -p ~/OneDrive
mkdir -p ~/.config/rclone
cp /mnt/d/Other\ Stuff/Linux/WSL2/rclone.conf ~/.config/rclone/
```

**Set up crontab:**

```
cat /mnt/d/Other\ Stuff/Linux/WSL2/crontab
```

* Copy bottom of crontab

```
crontab –e
```

* Paste at bottom

**Set up Linux symlinks for Windows tools on D drive:**

```
sudo ln -s /mnt/d/Other\ Stuff/Utilities/Minimal\ ADB\ \&\ Fastboot/adb.exe /usr/local/bin/adb
sudo ln -s /mnt/d/Other\ Stuff/Utilities/Minimal\ ADB\ \&\ Fastboot/fastboot.exe /usr/local/bin/fastboot
sudo ln -s /mnt/d/Games/Utilities/chdman/chdman.exe /usr/local/bin/chdman
sudo ln -s /mnt/d/Games/PC\ Games/Emulators\ \&\ Ports/Dolphin/DolphinTool.exe /usr/local/bin/dolphin-tool
```

**Create other directories:**

```
echo [REDACTED] | base64 -d >> ~/.sharelogin
sudo mkdir -p /mnt/shield
sudo mkdir -p /mnt/shield2
sudo mkdir -p /mnt/PC/C
sudo mkdir -p /mnt/PC/D
mkdir -p ~/.lastrun
```
