#!/bin/bash
unset HISTFILE

[[ -f /tmp/ubuntu-mounts.running ]] && exit 1
touch /tmp/ubuntu-mounts.running

##################################################

for i in OneDrive OneDrive-2 OneDrive-3; do
  mountpoint -q /mnt/$i || \
  daemonize $(which rclone) --vfs-cache-mode full mount ${i}: /mnt/$i
done

# mountpoint -q /mnt/AndroidData || \
# sudo bindfs --force-user=farmerbb --force-group=farmerbb ~/.local/share/waydroid/data /mnt/AndroidData

# timeout 10 mount-sshfs nuc /mnt/NUC
timeout 10 mount-cifs 192.168.86.10 Files /mnt/NUC farmerbb
timeout 10 mount-adbfs

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/ubuntu-mounts.lastrun
rm -f /tmp/ubuntu-mounts.running
