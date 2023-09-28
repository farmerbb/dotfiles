#!/bin/bash
# Adapted from https://github.com/Kiaru-the-Fox/Sonic-Mania-Android-Build-Guide/blob/main/ManiaAndroidBuildHelper_2.0.bat

CURRENT_DIR=$(pwd)

sudo rm -rf ~/sonicmania
mkdir ~/sonicmania
cd ~/sonicmania

git clone https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation.git --recursive
git clone https://github.com/Rubberduckycooly/RSDKv5-Example-Mods.git
git clone https://github.com/Rubberduckycooly/GameAPI.git

cd Sonic-Mania-Decompilation/dependencies/RSDKv5/dependencies/android
curl -L http://downloads.xiph.org/releases/theora/libtheora-1.1.1.zip --output libtheora.zip
curl -L http://downloads.xiph.org/releases/ogg/libogg-1.3.5.zip --output libogg.zip
unzip libtheora.zip
unzip libogg.zip

mv libtheora-1.1.1 libtheora
mv libogg/include/ogg/config_types.h libogg-1.3.5/include/ogg
rm -rf libogg
mv libogg-1.3.5 libogg

rm libtheora.zip
rm libogg.zip

cp -r libtheora ../windows
cp -r libogg ../windows

cd ~/sonicmania
cp -r GameAPI RSDKv5-Example-Mods/ManiaTouchControls/GameAPI
cp -r GameAPI RSDKv5-Example-Mods/UltrawideMania/GameAPI

cd Sonic-Mania-Decompilation/dependencies/RSDKv5/android/app/jni
ln -s ~/sonicmania/Sonic-Mania-Decompilation Game
ln -s ~/sonicmania/GameAPI GameAPI
ln -s ~/sonicmania/RSDKv5-Example-Mods/ManiaTouchControls MTouchCtrl
ln -s ~/sonicmania/RSDKv5-Example-Mods/UltrawideMania UWMania

cd ../..
chmod +x gradlew
./gradlew assembleRelease

apksigner sign --ks release-key.jks --ks-key-alias key0 --ks-pass pass:retroengine --key-pass pass:retroengine --in app/build/outputs/apk/release/app-release-unsigned.apk --out "$CURRENT_DIR/RSDKv5.apk"

cd "$CURRENT_DIR"
sudo rm -rf ~/sonicmania
rm -f RSDKv5.apk.idsig
