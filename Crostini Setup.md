## Basic Configuration

**Create symlinks:** 

* Make sure that "My files" and "SD Card" are shared with Linux

```
ln -s /mnt/chromeos/MyFiles/Downloads/ ~/Downloads
ln -s /mnt/chromeos/removable/SD\ Card/Games/ ~/Games
ln -s /mnt/chromeos/removable/SD\ Card/Media/ ~/Media
ln -s /mnt/chromeos/removable/SD\ Card/Other\ Stuff/ ~/Other\ Stuff
ln -s ~/AndroidData/media/0/Settings/ ~/Settings
```

**Create other directories:**

```
mkdir ~/Android
mkdir ~/AndroidData
mkdir ~/AndroidStudioProjects
mkdir ~/ChromeOS
mkdir ~/OneDrive
mkdir ~/NUC
mkdir ~/.gradle
mkdir ~/.lastrun
mkdir ~/adbfs
```

**Install essential programs:**

```
sudo apt update
sudo apt install nano rsync rclone cron sshfs catimg btrfs-progs vbindiff sox libsox-fmt-all zip unzip samba bindfs smem xserver-xephyr timidity xdotool aria2 daemonize pv bc lrzip htop
```

**Restore scripts & utilities:**

```
sudo chown -R farmerbb:farmerbb /usr/local/bin
ln -s ~/Other\ Stuff/Linux/Scripts/fix-desktop-file /usr/local/bin/fix-gtk3-desktop-file
ln -s ~/Other\ Stuff/Linux/Scripts/fix-desktop-file /usr/local/bin/fix-qt-desktop-file
ln -s ~/Other\ Stuff/Linux/Scripts/wine-start /usr/local/bin/winebox-start
ln -s ~/Other\ Stuff/Utilities/7-Zip/Linux/7zz /usr/local/bin/7z
chmod +x /usr/local/bin/*
```

**Restore configuration:**

```
echo '' >> ~/.bashrc
echo 'for i in linux-generic android-dev crostini; do' >> ~/.bashrc
echo '  source ~/Other\\ Stuff/Linux/Bash\\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc
```

* Close and re-open Terminal after running the above commands
 
```
cat ~/Other\ Stuff/Chrome\ OS/Crostini/crontab
```

* Copy bottom of crontab

```
crontab -e
```

* Paste at bottom of file

```
mkdir -p ~/.config/rclone
cp ~/Other\ Stuff/Chrome\ OS/Crostini/rclone.conf ~/.config/rclone
sudo mkdir -p /etc/samba
sudo cp ~/Other\ Stuff/Chrome\ OS/Crostini/smb.conf /etc/samba/smb.conf
echo "farmerbb = Braden" | sudo tee /etc/samba/usermap.txt > /dev/null
mkdir -p ~/.ssh
cp ~/Other\ Stuff/Chrome\ OS/Crostini/config ~/.ssh/config
sudo cp ~/Other\ Stuff/Chrome\ OS/Crostini/hosts /etc/hosts
```

**Create Samba user:**
 
```
sudo smbpasswd -a farmerbb
```

## Applications

**Download apps:**

* SmartGit: <https://www.syntevo.com/smartgit/download>

* NoMachine: <https://www.nomachine.com/download/linux>  

**Install downloaded deb packages:**
 
```
for i in ~/Downloads/*.deb; do sudo dpkg -i $i; done
```

**Install other apps:**

```
sudo apt install thunar bleachbit gimp mousepad qdirstat synaptic gnome-system-monitor audacity ristretto rhythmbox evince gnome-tweaks cura vlc
```

**Fix desktop files:**

```
fix-gtk3-desktop-file /usr/share/applications/syntevo-smartgit.desktop
fix-qt-desktop-file /usr/share/applications/vlc.desktop
fix-thunar
```

## SSH Keys

**Generate SSH key:**

```
ssh-keygen
cat ~/.ssh/id_rsa.pub
```

* Copy to clipboard

**Add SSH key to source control sites:**

* GitHub: <https://github.com/settings/ssh/new>

* GitLab: <https://gitlab.com/-/profile/keys>

**Add SSH key to remote hosts** (`pi2`, `nuc`, `pc`)

```
nano ~/.ssh/authorized_keys
```

* Paste new SSH key at bottom of file

* Remove older entrie(s) for farmerbb@penguin

**Add SSH key to local Chrome OS host** (`crosh`)

```
echo "(paste key here)" > ~/.ssh/authorized_keys
```

<s>**Add SSH key to local Android host** (SimpleSSHD)</s>

