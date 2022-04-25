#!/bin/bash

NAME="$@"
if [[ ! -f "/mnt/files/Local/Backup/win11-vfio.$NAME.qcow2" ]]; then
  echo "Available backups:"
  ls -1 /mnt/files/Local/Backup/win11-vfio.*.qcow2 | cut -d'.' -f2
  echo
  BASENAME=$(basename "$0")
  echo "Usage: $BASENAME <name-of-backup>"
  exit 1
fi

[[ -z $(which pv) ]] && sudo apt-get install -y pv

echo "Shutting down VM..."
touch /tmp/vm-maintenance
sudo virsh shutdown win11-vfio >/dev/null 2>&1

SECONDS=0
while sudo virsh list | grep win11-vfio >/dev/null 2>&1; do
  sleep 1

  if [[ $SECONDS -ge 30 ]]; then
    echo "VM is taking a while to shutdown, trying again..."
    sudo virsh shutdown win11-vfio >/dev/null 2>&1
    SECONDS=0
  fi
done

echo "Restoring backup \"$NAME\"..."
sudo bash -c "pv < \"/mnt/files/Local/Backup/win11-vfio.$NAME.qcow2\" > /var/lib/libvirt/images/win11-vfio.qcow2"

echo "Restarting VM..."
sudo virsh start win11-vfio >/dev/null 2>&1
rm /tmp/vm-maintenance
