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

mountpoint -q /mnt/OneDrive || \
daemonize $(which rclone) --vfs-cache-mode writes mount OneDrive: /mnt/OneDrive

mount-cifs 192.168.86.4 internal /mnt/shield farmerbb [REDACTED]
mount-cifs 192.168.86.5 C /mnt/PC/C Braden
mount-cifs 192.168.86.5 Z /mnt/PC/Z Braden
mount-cifs 192.168.86.24 SystemScratch /mnt/xbox DevToolsUser [REDACTED]

timeout 10 mount-sshfs pi /mnt/pi

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/nuc-mounts.lastrun
rm -f /tmp/nuc-mounts.running
