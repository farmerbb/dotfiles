#!/usr/bin/env bash

[[ -z $2 ]] && \
  echo "Usage: ./jksv-to-eden.sh <path-to-jksv-folder> <path-to-eden-zip>" && \
  exit 1

set -euo pipefail

JKSV_ROOT="$1"
OUTPUT_ZIP="${2:-eden_save.zip}"

KIRBY_ID="01004D300C5AE000"
SWORD_ID="0100ABF008968000"
MARIO_ID="010054400D2E6000"

KIRBY_NAME="Kirby and the Forgotten Land"
SWORD_NAME="Pokemon Sword"
MARIO_NAME="Super Mario 3D World + Bowser's Fury"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

extract_latest() {
  local game_dir="$1"
  local title_id="$2"

  local latest_zip
  latest_zip="$(ls -t "$game_dir"/*.zip | head -n1)"

  echo "Using $latest_zip"
  mkdir -p "$TMP_DIR/$title_id"
  unzip -q "$latest_zip" -d "$TMP_DIR/$title_id"
}

extract_latest "$JKSV_ROOT/$KIRBY_NAME" "$KIRBY_ID"
extract_latest "$JKSV_ROOT/$SWORD_NAME" "$SWORD_ID"
extract_latest "$JKSV_ROOT/$MARIO_NAME" "$MARIO_ID"

(
  cd "$TMP_DIR"
  zip -qr "$OUTPUT_ZIP" \
    "$KIRBY_ID" \
    "$SWORD_ID" \
    "$MARIO_ID"
)

mv "$TMP_DIR/$OUTPUT_ZIP" .
echo "Created Eden save zip: $OUTPUT_ZIP"
