#!/bin/bash
unset HISTFILE

[[ -f /tmp/btrfs-configure-reclaim.running ]] && exit 1
touch /tmp/btrfs-configure-reclaim.running

##################################################

SYSFS_PATH=/sys/fs/btrfs/$(sudo btrfs filesystem show -m | grep uuid | cut -d' ' -f5)/allocation/data
for i in dynamic_reclaim periodic_reclaim; do
  echo 1 | sudo tee $SYSFS_PATH/$i > /dev/null
done

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/btrfs-configure-reclaim.lastrun
rm -f /tmp/btrfs-configure-reclaim.running
