#!/bin/bash

CURRENT_DIR=$(pwd)
PASSWORD=$(base64 -d <<< [REDACTED])

sudo apt-get update
sudo apt-get -y install git wget maven ninja-build

sdkmanager "ndk;25.1.8937393"
export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/25.1.8937393"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

git clone --recurse-submodules https://github.com/TerryCavanagh/VVVVVV.git
cd VVVVVV

wget https://www.libsdl.org/release/SDL2-2.28.5.tar.gz
tar xzfv SDL2-2.28.5.tar.gz

cd SDL2-2.28.5
./build-scripts/android-prefab.sh
mvn install:install-file -Dfile=build-android-prefab/prefab-2.28.5/SDL2-2.28.5.aar -DpomFile=build-android-prefab/prefab-2.28.5/SDL2-2.28.5.pom

cd ../desktop_version/VVVVVV-android/app
sed -i "s/enable true/enable false/g" build.gradle

cd src/main
mkdir -p assets
cd assets
wget https://thelettervsixtim.es/makeandplay/data.zip

cd ../../../..
./gradlew assembleRelease

cd app/build/outputs/apk/release
apksigner sign --ks ~/Keystore --ks-key-alias farmerbb --ks-pass pass:$PASSWORD --key-pass pass:$PASSWORD --in app-release-unsigned.apk --out "$CURRENT_DIR/VVVVVV.apk"

cd "$CURRENT_DIR"
sudo rm -rf VVVVVV
rm -f VVVVVV.apk.idsig
