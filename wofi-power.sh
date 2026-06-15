#!/usr/bin/env bash

LOCK="Lock Screen"
LOGOUT="Log Out"
REBOOT="Reboot System"
SHUTDOWN="Power Off"

options="$LOCK\n$LOGOUT\n$REBOOT\n$SHUTDOWN"

chosen=$(echo -e "$options" | wofi --dmenu \
  --conf "$HOME/.config/wofi-power/config" \
  --style "$HOME/.config/wofi-power/style.css")

chosen=$(echo "$chosen" | xargs)

case "$chosen" in
"$LOCK")
  # Uses hyprlock to lock the screen
  hyprlock
  ;;
"$LOGOUT")
  # Standard way to cleanly exit a Hyprland session
  killall Hyprland
  ;;
"$REBOOT")
  # Systemd command to restart the machine
  systemctl reboot
  ;;
"$SHUTDOWN")
  # Systemd command to turn off the machine
  systemctl poweroff
  ;;
*)
  # If the user presses Escape or clicks away, exit safely without doing anything
  exit 0
  ;;
esac
