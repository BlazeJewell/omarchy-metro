#!/bin/bash
# Bring minimized windows back onto a workspace and focus the last one.
# usage: restore.sh <workspace> <address>...
# On a tiled workspace a window goes back into the layout, sliding in from where
# minimize.sh parked it off the left edge. On an Omarchy floating workspace it
# stays floating and is centred. A window that was fullscreen goes back to
# fullscreen (fsmem.sh). Everything goes to Hyprland in one batch.
set -u
ws=$1; shift
(( $# )) || exit 0
here=$(dirname "$0")
. "$here/hbatch.sh"
layout=$(omarchy-hyprland-workspace-layout-current "$ws" 2>/dev/null || echo dwindle)
# the tags Omarchy's own minimize leaves (minimize.sh adds them too), per window
tags=$(hyprctl clients -j | jq -r --arg a " $* " '.[] | .address as $x | select($a | contains(" " + $x + " "))
  | .address + " " + ([(.tags // [])[] | select(test("^omarchy-minimized-from-"))] | join(" "))')
batch=()
for a in "$@"; do
  w="window = \"address:$a\""
  batch+=("dispatch hl.dsp.window.move({ workspace = \"$ws\", follow = false, $w })")
  if [[ $layout == floating ]]; then
    batch+=("dispatch hl.dsp.window.center({ $w })")
  else
    batch+=("dispatch hl.dsp.window.float({ action = \"off\", $w })")
  fi
  for t in $(awk -v a="$a" '$1 == a { $1 = ""; print }' <<<"$tags"); do
    batch+=("dispatch hl.dsp.window.tag({ tag = \"-$t\", $w })")
  done
done
batch+=("dispatch hl.dsp.focus({ window = \"address:${*: -1}\" })")
hbatch "${batch[@]}"
bash "$here/fsmem.sh" restore "$@"
