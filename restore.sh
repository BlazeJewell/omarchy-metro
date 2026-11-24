#!/bin/bash
# Bring minimized windows back onto a workspace and focus the last one.
# usage: restore.sh <workspace> <address>...
# On a tiled workspace a window goes back into the layout, sliding in from where
# minimize.sh parked it off the left edge. On an Omarchy floating workspace it
# stays floating and is centred. A window that was fullscreen goes back to
# fullscreen (fsmem.sh).
set -u
ws=$1; shift
(( $# )) || exit 0
here=$(dirname "$0")
layout=$(omarchy-hyprland-workspace-layout-current "$ws" 2>/dev/null || echo dwindle)
cmds=()
for a in "$@"; do
  w="window = \"address:$a\""
  cmds+=("dispatch hl.dsp.window.move({ workspace = \"$ws\", follow = false, $w })")
  if [[ $layout == floating ]]; then
    cmds+=("dispatch hl.dsp.window.center({ $w })")
  else
    cmds+=("dispatch hl.dsp.window.float({ action = \"off\", $w })")
  fi
  # the tag Omarchy's own minimize leaves (minimize.sh adds it too)
  for t in $(hyprctl clients -j | jq -r --arg a "$a" '.[] | select(.address == $a) | (.tags // [])[] | select(test("^omarchy-minimized-from-"))'); do
    cmds+=("dispatch hl.dsp.window.tag({ tag = \"-$t\", $w })")
  done
done
cmds+=("dispatch hl.dsp.focus({ window = \"address:${*: -1}\" })")
printf '%s\n' "${cmds[@]}" | while read -r c; do hyprctl ${c%% *} "${c#* }" >/dev/null; done
bash "$here/fsmem.sh" restore "$@"
