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

alias arcmenu-hidpi="dconf write /org/gnome/shell/extensions/arcmenu/menu-height 1100"
alias arcmenu-lodpi="dconf write /org/gnome/shell/extensions/arcmenu/menu-height 550"
alias virtualhere-client="sudo pkill vhuit64 && sleep 3; sudo daemonize /mnt/files/Other\ Stuff/Utilities/VirtualHere/vhuit64"

chmod +x "$LINUX_DIR_PREFIX/Scripts/"*
echo 10 | sudo tee /proc/sys/vm/swappiness >/dev/null

allow-all-usb() {
  echo 'SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/00-usb-permissions.rules >/dev/null
  sudo udevadm control --reload-rules
}

make-trackpad-great-again() {
  sudo add-apt-repository -y ppa:touchegg/stable
  sudo apt-get update
  sudo apt-get -y install touchegg xserver-xorg-input-synaptics

  mkdir -p ~/.config/touchegg
  cp "$DEVICE_DIR_PREFIX/touchegg.conf" ~/.config/touchegg
  sudo cp "$DEVICE_DIR_PREFIX/80synaptics" /etc/X11/Xsession.d

  echo
  echo 'Please log out, and log back in using the "Ubuntu on Xorg" session.'
}

export-extensions-conf() {
  FILE="$DEVICE_DIR_PREFIX/extensions.conf"
  [[ -f "$FILE" ]] && MD5=$(md5sum "$FILE")

  dconf dump /org/gnome/shell/extensions/ > "$FILE"
  [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/extensions.conf"
}

import-extensions-conf() {
  FILE="$DEVICE_DIR_PREFIX/extensions.conf"
  dconf load /org/gnome/shell/extensions/ < "$FILE"
}

update-grub() {
  FILE="$DEVICE_DIR_PREFIX/grub"
  [[ -f "$FILE" ]] && MD5=$(md5sum "$FILE")

  cp /etc/default/grub "$FILE"
  [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/grub"

  sudo sed -i 's/quick_boot="1"/quick_boot="0"/g' /etc/grub.d/30_os-prober
  sudo $(which update-grub)
}

boot-to-windows() {
  timedatectl set-local-rtc 1

  WINDOWS_MENU_TITLE=$(sudo awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep -i windows)
  sudo grub-reboot "$WINDOWS_MENU_TITLE"
  sudo shutdown -r now
}

export -f allow-all-usb
export -f make-trackpad-great-again
export -f export-extensions-conf
export -f import-extensions-conf
export -f update-grub
export -f boot-to-windows
