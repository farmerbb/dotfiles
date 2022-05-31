#!/bin/bash

[[ ! -f X360PkgTool.exe ]] && \
  echo "Please place X360PkgTool.exe in this directory, and try again." && \
  exit 1

if [[ -z $(which dos2unix) ]]; then
  sudo apt-get update
  sudo apt-get install -y dos2unix
fi

$(uname -r | grep "[m|M]icrosoft" > /dev/null) || WINE=wine

for i in $(find . -type f); do
  $WINE ./X360PkgTool.exe "$i" > output.txt

  if [[ $? = 0 ]]; then
    DISPLAY_NAME=$(cat output.txt | dos2unix -f | grep "Display Name:" | sed "s/Display Name://g" | awk '{$1=$1};1' | sed "s/:/ -/g")

    echo "Extracting $DISPLAY_NAME..."

    mv "$i" "$i.tmp"
    $WINE ./X360PkgTool.exe -ea "$i" "$i.tmp" > /dev/null
    rm "$i.tmp"
  fi
done

rm output.txt
