export ANDROID_SDK_ROOT="/home/$USER/Android/Sdk"
BUILD_TOOLS_DIR="$(ls -d1 $ANDROID_SDK_ROOT/build-tools/* | tail -n 1)"

ls -d ~/.local/share/Google/AndroidStudio*/Kotlin/kotlinc/bin >/dev/null 2>&1
[[ $? -eq 0 ]] && PLUGINS_DIR="$(ls -d1 ~/.local/share/Google/AndroidStudio*/Kotlin/kotlinc/bin | tail -n 1)"
[[ -z "$PLUGINS_DIR" ]] && PLUGINS_DIR="/opt/android-studio/plugins/Kotlin/kotlinc/bin"

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

export JAVA_HOME="/opt/android-studio/jre"
export PATH="$PLUGINS_DIR:$PLATFORM_TOOLS_DIR:$TOOLS_DIR:$CMDLINE_TOOLS_DIR:$TOOLS_BIN_DIR:$BUILD_TOOLS_DIR:$NDK_DIR:$JAVA_HOME/bin:$PATH"

alias gradle-stop="pkill -f '.*GradleDaemon.*'"
alias kill-android-studio="pkill -f '.*com.intellij.idea.Main.*' -9"
alias reset-android-studio='for i in ~/.cache ~/.local/share ~/.config; do rm -rf $i/Google; done'

gradle-deep-clean() {
  rm -rf ~/.gradle-delete

  pkill -f '.*GradleDaemon.*'

  mv ~/.gradle ~/.gradle-delete
  mkdir ~/.gradle
  mv ~/.gradle-delete/init.d ~/.gradle >/dev/null 2>&1
  mv ~/.gradle-delete/gradle.properties ~/.gradle >/dev/null 2>&1

  rm -rf ~/.gradle-delete &
  disown
}

emulator() {
  OLD_DIR="$PWD"
  cd "$ANDROID_SDK_ROOT/tools"
  ./emulator "$@"
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

export -f gradle-deep-clean
export -f emulator
export -f gradle-idle-stop
