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
export BTRFS_MNT="/mnt/files"
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

alias enable-touchscreen="xinput --enable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias enable-trackpad="xinput --enable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias disable-touchscreen="xinput --disable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias disable-trackpad="xinput --disable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias snapper="$(which snapper) -c home"
alias virtualhere-client="sudo pkill vhuit64 && sleep 3; sudo daemonize /mnt/files/Other\ Stuff/Utilities/VirtualHere/vhuit64"

chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1

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

export-extension-config() {
  DIR="$DEVICE_DIR_PREFIX/extensions"
  FILE="$DIR/$1.txt"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    dconf dump /org/gnome/shell/extensions/$1/ > "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/extensions/$1.txt"
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$DEVICE_DIR_PREFIX/##g"):\033[0m"
    ls "$DIR"/*.txt | sed -e "s#$DIR/##g" -e "s/\.txt//g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m export-extension-config <name of extension>"
  fi
}

import-extension-config() {
  DIR="$DEVICE_DIR_PREFIX/extensions"
  FILE="$DIR/$1.txt"
  if [[ -f "$FILE" ]]; then
    dconf load /org/gnome/shell/extensions/$1/ < "$FILE"
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$DEVICE_DIR_PREFIX/##g"):\033[0m"
    ls "$DIR"/*.txt | sed -e "s#$DIR/##g" -e "s/\.txt//g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m import-extension-config <name of extension>"
  fi
}

edit-grub-config() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/grub"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo nano /etc/default/grub
    cp /etc/default/grub "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/grub"
  fi

  sudo sed -i 's/quick_boot="1"/quick_boot="0"/g' /etc/grub.d/30_os-prober
  sudo update-grub
}

edit-fstab() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/fstab"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo nano /etc/fstab
    cp /etc/fstab "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/fstab"
  fi

  sudo mount -a
}

boot-to-windows() {
  timedatectl set-local-rtc 1

  WINDOWS_MENU_TITLE=$(sudo awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep -i windows)
# sudo grub-reboot "$WINDOWS_MENU_TITLE"
  sudo grub-set-default "$WINDOWS_MENU_TITLE"
  sudo shutdown -r now
}

install-blackbox() {
  sudo apt-get -y install flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.raggesilver.BlackBox
  flatpak update -y com.raggesilver.BlackBox
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /var/lib/flatpak/exports/bin/com.raggesilver.BlackBox 100
}

export -f allow-all-usb
export -f make-trackpad-great-again
export -f export-extension-config
export -f import-extension-config
export -f edit-grub-config
export -f edit-fstab
export -f boot-to-windows
export -f install-blackbox
