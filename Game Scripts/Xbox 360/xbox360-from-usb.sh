#!/bin/bash

[[ ! -f X360PkgTool.exe ]] && \
  echo "Please place X360PkgTool.exe in this directory, and try again." && \
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

    echo "Moving $DISPLAY_NAME..."

    mv "$i" "$DISPLAY_NAME"
    [[ -d "$i.data" ]] && mv "$i.data" "$DISPLAY_NAME.data"
  fi
done

rm output.txt
