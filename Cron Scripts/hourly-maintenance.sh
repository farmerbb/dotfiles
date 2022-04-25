#!/bin/bash
unset HISTFILE

[[ -f /tmp/hourly-maintenance.running ]] && exit 1
touch /tmp/hourly-maintenance.running

##################################################

convert-svgs
fix-crostini-icons

##################################################

[[ $? -eq 0 ]] && touch ~/.lastrun/hourly-maintenance.lastrun
rm -f /tmp/hourly-maintenance.running
