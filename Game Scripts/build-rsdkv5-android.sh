#!/bin/bash
# Adapted from https://github.com/RSDKModding/RSDKv5-Decompilation/blob/master/.github/workflows/build.yml

CURRENT_DIR=$(pwd)

sudo rm -rf ~/sonicmania
mkdir ~/sonicmania
cd ~/sonicmania

git clone https://github.com/RSDKModding/RSDKv5-Decompilation.git --recursive
cd RSDKv5-Decompilation

git clone https://github.com/RSDKModding/Sonic-Mania-Decompilation.git
git clone https://github.com/RSDKModding/RSDKv5-Example-Mods.git
git clone https://github.com/RSDKModding/RSDKv5-GameAPI.git

cd dependencies/android
curl -L -O https://downloads.xiph.org/releases/ogg/libogg-1.3.5.zip
curl -L -O https://downloads.xiph.org/releases/theora/libtheora-1.1.1.zip
unzip \*.zip
rm *.zip
rsync -ar libogg-*/* libogg
mv libtheora-* libtheora

cd -
rm Game
rmdir $PWD/Sonic-Mania-Decompilation/dependencies/RSDKv5
ln -s $PWD $PWD/Sonic-Mania-Decompilation/dependencies/RSDKv5
ln -s $PWD/RSDKv5-GameAPI RSDKv5-Example-Mods/ManiaTouchControls/GameAPI
ln -s $PWD/RSDKv5-GameAPI RSDKv5-Example-Mods/UltrawideMania/GameAPI
ln -s $PWD/Sonic-Mania-Decompilation ./android/app/jni/Game
ln -s $PWD/RSDKv5-Example-Mods/ManiaTouchControls ./android/app/jni/MTC
ln -s $PWD/RSDKv5-Example-Mods/UltrawideMania ./android/app/jni/UWM

cd android
./gradlew assembleRelease
mv app/build/outputs/apk/release/app-release.apk "$CURRENT_DIR/RSDKv5.apk"

cd "$CURRENT_DIR"
sudo rm -rf ~/sonicmania
