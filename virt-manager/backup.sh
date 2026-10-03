#!/bin/bash

NAME="$@"
[[ -z "$NAME" ]] && NAME="$(date +%Y%m%d)"

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

echo "Creating backup \"$NAME\"..."
mkdir -p /mnt/files/Local/Backup
sudo bash -c "qemu-img convert -p -f qcow2 -O qcow2 -o cluster_size=2M /var/lib/libvirt/images/win11-vfio.qcow2 \"/mnt/files/Local/Backup/win11-vfio.$NAME.qcow2\""

echo "Restarting VM..."
sudo virsh start win11-vfio >/dev/null 2>&1
rm /tmp/vm-maintenance
