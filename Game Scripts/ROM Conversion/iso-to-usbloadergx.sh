#!/bin/bash

# From https://github.com/gotbletu/shownotes/blob/master/wit_wii_gamecube_convert.md
convert-to-game-usbloadergx() {
  if [ $# -lt 1 ]; then
    echo -e "convert wii iso games to wbfs that will works with usbloadergx on a modded wii console"
    echo -e "\nUsage: $0 <filename>"
    echo -e "\nExample:\n$0 WiiSports.iso"
    echo -e "$0 MarioKart.iso Zelda.iso DonkeyKong.iso"
    echo -e "$0 *.iso"
    echo -e "\nUSBLoaderGX uses these paths:"
    echo -e "USB:/wbfs/"
    echo -e "USB:/wbfs/Name of game [GameID]/GameID.wbfs"
    echo -e "USB:/wbfs/Donkey Kong Country Returns (USA) [SF8E01]/SF8E01.wbfs"
    echo -e "\nSplit Wii Game Example:"
    echo -e "USB:/wbfs/Super Smash Bros Brawl (NTSC) [RSBE01]/RSBE01.wbf1"
    echo -e "USB:/wbfs/Super Smash Bros Brawl (NTSC) [RSBE01]/RSBE01.wbf2"
    echo -e "USB:/wbfs/Super Smash Bros Brawl (NTSC) [RSBE01]/RSBE01.wbf3"
    echo -e "USB:/wbfs/Super Smash Bros Brawl (NTSC) [RSBE01]/RSBE01.wbfs"
    return 1
  fi
  myArray=( "$@" )
  for arg in "${myArray[@]}"; do
    FILENAME="${arg%.*}"
    REGION=$(wit lll -H "$arg" | awk '{print $4}')
    GAMEID=$(wit lll -H "$arg" | awk '{print $1}')
    TITLE=$(wit lll -H "$arg" | awk '{ print substr($0, index($0,$5)) }' | awk '{$1=$1};1' )
    DIR_FILENAME="$FILENAME [$GAMEID]"
    DIR_TITLENAME="$TITLE ($REGION) [$GAMEID]"

    ## create proper folder structure base on title inside the rom, scrub image & convert to wbfs, auto split at 4GB a piece
    # mkdir -pv "$DIR_TITLENAME"
    # wit copy --wbfs --split "$arg" "$DIR_TITLENAME"/"$GAMEID.wbfs"

    ## create proper folder structure base on filename, scrub image & convert to wbfs, auto split at 4GB a piece
    mkdir -pv "$DIR_FILENAME"
    wit copy --wbfs --split "$arg" "$DIR_FILENAME"/"$GAMEID.wbfs"
  done
}

if [[ -z $(which wit) ]] ; then
  sudo apt-get update
  sudo apt-get install -y wit
fi

convert-to-game-usbloadergx "$@"
