#!/bin/bash

# export ANDROID_SDK_ROOT=/home/farmerbb/Android/Sdk
# cd Taskbar
# ./gradlew clean lib:build bintrayUpload -PbintrayUser=farmerbb -PbintrayKey=[REDACTED] -PdryRun=false

git clone --recurse-submodules git@github.com:farmerbb/libtaskbar.git
cd libtaskbar/
git submodule update --remote

rm -rf gradle*
cp -r Taskbar/gradle* .

VERSION=$(./gradlew outputVersion -q | tail -n1)

echo
read -p "Press Enter to add release notes for the $VERSION release..."

nano README.md
git-commit-and-push "libtaskbar $VERSION"

echo
echo "Visit the following URL to publish the $VERSION release:"
echo
echo "https://github.com/farmerbb/libtaskbar/releases/new/"

cd - >/dev/null 2>&1
rm -rf libtaskbar
