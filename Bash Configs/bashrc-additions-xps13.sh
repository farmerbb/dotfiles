export LINUX_DIR_PREFIX="/home/$USER/Other Stuff/Linux"
export DEVICE_DIR_PREFIX="/home/$USER/Other Stuff/Linux/Devices/Dell XPS 13"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/Dell XPS 13"
# export BTRFS_MNT="/mnt/files"
# export BTRFS_HOME_MNT="/mnt/files/Local/Home"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

export SYNC_DIRS=(
  "Games"
  "Media/Braden's Music"
  "Media/Other Audio"
  "Other Stuff"
)

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1
