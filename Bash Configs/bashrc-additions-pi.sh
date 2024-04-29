export LINUX_DIR_PREFIX="$(realpath ~/Other\ Stuff/Linux)"
export DEVICE_DIR_PREFIX="$(realpath ~/Other\ Stuff/Linux/Devices/Raspberry\ Pi\ 3B+)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/Raspberry Pi 3B+"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

export SYNC_DIRS=(
  "Other Stuff/Linux"
  "Other Stuff/Raspberry Pi/picons"
)

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1
