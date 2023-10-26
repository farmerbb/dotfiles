if [[ $XDG_SESSION_TYPE = x11 ]]; then
  alias enable-touchscreen="xinput --enable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
# alias enable-trackpad="xinput --enable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
  alias disable-touchscreen="xinput --disable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
# alias disable-trackpad="xinput --disable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
fi

alias enable-trackpad="gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled"
alias disable-trackpad="gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled"

virtualhere-client() {
  chmod +x /mnt/files/Other\ Stuff/Utilities/VirtualHere/vhuit64
  sudo pkill vhuit64 && sleep 3
  sudo daemonize /mnt/files/Other\ Stuff/Utilities/VirtualHere/vhuit64
}

allow-all-usb() {
  echo 'SUBSYSTEM=="usb", MODE="0660", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/00-usb-permissions.rules >/dev/null
  sudo udevadm control --reload-rules
}

make-trackpad-great-again() {
  sudo add-apt-repository -y ppa:touchegg/stable
  sudo apt-get update
  sudo apt-get -y install touchegg xserver-xorg-input-synaptics

  mkdir -p ~/.config/touchegg
  cp "$LINUX_DIR_PREFIX/Ubuntu/touchegg.conf" ~/.config/touchegg
  sudo cp "$DEVICE_DIR_PREFIX/80synaptics" /etc/X11/Xsession.d

  echo
  echo 'Please log out, and log back in using the "Ubuntu on Xorg" session.'
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

edit-synaptics() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/80synaptics"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo nano /etc/X11/Xsession.d/80synaptics
    cp /etc/X11/Xsession.d/80synaptics "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/80synaptics"
  fi

  pkill syndaemon
  bash /etc/X11/Xsession.d/80synaptics
}

edit-bluez-config() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/50-bluez-config.lua"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo nano /usr/share/wireplumber/bluetooth.lua.d/50-bluez-config.lua
    cp /usr/share/wireplumber/bluetooth.lua.d/50-bluez-config.lua "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/50-bluez-config.lua"
  fi

  systemctl --user restart wireplumber
}

edit-resolved-config() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/resolved.conf"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo nano /etc/systemd/resolved.conf
    cp /etc/systemd/resolved.conf "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/resolved.conf"
  fi

  sudo service systemd-resolved restart
  resolvectl status
}

boot-to-windows() {
  timedatectl set-local-rtc 1

  WINDOWS_MENU_TITLE=$(sudo awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep -i windows)
# sudo grub-reboot "$WINDOWS_MENU_TITLE"
  sudo grub-set-default "$WINDOWS_MENU_TITLE"
  sudo shutdown -r now
}

install-blackbox() {
  install-flatpak
  flatpak install flathub -y com.raggesilver.BlackBox
  sudo flatpak update -y --commit=1a3b7c86da1c662d5e793b03b83e9b02a4c151aea33fb03f07caaca1e576708a com.raggesilver.BlackBox

  sudo flatpak override com.raggesilver.BlackBox --filesystem=host
  sudo flatpak override com.raggesilver.BlackBox --device=all
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /var/lib/flatpak/exports/bin/com.raggesilver.BlackBox 100

  mkdir -p ~/.var/app
  cp -r "$LINUX_DIR_PREFIX/Ubuntu/com.raggesilver.BlackBox" ~/.var/app

  echo '#!/bin/bash' | sudo tee /usr/local/bin/blackbox > /dev/null
  echo 'flatpak run com.raggesilver.BlackBox --working-directory="$PWD"' | sudo tee -a /usr/local/bin/blackbox > /dev/null
  sudo chmod +x /usr/local/bin/blackbox

  gsettings set org.cinnamon.desktop.default-applications.terminal exec blackbox
}

install-ssh-server() {
  sudo apt-get update
  sudo apt-get -y install openssh-server
  sudo ufw allow ssh
}

install-input-remapper() {
  sudo apt-get update
  sudo apt-get -y install input-remapper
  sudo cp -r "$DEVICE_DIR_PREFIX/input-remapper" ~/.config
}

fix-libvirt-permissions() {
  echo -e '\nuser = "farmerbb"\ngroup = "farmerbb"\nsecurity_driver = "none"' | sudo tee -a /etc/libvirt/qemu.conf > /dev/null
  sudo service libvirtd restart
}

remove-all-snaps() {
  while [[ $SNAP_TO_REMOVE != "provided" ]]; do
    SNAP_TO_REMOVE=$(sudo snap remove $(snap list | awk '!/^Name|^snapd/ {print $1}' | grep -vxF core) 2>&1 | tr ' ' '\n' | tail -n1 | sed 's/\.//g')
    [[ $SNAP_TO_REMOVE != "removed" && $SNAP_TO_REMOVE != "provided" ]] && sudo snap remove $SNAP_TO_REMOVE
  done

  sudo snap remove snapd
  sudo apt remove --purge -y snapd gnome-software-plugin-snap
  sudo apt-mark hold snapd

  rm -rf ~/snap
}

install-plex-server() {
  echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list > /dev/null
  curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
  sudo apt-get update
  sudo apt-get -y install plexmediaserver
}

