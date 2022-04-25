#!/bin/bash

count=2
CDI_DIR=$(printf '%02d' $count)

for i in *.cdi; do
  while [[ -d $CDI_DIR ]]; do
    ((count++))
    CDI_DIR=$(printf '%02d' $count)
  done

  GAME_NAME=$(echo "$i" | sed s/.cdi//g)
  echo "Copying $GAME_NAME..."

  mkdir $CDI_DIR
  cp "$i" $CDI_DIR/disc.cdi
  echo "$GAME_NAME" > $CDI_DIR/name.txt
done
