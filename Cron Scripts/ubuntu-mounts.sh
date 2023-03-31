#!/bin/bash
unset HISTFILE

[[ -f /tmp/ubuntu-mounts.running ]] && exit 1
touch /tmp/ubuntu-mounts.running

##################################################

mountpoint -q ~/OneDrive || \
daemonize $(which rclone) --vfs-cache-mode writes mount OneDrive: ~/OneDrive

mountpoint -q ~/AndroidData || \
sudo bindfs --force-user=farmerbb --force-group=farmerbb ~/.local/share/waydroid/data ~/AndroidData

timeout 10 mount-nuc
timeout 10 mount-adbfs

run-bees

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/ubuntu-mounts.lastrun
rm -f /tmp/ubuntu-mounts.running
