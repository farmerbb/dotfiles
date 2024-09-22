#!/bin/bash

RETROARCH_REPO=~/libretro-super/retroarch
KEYSTORE=~/AndroidStudioProjects/Keystore
PASSWORD=$(base64 -d <<< [REDACTED])

CURRENT_DIR=$(pwd)
NDK_DIR="$(ls -d1 $ANDROID_SDK_ROOT/ndk/* | tail -n 1)"

cd $RETROARCH_REPO

git remote update origin --prune
VERSION=$(git tag | grep "v" | sort -V | tail -n 1)
#VERSION=origin/master

git clean -xfd
git reset --hard
git checkout $VERSION
git submodule update --init

cd pkg/android/phoenix
echo -e "sdk.dir=$ANDROID_SDK_ROOT\nndk.dir=$NDK_DIR" > local.properties
echo -e "storePassword=$PASSWORD\nkeyPassword=$PASSWORD\nkeyAlias=farmerbb\nstoreFile=$KEYSTORE" > keystore.properties

sed -i '' "s/abiFilters 'armeabi-v7a', 'x86'/abiFilters 'armeabi-v7a'/g" build.gradle
sed -i '' "s/applicationIdSuffix '.ra32'//g" build.gradle

./gradlew assembleRa32Release
cp build/outputs/apk/ra32/release/phoenix-ra32-release.apk $CURRENT_DIR/RetroArch-32bit.apk
