#!/bin/bash

[[ ! -f X360PkgTool.exe ]] && \
  echo "Please place X360PkgTool.exe in this directory, and try again." && \
  exit 1

[[ ! -d "Xbox 360" ]] && \
  echo "Please place the \"Xbox 360\" folder in this directory, and try again." && \
  exit 1

if [[ -f "Xbox 360/System/Content Cache" ]]; then
  HAS_CONTENT_CACHE=true
else
  echo "Unable to find Content Cache; filenames will be approximate."
  echo "Games installed from discs will appear as corrupted and won't be playable."
  echo
fi

if [[ -z $(which dos2unix) ]]; then
  sudo apt-get update
  sudo apt-get install -y dos2unix
fi

$(uname -r | grep "[m|M]icrosoft" > /dev/null) || WINE=wine
[[ ! -z $HAS_CONTENT_CACHE ]] && $WINE ./X360PkgTool.exe -e CDIs.bin "Xbox 360/System/Content Cache" > /dev/null

for i in Xbox\ 360/*/*; do
  $WINE ./X360PkgTool.exe "$i" > output.txt

  if [[ $? = 0 ]]; then
    echo "Moving $(echo $i | cut -d'/' -f3)..."

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
[[ -z $HAS_CONTENT_CACHE ]] && exit

mkdir -p Content/0000000000000000/FFFE07DF/00040000
mv Content/0000000000000000/00000000/00040000/* Content/0000000000000000/FFFE07DF/00040000

if [[ -z $(which strings) ]]; then
  sudo apt-get update
  sudo apt-get install -y binutils
fi

echo "Correcting filenames using data from Content Cache..."

split -b $((0x200)) CDIs.bin content-cache-
rm $(ls -1r content-cache-* | head -n1)

for i in content-cache-*; do
  GAME_ID=$(dd if=$i status=none iflag=skip_bytes,count_bytes skip=$((0x14C)) count=4 | od -An -v -tx1 | tr -d ' \n' | tr '[:lower:]' '[:upper:]')
  TYPE=$(dd if=$i status=none iflag=skip_bytes,count_bytes skip=$((0x10)) count=4 | od -An -v -tx1 | tr -d ' \n' | tr '[:lower:]' '[:upper:]')
  CONTENT_ID=$(dd if=$i status=none iflag=skip_bytes skip=$((0x114)) | strings | head -n1)

  INSTALL_DIR="Content/0000000000000000/$GAME_ID/$TYPE"
  for j in $INSTALL_DIR/*; do
    case $j in
      *$CONTENT_ID.data) true ;;
      *$CONTENT_ID) true ;;
      *.data) mv -n $j $INSTALL_DIR/$CONTENT_ID.data ;;
      *) mv -n $j $INSTALL_DIR/$CONTENT_ID ;;
    esac
  done
done

rm content-cache-*
rm CDIs.bin
