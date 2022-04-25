#!/bin/bash
if [[ $# -eq 0 || $# -eq 1 ]]; then
  echo "Usage: $0 MagicDosboxBkp_yyyymmddhhmmss.zip <from-device>"
  echo "(where <from-device> is one of: spin713, pixel4a, shield, shield2, or retroid)"
  exit 1
fi

convert() {
  BASENAME=$(basename $1)
  DIRNAME=$(dirname $1)
  [[ $DIRNAME = . ]] && DIRNAME=$(pwd)

  WORKING_DIR=$1-working
  BASE_FILENAME_FIRST=$(echo $BASENAME | sed "s/-mod-$2//g")
  BASE_FILENAME_SECOND=$(echo $BASE_FILENAME_FIRST | sed 's/.zip//g')
  FINAL_FILENAME=$DIRNAME/$BASE_FILENAME_SECOND-mod-$3.zip

  SHIELD_DIR=AC9D-0268/NVIDIA_SHIELD
  SHIELD2_DIR=9CD5-E221/NVIDIA_SHIELD
  SPIN713_DIR=BF17B9A278DEB8F2BC9F49198523B7855CB089E7
  PIXEL4A_DIR=emulated/0
  RETROID_DIR=1234567890

  if [[ $2 = shield ]] ; then
      FROM=$SHIELD_DIR
  elif [[ $2 = shield2 ]] ; then
      FROM=$SHIELD2_DIR
  elif [[ $2 = spin713 ]] ; then
      FROM=$SPIN713_DIR
  elif [[ $2 = pixel4a ]] ; then
      FROM=$PIXEL4A_DIR
  elif [[ $2 = retroid ]] ; then
      FROM=$RETROID_DIR
  fi

  if [[ $3 = shield ]] ; then
      TO=$SHIELD_DIR
  elif [[ $3 = shield2 ]] ; then
      TO=$SHIELD2_DIR
  elif [[ $3 = spin713 ]] ; then
      TO=$SPIN713_DIR
  elif [[ $3 = pixel4a ]] ; then
      TO=$PIXEL4A_DIR
  elif [[ $3 = retroid ]] ; then
      TO=$RETROID_DIR
  fi

  cd "$DIRNAME"
  rm -rf "$WORKING_DIR"
  rm -f "$FINAL_FILENAME"

  mkdir "$WORKING_DIR"
  unzip -q "$1" -d "$WORKING_DIR"

  cd "$WORKING_DIR/.MagicBox/Games/Data"

  for D in *; do
      if [[ -d "${D}" ]] ; then
          cd "${D}"

          if [[ -f "config.xml" ]] ; then
              sed -i "s#${FROM}#${TO}#g" config.xml
          fi

          cd ..
      fi
  done

  cd ../../..
  zip -rq "$FINAL_FILENAME" .MagicBox

  cd "$DIRNAME"
  rm -rf "$WORKING_DIR"
}

if [[ $# -eq 2 ]]; then
  rm -rfv "Magic DosBox"

  SHIELD_NAME="SHIELD (Downstairs)"
  SHIELD2_NAME="SHIELD (Upstairs)"
  SPIN713_NAME="Acer Spin 713"
  PIXEL4A_NAME="Pixel 4a"
  RETROID_NAME="Retroid Pocket 2"

  for target in shield shield2 spin713 pixel4a retroid ; do
    [[ $2 != $target ]] && convert $1 $2 $target

    TEMP_NAME="${target^^}_NAME"
    FINAL_DIR="Magic DosBox/${!TEMP_NAME}"

    BASENAME=$(basename $1)
    DIRNAME=$(dirname $1)
    [[ $DIRNAME = . ]] && DIRNAME=$(pwd)

    BASE_FILENAME_FIRST=$(echo $BASENAME | sed "s/-mod-$2//g")
    BASE_FILENAME_SECOND=$(echo $BASE_FILENAME_FIRST | sed 's/.zip//g')
    FINAL_FILENAME=$DIRNAME/$BASE_FILENAME_SECOND-mod-$target.zip

    mkdir -p "$FINAL_DIR"
    [[ $2 = $target ]] && cp "$1" "$FINAL_DIR"
    [[ $2 != $target ]] && mv "$FINAL_FILENAME" "$FINAL_DIR"
  done

  rm "$1"
fi

[[ $# -eq 3 ]] && convert $1 $2 $3