* <s>*Fresh app install:* Three-dot menu → Settings → check "Start on Boot" and "Start on Open"</s>

* <s>*Existing app install:* Three-dot menu → Reset Keys</s>


<s>`ssh 100.115.92.14 -p 2222`</s>

<s>`echo "(paste key here)" > authorized_keys`</s>

**Restore NoMachine settings (must be done after Settings folder is mounted):**

```
cp -r ~/Settings/NoMachine\ Settings/NoMachine ~
cp -r ~/Settings/NoMachine\ Settings/\*.nx\ \(Linux\) ~/.nx
```

## Development

**Install Android Studio and Android SDK:**

```
install-android-studio
install-android-sdk
```

**Copy files for Android development:**

```
cp ~/OneDrive/Android/Development/*.sh ~/AndroidStudioProjects
chmod +x ~/AndroidStudioProjects/*.sh
cp ~/OneDrive/Android/Development/Keys/Keystore ~
cp ~/OneDrive/Android/Development/gradle.properties ~/.gradle
```

**Clone GitHub projects:**

```
cd ~/AndroidStudioProjects
for i in Notepad SecondScreen Taskbar AppNotifier; do git clone git@github.com:farmerbb/$i.git; done
cd -
```

**<s>Set up remote execution (Mirakle):</s>**

<s>`cp -r ~/OneDrive/Android/Miscellaneous/Remote\ Execution/init.d ~/.gradle`</s>

## Wine

**Install Wine:**

```
install-wine
```

**Create .wine-cdrom directory:**

```
mkdir -p ~/.wine-cdrom
```

**Create Wine prefixes:**

*Common settings for all prefixes:*

* Libraries → New override for library: ddraw → Add → Yes

* Drives → Add → D: → Path: /home/farmerbb

* Drives → Add → A: → Path: /home/farmerbb/.wine-cdrom → Show Advanced → Type: CD-ROM

* Desktop Integration → Theme → Light
 
```
WINEPREFIX=~/.wine $(which winecfg)
```

* Graphics → Screen Resolution: 168

```
WINEPREFIX=~/.wine-monitor $(which winecfg)
```

```
winebox $(which winecfg)
```

* Applications → Windows version: Windows 95

* Graphics → *uncheck "Allow the window manager to..." options*

**Share drive C: across 64-bit prefixes**
 
```
mv ~/.wine/drive_c/ ~/.drive_c
ln -s ~/.drive_c ~/.wine/drive_c
rm -r ~/.wine-monitor/drive_c/
ln -s ~/.drive_c ~/.wine-monitor/drive_c
```

**Convert lnks to desktop files:**

```
convert-lnks
```

## Virtual Machines (QEMU / KVM)

**Install virt-manager:**

```
sudo apt install virt-manager
sudo cp ~/Other\ Stuff/Linux/virt-manager/virt-manager.desktop /usr/share/applications/virt-manager.desktop
```

**Install TPM emulation (for Windows 11):**

```
install-swtpm
```

**Fix qemu.conf file & copy hooks:**
 
```
echo "remember_owner=0" | sudo tee -a /etc/libvirt/qemu.conf > /dev/null

sudo cp ~/Other\ Stuff/Linux/virt-manager/hooks/* /etc/libvirt/hooks

sudo chmod +x /etc/libvirt/hooks/*
```

* Shut down and restart Crostini before proceeding

**Define VMs:**
 
```
for i in ~/Other\ Stuff/Linux/virt-manager/*.xml; do sudo virsh define "$i"; done
```

**Create disk images:**  
  
```
sudo chmod -R 777 /var/lib/libvirt/images/
qcow2-create /var/lib/libvirt/images/win11.qcow2 65G
qcow2-create /var/lib/libvirt/images/ubuntu21.10.qcow2 20G
```

**Auto-start network:**

```
sudo virsh net-start default
sudo virsh net-autostart default
```

## Finishing Touches

**Apply themes / fonts:**

```
apply-theme
```

* **Note:** For better looking Segoe UI fonts at high DPI, pull them from C:\\Windows\\Fonts on a Windows 11 machine / VM, then replace the files in `/usr/share/fonts/truetype/segoe-ui` and run `sudo fc-cache -f -v`

**Fix issues with missing icons:**

```
convert-svgs
refresh-icons
tmp-exec ~/Other\ Stuff/Chrome\ OS/Crostini/JetBrains/Icon\ Fixer/configure.sh
```

**Install essential software:**

```
install-log2ram
install-scrcpy
install-adbfs
install-advcpmv
```

**Install additional software (as needed):**

```
install-docker
install-steam
fix-steam
install-dolphin
install-celestia
```
