export ANDROID_SDK_ROOT="/home/$USER/Android/Sdk"
ls -d $ANDROID_SDK_ROOT/build-tools/* >/dev/null 2>&1
[[ $? -eq 0 ]] && BUILD_TOOLS_DIR="$(ls -d1 $ANDROID_SDK_ROOT/build-tools/* | tail -n 1)"

ls -d ~/.local/share/Google/AndroidStudio*/Kotlin/kotlinc/bin >/dev/null 2>&1
[[ $? -eq 0 ]] && PLUGINS_DIR="$(ls -d1 ~/.local/share/Google/AndroidStudio*/Kotlin/kotlinc/bin | tail -n 1)"
[[ -z "$PLUGINS_DIR" ]] && PLUGINS_DIR="$IDE_DIR/plugins/Kotlin/kotlinc/bin"

for f in "$PLUGINS_DIR"/* ; do
  [[ $f == *.bat ]] && continue
  sudo chmod +x $f
done

ls -d $ANDROID_SDK_ROOT/ndk/*/ >/dev/null 2>&1
[[ $? -eq 0 ]] && export NDK_DIR="$(ls -d1 $ANDROID_SDK_ROOT/ndk/*/ | tail -n 1)"

PLATFORM_TOOLS_DIR=$ANDROID_SDK_ROOT/platform-tools
TOOLS_DIR=$ANDROID_SDK_ROOT/tools
CMDLINE_TOOLS_DIR=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
TOOLS_BIN_DIR=$ANDROID_SDK_ROOT/tools/bin
EMULATOR_DIR=$ANDROID_SDK_ROOT/emulator
WEBOS_TOOLS_BIN_DIR="/home/$USER/webOS_TV_SDK/CLI/bin"

export PATH="$PLUGINS_DIR:$PLATFORM_TOOLS_DIR:$TOOLS_DIR:$CMDLINE_TOOLS_DIR:$TOOLS_BIN_DIR:$EMULATOR_DIR:$BUILD_TOOLS_DIR:$NDK_DIR:$PATH:$WEBOS_TOOLS_BIN_DIR"

alias clear-emulator-lockfiles="rm ~/.android/avd/*.avd/*.lock"
alias gradle-stop="pkill -f '.*GradleDaemon.*'"
alias kill-android-studio="pkill -f '.*com.intellij.idea.Main.*' -9"
alias reset-android-studio='for i in ~/.cache ~/.local/share ~/.config; do rm -rf $i/Google; done'
alias sdb="~/tizen-studio/tools/sdb"
alias tizen="~/tizen-studio/tools/ide/bin/tizen"
alias webos-get-token='ares-novacom --run "/bin/cat /var/luna/preferences/devmode_enabled"'
alias webos-shell='ares-novacom --run "/bin/sh -i"'

gradle-deep-clean() {
  rm -rf ~/.gradle-delete

  pkill -f '.*GradleDaemon.*'

  rm -rf ~/.m2

  mv ~/.gradle ~/.gradle-delete
  mkdir ~/.gradle
  [[ ! -z $BTRFS_HOME_MNT ]] && chattr +C ~/.gradle
  mv ~/.gradle-delete/init.d ~/.gradle >/dev/null 2>&1
  mv ~/.gradle-delete/gradle.properties ~/.gradle >/dev/null 2>&1

  rm -rf ~/.gradle-delete &
  disown
}

emulator() {
  OLD_DIR="$PWD"
  SECONDS=0

  cd "$ANDROID_SDK_ROOT/emulator"
  ./emulator "$@"

  [[ SECONDS -eq 0 ]] && \
    echo -e "\033[1mAVDs:\033[0m" && \
    ls -1 ~/.android/avd | grep ".avd" | sed -e "s/^/@/" -e "s/.avd//"

  cd "$PWD"
}

gradle-idle-stop() (
  # From https://superuser.com/a/784102
  pidtree() {
    declare -A CHILDS
    while read P PP;do
      CHILDS[$PP]+=" $P"
    done < <(ps -e -o pid= -o ppid=)

    walk() {
      echo $1
      for i in ${CHILDS[$1]};do
        walk $i
      done
    }

    for i in "$@";do
      walk $i
    done
  }

  for i in $(pgrep -f '.*KotlinCompileDaemon.*') $(pgrep -f '.*GradleDaemon.*'); do
    [[ $(pidtree $i | wc -l ) = 1 ]] && \
    [[ $(echo "$(top -b -n 2 -d 0.2 -p $i | tail -1 | awk '{print $9}') == 0.0" | bc -l) = 1 ]] && \
    kill $i
  done
)

init-android-dev-environment() {
  for i in AndroidStudioProjects .gradle; do
    mkdir -p ~/$i
    [[ ! -z $BTRFS_HOME_MNT ]] && chattr +C ~/$i
  done

  cp ~/OneDrive/Android/Development/*.sh ~/AndroidStudioProjects/
  cp ~/OneDrive/Android/Development/gradle.properties ~/.gradle/
  cp ~/OneDrive/Android/Development/Source\ Code/Keys/Keystore ~/AndroidStudioProjects/

  cd ~/AndroidStudioProjects
  chmod +x *.sh

  PROJECTS=( "$@" )
  [[ -z $PROJECTS ]] && PROJECTS=(
    AppNotifier
    Notepad
    SecondScreen
    Taskbar
  )

  for i in ${!PROJECTS[@]}; do
    REPO="${PROJECTS[$i]}"
    [[ ! -d $REPO ]] && \
      git-clone $REPO && \
      echo 'sdk.dir=/home/farmerbb/Android/Sdk' > $REPO/local.properties
  done

  cd - >/dev/null
}

project-root() {
  while [[ $SEARCH_DIR != '/' ]]; do
    if [[ -f build.gradle.kts || -f build.gradle ]]; then
      GRADLE_ROOT=$(realpath .)
    fi

    SEARCH_DIR=$(realpath ..)
    cd $SEARCH_DIR
  done

  cd $GRADLE_ROOT
}

export -f gradle-deep-clean
export -f emulator
export -f gradle-idle-stop
export -f init-android-dev-environment
export -f project-root
