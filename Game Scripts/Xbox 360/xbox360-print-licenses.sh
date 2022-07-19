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
    LICENSES=$(cat output.txt | dos2unix -f | sed '1,/License Descriptors/d;/Ids and Versions/,$d')

    echo "$i:"
    echo -e "$LICENSES"
    echo
  fi
done

rm output.txt
