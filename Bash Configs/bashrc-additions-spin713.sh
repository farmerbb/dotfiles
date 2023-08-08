export LINUX_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux)"
export DEVICE_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux/Devices/Acer\ Spin\ 713)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/Acer Spin 713"
export BTRFS_MNT="/mnt/files"
export BTRFS_HOME_MNT="/mnt/files/Local/Home"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

export SYNC_DIRS=(
  "Media/Braden's Music"
  "Other Stuff"
)

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1

# Remove once installed kernel is >= 6.2.13
UUID=$(sudo btrfs filesystem show -m | grep uuid | cut -d' ' -f5)
echo 1000 | sudo tee /sys/fs/btrfs/$UUID/discard/iops_limit > /dev/null
