#!/bin/bash

[[ ! -f X360PkgTool.exe ]] && \
  echo "Please place X360PkgTool.exe in this directory, and try again." && \
  exit 1

[[ ! -d "Content" ]] && \
  echo "Please place the \"Content\" folder in this directory, and try again." && \
  exit 1

if [[ -z $(which dos2unix) ]]; then
  sudo apt-get update
  sudo apt-get install -y dos2unix
fi

$(uname -r | grep "[m|M]icrosoft" > /dev/null) || WINE=wine

for i in Content/**/**/**/*; do
  $WINE ./X360PkgTool.exe "$i" > output.txt

  if [[ $? = 0 ]]; then
    DISPLAY_NAME=$(cat output.txt | dos2unix -f | grep -a "Display Name:" | sed "s/Display Name://g" | awk '{$1=$1};1' | sed "s/:/ -/g" | tr -cd '\40\41\43-\51\55\60-\73\100-\132\141-\172')
    INSTALL_DIR=$(cat output.txt | dos2unix -f | grep -a "Install Dir:" | sed "s/Install Dir://g" | awk '{$1=$1};1' | sed -e "s#\\\#/#g")

    TYPE=$(echo $INSTALL_DIR | cut -d'/' -f3)
    [[ $TYPE == 00000002 ]] && DIR="DLC" # Downloaded Items
    [[ $TYPE == 00004000 ]] && DIR="Disc Games" # Installed Xbox 360 Game
    [[ $TYPE == 00005000 ]] && DIR="Games on Demand (OG Xbox)" # Xbox Originals Game
    [[ $TYPE == 00007000 ]] && DIR="Games on Demand" # Xbox 360 Game
    [[ $TYPE == 00040000 ]] && DIR="System" # System Item
    [[ $TYPE == 00080000 ]] && DIR="Demos" # Game Demo
    [[ $TYPE == 000B0000 ]] && DIR="Title Updates" # Update
    [[ $TYPE == 000D0000 ]] && DIR="XBLA Games" # Xbox Live Arcade Game

    mkdir -p "Xbox 360/$DIR"
  # while [[ -f "Xbox 360/$DIR/$DISPLAY_NAME" ]]; do
  #   DISPLAY_NAME="$DISPLAY_NAME (duplicate)"
  # done

    echo "Moving $DISPLAY_NAME..."
    mv "$i" "Xbox 360/$DIR/$DISPLAY_NAME"
    [[ -d "$i.data" ]] && mv "$i.data" "Xbox 360/$DIR/$DISPLAY_NAME.data"
  fi
done

rm output.txt
