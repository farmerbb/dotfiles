[[ $PATH != */usr/local/bin* ]] && export PATH="$PATH:/usr/local/bin"
[[ -z $USER ]] && export USER="$(whoami)"
[[ -z $DISPLAY ]] && export DISPLAY=":0"
[[ -z $DBUS_SESSION_BUS_ADDRESS ]] && export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
[[ -z $XDG_RUNTIME_DIR ]] && export XDG_RUNTIME_DIR="/run/user/1000"

export PATH="/usr/NX/bin:$PATH"
export WINEDEBUG="-all"
export XAUTHORITY=$HOME/.Xauthority
xhost + > /dev/null 2>&1

if [[ $USER != chronos ]]; then
  alias cp="$(which advcp || which cp) --reflink=auto"
  alias mv="$(which advmv || which mv)"
fi

alias btrfs-dedupe="sudo jdupes -r1BQ /; gunzip ~/.hashfile; sudo duperemove -drh --hashfile=/home/$USER/.hashfile /; gzip ~/.hashfile"
alias btrfs-defrag="sudo btrfs filesystem defrag -rfv / || true"
alias btrfs-stats="sudo btrfs filesystem usage / 2>/dev/null"
alias current-governor="cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
alias docker-run="sudo docker build -t temp-container . && sudo docker run -it temp-container:latest"
alias docker-clean="sudo docker system prune --volumes -a -f"
alias ext4-reclaim-reserved-blocks="sudo tune2fs -m 0"
alias git-deep-clean="git clean -xfd && git reset --hard"
alias glados="curl -Ls https://tinyurl.com/y4xkv2dj | iconv -f windows-1252 | sort -R | head -n1"
alias install-micro="cd /usr/local/bin; curl https://getmic.ro/r | sudo bash; cd - >/dev/null 2>&1"
alias mount-all="sudo mount -a && mount-adbfs"
alias qcow2-create="qemu-img create -f qcow2 -o cluster_size=2M"
alias qemu="qemu-system-x86_64 -accel kvm -cpu host -m 1024"
alias qemu95="qemu-system-i386 -cpu pentium -vga cirrus -nic user,model=pcnet -soundhw sb16,pcspk"
alias starwars="telnet towel.blinkenlights.nl"
alias reboot-device="restart-device"
alias running-vms="sudo lsof 2>&1 | grep /dev/kvm | awk '!seen[\$2]++'"
alias running-vms-fast="sudo lsof /dev/kvm 2>&1 | grep /dev/kvm | awk '!seen[\$2]++'"
alias trim="sudo fstrim -av"
alias turn-off-tv="curl -X POST http://192.168.86.44:8060/keypress/PowerOff"
alias usb-monitor="clear; sudo udevadm monitor --subsystem-match=usb --property"
alias wireguard="sudo wg"
alias wireguard-up="sudo wg-quick up wg0"
alias wireguard-down="sudo wg-quick down wg0"

alias am="adb shell am"
alias pm="adb shell pm"
alias wm="adb shell wm"

echo '"\e[A": history-search-backward' > ~/.inputrc
echo '"\e[B": history-search-forward' >> ~/.inputrc
echo '"\eOA": history-search-backward' >> ~/.inputrc
echo '"\eOB": history-search-forward' >> ~/.inputrc

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
  [[ $USER != chronos ]] && mount-adbfs >/dev/null 2>&1
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
  elif [[ "${1,,}" = *.jpg || "${1,,}" = *.png || "${1,,}" = *.gif || "${1,,}" = *.bmp ]]; then
    catimg -w 120 "$1"
  elif [[ "${1,,}" = *.mp3 || "${1,,}" = *.m4a || "${1,,}" = *.wav \
       || "${1,,}" = *.ogg || "${1,,}" = *.flac ]]; then
    play -q "$1"
  elif [[ ! -z $(sed -n '/\x0/ { s/\x0/<NUL>/g; p}' "$1") ]]; then
    xxd -g1 "$1"
  else
    $(which cat) "$@"
  fi
}

git-commit-and-push() {
  [[ $# -ne 0 ]] && git add . && git commit -m "$@" && git push origin
}

list-roms() {
  for i in bin smd nes gba sfc smc z64 n64 iso chd cue zip col a78 nsp gb gbc ngc; do
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
    [[ ! -z $(which btrfs) ]] && DISK_MONITOR="sudo btrfs filesystem usage / 2>/dev/null | sed -e 1d -e 9,10d -e 12d | head -n9"
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
    [[ $(md5sum "$FILE") != $MD5 ]] && . ~/.bashrc && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Bash Configs/bashrc-additions-$1.sh"
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
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/hosts"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    sudo nano /etc/hosts
    cp /etc/hosts "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/hosts"
  fi
}

edit-ssh-config() {
  DIR="$DEVICE_DIR_PREFIX"
  FILE="$DIR/config"
  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    nano ~/.ssh/config
    cp ~/.ssh/config "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_DEVICE_DIR_PREFIX/config"
  fi
}

install-apks-recursive() {
  for i in . */; do install-apks $i $1; done
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

qcow2-optimize() {
  [[ "$1" != *.qcow2 ]] && return 1
  [[ ! -f "$1" ]] && return 1

  sudo mv "$1" "$1".old
  sudo qemu-img convert -f qcow2 -O qcow2 -o cluster_size=2M "$1".old "$1" || sudo mv "$1".old "$1"
  sudo rm -f "$1".old
}

fix-thunar() {
  if [[ -z $(which xdg-mime) ]]; then
    sudo apt-get update
    sudo apt-get install -y dconf-cli
  fi

  [[ $HOSTNAME = penguin ]] && SUFFIX=".png"
  [[ $HOSTNAME != penguin ]] && SUFFIX=".svg"

  for i in /usr/share/applications/thunar*.desktop; do
    sudo sed -i "s#Icon=org.xfce.thunar#Icon=/usr/share/icons/Qogir/scalable/apps/file-manager$SUFFIX#g" $i
  done

  sudo sed -i -e '/^inode\/directory=/d' -e '/^x-directory\/normal=/d' /usr/share/applications/defaults.list
  echo -e "inode/directory=thunar.desktop\nx-directory/normal=thunar.desktop" | sudo tee -a /usr/share/applications/defaults.list > /dev/null

  xdg-mime default thunar.desktop inode/directory application/x-gnome-saved-search
  gsettings set org.gnome.desktop.background show-desktop-icons false
}

restart-device() {
  [[ -z $1 ]] && return 0
  ssh $1 '/mnt/c/Windows/System32/cmd.exe /c shutdown /f /r /t 0 || sudo reboot' && return 0

  adb connect $1
  sleep 1
  adb -s $1 shell settings put global hdmi_one_touch_play_enabled 0
  sleep 1
  adb -s $1 reboot
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

clear-local() {
  for i in $(cat /etc/mtab | grep $(realpath ~/Local) | cut -d' ' -f2); do
    sudo umount "$i"
  done

  sudo rm -rf ~/Local/*
  sudo rm -rf ~/Local/.* >/dev/null 2>&1
}

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
export -f edit-ssh-config
export -f install-apks-recursive
export -f max-cpu
export -f unsparsify
export -f qcow2-optimize
export -f fix-thunar
export -f restart-device
export -f take-screenshot
export -f uninstall-all-apps
export -f reset-config-file
export -f sync-timestamps
export -f what-is
export -f git-clone
export -f install-pip2
export -f clear-local
