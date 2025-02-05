#!/bin/bash

DOLPHIN_TOOL="flatpak run --command=dolphin-tool org.DolphinEmu.dolphin-emu"

for i in *.rvz; do
  GAME_NAME=$(echo "$i" | sed s/.rvz//g)
  echo "Converting $GAME_NAME..."
  $DOLPHIN_TOOL convert -i "$i" -o "$GAME_NAME.iso" -f iso
done
