#!/bin/bash
unset HISTFILE

[[ -f /tmp/daily-maintenance.running ]] && exit 1
touch /tmp/daily-maintenance.running

##################################################

convert-lnks
vm-clean
[[ $(date +%w) = 0 ]] && btrfs-defrag
btrfs-dedupe

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/daily-maintenance.lastrun
rm -f /tmp/daily-maintenance.running
