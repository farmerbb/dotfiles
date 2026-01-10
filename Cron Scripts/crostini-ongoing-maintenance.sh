#!/bin/bash
unset HISTFILE

bash -i ~/Other\ Stuff/Linux/Cron\ Scripts/crostini-mounts.sh

resolution() {
  xdpyinfo | grep dimensions | cut -d' ' -f 7
}

density() {
  xdpyinfo | grep resolution | cut -d' ' -f 7
}

while true; do
  NEW_RESOLUTION=$(resolution)
  NEW_DENSITY=$(density)

  if [[ $NEW_RESOLUTION != $RESOLUTION || $NEW_DENSITY != $DENSITY ]]; then
    fix-arc && restart-sommelier

    RESOLUTION=$(resolution)
    DENSITY=$(density)
  fi

  reclaim-vm-memory 0.5
  sleep 5
done
