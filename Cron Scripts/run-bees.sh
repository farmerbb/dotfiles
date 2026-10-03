#!/bin/bash
unset HISTFILE

[[ -f /tmp/run-bees.running ]] && exit 1
touch /tmp/run-bees.running

##################################################

start-bees() {
  [[ ! -z $(pidof bees) ]] && exit 1
  [[ -f /tmp/.btrfs-maintenance ]] && exit 1

  sudo umount /run/bees/mnt/* >/dev/null 2>&1
  sudo daemonize /usr/sbin/beesd $(sudo btrfs filesystem show -m | grep uuid | cut -d' ' -f5 | head -n1)
  while [[ -z $(pgrep bees) ]]; do sleep 1; done

  for i in $(pgrep bees); do
    sudo schedtool -D -n20 $i
    sudo ionice -c3 -p $i
  done
}

CHARGING=$(cat /sys/class/power_supply/AC/online >/dev/null 2>&1)
BATTERY=$(cat /sys/class/power_supply/BAT0/capacity >/dev/null 2>&1)

if [[ ! -d /sys/class/power_supply/BAT0 || $CHARGING != 0 && $BATTERY > 90 || $BATTERY = 100 ]]; then
  start-bees
else
  sudo pkill bees || true
fi

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/run-bees.lastrun
rm -f /tmp/run-bees.running
