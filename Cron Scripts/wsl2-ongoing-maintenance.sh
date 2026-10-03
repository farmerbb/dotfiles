#!/bin/bash
unset HISTFILE

sudo sysctl -p
sudo sysctl -w net.ipv4.ping_group_range="0 1000"
sudo chmod 666 /dev/kvm

rm -f /tmp/*.running
bash -i /mnt/z/Other\ Stuff/Linux/Cron\ Scripts/wsl2-mounts.sh

# mem-below-threshold() {
#   echo "$(awk '$3=="kB"{printf ": %.0f:", $2=$2*1024;} 1' /proc/meminfo | grep MemAvailable | cut -d':' -f2 | sed 's/,//g') < $1 * 1024^3" | bc -l
# }

# while true; do
#   [[ ! -z $(pgrep java) ]] && ([[ $(mem-below-threshold 0.5) = 1 ]] && gradle-idle-stop || return 0)
#   sleep 5
# done
