#!/bin/bash

# From https://github.com/gotbletu/shownotes/blob/master/wit_wii_gamecube_convert.md
convert-to-game-nintendont() {
  if [ $# -lt 1 ]; then
    echo -e "convert gamecube iso games to ciso (compress iso, ignore unused blocks)."
    echo -e "works with nintendont v4.428+ and usbloadergx on a modded wii console."
    echo -e "Note: after conversion the ciso will be renamed to iso to make it work under usbloadergx"
    echo -e "\nUsage: $0 <filename>"
    echo -e "\nExample:\n$0 Melee.iso"
    echo -e "$0 Melee.iso DoubleDash.iso WindWaker.iso"
    echo -e "$0 *.iso"
    echo -e "\nNintendont uses these paths:"
    echo -e "USB:/games/"
    echo -e "USB:/games/Name of game [GameID]/game.iso"
    echo -e "USB:/games/Legend of Zelda the Wind Waker (USA) [GZLP01]/game.iso"
    echo -e "\nMultiple Gamecube Disc Example:"
    echo -e "USB:/games/Resident Evil 4 (USA) [G4BE08]/game.iso"
    echo -e "USB:/games/Resident Evil 4 (USA) [G4BE08]/disc2.iso"
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

    ## no conversion; only generate folder base on title inside the rom, move iso to folder
    # mkdir -pv "$DIR_TITLENAME"
    # mv -v "$arg" "$DIR_TITLENAME"/game.iso

    ## no conversion; only generate folder base on filename, move iso to folder
    # mkdir -pv "$DIR_FILENAME"
    # mv -v "$arg" "$DIR_FILENAME"/game.iso

    ## convert to ciso; generate folder base on title inside the rom; move ciso to folder
    ## rename ciso to iso ; this will make it compatible with both nintendont and usbloadergx
    # mkdir -pv "$DIR_TITLENAME"
    # wit copy --ciso "$arg" "$DIR_TITLENAME"/game.iso

    ## convert to ciso; generate folder base on filename; move ciso to folder
    ## rename ciso to iso ; this will make it compatible with both nintendont and usbloadergx
    mkdir -pv "$DIR_FILENAME"
    wit copy --ciso "$arg" "$DIR_FILENAME"/game.iso
  done
}

if [[ -z $(which wit) ]] ; then
  sudo apt-get update
  sudo apt-get install -y wit
fi

convert-to-game-nintendont "$@"
