#!/bin/bash

DPI=$(xrdb -get Xft.dpi)
if [[ $DPI -eq 96 ]]; then
  wezterm start --cwd "$PWD"
else
  WAYLAND_DISPLAY=1 wezterm --config window_decorations=\"RESIZE\" start --cwd "$PWD"
fi
