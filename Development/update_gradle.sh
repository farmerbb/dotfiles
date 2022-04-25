#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo "Usage: $0 <version> <project-dir>"
    exit 1
fi

if [ -z "$ANDROID_HOME" ]
then
    export ANDROID_HOME=~/Android/Sdk
fi

cd $2
for i in {1..2}; do ./gradlew wrapper --gradle-version=$1 --distribution-type=all; done
