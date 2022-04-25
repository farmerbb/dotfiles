#!/bin/bash
unset HISTFILE

[[ -f /tmp/wsl2-mounts.running ]] && exit 1
touch /tmp/wsl2-mounts.running

##################################################

# Mount operations are placed here instead of /etc/fstab,
# in order to vastly improve container startup time.

# Before installing this in crontab, run the following commands:
#   sudo apt install cifs-utils
#   echo [REDACTED] | base64 -d > ~/.sharelogin

# To allow pings on Windows PCs:
#   netsh advfirewall firewall add rule name="Allow pings" protocol=icmpv4:8,any dir=in action=allow

mountpoint -q ~/OneDrive || \
daemonize $(which rclone) --vfs-cache-mode writes mount OneDrive: ~/OneDrive

mountpoint -q /mnt/shield || ping -c1 -W1 192.168.86.4 && \
sudo mount -t cifs -o user=farmerbb,password=bile-scam-kx,uid=farmerbb,gid=farmerbb //192.168.86.4/internal /mnt/shield

mountpoint -q /mnt/shield2 || ping -c1 -W1 192.168.86.8 && \
sudo mount -t cifs -o user=farmerbb,password=weeks-pill-bled,uid=farmerbb,gid=farmerbb //192.168.86.8/internal /mnt/shield2

mountpoint -q /mnt/PC/C || ping -c1 -W1 192.168.86.5 && \
sudo mount -t cifs -o user=Braden,credentials=/home/farmerbb/.sharelogin,uid=farmerbb,gid=farmerbb //192.168.86.5/C /mnt/PC/C || true

mountpoint -q /mnt/PC/D || ping -c1 -W1 192.168.86.5 && \
sudo mount -t cifs -o user=Braden,credentials=/home/farmerbb/.sharelogin,uid=farmerbb,gid=farmerbb //192.168.86.5/D /mnt/PC/D || true

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/wsl2-mounts.lastrun
rm -f /tmp/wsl2-mounts.running
