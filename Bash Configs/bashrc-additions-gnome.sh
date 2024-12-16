ALL_EXTENSIONS=(
  dash-to-panel@jderose9.github.com
  mprisLabel@moon-0xff.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
  grand-theft-focus@zalckos.github.com
  arcmenu@arcmenu.com
  quick-settings-tweaks@qwreey
  gestureImprovements@gestures
  ding@rastersoft.com
  ubuntu-appindicators@ubuntu.com
  gsconnect@andyholmes.github.io
  tiling-assistant@leleat-on-github
  compiz-windows-effect@hermes83.github.com
  notification-banner-reloaded@marcinjakubowski.github.com
  transparent-window-moving@noobsai.github.com
  auto-power-profile@dmy3k.github.io
  custom-command-toggle@storageb.github.com
  space-bar@luchrioh
  workspace-switcher-manager@G-dH.github.com
)

EXTENSIONS_WEB=(
  1160 # dash-to-panel@jderose9.github.com
  4928 # mprisLabel@moon-0xff.github.com
  19   # user-theme@gnome-shell-extensions.gcampax.github.com
  5410 # grand-theft-focus@zalckos.github.com
  3628 # arcmenu@arcmenu.com
  3210 # compiz-windows-effect@hermes83.github.com
  4651 # notification-banner-reloaded@marcinjakubowski.github.com
  3733 # tiling-assistant@leleat-on-github
  6583 # auto-power-profile@dmy3k.github.io
  7012 # custom-command-toggle@storageb.github.com
  1446 # transparent-window-moving@noobsai.github.com
  5090 # space-bar@luchrioh
  4788 # workspace-switcher-manager@G-dH.github.com
# 4245 # gestureImprovements@gestures
# 5446 # quick-settings-tweaks@qwreey
)

EXTENSIONS_APT=(
  gnome-shell-extension-desktop-icons-ng # ding@rastersoft.com
  gnome-shell-extension-appindicator     # ubuntu-appindicators@ubuntu.com
  gnome-shell-extension-gsconnect        # gsconnect@andyholmes.github.io
)

if [[ $HOSTNAME = NUC ]]; then
  ALL_EXTENSIONS=("${ALL_EXTENSIONS[@]/auto-power-profile@dmy3k.github.io}" )
  ALL_EXTENSIONS=("${ALL_EXTENSIONS[@]/gsconnect@andyholmes.github.io}" )
  EXTENSIONS_WEB=("${EXTENSIONS_WEB[@]/6583}" )
  EXTENSIONS_APT=("${EXTENSIONS_APT[@]/gnome-shell-extension-gsconnect}" )
fi

export-extension-config() {
  DIR="$LINUX_DIR_PREFIX/Ubuntu/extensions"
  FILE="$DIR/$1.txt"
  CONFIG_DIR=~/.config/$1

  if [[ -f "$FILE" ]]; then
    MD5=$(md5sum "$FILE")
    dconf dump /org/gnome/shell/extensions/$1/ > "$FILE"
    [[ $(md5sum "$FILE") != $MD5 ]] && cp "$FILE" "$OD_LINUX_DIR_PREFIX/Ubuntu/extensions/$1.txt"

    if [[ -d "$CONFIG_DIR" ]]; then
      for i in "$LINUX_DIR_PREFIX" "$OD_LINUX_DIR_PREFIX"; do
        rm -rf "$i/Ubuntu/extensions/$1"
        cp -r "$CONFIG_DIR" "$i/Ubuntu/extensions/$1"
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

fix-extensions() {
  dconf write /org/gnome/shell/disable-user-extensions false

  for i in $(gnome-extensions list); do
    echo ${ALL_EXTENSIONS[@]} | grep -owq $i && EXT_COMMAND=enable || EXT_COMMAND=disable
    gnome-extensions $EXT_COMMAND $i
  done
}

sync-extensions() {
  for i in ~/Other\ Stuff/Linux/Gnome\ Extensions/*.zip; do
    gnome-extensions install --force "$i"
  done

  if [[ -z $(which curl) ]]; then
    sudo apt-get update
    sudo apt-get install -y curl
  fi

  if [[ -z $(which gnome-shell-extension-installer) ]]; then
    sudo curl -L "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer" -o /usr/local/bin/gnome-shell-extension-installer
    sudo chmod +x /usr/local/bin/gnome-shell-extension-installer
  fi

  gnome-shell-extension-installer ${EXTENSIONS_WEB[@]}

  sudo apt-get update
  sudo apt-get install -y ${EXTENSIONS_APT[@]} gnome-shell-extension-manager

  for i in $(gnome-extensions list); do
    echo ${ALL_EXTENSIONS[@]} | grep -owq $i || UNINSTALL=true
    [[ $UNINSTALL = true ]] && gnome-extensions uninstall $i; UNINSTALL=false
  done

  DIR="$LINUX_DIR_PREFIX/Ubuntu/extensions"
  for i in $(ls --color=auto "$DIR"/*.txt | sed -e "s#$DIR/##g" -e "s/\.txt//g" -e "s/:/:\n/g"); do
    import-extension-config $i
  done

  echo
  echo "Please reboot, then run 'fix-extensions' to finish applying changes."
}

export -f export-extension-config
export -f import-extension-config
export -f fix-extensions
export -f sync-extensions
