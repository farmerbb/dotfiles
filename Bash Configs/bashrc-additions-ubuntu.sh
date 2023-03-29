if [[ $XDG_SESSION_TYPE = x11 ]]; then
  alias enable-touchscreen="xinput --enable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
  alias enable-trackpad="xinput --enable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
  alias disable-touchscreen="xinput --disable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
  alias disable-trackpad="xinput --disable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
fi

alias virtualhere-client="sudo pkill vhuit64 && sleep 3; sudo daemonize /mnt/files/Other\ Stuff/Utilities/VirtualHere/vhuit64"

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

export-extension-config() {
  DIR="$LINUX_DIR_PREFIX/Ubuntu/extensions"
  FILE="$DIR/$1.txt"
  CONFIG_DIR="$DIR/$1"

  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    dconf dump /org/gnome/shell/extensions/$1/ > "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Ubuntu/extensions/$1.txt"

    if [[ -d "$CONFIG_DIR" ]]; then
      for i in "$LINUX_DIR_PREFIX" "$OD_LINUX_DIR_PREFIX"; do
        rm -rf "$i/Ubuntu/extensions/$1"
        cp -r ~/.config/$1 "$i/Ubuntu/extensions/$1"
      done
    fi
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$LINUX_DIR_PREFIX/Ubuntu/##g"):\033[0m"
    ls "$DIR"/*.txt | sed -e "s#$DIR/##g" -e "s/\.txt//g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m export-extension-config <name of extension>"
  fi
}

import-extension-config() {
  DIR="$LINUX_DIR_PREFIX/Ubuntu/extensions"
  FILE="$DIR/$1.txt"
  CONFIG_DIR="$DIR/$1"

  if [[ -f "$FILE" ]]; then
    dconf load /org/gnome/shell/extensions/$1/ < "$FILE"

    if [[ -d "$CONFIG_DIR" ]]; then
      rm -rf ~/.config/$1
      cp -r "$CONFIG_DIR" ~/.config
    fi
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$LINUX_DIR_PREFIX/Ubuntu/##g"):\033[0m"
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

boot-to-windows() {
  timedatectl set-local-rtc 1

  WINDOWS_MENU_TITLE=$(sudo awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep -i windows)
# sudo grub-reboot "$WINDOWS_MENU_TITLE"
  sudo grub-set-default "$WINDOWS_MENU_TITLE"
  sudo shutdown -r now
}

install-blackbox() {
  if [[ -z $(which flatpak) ]]; then
    sudo apt-get update
    sudo apt-get -y install flatpak
  fi

  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.raggesilver.BlackBox
  flatpak update -y com.raggesilver.BlackBox
  sudo flatpak override com.raggesilver.BlackBox --filesystem=host
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /var/lib/flatpak/exports/bin/com.raggesilver.BlackBox 100

  mkdir -p ~/.var/app
  cp -r "$LINUX_DIR_PREFIX/Ubuntu/com.raggesilver.BlackBox" ~/.var/app

  echo '#!/bin/bash' | sudo tee /usr/local/bin/blackbox > /dev/null
  echo 'REALPATH=$(realpath "$1")' | sudo tee -a /usr/local/bin/blackbox > /dev/null
  echo 'flatpak run com.raggesilver.BlackBox --working-directory="$REALPATH"' | sudo tee -a /usr/local/bin/blackbox > /dev/null
  sudo chmod +x /usr/local/bin/blackbox

  gsettings set org.cinnamon.desktop.default-applications.terminal exec blackbox
}

install-tlp() {
  sudo apt-get update
  sudo apt-get -y install tlp tlp-rdw
  sudo systemctl enable tlp.service
  sudo tlp start
  tlp-stat -s
}

install-ssh-server() {
  sudo apt-get update
  sudo apt-get -y install openssh-server
  sudo ufw allow ssh
}

open-youtube-tv() {
  [[ ! -z $(pgrep chrome) ]] && return 1

  x-www-browser youtube.com/tv &
  sleep 5

  xdotool key ctrl+r
  xdotool key F11
  sleep 1

  xdotool mousemove 2970 165
  xdotool click 1
}

install-wireguard-server() {
  [[ -z $(which docker) ]] && install-docker

  docker run -d \
    --name=wireguard \
    --cap-add=NET_ADMIN \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Denver \
    -e SERVERURL=[REDACTED] \
    -e SERVERPORT=[REDACTED] \
    -e PEERS=5 \
    -e PEERDNS=192.168.86.1 \
    -e ALLOWEDIPS=10.13.13.0/24,192.168.86.0/24,94.140.14.14/32 \
    -e LOG_CONFS=true \
    -p 51820:51820/udp \
    -v /mnt/files/Other\ Stuff/Linux/Network\ Config/WireGuard:/config \
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --restart unless-stopped \
    lscr.io/linuxserver/wireguard:latest
}

install-input-remapper() {
  sudo apt-get update
  sudo apt-get -y install input-remapper
  sudo cp -r "$DEVICE_DIR_PREFIX/input-remapper" ~/.config
}

fix-extensions() {
  dconf write /org/gnome/shell/disable-user-extensions false

  for i in $(gnome-extensions list); do
    EXT_PATH=$(gnome-extensions info $i | grep "Path:" | cut -d' ' -f4)
    EXT_COMMAND=enable
#   [[ "$EXT_PATH" = /home/$USER/* ]] && EXT_COMMAND=enable || EXT_COMMAND=disable
    gnome-extensions $EXT_COMMAND $i
  done
}

fix-libvirt-permissions() {
  echo -e '\nuser = "farmerbb"\ngroup = "farmerbb"' | sudo tee -a /etc/libvirt/qemu.conf > /dev/null
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

wireguard-server-shell() {
  if [[ $HOSTNAME = NUC ]]; then
    docker exec -it wireguard /bin/bash
    return 0
  fi

  ssh nuc -o LogLevel=QUIET -t docker exec -it wireguard /bin/bash
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

  while [[ true != $(waydroid prop get persist.waydroid.multi_windows) ]]; do
    sleep 1
    waydroid prop set persist.waydroid.multi_windows true
  done

  while [[ -z $GSF_ID ]]; do
    sleep 1
    GSF_ID=$(sudo sqlite3 ~/.local/share/waydroid/data/data/com.google.android.gsf/databases/gservices.db \
      "select * from main where name = \"android_id\";" | cut -d'|' -f2)
  done

  echo
  echo "  https://www.google.com/android/uncertified/"
  echo "  GSF ID: $GSF_ID"
  echo

  sudo systemctl restart waydroid-container
}

toggle-vm-maintenance() {
  if [[ -f /tmp/vm-maintenance ]]; then
    rm /tmp/vm-maintenance
    echo "VM maintenance off"
  else
    touch /tmp/vm-maintenance
    echo "VM maintenance on"
  fi
}

export -f allow-all-usb
export -f make-trackpad-great-again
export -f export-extension-config
export -f import-extension-config
export -f edit-grub-config
export -f edit-fstab
export -f edit-synaptics
export -f boot-to-windows
export -f install-blackbox
export -f install-tlp
export -f install-ssh-server
export -f open-youtube-tv
export -f install-wireguard-server
export -f install-input-remapper
export -f fix-extensions
export -f fix-libvirt-permissions
export -f remove-all-snaps
export -f wireguard-server-shell
export -f install-plex-server
export -f install-waydroid
export -f toggle-vm-maintenance