install-waydroid() {
  sudo apt-get update
  sudo apt-get -y install curl ca-certificates daemonize sqlite3 gir1.2-vte-2.91 gir1.2-webkit2-4.0

  curl https://repo.waydro.id | sudo bash
  sudo apt-get -y install waydroid

  sudo waydroid init -s GAPPS -f
  daemonize /usr/bin/waydroid session start

  wget -O - https://raw.githubusercontent.com/axel358/Waydroid-Settings/main/install.sh | bash

# while [[ true != $(waydroid prop get persist.waydroid.multi_windows) ]]; do
#   sleep 1
#   waydroid prop set persist.waydroid.multi_windows true
# done

  while [[ -z $GSF_ID ]]; do
    sleep 1
    GSF_ID=$(sudo sqlite3 ~/.local/share/waydroid/data/data/com.google.android.gsf/databases/gservices.db \
      "select * from main where name = \"android_id\";" | cut -d'|' -f2)
  done

  echo
  echo "  https://www.google.com/android/uncertified/"
  echo "  GSF ID: $GSF_ID"
  echo

# sudo systemctl restart waydroid-container
}

install-rhythmbox() {
  sudo apt-get update
  sudo apt-get -y install rhythmbox ubuntu-restricted-extras ttf-mscorefonts-installer-
  dconf load /org/gnome/rhythmbox/ < "$LINUX_DIR_PREFIX/Ubuntu/rhythmbox.txt"

  mkdir -p ~/.local/share/rhythmbox/profiles
  echo "Braden's Music" > ~/.local/share/rhythmbox/profiles/current.txt
}

toggle-ultrawide-fixes() {
  [[ $(dconf read /org/gnome/shell/extensions/tiling-assistant/adapt-edge-tiling-to-favorite-layout) = true ]] && \
    dconf reset /org/gnome/shell/extensions/tiling-assistant/adapt-edge-tiling-to-favorite-layout || \
    dconf write /org/gnome/shell/extensions/tiling-assistant/adapt-edge-tiling-to-favorite-layout true
}

install-eupnea-utils() {
  [[ $(sudo dmidecode -s system-manufacturer) != Google ]] && \
    echo "Not a Chromebook; exiting" && \
    return 1

  for i in ~/Other\ Stuff/Chrome\ OS/Eupnea/*.deb; do
    install-deb "$i"
  done

  /usr/lib/eupnea/set-keymap --automatic
  setup-audio
}

install-displaylink-driver() {
  if [[ ! -z $(which displaylink-installer) ]]; then
    sudo displaylink-installer uninstall
    sleep 1
  fi

  if [[ -z $(which wget) ]]; then
    sudo apt-get update
    sudo apt-get -y install wget
  fi

  wget https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
  install-deb synaptics-repository-keyring.deb
  rm synaptics-repository-keyring.deb

  sudo apt-get update
  sudo apt-get -y install displaylink-driver

  systemctl start displaylink-driver
}

install-flatpak() {
  if [[ -z $(which flatpak) ]]; then
    sudo apt-get update
    sudo apt-get -y install flatpak
  fi

  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

update-firmware() {
  CHARGING=$(cat /sys/class/power_supply/AC/online)
  if [[ $CHARGING = 0 ]]; then
    echo "Device must be charging to update firmware"
    return 1
  fi

  sudo fwupdmgr refresh --force && \
    sudo fwupdmgr get-updates && \
    sudo fwupdmgr update
}

adb-waydroid() {
  get_ip="ip addr show eth0 | grep 'inet ' | cut -d ' ' -f 6 | cut -d / -f 1"
  adb connect $(echo $get_ip | sudo waydroid shell):5555
}

install-wezterm() {
  curl -LO https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu22.04.deb
  install-deb ./wezterm-nightly.Ubuntu22.04.deb
  rm ./wezterm-nightly.Ubuntu22.04.deb

  rm -rf ~/.config/wezterm
  cp -r ~/Other\ Stuff/Linux/WezTerm ~/.config/wezterm
  ln -sf ~/.config/wezterm/wezterm-linux.lua .wezterm.lua

  echo '#!/bin/bash' | sudo tee /usr/local/bin/wezterm-start > /dev/null
  echo 'wezterm start --cwd "$PWD"' | sudo tee -a /usr/local/bin/wezterm-start > /dev/null
  sudo chmod +x /usr/local/bin/wezterm-start

  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/wezterm 101
  gsettings set org.cinnamon.desktop.default-applications.terminal exec wezterm-start
}

export -f virtualhere-client
export -f allow-all-usb
export -f make-trackpad-great-again
export -f edit-grub-config
export -f edit-fstab
export -f edit-synaptics
export -f edit-bluez-config
export -f edit-resolved-config
export -f boot-to-windows
export -f install-blackbox
export -f install-ssh-server
export -f install-input-remapper
export -f fix-libvirt-permissions
export -f remove-all-snaps
export -f install-plex-server
export -f install-waydroid
export -f install-rhythmbox
export -f toggle-ultrawide-fixes
export -f install-eupnea-utils
export -f install-displaylink-driver
export -f install-flatpak
export -f update-firmware
export -f adb-waydroid
export -f install-wezterm
