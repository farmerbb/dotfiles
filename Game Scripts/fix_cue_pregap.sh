#!/bin/bash

# Usage: ./fix_cue_pregap.sh file.cue

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 file.cue"
    exit 1
fi

CUE_FILE="$1"
TMP_FILE=$(mktemp)
SEEN_PREGAP=false
SKIPPED_FIRST_INDEX=false
PREGAP_FRAMES=0

# Convert MM:SS:FF to total frames
pregap_frames() {
    IFS=':' read -r mm ss ff <<< "$1"
    echo $(( (10#$mm * 60 + 10#$ss) * 75 + 10#$ff ))
}

# Convert total frames back to MM:SS:FF
frames_to_time() {
    local frames=$1
    local total_seconds=$(( frames / 75 ))
    local ff=$(( frames % 75 ))
    local mm=$(( total_seconds / 60 ))
    local ss=$(( total_seconds % 60 ))
    printf "%02d:%02d:%02d" $mm $ss $ff
}

while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*PREGAP[[:space:]]+([0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
        PREGAP_TIME="${BASH_REMATCH[1]}"
        PREGAP_FRAMES=$(pregap_frames "$PREGAP_TIME")
        SEEN_PREGAP=true
        SKIPPED_FIRST_INDEX=false
        continue  # Skip the PREGAP line itself
    fi

    if $SEEN_PREGAP && [[ "$line" =~ ^([[:space:]]*INDEX[[:space:]]+01[[:space:]]+)([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
        if ! $SKIPPED_FIRST_INDEX; then
            # Skip adjusting the first INDEX 01 after PREGAP
            SKIPPED_FIRST_INDEX=true
            echo "$line" >> "$TMP_FILE"
            continue
        fi

        prefix="${BASH_REMATCH[1]}"
        mm=${BASH_REMATCH[2]}
        ss=${BASH_REMATCH[3]}
        ff=${BASH_REMATCH[4]}
        orig_frames=$(( (10#$mm * 60 + 10#$ss) * 75 + 10#$ff ))
        new_frames=$(( orig_frames - PREGAP_FRAMES ))

        if [ "$new_frames" -lt 0 ]; then
            echo "Error: resulting index time would be negative. Original: $mm:$ss:$ff"
            rm "$TMP_FILE"
            exit 1
        fi

        new_time=$(frames_to_time "$new_frames")
        echo "${prefix}${new_time}" >> "$TMP_FILE"
    else
        echo "$line" >> "$TMP_FILE"
    fi
done < "$CUE_FILE"

# Replace original file
mv "$TMP_FILE" "$CUE_FILE"
echo "✅ PREGAP removed and offsets adjusted (except first INDEX after PREGAP): $CUE_FILE"
