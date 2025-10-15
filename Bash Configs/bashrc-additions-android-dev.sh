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
alias kill-intellij="pkill idea -9"
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
  if [[ ! -z $PROJECTS ]]; then
    for i in ${!PROJECTS[@]}; do
      REPO="${PROJECTS[$i]}"
      [[ ! -d $REPO ]] && \
        git-clone $REPO && \
        echo 'sdk.dir=/home/farmerbb/Android/Sdk' > $REPO/local.properties
    done
  fi

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

sign-apk() {
  if [[ -z "$2" ]]; then
    echo "Usage: sign-apk <input-filename> <output-filename>"
    return 1
  fi

  PASSWORD=$(base64 -d <<< [REDACTED])
  apksigner sign --ks ~/AndroidStudioProjects/Keystore --ks-key-alias farmerbb --ks-pass pass:$PASSWORD --key-pass pass:$PASSWORD --in "$1" --out "$2"
}

export -f gradle-deep-clean
export -f emulator
export -f init-android-dev-environment
export -f project-root
export -f sign-apk
