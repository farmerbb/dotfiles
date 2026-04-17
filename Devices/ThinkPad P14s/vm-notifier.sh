#!/bin/bash

# Read the message from stdin (provided by socat)
MESSAGE=$(cat)

# Ensure the script knows where your desktop is
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Send the notification
notify-send -u critical "The Robot™" "$MESSAGE"
