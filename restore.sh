#!/bin/bash
# Bring minimized windows back onto a workspace and focus the last one.
# usage: restore.sh <workspace> <address>...
# On a tiled workspace a window goes back into the layout; on an Omarchy
# floating workspace it stays floating and is centred. A window that was
# fullscreen goes back to fullscreen (fsmem.sh). Everything goes to Hyprland in
# one batch, placed at once with no Hyprland animation.
# SIDEBAR_FX=1: the sidebar draws the GNOME-style grow itself, so the windows
# come back invisible (opacity 0; the sidebar shows them when it's done) and
# their final geometry is printed as JSON: {"0x…": {x, y, w, h}}.
set -u
ws=$1; shift
(( $# )) || exit 0
here=$(dirname "$0")
. "$here/hbatch.sh"
fx=${SIDEBAR_FX:-}
layout=$(omarchy-hyprland-workspace-layout-current "$ws" 2>/dev/null || echo dwindle)
# the tags Omarchy's own minimize leaves (minimize.sh adds them too), per window
tags=$(hyprctl clients -j | jq -r --arg a " $* " '.[] | .address as $x | select($a | contains(" " + $x + " "))
  | .address + " " + ([(.tags // [])[] | select(test("^omarchy-minimized-from-"))] | join(" "))')
batch=() unanim=()
for a in "$@"; do
  w="window = \"address:$a\""
  batch+=("dispatch hl.dsp.window.set_prop({ prop = \"no_anim\", value = \"1\", $w })")
  [[ -n $fx ]] && batch+=("dispatch hl.dsp.window.set_prop({ prop = \"opacity\", value = \"0\", $w })")
  batch+=("dispatch hl.dsp.window.move({ workspace = \"$ws\", follow = false, $w })")
  if [[ $layout == floating ]]; then
    batch+=("dispatch hl.dsp.window.center({ $w })")
  else
    batch+=("dispatch hl.dsp.window.float({ action = \"off\", $w })")
  fi
  for t in $(awk -v a="$a" '$1 == a { $1 = ""; print }' <<<"$tags"); do
    batch+=("dispatch hl.dsp.window.tag({ tag = \"-$t\", $w })")
  done
  unanim+=("dispatch hl.dsp.window.set_prop({ prop = \"no_anim\", value = \"unset\", $w })")
done
batch+=("dispatch hl.dsp.focus({ window = \"address:${*: -1}\" })")
hbatch "${batch[@]}"
bash "$here/fsmem.sh" restore "$@"
if [[ -n $fx ]]; then
  hyprctl clients -j | jq -c --arg a " $* " 'map(.address as $x | select($a | contains(" " + $x + " "))
    | {key: .address, value: {x: .at[0], y: .at[1], w: .size[0], h: .size[1]}}) | from_entries'
fi
IFS=";"
setsid bash -c '. "$1"; sleep 0.05; hbatch "$2"' _ "$here/hbatch.sh" "${unanim[*]}" >/dev/null 2>&1 < /dev/null &
exit 0
