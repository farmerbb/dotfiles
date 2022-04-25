#!/bin/bash
if [[ $# -ne 3 ]] ; then
    echo "Usage: $0 retroarch.cfg <from-arch> <to-arch>"
    echo "(where <from-arch> and <to-arch> are: x32, x64, a32, or a64)"
    exit 1
fi

BASENAME=$(basename $1)
DIRNAME=$(dirname $1)

if [[ $DIRNAME = . ]] ; then
    DIRNAME=$(pwd)
fi

BASE_FILENAME_FIRST=$(echo $BASENAME | sed "s/-mod-$2//g")
BASE_FILENAME_SECOND=$(echo $BASE_FILENAME_FIRST | sed 's/.cfg//g')
FINAL_FILENAME=$DIRNAME/$BASE_FILENAME_SECOND-mod-$3.cfg

if [[ $2 = x32 ]] ; then
    BUILDBOT_ARCH_FROM=x86
    PACKAGE_NAME_FROM=com.retroarch.ra32
    OZONE_THEME_FROM=ozone_menu_color_theme\ =\ \"2\"
elif [[ $2 = x64 ]] ; then
    BUILDBOT_ARCH_FROM=x86_64
    PACKAGE_NAME_FROM=com.retroarch
    OZONE_THEME_FROM=ozone_menu_color_theme\ =\ \"1\"
elif [[ $2 = a32 ]] ; then
    BUILDBOT_ARCH_FROM=armeabi-v7a
    PACKAGE_NAME_FROM=com.retroarch.ra32
    OZONE_THEME_FROM=ozone_menu_color_theme\ =\ \"2\"
elif [[ $2 = a64 ]] ; then
    BUILDBOT_ARCH_FROM=arm64-v8a
    PACKAGE_NAME_FROM=com.retroarch
    OZONE_THEME_FROM=ozone_menu_color_theme\ =\ \"1\"
fi

if [[ $3 = x32 ]] ; then
    BUILDBOT_ARCH_TO=x86
    PACKAGE_NAME_TO=com.retroarch.ra32
    OZONE_THEME_TO=ozone_menu_color_theme\ =\ \"2\"
elif [[ $3 = x64 ]] ; then
    BUILDBOT_ARCH_TO=x86_64
    PACKAGE_NAME_TO=com.retroarch
    OZONE_THEME_TO=ozone_menu_color_theme\ =\ \"1\"
elif [[ $3 = a32 ]] ; then
    BUILDBOT_ARCH_TO=armeabi-v7a
    PACKAGE_NAME_TO=com.retroarch.ra32
    OZONE_THEME_TO=ozone_menu_color_theme\ =\ \"2\"
elif [[ $3 = a64 ]] ; then
    BUILDBOT_ARCH_TO=arm64-v8a
    PACKAGE_NAME_TO=com.retroarch
    OZONE_THEME_TO=ozone_menu_color_theme\ =\ \"1\"
fi

cd "$DIRNAME"
rm -f "$FINAL_FILENAME"

cp "$1" "$FINAL_FILENAME"

sed -i "s#${BUILDBOT_ARCH_FROM}#${BUILDBOT_ARCH_TO}#g" "$FINAL_FILENAME"
sed -i "s#${PACKAGE_NAME_FROM}#${PACKAGE_NAME_TO}#g" "$FINAL_FILENAME"
sed -i "s#${OZONE_THEME_FROM}#${OZONE_THEME_TO}#g" "$FINAL_FILENAME"
