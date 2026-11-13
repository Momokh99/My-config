#!/usr/bin/env bash

# Matugen runs this after rewriting gtk-4.0/colors.css. Toggling the scheme
# forces GTK to re-read the stylesheet; restoring the original value keeps the
# user's preference (including "default") intact.
set -u

command -v gsettings >/dev/null 2>&1 || exit 0

current=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null) || exit 0
[ -n "$current" ] || exit 0

if [ "$current" = "'prefer-light'" ]; then
    other="'prefer-dark'"
else
    other="'prefer-light'"
fi

gsettings set org.gnome.desktop.interface color-scheme "$other" 2>/dev/null || exit 0
gsettings set org.gnome.desktop.interface color-scheme "$current" 2>/dev/null || exit 0
