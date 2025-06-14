[[ $PATH != */usr/local/bin* ]] && export PATH="$PATH:/usr/local/bin"
[[ -z $USER ]] && export USER="$(id -un)"
[[ -z $DISPLAY ]] && export DISPLAY=":0"
[[ -z $DBUS_SESSION_BUS_ADDRESS ]] && export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
[[ -z $XDG_RUNTIME_DIR ]] && export XDG_RUNTIME_DIR="/run/user/$(id -u)"

TEMP_JAVA_PATH=$(realpath /etc/alternatives/java)
export JAVA_HOME="${TEMP_JAVA_PATH%%/bin/java}"
[[ ! -d "$JAVA_HOME" ]] && [[ -d "$IDE_DIR" ]] && export JAVA_HOME="$IDE_DIR/jbr"

export PATH="$JAVA_HOME/bin:/usr/NX/bin:$PATH"
export WINEDEBUG="-all"
# export XAUTHORITY=$HOME/.Xauthority
# xhost + > /dev/null 2>&1

if [[ $USER != chronos ]]; then
  alias cp="$(which advcp || which cp) --reflink=auto --sparse=auto"
  alias mv="$(which advmv || which mv)"
fi

alias 7z='~/Other\ Stuff/Utilities/7-Zip/Linux/7zz'
alias badram='sudo cat /proc/iomem | grep "Unusable memory"'
alias chdman='~/Games/Utilities/chdman/chdman'
alias cpu-monitor='watch -n1 "lscpu -e; echo; sensors coretemp-isa-0000 dell_smm-isa-0000"'
alias current-governor="cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
alias docker-clean="docker system prune --volumes -a -f; docker volume prune -a -f"
alias docker-compose="docker compose"
alias docker-upgrade-all='YML=~/Docker/docker-compose.yml; docker compose -f $YML pull; docker compose -f $YML up -d --remove-orphans; docker-clean'
alias download-chromeosflex="wget --trust-server-names https://dl.google.com/chromeos-flex/images/latest.bin.zip"
alias firmware-util="curl -LOk mrchromebox.tech/firmware-util.sh && sudo bash firmware-util.sh; rm firmware-util.sh"
alias flatpak-upgrade-all="flatpak update -y; flatpak uninstall --unused -y; flatpak uninstall --delete-data -y"
alias flush-dns-cache="sudo systemctl restart systemd-resolved; resolvectl status"
alias glados="curl -Ls https://tinyurl.com/y4xkv2dj | iconv -f windows-1252 | sort -R | head -n1"
alias hibernate="sudo swapon /swapfile; sudo systemctl --no-block hibernate || sudo swapoff /swapfile"
alias hypercalc="perl ~/Other\ Stuff/Utilities/hypercalc.txt"
alias install-liquorix="curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash"
alias lazydocker='~/Other\ Stuff/Utilities/lazydocker/lazydocker'
alias local-ip="ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'"
alias make="make -j$(nproc)"
alias mine="sudo chown -R $USER:$USER"
alias mount-all="sudo mount -a && mount-adbfs"
alias mount-iso="mount-chd"
alias mount-nuc="mount-cifs 192.168.86.10 Files /mnt/NUC farmerbb"
alias nano='MICRO_TRUECOLOR=1 micro'
alias port-monitor='watch -n1 "sudo lsof -i -P -n | grep LISTEN"'
alias ports-monitor='port-monitor'
alias public-ip="dig @resolver4.opendns.com myip.opendns.com +short"
alias public-ipv6="dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6"
alias python="python3"
alias qemu="qemu-system-x86_64 -monitor stdio -accel kvm -cpu host -m 4G -smp cores=6"
alias qemu-gl="qemu -display gtk,gl=on -device virtio-vga-gl"
alias qemu95="qemu-system-i386 -monitor stdio -cpu pentium -vga cirrus -nic user,model=pcnet -device sb16 -m 256"
alias qr-code="qrencode -t UTF8"
alias reboot-device="restart-device"
alias reboot-to-bios="sudo systemctl reboot --firmware-setup"
alias refresh-bash-config='source "$LINUX_DIR_PREFIX/Scripts/install-bash-config"'
alias refresh-theme='for i in {1..2}; do darkman toggle >/dev/null; done'
alias reset-webcam="sudo usbreset 046d:082c"
alias reset-audio="systemctl --user restart wireplumber pipewire pipewire-pulse"
alias robomirror-linux-dir='SYNC_DIRS=("Other Stuff/Linux"); robomirror onedrive; refresh-bash-config'
alias running-vms="sudo lsof 2>&1 | grep /dev/kvm | awk '!seen[\$2]++'"
alias running-vms-fast="sudo lsof /dev/kvm 2>&1 | grep /dev/kvm | awk '!seen[\$2]++'"
alias set-timezone='timedatectl set-timezone "America/Denver"; timedatectl'
alias starwars="telnet towel.blinkenlights.nl"
alias sudo="sudo "
alias trim="sudo fstrim -av"
alias turn-off-tv="curl -X POST http://192.168.86.44:8060/keypress/PowerOff"
alias usb-monitor="clear; sudo udevadm monitor --subsystem-match=usb --property"
alias usbtop="sudo modprobe usbmon; sudo usbtop"
alias wine="winecmd wine"
alias winecfg="winecmd winecfg"
alias wineserver="winecmd wineserver"
alias wireguard-up="sudo wg-quick up wg0 && touch /tmp/.wg-force-up && stop-nuc && timeout 10 bash -i -c mount-nuc; true"
alias wireguard-down="sudo wg-quick down wg0 && rm -f /tmp/.wg-force-up && stop-nuc && timeout 10 bash -i -c mount-nuc; true"
alias youtube-dl="python3 ~/Other\ Stuff/Audio\ \&\ Video\ Tools/youtube-dl"

