#!/bin/bash
unset HISTFILE

[[ -f /tmp/keyboard-backlight.running ]] && exit 1
touch /tmp/keyboard-backlight.running

##################################################

echo 50 | sudo tee '/sys/class/leds/chromeos::kbd_backlight/brightness' > /dev/null

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/keyboard-backlight.lastrun
rm -f /tmp/keyboard-backlight.running
