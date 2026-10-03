<<'##################################################'

# To install, run the following:

echo '' >> ~/.bashrc
echo 'for i in linux-generic android-dev crostini; do' >> ~/.bashrc
echo '  source ~/Other\ Stuff/Linux/Bash\ Configs/bashrc-additions-$i.sh' >> ~/.bashrc
echo 'done' >> ~/.bashrc

##################################################

export XCURSOR_SIZE=$(echo "$(xdpyinfo | grep resolution | cut -d' ' -f 7 | cut -d'x' -f 1)/4" | bc | cut -d'.' -f 1)
export XCURSOR_SIZE_LOW_DENSITY=$(echo "$XCURSOR_SIZE/2" | bc)

alias garcon-logs="sudo journalctl -b -t garcon -e -f"
alias restart-arc="adb-shell arc reboot; echo Restarting...; sleep 1; fix-arc"
alias wine-stop='for i in wine wine-monitor winebox; do WINEPREFIX=~/.$i wineserver -k; done'

for i in msidb msiexec notepad regedit regsvr32 wineboot winecfg wineconsole winedbg winefile winemine winepath; do
  alias $i="wine $i"
done

vm-escape() {
  ssh crosh -o LogLevel=QUIET -t bash -i -c \""$@"\"
}

alias change-governor="vm-escape change-governor"
alias current-governor="vm-escape current-governor"
alias renice-crosvm="vm-escape renice-crosvm"
alias restart-ui="vm-escape sudo restart ui"
alias termina="vm-escape vmc start termina"
alias trim="vm-escape trim"
alias usb-monitor="vm-escape usb-monitor"
alias virtualhere-server="vm-escape virtualhere-server"

export LINUX_DIR_PREFIX="$(realpath ~/Other\ Stuff/Linux)"
export DEVICE_DIR_PREFIX="$(realpath ~/Other\ Stuff/Chrome\ OS/Crostini)"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Chrome OS/Crostini"
export BTRFS_MNT="/"

export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"
export QT_QPA_PLATFORMTHEME=qt5ct
export SYS_MONITOR_PREFIX="ssh crosh"

restart-sommelier() {
  timeout 2 bash -c "systemctl --user daemon-reload; systemctl --user restart sommelier-x@0.service"
  while [[ $? -ne 0 ]]; do restart-sommelier; done
}

set-window-color() {
  CONF_DIR=~/.config/systemd/user/sommelier-x@0.service.d
  mkdir -p $CONF_DIR
  echo -e "[Service]\nEnvironment=\"SOMMELIER_FRAME_COLOR=#$1\"" > ${CONF_DIR}/override.conf

  echo $1 > ~/.window-color
  restart-sommelier
}

fix() {
  DPI=$(xdpyinfo | grep resolution | cut -d' ' -f 7 | cut -d'x' -f 1 | cut -d'.' -f 1)
  [[ $DPI -ne 96 ]] && SCALE=0.625
  [[ $DPI -eq 96 ]] && SCALE=1.0

  fix-x-cursor &
  disown
  WINEPREFIX=~/.wine-monitor sommelier -X --drm-device=/dev/dri/renderD128 --glamor --scale=$SCALE --dpi=96 "$@"
}

fix-gtk3() {
  DPI=$(xdpyinfo | grep resolution | cut -d' ' -f 7 | cut -d'x' -f 1 | cut -d'.' -f 1)
  if [[ $DPI -ne 96 ]]; then
    fix-x-cursor 48 &
    disown
    GDK_BACKEND=x11 GDK_SCALE=2 sommelier -X --scale=1.25 "$@"
  fi

# [[ $XCURSOR_SIZE -ne 24 ]] && GDK_BACKEND=x11 GDK_SCALE=2 GDK_DPI_SCALE=0.5 "$@"
  [[ $DPI -eq 96 ]] && GDK_BACKEND=x11 GDK_SCALE=1 GDK_DPI_SCALE=1.0 "$@"
}

