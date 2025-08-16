#!/bin/bash
unset HISTFILE

[[ -f /tmp/nuc-mounts.running ]] && exit 1
touch /tmp/nuc-mounts.running

##################################################

# Mount operations are placed here instead of /etc/fstab.

# Before installing this in crontab, run the following commands:
#   sudo apt install cifs-utils
#   echo password=$(echo [REDACTED] | base64 -d) > ~/.sharelogin

# To allow pings on Windows PCs:
#   netsh advfirewall firewall add rule name="Allow pings" protocol=icmpv4:8,any dir=in action=allow

for i in OneDrive OneDrive-2 OneDrive-3; do
  # user_allow_other must be uncommented in /etc/fuse.conf for --allow-other to take effect
  mountpoint -q /mnt/$i || \
  daemonize $(which rclone) --vfs-cache-mode full mount --allow-other ${i}: /mnt/$i
done

mount-cifs 192.168.86.4 internal /mnt/shield farmerbb [REDACTED]
mount-cifs 192.168.86.5 C /mnt/PC/C Braden
mount-cifs 192.168.86.5 Z /mnt/PC/Z Braden
mount-cifs 192.168.86.24 SystemScratch /mnt/xbox DevToolsUser [REDACTED]

timeout 10 mount-sshfs pi /mnt/pi
timeout 10 mount-adbfs

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/nuc-mounts.lastrun
rm -f /tmp/nuc-mounts.running
