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
OUTPUT_FILENAME="$(echo "$*" | sed "s#/##")-output.zip"

export KSTOREFILE=~/AndroidStudioProjects/Keystore
export KEYALIAS=farmerbb
export KEYPWD=$PASSWORD
export KSTOREPWD=$PASSWORD

# Remove old output.zip file
rm -f "$OUTPUT_FILENAME"

# Reset the git repo
cd "$*"
[[ -f local.properties ]] && mv local.properties ..
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
    zip -rq "$OUTPUT_FILENAME" "$*"
    cd "$*"

    # Open folder where APKs are stored
    open ./app/build/outputs/apk
fi

[[ -f ../local.properties ]] && mv ../local.properties .
echo Done!
