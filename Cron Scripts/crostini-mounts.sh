#!/bin/bash
unset HISTFILE

[[ -f /tmp/crostini-mounts.running ]] && exit 1
touch /tmp/crostini-mounts.running

##################################################

# Mount operations are placed here instead of /etc/fstab,
# in order to vastly improve container startup time.
# This also allows them to appear in the side menu of file managers.

# To allow pings on Windows PCs:
#   netsh advfirewall firewall add rule name="Allow pings" protocol=icmpv4:8,any dir=in action=allow

check-ssid() {
  touch ~/.ssid
  SSID=$(ssh crosh sudo iw dev wlan0 info | grep -Po '(?<=ssid ).*')

  OLD_SSID=$(cat ~/.ssid)
  echo $SSID > ~/.ssid

  HOME_SSID="[REDACTED]"

  [[ $OLD_SSID = $SSID ]] && return
  [[ $OLD_SSID != $HOME_SSID ]] && [[ $SSID != $HOME_SSID ]] && return

  sudo umount ~/NUC
  [[ -z $SSID ]] && return

  if [[ $SSID = $HOME_SSID ]]; then
    sed -i '13,14 s/^##*//' ~/.ssh/config
    sed -i '15,16 s/^/#/' ~/.ssh/config
  else
    sed -i '13,14 s/^/#/' ~/.ssh/config
    sed -i '15,16 s/^##*//' ~/.ssh/config
  fi
}

mountpoint -q ~/OneDrive || \
daemonize $(which rclone) --vfs-cache-mode writes mount OneDrive: ~/OneDrive

mountpoint -q ~/AndroidData || \
# sshfs 100.115.92.14:/storage/emulated/0 ~/AndroidFiles -p 2222
CROS_USER_ID_HASH=$(ssh crosh ls /home/user) && \
sshfs root@crosh:/home/.shadow/$CROS_USER_ID_HASH/mount/root/android-data/data ~/AndroidData

mountpoint -q ~/ChromeOS || \
sshfs crosh:/ ~/ChromeOS -o follow_symlinks

# check-ssid

# mountpoint -q ~/NUC || ping -c1 -W1 nuc && \
# sshfs nuc:/ ~/NUC -o follow_symlinks

mountpoint -q ~/Other\ Stuff/Linux/Scripts || \
sudo bindfs --perms=0755 ~/Other\ Stuff/Linux/Scripts ~/Other\ Stuff/Linux/Scripts

mountpoint -q ~/Other\ Stuff/Operating\ Systems || \
sudo bindfs --perms=0777 --force-user=libvirt-qemu --force-group=libvirt-qemu ~/Other\ Stuff/Operating\ Systems ~/Other\ Stuff/Operating\ Systems

# mountpoint -q ~/Games/PC\ Games/Emulators\ \&\ Ports || \
# sudo bindfs --perms=0755 ~/Games/PC\ Games/Emulators\ \&\ Ports ~/Games/PC\ Games/Emulators\ \&\ Ports

# mountpoint -q ~/Games/Utilities || \
# sudo bindfs --perms=0755 ~/Games/Utilities ~/Games/Utilities

mountpoint -q ~/Other\ Stuff/Utilities/7-Zip/Linux || \
sudo bindfs --perms=0755 ~/Other\ Stuff/Utilities/7-Zip/Linux ~/Other\ Stuff/Utilities/7-Zip/Linux

timeout 10 mount-nuc
timeout 10 mount-adbfs
ssh crosh sudo mount -o remount,exec /home/chronos/user

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/crostini-mounts.lastrun
rm -f /tmp/crostini-mounts.running
