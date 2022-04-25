<<'##################################################'

# To install, run the following:

echo '' >> ~/.bashrc
echo 'for i in linux-generic android-dev ubuntu; do' >> ~/.bashrc
echo '  source /mnt/files/Other\ Stuff/Linux/Bash\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc

##################################################

export LINUX_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux)"
export DEVICE_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux/Ubuntu)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Ubuntu"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

alias virtualhere-client="sudo pkill vhuit64 && sleep 3; sudo daemonize /mnt/files/Other\ Stuff/Utilities/VirtualHere/vhuit64"

chmod +x "$LINUX_DIR_PREFIX/Scripts/"*
echo 10 | sudo tee /proc/sys/vm/swappiness >/dev/null

allow-all-usb() {
  echo 'SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/00-usb-permissions.rules >/dev/null
  sudo udevadm control --reload-rules
}

export -f allow-all-usb
