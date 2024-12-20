#!/bin/bash

[[ ! -f X360PkgTool.exe ]] && \
  echo "Please place X360PkgTool.exe in this directory, and try again." && \
  exit 1

if [[ -z $(which dos2unix) ]]; then
  sudo apt-get update
  sudo apt-get install -y dos2unix
fi

$(uname -r | grep "[m|M]icrosoft" > /dev/null) || WINE=wine

for i in *; do
  $WINE ./X360PkgTool.exe "$i" > output.txt

  if [[ $? = 0 ]]; then
    echo "Moving $i..."

    CONTENT_ID=$(cat output.txt | dos2unix -f | grep -a "Content Id:" | sed "s/Content Id://g" | awk '{$1=$1};1')
    INSTALL_DIR=$(cat output.txt | dos2unix -f | grep -a "Install Dir:" | sed "s/Install Dir://g" | awk '{$1=$1};1' | sed -e "s#\\\#/#g")
    VERSION=$(cat output.txt | dos2unix -f | grep -a "Base Version:" | sed "s/Base Version://g" | awk '{$1=$1};1')

    TYPE=$(echo $INSTALL_DIR | cut -d'/' -f3)
    [[ $TYPE == 00005000 ]] && CONTENT_ID=$(echo $CONTENT_ID | cut -c1-32,41-)
    [[ $TYPE == 00007000 ]] && CONTENT_ID=$(echo $CONTENT_ID | cut -c1-32,41-)
    [[ $TYPE == 000B0000 ]] && CONTENT_ID="tu${VERSION}_00000000"

    mkdir -p "Content/$INSTALL_DIR"
    mv "$i" "Content/$INSTALL_DIR/$CONTENT_ID"
    [[ -d "$i.data" ]] && mv "$i.data" "Content/$INSTALL_DIR/$CONTENT_ID.data"
  fi
done

rm output.txt
