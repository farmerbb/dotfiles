#!/bin/bash
unset HISTFILE

[[ -f /tmp/copy-shortcuts-to-start-menu.running ]] && exit 1
touch /tmp/copy-shortcuts-to-start-menu.running

##################################################

copy-shortcuts-to-start-menu

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/copy-shortcuts-to-start-menu.lastrun
rm -f /tmp/copy-shortcuts-to-start-menu.running