alias am="adb shell am"
alias pm="adb shell pm"
alias wm="adb shell wm"

echo '"\e[A": history-search-backward' > ~/.inputrc
echo '"\e[B": history-search-forward' >> ~/.inputrc
echo '"\eOA": history-search-backward' >> ~/.inputrc
echo '"\eOB": history-search-forward' >> ~/.inputrc

btrfs-dedupe() {
  touch /tmp/.btrfs-maintenance
  sudo pkill bees

  sudo beesd $(sudo btrfs filesystem show -m | grep uuid | cut -d' ' -f5)

# sudo jdupes -r1BQ $BTRFS_MNT
# gunzip ~/.hashfile
# sudo duperemove -drh --hashfile=/home/$USER/.hashfile $BTRFS_MNT
# gzip ~/.hashfile

  rm /tmp/.btrfs-maintenance
}

btrfs-defrag() {
  touch /tmp/.btrfs-maintenance
  sudo pkill bees

  for i in $BTRFS_MNT $BTRFS_HOME_MNT $BTRFS_FILES_MNT $BTRFS_VMS_MNT; do
    [[ ! -z $i ]] && sudo btrfs filesystem defrag -rfv -czstd $i || true
  done

  rm /tmp/.btrfs-maintenance
}

btrfs-stats() {
  sudo btrfs filesystem usage -T $BTRFS_MNT 2>/dev/null

  echo
  printf "Run compsize? (Yes: ENTER, No: CTRL+C)"
  read _

  echo "Running compsize..."
  echo

  mkdir -p /tmp/compsize-mnt
  sudo mount UUID=$(sudo btrfs filesystem show -m | grep uuid | cut -d' ' -f5) /tmp/compsize-mnt
  sudo compsize /tmp/compsize-mnt
  sudo umount /tmp/compsize-mnt
}

btrfs-check() {
  DEVICES=$(sudo btrfs device scan | grep 'registered:' | sed 's/registered: //g')
  for i in "${DEVICES[@]}"; do
    sudo btrfs check --force $i
  done
}

find-files() {
  find . -exec file -- {} + | grep -i "$*"
}

set-title() {
  [[ -z "$ORIG" ]] && ORIG=$PS1

  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}

adb() {
  $(which adb) "$@"
  RETURNVAL=$?
  [[ $USER != chronos ]] && mount-adbfs >/dev/null 2>&1
  return $RETURNVAL
}

adb-shell() {
  adb connect "$1"
  adb -s "$1" shell "${@:2}"
}

cat() {
  if [[ ! -t 1 ]]; then
    $(which cat) "$@"
  elif [[ ! -f "$1" ]]; then
    $(which cat) "$@"
  elif [[ -d "$1" ]]; then
    ls -al "$1"
  elif [[ "${1,,}" = *.jpg || "${1,,}" = *.jpeg || "${1,,}" = *.png || "${1,,}" = *.gif || "${1,,}" = *.bmp ]]; then
    img2sixel "$1"
  elif [[ "${1,,}" = *.mp3 || "${1,,}" = *.m4a || "${1,,}" = *.wav \
       || "${1,,}" = *.ogg || "${1,,}" = *.flac ]]; then
    play -q "$1"
  elif [[ ! -z $(sed -n '/\x0/ { s/\x0/<NUL>/g; p}' "$1") ]]; then
    xxd -g1 "$1"
  else
    highlight -O ansi --force --stdout "$@"
  fi
}

