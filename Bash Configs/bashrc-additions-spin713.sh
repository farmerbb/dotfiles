<<'##################################################'

# To install, run the following:

echo '' >> ~/.bashrc
echo 'for i in linux-generic ubuntu spin713; do' >> ~/.bashrc
echo '  source /mnt/files/Other\ Stuff/Linux/Bash\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc

##################################################

export LINUX_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux)"
export DEVICE_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux/Devices/Acer Spin 713)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/Acer Spin 713"
export BTRFS_MNT="/mnt/files"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

export SYNC_DIRS=(
  "Media/Braden's Music"
  "Other Stuff"
)

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1