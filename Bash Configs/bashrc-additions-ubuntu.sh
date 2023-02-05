alias enable-touchscreen="xinput --enable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias enable-trackpad="xinput --enable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias disable-touchscreen="xinput --disable $(xinput --list | grep -i 'Finger touch' | grep -o 'id=[0-9]*' | sed 's/id=//')"
alias disable-trackpad="xinput --disable $(xinput --list | grep -i 'Touchpad' | grep -o 'id=[0-9]*' | sed 's/id=//')"
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
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    dconf dump /org/gnome/shell/extensions/$1/ > "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Ubuntu/extensions/$1.txt"
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
  if [[ -f "$FILE" ]]; then
    dconf load /org/gnome/shell/extensions/$1/ < "$FILE"
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

boot-to-windows() {
  timedatectl set-local-rtc 1

  WINDOWS_MENU_TITLE=$(sudo awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep -i windows)
# sudo grub-reboot "$WINDOWS_MENU_TITLE"
  sudo grub-set-default "$WINDOWS_MENU_TITLE"
  sudo shutdown -r now
}

install-blackbox() {
  sudo apt-get update
  sudo apt-get -y install flatpak
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

install-unclutter() {
  sudo apt-get update
  sudo apt-get -y install unclutter-xfixes
  sudo cp "$LINUX_DIR_PREFIX/Ubuntu/unclutter" /etc/default/unclutter
}

open-youtube-tv() {
  x-www-browser youtube.com/tv &
  sleep 3

  xdotool key ctrl+r
  xdotool key F11
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
    -e PEERDNS=1.1.1.1 \
    -e LOG_CONFS=true \
    -p 51820:51820/udp \
    -v /mnt/files/Other\ Stuff/Network\ Config/WireGuard:/config \
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --restart unless-stopped \
    lscr.io/linuxserver/wireguard:latest
}

export -f allow-all-usb
export -f make-trackpad-great-again
export -f export-extension-config
export -f import-extension-config
export -f edit-grub-config
export -f edit-fstab
export -f boot-to-windows
export -f install-blackbox
export -f install-tlp
export -f install-ssh-server
export -f install-unclutter
export -f open-youtube-tv
export -f install-wireguard-server