fix-qt() {
  DPI=$(xdpyinfo | grep resolution | cut -d' ' -f 7 | cut -d'x' -f 1 | cut -d'.' -f 1)
  [[ $DPI -ne 96 ]] && QT_FONT_DPI=96 QT_SCALE_FACTOR=1.6 "$@"
  [[ $DPI -eq 96 ]] && "$@"
}

winebox() {
# [[ $XCURSOR_SIZE -ne 24 ]] && SCALE=0.319148936
# [[ $XCURSOR_SIZE -eq 24 ]] && SCALE=0.444444444

# fix-x-cursor &
# disown
# WINEPREFIX=~/.winebox sommelier -X --drm-device=/dev/dri/renderD128 --glamor --scale=$SCALE $(which wine) "$@"

##################################################

  DPI=$(xdpyinfo | grep resolution | cut -d' ' -f 7 | cut -d'x' -f 1 | cut -d'.' -f 1)
  [[ $DPI -ne 96 ]] && SCALE=0.349
  [[ $DPI -eq 96 ]] && SCALE=0.480
  [[ -z $SCREEN ]] && SCREEN=640x480x16

  sommelier -X --drm-device=/dev/dri/renderD128 --glamor --scale=$SCALE Xephyr :9 -ac -screen $SCREEN &
  disown

  DISPLAY=:9 XCURSOR_SIZE=24 WINEPREFIX=~/.winebox $(which wine) "$@"
  sleep 1

  EXE=$(echo "${@: -1}")
  EXE=$(echo ${EXE##*\\})

  while pgrep "$EXE" >/dev/null 2>&1; do
    sleep 1
  done

  pkill Xephyr
}

sommelier() {
  SOMMELIER_FRAME_COLOR=#$(cat ~/.window-color) $(which sommelier) "$@"
}

fix-arc() {
  DISPLAY_METRICS=""

  touch ~/.display-metrics
  adb connect arc

  for i in $(scrcpy -s arc -V error --display 65535 | grep 'scrcpy --display' | cut -d' ' -f 9); do
    RESOLUTION=$(adb -s arc shell wm size -d $i | cut -d' ' -f 3)
    [[ $RESOLUTION != 2256x1504 ]] && DENSITY=160
    [[ $RESOLUTION = 2256x1504 ]] && DENSITY=213

    adb -s arc shell wm density $DENSITY -d $i

    DISPLAY_METRICS="${DISPLAY_METRICS}$RESOLUTION $DENSITY "
  done

  OLD_METRICS=$(cat ~/.display-metrics)
  echo $DISPLAY_METRICS > ~/.display-metrics
  NEW_METRICS=$(cat ~/.display-metrics)

  [[ $OLD_METRICS != $NEW_METRICS ]] && return 0
  [[ $OLD_METRICS = $NEW_METRICS ]] && return 1
}

reclaim-vm-memory() (
  mem-below-threshold() {
    echo "$(ssh root@crosh crosvm balloon_stats /var/run/vm/vm.*/crosvm.sock | grep available_memory | cut -d':' -f2 | sed 's/,//g') < $1 * 1024^3" | bc -l
  }

  [[ -z $1 ]] && THRESHOLD=99
  [[ ! -z $1 ]] && THRESHOLD=$1

  [[ ! -z $(pgrep java) ]] && ([[ $(mem-below-threshold $THRESHOLD) = 1 ]] && gradle-idle-stop || return 0)
  [[ $(mem-below-threshold $THRESHOLD) = 1 ]] && (adb-shell arc am kill-all && vm-escape reclaim-vm-memory arcvm) || return 0
  [[ $(mem-below-threshold $THRESHOLD) = 1 ]] && vm-escape reclaim-vm-memory termina || return 0
)

resize-crostini-disk() {
  [[ -z $1 ]] && return 1
  ssh crosh vmc resize termina $(echo "$1 * 1024^3" | bc -l | cut -d. -f1) || dmesg | tail
}

export -f vm-escape
export -f restart-sommelier
export -f set-window-color
export -f fix
export -f fix-gtk3
export -f fix-qt
export -f winebox
export -f sommelier
export -f fix-arc
export -f reclaim-vm-memory
