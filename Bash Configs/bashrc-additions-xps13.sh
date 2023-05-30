export LINUX_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux)"
export DEVICE_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux/Devices/Dell\ XPS\ 13)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/Dell XPS 13"
export BTRFS_MNT="/mnt/files"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

export SYNC_DIRS=(
  "Games"
  "Media/Braden's Music"
  "Media/Other Audio"
  "Other Stuff"
)

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1

# Remove once installed kernel is >= 6.2.13
UUID=$(sudo btrfs filesystem show -m | grep uuid | cut -d' ' -f5)
echo 1000 | sudo tee /sys/fs/btrfs/$UUID/discard/iops_limit > /dev/null


