#!/bin/bash
# Minimize the focused window the sidebar's way (slides out left, works on any workspace). Bound to Super+M.
read -r a wsname < <(hyprctl activewindow -j | jq -r '"\(.address // "") \(.workspace.name // "")"')
[[ -n $a && $a != null && $wsname != special:* ]] || exit 0
exec bash "$(dirname "$0")/minimize.sh" "$a"
