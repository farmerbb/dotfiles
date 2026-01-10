export LINUX_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux)"
# export DEVICE_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux/Devices/VM)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
# export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/VM"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1
