#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo "Usage: $0 <project-dir>"
    exit 1
fi

echo Make sure Android Studio is closed and all files are committed before proceeding.
read -p "Press Enter to continue..."

# Export environment variables
if [ -z "$ANDROID_HOME" ]
then
    export ANDROID_HOME=~/Android/Sdk
fi

PASSWORD=$(base64 -d <<< [REDACTED])

export KSTOREFILE=~/Keystore
export KEYALIAS=farmerbb
export KEYPWD=$PASSWORD
export KSTOREPWD=$PASSWORD

# Remove old output.zip file
rm -f output.zip

# Reset the git repo
cd "$*"
git clean -xfd
git reset --hard

if [[ $? != 0 ]]; then
    rm -r build
    rm -r app/build
fi

# Finally, build the APK
./gradlew app:assembleRelease

if [[ $? == 0 ]]; then
    # Zip folder contents
    cd ..
    zip -rq output.zip "$*"
    cd "$*"

    # Open folder where APKs are stored
    thunar ./app/build/outputs/apk &
fi

echo Done!
