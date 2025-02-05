#!/bin/bash

count=2
GDI_DIR=$(printf '%02d' $count)
CHDMAN=~/Games/Utilities/chdman/chdman

rm -f track*
for i in *.chd; do
  while [[ -d $GDI_DIR ]]; do
    ((count++))
    GDI_DIR=$(printf '%02d' $count)
  done

  GAME_NAME=$(echo "$i" | sed s/.chd//g)
  echo "Converting $GAME_NAME..."

  $CHDMAN extractcd -i "$i" -o track.gdi
  mkdir $GDI_DIR
  mv track.gdi $GDI_DIR/disc.gdi
  mv track* $GDI_DIR
  echo "$GAME_NAME" > $GDI_DIR/name.txt
done
