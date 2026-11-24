#!/bin/bash
# solo.sh --clear <workspace> [address to keep ...]
# Minimize the tiled windows on a workspace before the sidebar brings an app
# forward or restores it there, so it comes up full instead of tiling first.
# They're lifted out of the layout right away; minimize.sh slides them off to
# the left and hides them in the background.
# (New windows are handled by hypr/solo.lua.)
set -u
[[ ${1:-} == --clear ]] || exit 1
ws=$2; shift 2; keep=" $* "
here=$(dirname "$0")
parked=()
bash "$here/fsmem.sh" save   # a fullscreen window comes back fullscreen later
for other in $(hyprctl clients -j | jq -r --argjson ws "$ws" '.[] | select(.workspace.id == $ws and (.floating | not)) | .address'); do
  [[ $keep == *" $other "* ]] && continue
  hyprctl dispatch "hl.dsp.window.float({ action = \"on\", window = \"address:$other\" })" >/dev/null
  parked+=("$other")
done
(( ${#parked[@]} )) && setsid bash "$here/minimize.sh" "${parked[@]}" >/dev/null 2>&1 < /dev/null &
exit 0
