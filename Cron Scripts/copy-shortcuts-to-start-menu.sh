#!/bin/bash
unset HISTFILE

[[ -f /tmp/copy-shortcuts-to-start-menu.running ]] && exit 1
touch /tmp/copy-shortcuts-to-start-menu.running

##################################################

cd /mnt/c/Users/Braden/AppData/Roaming/Microsoft/Windows/Start\ Menu
rm -r ​*

for i in /mnt/z/Other\ Stuff/Shortcuts/*; do
  BASENAME=$(basename "$i")
  mkdir "​$BASENAME"
  cp "$i"/* "​$BASENAME"
done

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/copy-shortcuts-to-start-menu.lastrun
rm -f /tmp/copy-shortcuts-to-start-menu.running
