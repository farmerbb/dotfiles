generate-aliases() {
  cd /mnt/c
  WIN_PATH=$(/mnt/c/Windows/System32/cmd.exe /c 'echo %PATH%' | sed -e "s#\\\#/#g" -e "s#C:#\/mnt/c#g" -e "s#;#\n#g" -e "s#\r##g")
  COMPGEN=($(compgen -c))

  while IFS= read -r dir; do
    if [[ -d "$dir" ]] ; then
      cd "$dir"
      SANITIZED_DIR=$(echo $PWD | sed -e "s/ /\\\ /g" -e "s/(/\\\(/g" -e "s/)/\\\)/g")
      for i in *.exe ; do
        CMD_NAME=$(echo $i | sed "s/.exe//g")
        [[ " ${COMPGEN[@]} " =~ " $CMD_NAME " ]] || echo "alias $CMD_NAME=\"$SANITIZED_DIR/$i\"" && COMPGEN+=("$CMD_NAME")
      done
    fi
  done <<< "$WIN_PATH"
}

f=$(mktemp)
(generate-aliases >$f && mv $f /tmp/aliases &)

for i in {a..z}; do alias $i:="cd /mnt/$i"; done

export LINUX_DIR_PREFIX="/mnt/z/Other Stuff/Linux"
export DEVICE_DIR_PREFIX="/mnt/z/Other Stuff/Linux/WSL2"
export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/WSL2"

# export DISPLAY=$(ip route|awk '/^default/{print $3}'):0.0
# export LIBGL_ALWAYS_INDIRECT=1
export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

alias sudo="sudo "
alias poweroff="/mnt/c/Windows/System32/shutdown.exe /s /t 0"
alias reboot="/mnt/c/Windows/System32/shutdown.exe /r /t 0"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

preexec() {
  [[ -f /tmp/aliases ]] || return

  EXISTS=$(compgen -c "$1" | grep -w "$1")
  source /tmp/aliases
  rm /tmp/aliases

  EXISTS2=$(compgen -c "$1" | grep -w "$1")
  [[ -z "$EXISTS" ]] && [[ ! -z "$EXISTS2" ]] && eval "$@"
}

copy-shortcuts-to-start-menu() {
  cd /mnt/c/Users/Braden/AppData/Roaming/Microsoft/Windows/Start\ Menu && \
    rm -r ​ *

  for i in /mnt/z/Other\ Stuff/Shortcuts/*; do
    BASENAME=" $(basename "$i")"
    mkdir "​$BASENAME"
    cp "$i"/* "​$BASENAME"
  done

  cd - > /dev/null
}

open() {
  /mnt/c/Windows/explorer.exe "$(wslpath -w "$1")"
}

export -f copy-shortcuts-to-start-menu
export -f open
