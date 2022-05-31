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

    CONTENT_ID=$(cat output.txt | dos2unix -f | grep "Content Id:" | sed "s/Content Id://g" | awk '{$1=$1};1')
    INSTALL_DIR=$(cat output.txt | dos2unix -f | grep "Install Dir:" | sed "s/Install Dir://g" | awk '{$1=$1};1' | sed -e "s#\\\#/#g")

    mkdir -p "Content/$INSTALL_DIR"
    mv "$i" "Content/$INSTALL_DIR/$CONTENT_ID"
    [[ -d "$i.data" ]] && mv "$i.data" "Content/$INSTALL_DIR/$CONTENT_ID.data"
  fi
done

rm output.txt
