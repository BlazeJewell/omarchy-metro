#!/bin/bash
# Minimize windows: hide them in special:minimized at once, with no Hyprland
# animation. The sidebar draws the GNOME-style shrink itself (a copy of the
# window over the screen, see "window effects" in Sidebar.qml), so here they
# just go.
#
# usage: minimize.sh <address>...
#        minimize.sh --clear <workspace> [address to keep ...]
#            the tiled windows on that workspace, except the ones kept (solo.sh)
# SIDEBAR_THEN, if set, is more "dispatch ..." commands (;-separated) sent in the
# same batch, so whatever the sidebar brings forward changes in the same frame.
#
# Every hyprctl call costs tens of milliseconds, so the state is read in one
# call and everything goes to Hyprland in one batch.
set -u
here=$(dirname "$0")
. "$here/hbatch.sh"
then=${SIDEBAR_THEN:-}
state=$(hyprctl -j --batch "monitors; clients" | jq -cs '{mon: .[0], clients: .[1]}')
fsnote=()

if [[ ${1:-} == --clear ]]; then
  ws=$2; shift 2
  # any fullscreen window on this workspace comes back fullscreen later (fsmem.sh)
  read -ra fsnote < <(jq -r --argjson ws "$ws" '[.clients[] | select(.workspace.id == $ws and (.fullscreen // 0) > 0) | .address, (.fullscreen | tostring)] | join(" ")' <<<"$state")
  sel=$(jq -c --argjson ws "$ws" --arg keep " $* " '[.clients[] | .address as $x
    | select(.workspace.id == $ws and (.floating | not) and ($keep | contains(" " + $x + " ") | not))]' <<<"$state")
else
  sel=$(jq -c --arg a " $* " '[.clients[] | .address as $x | select($a | contains(" " + $x + " "))]' <<<"$state")
  # a fullscreen window comes back fullscreen when restored (fsmem.sh)
  read -ra fsnote < <(jq -r '[.[] | select((.fullscreen // 0) > 0) | .address, (.fullscreen | tostring)] | join(" ")' <<<"$sel")
fi
(( ${#fsnote[@]} )) && bash "$here/fsmem.sh" note "${fsnote[@]}"

# One line per window: address, workspace
info=$(jq -r '.[] | "\(.address) \(.workspace.id)"' <<<"$sel")
if [[ -z $info ]]; then
  [[ -n $then ]] && hbatch "$then"
  exit 0
fi
active=$(jq -r 'first(.clients[] | select(.focusHistoryID == 0) | .address) // "-"' <<<"$state")
ws=$(awk 'NR == 1 { print $2 }' <<<"$info")

batch=() unanim=() addrs=()
while read -r a wsid; do
  w="window = \"address:$a\""
  addrs+=("$a")
  # the same tag Omarchy's minimize uses, so its dock knows where a window came from
  [[ $wsid =~ ^[0-9]+$ ]] && batch+=("dispatch hl.dsp.window.tag({ tag = \"+omarchy-minimized-from-$wsid\", $w })")
  batch+=("dispatch hl.dsp.window.set_prop({ prop = \"no_anim\", value = \"1\", $w })"
          "dispatch hl.dsp.window.move({ workspace = \"special:minimized\", follow = false, $w })")
  unanim+=("dispatch hl.dsp.window.set_prop({ prop = \"no_anim\", value = \"unset\", $w })")
done <<<"$info"
# If the window in front was one of these (and nothing else is being brought
# forward), hand focus back to its workspace so it doesn't stay on a hidden
# window (and the next app opened doesn't join it).
[[ -z $then && " ${addrs[*]} " == *" $active "* && $ws =~ ^[0-9]+$ && $ws -ge 1 ]] && batch+=("dispatch hl.dsp.focus({ workspace = \"$ws\" })")

[[ -n $then ]] && batch+=("$then")
hbatch "${batch[@]}"
# animations back on once Hyprland has placed them
IFS=";"
setsid bash -c '. "$1"; sleep 0.05; hbatch "$2"' _ "$here/hbatch.sh" "${unanim[*]}" >/dev/null 2>&1 < /dev/null &
exit 0
