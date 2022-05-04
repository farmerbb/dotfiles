**Ensure that files drive is mounted inside WSL:**

* (VM only) Copy Z:\\Other Stuff\\Linux\\virt-manager\\wsl-fstab to local filesystem, then move to /etc/fstab inside WSL

```
sudo mkdir -p /mnt/z
sudo ln -s /mnt/z /mnt/d
sudo mount -a
```

**Enable passwordless sudo:**  

```
/mnt/z/Other\ Stuff/Linux/Scripts/passwordless-sudo
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

* Go to Z:\\Other Stuff\\Linux\\WSL2\\Startup, and follow steps in Instructions.txt

* Run wsl2-startup.bat as administrator (or just reboot PC) 

**Set up bash config:**  

```
curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
echo '' >> ~/.bashrc
echo 'for i in linux-generic wsl2; do' >> ~/.bashrc
echo '  source /mnt/z/Other\ Stuff/Linux/Bash\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc
```

**Set up OneDrive mount via rclone:**  

```
mkdir -p ~/OneDrive
mkdir -p ~/.config/rclone
cp /mnt/z/Other\ Stuff/Linux/WSL2/rclone.conf ~/.config/rclone/
```

**Set up crontab:**

```
cat /mnt/z/Other\ Stuff/Linux/WSL2/crontab
```

* Copy bottom of crontab

```
crontab –e
```

* Paste at bottom

**Set up Linux symlinks for Windows tools on Z drive:**

```
sudo ln -s /mnt/z/Other\ Stuff/Utilities/Minimal\ ADB\ \&\ Fastboot/adb.exe /usr/local/bin/adb
sudo ln -s /mnt/z/Other\ Stuff/Utilities/Minimal\ ADB\ \&\ Fastboot/fastboot.exe /usr/local/bin/fastboot
sudo ln -s /mnt/z/Games/Utilities/chdman/chdman.exe /usr/local/bin/chdman
sudo ln -s /mnt/z/Games/PC\ Games/Emulators\ \&\ Ports/Dolphin/DolphinTool.exe /usr/local/bin/dolphin-tool
```

**Create other directories:**

```
echo [REDACTED] | base64 -d >> ~/.sharelogin
sudo mkdir -p /mnt/shield
sudo mkdir -p /mnt/shield2
sudo mkdir -p /mnt/PC/C
sudo mkdir -p /mnt/PC/Z
sudo ln -s /mnt/PC/Z /mnt/PC/D
mkdir -p ~/.lastrun
```
