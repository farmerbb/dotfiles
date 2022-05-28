#!/bin/bash
# This script is intended to be run on Windows using MSYS2 MinGW 64-bit,
# which can be downloaded from msys2.org

pacman -S --needed --noconfirm git make python3 mingw-w64-x86_64-gcc patch

cd
rm -rf sm64-port
git clone https://github.com/sm64-port/sm64-port.git
cd sm64-port

patch -p1 < enhancements/60fps.patch
sed -i "s/G_IM_FMT_RGBA/G_IM_FMT_IA/g" actors/burn_smoke/model.inc.c

cp /z/Games/Emulation/Retail/Nintendo\ 64/Super\ Mario\ 64.z64 baserom.us.z64
make -j4

cp build/us_pc/sm64.us.f3dex2e.exe /c/Users/Braden/Desktop