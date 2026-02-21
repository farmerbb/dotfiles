#!/usr/bin/env bash

[[ -z $2 ]] && \
  echo "Usage: ./eden-to-jksv.sh <path-to-eden-zip> <path-to-jksv-folder>" && \
  exit 1

set -euo pipefail

EDEN_ZIP="$1"
OUTPUT_ROOT="$2"

KIRBY_ID="01004D300C5AE000"
SWORD_ID="0100ABF008968000"
MARIO_ID="010054400D2E6000"

KIRBY_NAME="Kirby and the Forgotten Land"
SWORD_NAME="Pokemon Sword"
MARIO_NAME="Super Mario 3D World + Bowser's Fury"

STAMP="$(date +"%Y-%m-%d_%H-%M-%S")"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

unzip -q "$EDEN_ZIP" -d "$TMP_DIR"

make_jksv_zip() {
  local title_id="$1"
  local game_name="$2"

  local src="$TMP_DIR/$title_id"
  [[ -d "$src" ]] || return

  local out_dir
  out_dir="$(realpath -m "$OUTPUT_ROOT/$game_name")"
  mkdir -p "$out_dir"

  local zip_name="Braden - $STAMP.zip"
  (
      cd "$src"
      zip -qr "$out_dir/$zip_name" .
  )

  echo "Created JKSV backup: $out_dir/$zip_name"
}

make_jksv_zip "$KIRBY_ID" "$KIRBY_NAME"
make_jksv_zip "$SWORD_ID" "$SWORD_NAME"
make_jksv_zip "$MARIO_ID" "$MARIO_NAME"
