#!/bin/bash

# Usage: ./fix_cue_pregap.sh file.cue
#
# - If no PREGAP is found, do nothing
# - If PREGAP exists:
#   * Remove PREGAP line
#   * Leave INDEX 01 unchanged
#   * Insert INDEX 00 before each post-PREGAP INDEX 01
#     (skip the very first one, and skip if INDEX 00 already present)
#   * Save original file as file.cue.bak
#   * Print a summary of changes

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 file.cue"
    exit 1
fi

CUE_FILE="$1"
if [ ! -f "$CUE_FILE" ]; then
    echo "Error: file not found: $CUE_FILE"
    exit 1
fi

TMP_FILE=$(mktemp)
BACKUP_FILE="${CUE_FILE}.bak"

SEEN_PREGAP=false
SKIPPED_FIRST_INDEX=false
PREGAP_FRAMES=0
LAST_WAS_INDEX00=false
CHANGES=()

# Convert MM:SS:FF to total frames
to_frames() {
    IFS=':' read -r mm ss ff <<< "$1"
    echo $(( (10#$mm * 60 + 10#$ss) * 75 + 10#$ff ))
}

# Convert total frames back to MM:SS:FF
to_time() {
    local frames=$1
    local total_seconds=$(( frames / 75 ))
    local ff=$(( frames % 75 ))
    local mm=$(( total_seconds / 60 ))
    local ss=$(( total_seconds % 60 ))
    printf "%02d:%02d:%02d" $mm $ss $ff
}

# First pass: check for PREGAP
if ! grep -q -E '^[[:space:]]*PREGAP[[:space:]]+[0-9]{2}:[0-9]{2}:[0-9]{2}' "$CUE_FILE"; then
    echo "ℹ️  No PREGAP found in $CUE_FILE — no changes made."
    exit 0
fi

# Backup
cp -f "$CUE_FILE" "$BACKUP_FILE"
echo "📀 Backup saved as: $BACKUP_FILE"

# Process file
lineno=0
while IFS= read -r line; do
    lineno=$((lineno + 1))

    # Detect PREGAP
    if [[ "$line" =~ ^[[:space:]]*PREGAP[[:space:]]+([0-9]{2}:[0-9]{2}:[0-9]{2}) ]]; then
        PREGAP_TIME="${BASH_REMATCH[1]}"
        PREGAP_FRAMES=$(to_frames "$PREGAP_TIME")
        SEEN_PREGAP=true
        SKIPPED_FIRST_INDEX=false
        LAST_WAS_INDEX00=false
        CHANGES+=("Removed PREGAP $PREGAP_TIME (line $lineno)")
        continue  # drop the line
    fi

    # Detect INDEX 00
    if [[ "$line" =~ ^[[:space:]]*INDEX[[:space:]]+00 ]]; then
        LAST_WAS_INDEX00=true
        echo "$line" >> "$TMP_FILE"
        continue
    fi

    # Handle INDEX 01 after pregap
    if $SEEN_PREGAP && [[ "$line" =~ ^([[:space:]]*)INDEX[[:space:]]+01[[:space:]]+([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
        indent="${BASH_REMATCH[1]}"
        mm=${BASH_REMATCH[2]}
        ss=${BASH_REMATCH[3]}
        ff=${BASH_REMATCH[4]}
        orig_frames=$(( (10#$mm * 60 + 10#$ss) * 75 + 10#$ff ))

        if ! $SKIPPED_FIRST_INDEX; then
            # First INDEX 01 → keep as-is
            SKIPPED_FIRST_INDEX=true
            echo "$line" >> "$TMP_FILE"
            LAST_WAS_INDEX00=false
            continue
        fi

        if ! $LAST_WAS_INDEX00; then
            # Insert INDEX 00 only if not already present
            new_frames=$(( orig_frames - PREGAP_FRAMES ))
            if [ "$new_frames" -lt 0 ]; then
                echo "❌ Error: resulting INDEX 00 would be negative (original $mm:$ss:$ff)."
                rm "$TMP_FILE"
                exit 1
            fi
            new_time=$(to_time "$new_frames")
            echo "${indent}INDEX 00 $new_time" >> "$TMP_FILE"
            CHANGES+=("Inserted INDEX 00 $new_time before INDEX 01 $mm:$ss:$ff (line $lineno)")
        fi

        echo "$line" >> "$TMP_FILE"
        LAST_WAS_INDEX00=false
    else
        echo "$line" >> "$TMP_FILE"
        LAST_WAS_INDEX00=false
    fi
done < "$CUE_FILE"

# Replace original file
mv "$TMP_FILE" "$CUE_FILE"

echo "✅ Finished updating $CUE_FILE"
echo
echo "Summary of changes:"
for c in "${CHANGES[@]}"; do
    echo "  - $c"
done