git-commit-and-push() {
  [[ $# -ne 0 ]] && git add . && git commit -m "$@" && git push origin
}

list-roms() {
  for i in bin smd nes gba sfc smc z64 n64 iso chd cue zip col a78 nsp gb gbc ngc sms; do
    ls *.$i >/dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
      ls -1 *.$i | sed "s/.$i//g"
    fi
  done
}

[[ $(type -t change-governor) = alias ]] && unalias change-governor

change-governor() {
  for i in $(seq 0 $(nproc --ignore=1)); do
    echo $1 | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor > /dev/null
  done
}

sys-monitor() {
  EXIT=0
  MIN_COLS=65
  MIN_ROWS=24

  [[ "$COLUMNS" -lt "$MIN_COLS" ]] && echo "Terminal width must be at least $MIN_COLS columns." && EXIT=1
  [[ "$LINES" -lt "$MIN_ROWS" ]] && echo "Terminal height must be at least $MIN_ROWS rows." && EXIT=1

  if [[ "$EXIT" != 1 ]]; then
    SMEM_COLS="pid user name swap pss"
    CPU_MONITOR="$SYS_MONITOR_PREFIX lscpu | grep 'MHz\|Model name' | tr -s ' ' | column -t -s':' -o':   '; echo -n \"CPU usage:      \""
    CPU_USAGE="$SYS_MONITOR_PREFIX top -b -n1 | grep 'Cpu(s)' | awk '{print \$2+\$4 \"%\"}'; echo -n \"CPU governor:   \""
    CPU_GOVERNOR="$SYS_MONITOR_PREFIX cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo; echo -n \"Fan speed:      \""
    [[ $HOSTNAME = penguin ]] && FAN_SPEED="echo \"scale=4; \$($SYS_MONITOR_PREFIX cat /sys/class/thermal/cooling_device0/cur_state) / \$($SYS_MONITOR_PREFIX cat /sys/class/thermal/cooling_device0/max_state) * 100\" | bc | sed -e 's/.00/%/g' -e 's/^0$/0%/g' -e 's/%%00/100%/g'; echo"
    [[ $HOSTNAME != penguin ]] && FAN_SPEED="echo; echo"
    [[ -z $(which btrfs) ]] && DISK_MONITOR="df -h | sort | uniq -f0 -w16 | sort -h -k2 | (sed -u 2q; tail -n6; echo)"
    [[ ! -z $(which btrfs) ]] && DISK_MONITOR="sudo btrfs filesystem usage $BTRFS_MNT 2>/dev/null | sed -e 1d -e 9,10d -e 12d | head -n9"
    MEM_MONITOR="sudo smem -c \"$SMEM_COLS\" -tk | (sed -u 1q; tail -n\$((LINES-22)))"
    [[ $1 = "-p" ]] && LAST_LINE="sudo smem -c \"$SMEM_COLS\" -tp | tail -n1"

    if [[ $1 != "-p" ]]; then
      [[ $HOSTNAME = penguin ]] && MEM_STATS="ssh root@crosh crosvm balloon_stats /var/run/vm/vm.*/crosvm.sock | grep 'available_memory\|total_memory'"
      [[ $HOSTNAME != penguin ]] && MEM_STATS="awk '\$3==\"kB\"{printf \": %.0f:\", \$2=\$2*1024;} 1' /proc/meminfo | grep 'MemTotal\|MemAvailable'"
      LAST_LINE="echo; $MEM_STATS | cut -d':' -f2 | sed 's/,//g' | numfmt --to iec --format '%.2f' | tr -s ' ' | sed -e '1 s/^/Total:/' -e '2 s/^/Available:/' | column"
    fi

    watch -n0 "$CPU_MONITOR; $CPU_USAGE; $CPU_GOVERNOR; $FAN_SPEED; $DISK_MONITOR; $MEM_MONITOR; $LAST_LINE"
  fi
}

lastrun() (
  lastrun-internal() {
    for i in ~/.lastrun/*.lastrun; do
      echo "$(basename $i | sed 's/.lastrun/: /g')$(date -r $i)"
    done
  }

  lastrun-internal | column -t -o " "
)

edit-script() {
  DIR="$LINUX_DIR_PREFIX/Scripts"
  FILE="$DIR/$1"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Scripts/$1"
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$LINUX_DIR_PREFIX/##g"):\033[0m"
    ls "$DIR" | sed -e "s#$DIR##g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m edit-script <name of script>"
  fi
}

edit-bash-config() {
  DIR="$LINUX_DIR_PREFIX/Bash Configs"
  FILE="$DIR/bashrc-additions-$1.sh"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && refresh-bash-config && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Bash Configs/bashrc-additions-$1.sh"
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$LINUX_DIR_PREFIX/##g"):\033[0m"
    ls "$DIR"/*.sh | sed -e "s#$DIR/bashrc-additions-##g" -e "s/\.sh//g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m edit-bash-config <name of script>"
  fi
}

edit-cron-script() {
  DIR="$LINUX_DIR_PREFIX/Cron Scripts"
  FILE="$DIR/$1.sh"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Cron Scripts/$1.sh"
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$LINUX_DIR_PREFIX/##g"):\033[0m"
    ls "$DIR"/*.sh | sed -e "s#$DIR/##g" -e "s/\.sh//g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m edit-cron-script <name of script>"
  fi
}

edit-crontab() {
  crontab -l > /dev/null || return 1

  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/crontab"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    crontab -e
    crontab -l > "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/crontab"
  fi
}

edit-vm-config() {
  DIR="$LINUX_DIR_PREFIX/virt-manager"
  FILE="$DIR/$1.xml"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo virsh edit $1 && (sudo virsh dumpxml $1 > "$FILE") || nano "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/virt-manager/$1.xml"
  else
    echo -e "\033[1m$(echo $DIR | sed "s#$LINUX_DIR_PREFIX/##g"):\033[0m"
    ls "$DIR"/*.xml | sed -e "s#$DIR/##g" -e "s/\.xml//g" -e "s/:/:\n/g" | column
    echo

    echo -e "\033[1mUsage:\033[0m edit-vm-config <name of libvirt domain>"
  fi
}

edit-hosts() {
  DIR="$LINUX_DIR_PREFIX/Network Config"
  FILE="$DIR/hosts"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    update-hosts "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Network Config/hosts"
  fi
}

edit-netdata-config() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/netdata.conf"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    sudo cp "$FILE" /etc/netdata/netdata.conf
    if [[ $(md5sum "$FILE") != $MD5 ]]; then
      sudo systemctl restart netdata
      cp "$FILE" "$OD_DEVICE_DIR_PREFIX/netdata.conf"
    fi
  fi
}

edit-caddyfile() {
  DIR="$LINUX_DIR_PREFIX/Network Config"
  FILE="$DIR/Caddyfile"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano "$FILE"
    caddy reload --config ~/Other\ Stuff/Linux/Network\ Config/Caddyfile
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Network Config/Caddyfile"
  fi
}

install-apks-recursive() {
# for i in . */; do install-apks $i $1; done
  find . -type d -exec install-apks {} $1 \;
}

max-cpu() {
  for i in $(seq 0 $(nproc --ignore=1)); do
    nice -20 yes > /dev/null &
  done

  printf "Press Enter to stop..."
  read _
  pkill yes
}

unsparsify() {
  [[ -f "$1" ]] && \
    sudo fallocate -l $(stat --format="%s" "$1") "$1" && \
    sudo dd if="$1" of="$1" conv=notrunc bs=1M
}

qcow2-create() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: qcow2-create <filename> <size>"
    return 1
  fi

  touch "$1"
  chattr +C "$1"
  qemu-img create -f qcow2 -o cluster_size=2M "$1" "$2"
}

qcow2-optimize() {
  [[ ! -f "$1" ]] && return 1

  mv "$1" "$1".old

  touch "$1"
  chattr +C "$1"

  qemu-img convert -p -c -f qcow2 -O qcow2 -o cluster_size=2M "$1".old "$1" || mv "$1".old "$1"
  rm -f "$1".old
}

qcow2-to-raw() {
  [[ ! -f "$1" ]] && return 1
  [[ "$1" = *.img ]] && return 1

  NEW_FILENAME=$(echo "$1" | sed "s/.qcow2/.img/g")
  [[ "$1" = "$NEW_FILENAME" ]] && NEW_FILENAME="$1.img"

  qemu-img convert -p -f qcow2 -O raw "$1" "$NEW_FILENAME" || rm "$NEW_FILENAME"
}

raw-to-qcow2() {
  [[ ! -f "$1" ]] && return 1
  [[ "$1" = *.qcow2 ]] && return 1

  NEW_FILENAME=$(echo "$1" | sed "s/.img/.qcow2/g")
  [[ "$1" = "$NEW_FILENAME" ]] && NEW_FILENAME="$1.qcow2"

  qemu-img convert -p -c -f raw -O qcow2 -o cluster_size=2M "$1" "$NEW_FILENAME" || rm "$NEW_FILENAME"
}

set-default-filemanager() {
  [[ -z $1 ]] && return 1
  [[ ! -f /usr/share/applications/$1.desktop ]] && return 1

  if [[ -z $(which xdg-mime) ]]; then
    sudo apt-get update
    sudo apt-get install -y dconf-cli
  fi

  sudo sed -i -e '/^inode\/directory=/d' -e '/^x-directory\/normal=/d' /usr/share/applications/defaults.list
  echo -e "inode/directory=$1.desktop\nx-directory/normal=$1.desktop" | sudo tee -a /usr/share/applications/defaults.list > /dev/null

  xdg-mime default $1.desktop inode/directory application/x-gnome-saved-search
  gsettings set org.gnome.desktop.background show-desktop-icons false
}

restart-device() {
  [[ -z $1 ]] && return 0
  ssh $1 '/mnt/c/Windows/System32/cmd.exe /c shutdown /f /r /t 0 || sudo reboot' 2&>/dev/null && return 0

  adb connect $1
  sleep 1

  if [[ $1 == *shield* ]]; then
    adb -s $1 shell settings put global hdmi_one_touch_play_enabled 0
    sleep 1
  fi

  adb -s $1 reboot

  if [[ $1 == *shield* ]]; then
    until adb -s $1 shell settings put global hdmi_one_touch_play_enabled 1 2>/dev/null; do
      ((TRIES+=1))
      [[ $TRIES > 60 ]] && return 1

      echo "Waiting for SHIELD to reboot..."
      sleep 5
    done

    adb -s $1 shell input keyevent 26
  fi
}

take-screenshot() {
  adb connect $1
  sleep 1
  adb -s $1 shell input keyevent 120
}

uninstall-all-apps() {
  if [[ ! -z $1 ]]; then
  # adb connect $1
    DASH_S="-s"
    DEVICE=$1
  else
    DASH_S=""
    DEVICE=""
  fi

  echo "WARNING: About to uninstall all third-party apps from this device!"
  echo "Press Enter to continue..."
  read _

  LAUNCHER=$(adb $DASH_S $DEVICE shell pm resolve-activity --components -a android.intent.action.MAIN -c android.intent.category.HOME | cut -d'/' -f1)
  for i in $(adb $DASH_S $DEVICE shell pm list packages -3 | cut -d':' -f2); do
    if [[ $i = $LAUNCHER ]]; then
      echo "Skipping uninstall of $i (currently set as launcher)"
    else
      printf "Uninstalling $i... "
      adb $DASH_S $DEVICE shell pm uninstall $i
    fi
  done
}

reset-config-file() {
  REALPATH=$(realpath $1)
  PKG_NAME=$(dpkg -S $REALPATH | cut -d':' -f1)
  [[ -z $PKG_NAME ]] && return 1

  sudo rm $REALPATH
  sudo apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall $PKG_NAME
}

sync-timestamps() {
  [[ $# -ne 2 ]] && return 1
  DESTINATION=$(realpath "$2")

  cd "$1"
  find . -exec touch "$DESTINATION/{}" --reference "{}" \;
  cd - >/dev/null 2>&1
}

what-is() {
  TYPE=$(type -t $1)
  [[ $TYPE = file ]] && cat "$(type -p $1)"
  [[ $TYPE = alias ]] && type $1 | sed -e "s/$1 is aliased to \`//g" -e "s/.$//"
  [[ $TYPE = function ]] && type $1 | sed -z "s/\n    /\n/g" | sed -z "s/;\n/\n/g" | head -n -1 | tail -n +4
}

git-clone() {
  git clone git@github.com:farmerbb/$1.git
}

install-pip2() {
  sudo apt-get -y install curl python-dev
  curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
  sudo python2 get-pip.py
  rm get-pip.py
}

git-deep-clean() {
  [[ -f local.properties ]] && mv local.properties /tmp
  [[ -d .idea ]] && mv .idea /tmp

  sudo git clean -xfd && git reset --hard

  [[ -f /tmp/local.properties ]] && \
    mv /tmp/local.properties . && \
    echo && \
    echo "NOTE: local.properties file has been kept"

  [[ -d /tmp/.idea ]] && \
    mv /tmp/.idea . && \
    echo && \
    echo "NOTE: .idea directory has been kept"
}

install-deb() {
  sudo dpkg -i "$1"
  sudo apt --fix-broken install -y
}

ext4-reclaim-reserved() {
  for i in $(cat /etc/mtab | grep 'ext4 rw' | cut -d' ' -f1); do
    sudo tune2fs -m 0 $i
  done
}

sort-files-by-md5sum() {
  for i in *; do
    if [[ -f "$i" ]]; then
      MD5=$(md5sum "$i" | cut -d' ' -f1)
      mkdir -p $MD5
      mv "$i" $MD5
    fi
  done
}

process-args() {
  regex='^[0-9]+$'
  if ! [[ $1 =~ $regex ]] ; then
    for i in $(pidof $1); do
      ps -p $i -o args | tail -n +2; echo
    done
  else
    ps -p $1 -o args | tail -n +2; echo
  fi
}

robomirror() {
  LOCKFILE=/run/user/$UID/.robomirror
  $(uname -r | grep "[m|M]icrosoft" > /dev/null) && IS_WSL=true

  [[ -z $(which nc) ]] && INSTALL_DEPENDENCIES=true
  [[ -z $IS_WSL ]] && [[ -z $(which rsync) ]] && INSTALL_DEPENDENCIES=true
  [[ -z $IS_WSL ]] && [[ -z $(which rclone) ]] && INSTALL_DEPENDENCIES=true

  if [[ ! -z $INSTALL_DEPENDENCIES ]]; then
    sudo apt-get update
    sudo apt-get -y install netcat-openbsd rclone rsync
  fi

  if [[ -z $IS_WSL ]]; then
    RSYNC=rsync
    RSYNC_DEST_ROOT=/mnt/files

    RCLONE=rclone
    RCLONE_DEST_ROOT=/mnt/files
  else
    RSYNC=/mnt/z/Other\ Stuff/Utilities/cwRsync/bin/rsync.exe
    RSYNC_DEST_ROOT=/cygdrive/z

    RCLONE=/mnt/z/Other\ Stuff/Utilities/rclone/rclone.exe
    RCLONE_DEST_ROOT=Z:
  fi

  if [[ -z $1 ]]; then
    if [[ $HOSTNAME = NUC ]]; then
      SOURCE=onedrive
    else
      timeout 1 nc -z 192.168.86.10 22 2> /dev/null
      if [[ $? = 0 ]]; then
        SOURCE=nuc
      else
        SOURCE=onedrive
      fi
    fi
  fi

  [[ $1 = nuc ]] && SOURCE=nuc
  [[ $1 = onedrive ]] && SOURCE=onedrive
  [[ $1 = verify ]] && SOURCE=verify

  [[ -z $SOURCE ]] && \
    echo 'Usage: robomirror <nuc | onedrive | verify>' && \
    return 1

  [[ ${#SYNC_DIRS[@]} -eq 0 ]] && \
    echo 'SYNC_DIRS variable is not defined; exiting' && \
    return 1

  [[ -f $LOCKFILE ]] && \
    echo "Lockfile $LOCKFILE is present; exiting" && \
    return 1

  touch $LOCKFILE

  for i in ${!SYNC_DIRS[@]}; do
    DIR="${SYNC_DIRS[$i]}"

    if [[ $SOURCE = nuc ]]; then
      echo "Mirroring $DIR from NUC using rsync..."
      if [[ -z $IS_WSL ]] || [[ -d "$RSYNC_DEST_ROOT/$DIR" ]]; then
        echo
        "$RSYNC" -avz --no-perms --delete --inplace --compress-choice=zstd --compress-level=1 "192.168.86.10::Files/$DIR/" "$RSYNC_DEST_ROOT/$DIR"
      else
        echo "Directory \"$RSYNC_DEST_ROOT/$DIR\" does not exist; aborting"
      fi
    fi

    if [[ $SOURCE = onedrive ]]; then
      echo "Mirroring $DIR from OneDrive using rclone..."
      if [[ -d "$RCLONE_DEST_ROOT/$DIR" ]]; then
        echo
        "$RCLONE" sync -v "OneDrive:$DIR" "$RCLONE_DEST_ROOT/$DIR"
      else
        echo "Directory \"$RCLONE_DEST_ROOT/$DIR\" does not exist; aborting"
      fi
    fi

    if [[ $SOURCE = verify ]]; then
      echo "Verifying files in $DIR using rclone..."
      if [[ -d "$RCLONE_DEST_ROOT/$DIR" ]]; then
        echo
        "$RCLONE" check -v "OneDrive:$DIR" "$RCLONE_DEST_ROOT/$DIR"
      else
        echo "Directory \"$RCLONE_DEST_ROOT/$DIR\" does not exist; aborting"
      fi
    fi

    echo
  done

  rm $LOCKFILE
}

docker-stop() {
  docker stop $(docker ps -a -q)
}

install-samba() {
  sudo apt-get update
  sudo apt-get -y install samba

  sudo mkdir -p /etc/samba
  sudo cp ~/Other\ Stuff/Linux/Ubuntu/smb.conf /etc/samba/smb.conf
  echo "farmerbb = Braden" | sudo tee /etc/samba/usermap.txt > /dev/null

  echo
  sudo smbpasswd -a farmerbb
  sudo systemctl restart smbd.service
}

iommu-groups() {
  shopt -s nullglob
  for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
      echo -e "\t$(lspci -nns ${d##*/})"
    done;
  done;
}

install-wireguard-client() {
  [[ $1 != peer* ]] && \
    echo "Usage: install-wireguard-client <peer#>" && \
    return 1

  sudo apt-get update
  sudo apt-get -y install wireguard resolvconf
  sudo cp ~/Other\ Stuff/Docker/wireguard/$1/$1.conf /etc/wireguard/wg0.conf
}

wireguard-run() {
  sudo wg-quick up wg0 2>/dev/null
  ${@:1}
  sudo wg-quick down wg0 2>/dev/null
}

shield-share-menu() {
  for i in shield 0323118103330; do
    adb devices | grep -q $i && adb -s $i shell input keyevent --longpress KEYCODE_HOME
  done
}

wireguard-monitor() {
  if [[ $HOSTNAME = NUC ]]; then
    COMMAND='docker exec -it wireguard wg'
  else
    COMMAND='ssh nuc -o LogLevel=QUIET -t docker exec -it wireguard wg'
  fi

  watch --color -n1 $COMMAND
}

toggle-vm-maintenance() {
  [[ $HOSTNAME != PC ]] && return 1

  if [[ -f /tmp/vm-maintenance ]]; then
    rm /tmp/vm-maintenance
    sudo virsh start win11-vfio >/dev/null 2>&1
    echo "VM maintenance off"
  else
    touch /tmp/vm-maintenance
    sudo virsh shutdown win11-vfio >/dev/null 2>&1
    echo "VM maintenance on"
  fi
}

install-makemkv() {
  [[ -z $1 ]] && \
    echo "Usage: install-makemkv <version>" && \
    return 1

  sudo apt-get update
  sudo apt-get -y install wget build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev html-xml-utils

  for i in oss bin; do
    FILENAME=makemkv-$i-$1

    wget https://www.makemkv.com/download/$FILENAME.tar.gz
    tar xzfv $FILENAME.tar.gz

    cd $FILENAME
    [[ -f configure ]] && ./configure
    make -j$(nproc)
    sudo make install

    cd -
    sudo rm -r $FILENAME
    rm $FILENAME.tar.gz
  done

  echo ""
  echo "  MakeMKV Beta Key:"
  echo "  $(curl -s https://forum.makemkv.com/forum/viewtopic.php?t=1053 | hxclean | hxselect -c code)"
  echo ""
}

apt-install-held-pkgs() {
  # From https://askubuntu.com/a/1449756
  sudo apt-get install -y --only-upgrade `sudo apt-get upgrade | awk 'BEGIN{flag=0} /The following packages have been kept back:/ { flag=1} /^ /{if (flag) print}'`
}

folder2iso() {
  [[ ! -d "$1" ]] && return 1
  FILENAME=$(basename "$1")
  mkisofs -J -V "$FILENAME" -o "$FILENAME.iso" "$1"
}

video-capture() {
  OUTPUT="$1"
  [[ -z $OUTPUT ]] && OUTPUT=/dev/null

  if [[ -z $(which v4l2-ctl) || -z $(which ffmpeg) ]]; then
    sudo apt-get update
    sudo apt-get install -y v4l-utils ffmpeg
  fi

  DEVICE=$(v4l2-ctl --list-devices | grep -A1 "USB Video" | tail -n1 | xargs)
  v4l2-ctl -d $DEVICE -c brightness=0
  v4l2-ctl -d $DEVICE -c contrast=128
  v4l2-ctl -d $DEVICE -c saturation=128
  v4l2-ctl -d $DEVICE -c hue=0

  AUDIO_DEVICE=$(arecord -l | grep MS2109 | sed -n 's/^card \([0-9]\+\):.*device \([0-9]\+\):.*/hw:\1,\2/p')

# arecord -D sysdefault:CARD=MS2109 -f cd - | aplay - &
# disown

# guvcview --device=$DEVICE > /dev/null 2>&1

  ffmpeg \
    -f v4l2 -input_format mjpeg -video_size 1920x1080 -i $DEVICE \
    -f alsa -i $AUDIO_DEVICE -map 0:v -map 1:a -c:v copy -c:a aac -f matroska - \
    | tee >(ffplay -fflags nobuffer -) > "$OUTPUT"

# sudo pkill arecord
  echo
}

terminal-size() {
  while true; do
    printf "\r\033[K$(tput cols)x$(tput lines) "
  done
}

process-death() {
  [[ -z $2 ]] && \
    echo "Usage: process-death <device> <package-name>" && \
    adb devices && \
    return 1

  adb -s $1 shell input keyevent 3
  sleep 1

  adb -s $1 shell am kill $2
  adb -s $1 shell am start $2
}

aot-compile() {
  [[ -z $2 ]] && \
    echo "Usage: aot-compile <device> <package-name | -a>" && \
    adb devices && \
    return 1

  adb -s $1 shell cmd package compile -m speed -f $2

  if [[ $2 = "-a" ]]; then
    adb -s $1 shell am kill-all
  else
    adb -s $1 shell am kill $2
  fi
}

install-steam() {
  sudo dpkg --add-architecture i386
  sudo apt-get update
  sudo apt-get -y install steam
}

install-tvheadend() {
  curl -1sLf 'https://dl.cloudsmith.io/public/tvheadend/tvheadend/setup.deb.sh' | sudo -E bash
  sudo apt-get -y install tvheadend
}

apt-upgrade-all() {
  sudo apt-get update
  sudo apt-get upgrade -y
  apt-install-held-pkgs
  sudo apt-get autoremove -y
  sudo apt-get purge -y $(dpkg -l | grep '^rc' | awk '{print $2}')
}

pi() {
  if [[ $HOSTNAME = NUC ]]; then
    ssh pi
    return 0
  fi

  ssh nuc -o LogLevel=QUIET -t ssh pi
}

install-rsyncd() {
  echo "[Files]" | sudo tee /etc/rsyncd.conf > /dev/null
  echo "path = /mnt/files" | sudo tee -a /etc/rsyncd.conf > /dev/null

  sudo ufw allow 873/tcp
  sudo rsync --daemon
}

pip() {
  PIP=$(which pip)
  if [[ -z $PIP ]]; then
    sudo apt-get update
    sudo apt-get install -y python3-pip
    PIP=$(which pip)
  fi

  if [[ $1 = install ]]; then
    $PIP "$@" --break-system-packages
  else
    $PIP "$@"
  fi
}

webos-reset-dev-mode() {
  TOKEN=[REDACTED]
  for i in Reset Check; do
    curl https://developer.lge.com/secure/${i}DevModeSession.dev?sessionToken=$TOKEN
    echo
  done
}

disable-android-tv-launcher() {
  adb shell pm list features | grep -q com.google.android.feature.AMATI_EXPERIENCE

  if [[ $? = 0 ]]; then
    PACKAGES=(
      com.google.android.apps.tv.launcherx
      com.google.android.tungsten.setupwraith
    )
  else
    PACKAGES=com.google.android.tvlauncher
  fi

  for i in ${PACKAGES[@]}; do
    adb shell pm disable-user --user 0 $i
  done
}

switch-user() {
  [[ -z $1 ]] && \
    echo "Usage: switch-user <username>" &&
    return 1

  sudo machinectl shell ${1}@ /bin/bash
}

dns-failsafe() {
  [[ -z $1 ]] && IP=127.0.0.53 || IP=$1
  sudo sed -i "s/^\(nameserver\).*/\1 $IP/" /etc/resolv.conf
  echo "Temporarily setting DNS to $IP"
}

install-netdata() {
  wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && \
  sh /tmp/netdata-kickstart.sh --disable-telemetry

  CONF_DIR=$(curl localhost:19999/netdata.conf | grep '# config = ' | xargs | sed 's/# config = //')
  DIR="$DEVICE_DIR_PREFIX/netdata"
  if [[ -d "$DIR" ]]; then
    sudo cp -rT "$DIR" "$CONF_DIR"
    sudo systemctl restart netdata
  else
    for i in "$DEVICE_DIR_PREFIX" "$OD_DEVICE_DIR_PREFIX"; do
      mkdir -p "$i/netdata"
      cp "$CONF_DIR/netdata.conf" "$i/netdata/netdata.conf"
    done
  fi
}

update-everything() {
  if [[ $HOSTNAME != NUC ]]; then
    timeout 1 nc -z 192.168.86.10 22 2> /dev/null
    [[ $? = 0 ]] && robomirror nuc
  fi

  mountpoint -q /mnt/OneDrive && robomirror-linux-dir
  apt-upgrade-all

  for i in ${!SOURCES[@]}; do
    case "${SOURCES[$i]}" in
      flatpak)
        flatpak-upgrade-all
      ;;

      docker)
        docker-upgrade-all
      ;;

      caddy)
        upgrade-caddy
      ;;
    esac
  done
}

mac-address() {
  MAC=$(cat /sys/class/net/$(ip -o route get to 8.8.8.8 | cut -d' ' -f5)/address)
  echo ${MAC^^}
}

network-scan() {
  if [[ -z $(which nmap) ]]; then
    sudo apt-get update
    sudo apt-get install -y nmap
  fi

  if [[ -z $1 ]]; then
    IP=$(local-ip)
    IP=${IP%.*}

    sudo nmap -sn $IP.0/24 --exclude $IP.255 | sed -e '/^Host is up/d' -e "s/Nmap done/MAC Address: $(mac-address)\n\nNmap done/" -e 's/Nmap scan report for /\n/'
  else
    sudo nmap -p- $1 | sed -e '/^Not shown/d' -e 's/PORT/\nPORT/' -e 's/MAC Address/\nMAC Address/' -e 's/Nmap scan report for /\n/'
  fi
}

apt-reenable-sources() {
  for i in /etc/apt/sources.list.d/*.sources; do
    grep -q 'cdrom:' $i || sudo sed -i 's/Enabled: no/Enabled: yes/' $i
  done
}

install-mosquitto() {
  sudo apt-get update
  sudo apt-get install -y mosquitto mosquitto-clients

  echo 'listener 1883 0.0.0.0' | sudo tee -a /etc/mosquitto/mosquitto.conf > /dev/null
  echo 'allow_anonymous true' | sudo tee -a /etc/mosquitto/mosquitto.conf > /dev/null

  sudo systemctl restart mosquitto
}

install-caddy() {
  if [[ -z $(which xcaddy) ]]; then
    sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-xcaddy-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/xcaddy/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-xcaddy.list

    sudo apt-get update
    sudo apt-get install -y golang-go xcaddy
  fi

  xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-l4

  sudo mv caddy /usr/local/bin/caddy
  sudo rm -rf ~/go
}

docker-run() {
  if [[ ! -f Dockerfile ]]; then
    [[ -z $1 ]] && echo "Usage: docker-run <image-name>" && return 1

    DIR="/tmp/docker-run"
    mkdir -p $DIR

    echo "FROM $1:latest" > $DIR/Dockerfile
    TAG_SUFFIX="-$1"
  else
    DIR="."
    TAG_SUFFIX="$(basename "$PWD")"
  fi

  docker build -t temp-container-$TAG_SUFFIX $DIR || return 1
  docker run -it temp-container-$TAG_SUFFIX:latest
}

upgrade-caddy() {
  MD5=$(md5sum $(which caddy))
  sudo caddy upgrade
  [[ $(md5sum $(which caddy)) != $MD5 ]] && \
    caddy stop && \
    sudo caddy start --config ~/Other\ Stuff/Linux/Network\ Config/Caddyfile
}

tinytuya() {
  [[ -z $(which pipx) ]] && \
    sudo apt-get update && \
    sudo apt-get install -y pipx

  [[ -z $(which tinytuya) ]] && \
    pipx install tinytuya

  cd ~/Other\ Stuff/Linux/Network\ Config/tinytuya
  $(which tinytuya) "$@"
  cd - >/dev/null
}

stop-nuc() {
  ssh -q -O stop nuc
  timeout 2 sudo umount /mnt/NUC 2> /dev/null || \
  timeout 2 sudo umount -f /mnt/NUC 2> /dev/null || \
  timeout 2 sudo umount -l /mnt/NUC 2> /dev/null || \
  echo "Failed to stop NUC"
}

install-python2() {
  wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
  tar xzf Python-2.7.18.tgz

  cd Python-2.7.18
  sudo ./configure --enable-optimizations
  sudo make altinstall
  sudo ln -s /usr/local/bin/python2.7 /usr/bin/python2

  cd ..
  sudo rm -r Python-2.7.18*
}

network-monitor() {
  watch -e -n1 ip -h -s link show $1 || echo -e "\033[1mDevices:\033[0m\n$(ip -br link | cut -d' ' -f1)"
}

twingate-up() {
  sudo ufw enable

  sudo sed -i 's/DNS=/#DNS=/' /etc/systemd/resolved.conf
  sudo sed -i 's/DNSOverTLS=/#DNSOverTLS=/' /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved

  twingate start
}

twingate-down() {
  twingate stop

  sudo sed -i 's/#DNS=/DNS=/' /etc/systemd/resolved.conf
  sudo sed -i 's/#DNSOverTLS=/DNSOverTLS=/' /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved

  sudo ufw disable
}

export -f btrfs-dedupe
export -f btrfs-defrag
export -f btrfs-stats
export -f find-files
export -f set-title
export -f adb
export -f adb-shell
export -f cat
export -f git-commit-and-push
export -f list-roms
export -f change-governor
export -f sys-monitor
export -f lastrun
export -f edit-script
export -f edit-bash-config
export -f edit-cron-script
export -f edit-crontab
export -f edit-vm-config
export -f edit-hosts
export -f edit-netdata-config
export -f edit-caddyfile
export -f install-apks-recursive
export -f max-cpu
export -f unsparsify
export -f qcow2-create
export -f qcow2-optimize
export -f qcow2-to-raw
export -f raw-to-qcow2
export -f set-default-filemanager
export -f restart-device
export -f take-screenshot
export -f uninstall-all-apps
export -f reset-config-file
export -f sync-timestamps
export -f what-is
export -f git-clone
export -f install-pip2
export -f git-deep-clean
export -f install-deb
export -f ext4-reclaim-reserved
export -f sort-files-by-md5sum
export -f process-args
export -f robomirror
export -f docker-stop
export -f install-samba
export -f iommu-groups
export -f install-wireguard-client
export -f wireguard-run
export -f shield-share-menu
export -f wireguard-monitor
export -f toggle-vm-maintenance
export -f install-makemkv
export -f apt-install-held-pkgs
export -f folder2iso
export -f video-capture
export -f terminal-size
export -f process-death
export -f aot-compile
export -f install-steam
export -f install-tvheadend
export -f apt-upgrade-all
export -f pi
export -f install-rsyncd
export -f pip
export -f webos-reset-dev-mode
export -f disable-android-tv-launcher
export -f switch-user
export -f dns-failsafe
export -f install-netdata
export -f update-everything
export -f mac-address
export -f network-scan
export -f apt-reenable-sources
export -f install-mosquitto
export -f install-caddy
export -f docker-run
export -f upgrade-caddy
export -f tinytuya
export -f stop-nuc
export -f install-python2
export -f network-monitor
export -f twingate-up
export -f twingate-down
