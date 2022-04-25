#!/bin/bash

for i in *.rvz; do
  GAME_NAME=$(echo "$i" | sed s/.rvz//g)
  echo "Converting $GAME_NAME..."
  dolphin-tool convert -i "$i" -o "$GAME_NAME.iso" -f iso
done
