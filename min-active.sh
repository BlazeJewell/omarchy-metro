#!/bin/bash
# Minimize the focused window the sidebar's way (slides out left, works on any workspace). Bound to Super+M.
a=$(hyprctl activewindow -j | jq -r '.address // empty')
[[ -n $a && $(hyprctl activewindow -j | jq -r '.workspace.name') != special:* ]] || exit 0
exec bash "$(dirname "$0")/minimize.sh" "$a"
