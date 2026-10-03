@echo off

title "VFIO Host Mounts"
"Z:\Other Stuff\Utilities\NirCmd\nircmd.exe" win hide ititle "VFIO Host Mounts"

ssh farmerbb@192.168.86.23 "sudo mount -t cifs -o user=Braden,credentials=/home/farmerbb/.sharelogin,uid=farmerbb,gid=farmerbb //192.168.86.24/C /mnt/c"
ssh farmerbb@192.168.86.23 "sudo mount -t cifs -o user=Braden,credentials=/home/farmerbb/.sharelogin,uid=farmerbb,gid=farmerbb //192.168.86.24/Z /mnt/files"
exit
