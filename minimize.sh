#!/bin/bash
# Minimize windows by sliding them out to the left: each is lifted out of the
# tiling layout, slides off the left edge at full size, then moves to
# special:minimized. It stays parked there, so restoring it and handing it back
# to the layout slides it in from the left again.
# usage: minimize.sh <address>...
set -u
(( $# )) || exit 0
d() { hyprctl dispatch "$1" >/dev/null; }
mon=$(hyprctl monitors -j | jq -c '.[] | select(.focused == true)')
read -r mx my mw mh rl rt rr rb < <(jq -r '(.scale) as $s |
  "\(.x) \(.y) \(.width / $s | floor) \(.height / $s | floor) \(.reserved[0]) \(.reserved[1]) \(.reserved[2]) \(.reserved[3])"' <<<"$mon")
w=$(( mw - rl - rr - 24 )); h=$(( mh - rt - rb - 24 ))
x=$(( mx + rl - w - 40 )); y=$(( my + rt + 12 ))
active=$(hyprctl activewindow -j | jq -r '.address // ""')
ws=$(hyprctl clients -j | jq -r --arg a "$1" 'first(.[] | select(.address == $a) | .workspace.id) // empty')
# a fullscreen window comes back fullscreen when restored (fsmem.sh)
bash "$(dirname "$0")/fsmem.sh" save "$@"
for a in "$@"; do
  d "hl.dsp.window.float({ action = \"on\", window = \"address:$a\" })"
  # the same tag Omarchy's minimize uses, so its dock knows where a window came from
  [[ $ws =~ ^[0-9]+$ ]] && d "hl.dsp.window.tag({ tag = \"+omarchy-minimized-from-$ws\", window = \"address:$a\" })"
done
# On an Omarchy floating workspace windows keep their own size; on a tiled one
# they slide out at full size.
floating=false
[[ $ws =~ ^[0-9]+$ && $(omarchy-hyprland-workspace-layout-current "$ws" 2>/dev/null) == floating ]] && floating=true
for a in "$@"; do
  $floating || d "hl.dsp.window.resize({ x = $w, y = $h, window = \"address:$a\" })"
  d "hl.dsp.window.move({ x = $x, y = $y, window = \"address:$a\" })"
done
sleep 0.45
for a in "$@"; do
  d "hl.dsp.window.move({ workspace = \"special:minimized\", follow = false, window = \"address:$a\" })"
  # Moving onto the special workspace re-places it; park it off the left edge again (unseen).
  d "hl.dsp.window.move({ x = $x, y = $y, window = \"address:$a\" })"
done
# If the window in front was one of these, hand focus back to its workspace so
# it doesn't stay on a hidden window (and the next app opened doesn't join it).
if [[ " $* " == *" $active "* && -n $ws && $ws -ge 1 ]]; then d "hl.dsp.focus({ workspace = \"$ws\" })"; fi
