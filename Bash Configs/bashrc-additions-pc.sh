# export LINUX_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux)"
# export DEVICE_DIR_PREFIX="$(realpath /mnt/files/Other\ Stuff/Linux/Devices/PC)"
# export OD_LINUX_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux"
# export OD_DEVICE_DIR_PREFIX="/home/$USER/OneDrive/Other Stuff/Linux/Devices/PC"
# export PATH="$PATH:$LINUX_DIR_PREFIX/Scripts"

export SYNC_DIRS=(
  "Games"
  "Other Stuff"
)

# chmod +x "$LINUX_DIR_PREFIX/Scripts/"* >/dev/null 2>&1

# copy-shortcuts-to-start-menu() {
#   cd /mnt/c/Users/Braden/AppData/Roaming/Microsoft/Windows/Start\ Menu && \
#     rm -rf  * >/dev/null 2>&1
# 
#   for i in /mnt/files/Other\ Stuff/Shortcuts/*; do
#     BASENAME=" $(basename "$i")"
#     mkdir "$BASENAME"
#     cp "$i"/* "$BASENAME"
#   done
# 
#   cd - > /dev/null
# }

# export -f copy-shortcuts-to-start-menu
