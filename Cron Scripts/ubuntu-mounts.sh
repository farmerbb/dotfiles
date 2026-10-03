#!/bin/bash
unset HISTFILE

[[ -f /tmp/ubuntu-mounts.running ]] && exit 1
touch /tmp/ubuntu-mounts.running

##################################################

# Mount operations are placed here instead of /etc/fstab.

# Before installing this in crontab, run the following commands:
#   sudo apt install cifs-utils
#   echo password=$(echo [REDACTED] | base64 -d) > ~/.sharelogin

mountpoint -q /mnt/OneDrive || \
daemonize $(which rclone) --vfs-cache-mode full mount OneDrive-union: /mnt/OneDrive

# mountpoint -q /mnt/AndroidData || \
# sudo bindfs --force-user=farmerbb --force-group=farmerbb ~/.local/share/waydroid/data /mnt/AndroidData

# Moved to fstab
# timeout 10 mount-cifs 192.168.86.10 Files /mnt/NUC farmerbb
timeout 10 mount-adbfs

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/ubuntu-mounts.lastrun
rm -f /tmp/ubuntu-mounts.running
