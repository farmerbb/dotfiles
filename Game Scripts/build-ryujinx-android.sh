#!/bin/bash
# NOTE: This does not currently produce a working APK, it builds fine but freezes at runtime

CURRENT_DIR=$(pwd)

sudo apt-get update
sudo apt-get -y install git wget lld cmake ninja-build

if [[ -d /usr/lib/dotnet ]]; then
  PREV_DOTNET_INSTALL=true
  sudo mv /usr/lib/dotnet /usr/lib/dotnet-old
fi

sudo mkdir /usr/lib/dotnet
sudo chown $USER:$USER /usr/lib/dotnet

cd /usr/lib/dotnet
wget 'https://download.visualstudio.microsoft.com/download/pr/3b2b3c23-574b-45d7-b2b0-c67f0e935308/23ed647eb71a8f07414124422c15927d/dotnet-sdk-9.0.100-rc.1.24452.12-linux-x64.tar.gz'
tar xzfv dotnet-sdk-9.0.100-rc.1.24452.12-linux-x64.tar.gz
rm dotnet-sdk-9.0.100-rc.1.24452.12-linux-x64.tar.gz
cd - >/dev/null

sdkmanager "ndk;25.1.8937393"
export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/25.1.8937393"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

git clone https://github.com/emmauss/Ryujinx.git
cd Ryujinx
git checkout libryujinx_bionic
cd src/RyujinxAndroid

sed -i '$ d' gradle.properties
echo 'org.ryujinx.llvm.toolchain.path=/home/farmerbb/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin' >> gradle.properties

grep -q 'abortOnError' build.gradle || sed -i 's/android {/android { lintOptions { abortOnError false }/' build.gradle

chmod +x gradlew
./gradlew assembleRelease

cp app/build/outputs/apk/release/app-release.apk "$CURRENT_DIR/Ryujinx.apk"

if [[ ! -z $PREV_DOTNET_INSTALL ]]; then
  sudo rm -r /usr/lib/dotnet
  sudo mv /usr/lib/dotnet-old /usr/lib/dotnet
fi
