#!/bin/bash
# Place an app beside the tiled window under a drop point.
# usage: drop.sh <x> <y> <window-address|-> <launch-command|->
#   x, y            drop point in global logical pixels
#   window-address  an open window of the app to move there, or "-"
#   launch-command  command that starts the app when it has no window, or "-"
set -u
X=${1%.*}; Y=${2%.*}; WIN=$3; LAUNCH=$4

pos=$(hyprctl cursorpos); cx=${pos%%,*}; cy=${pos##*, }
restore_cursor() { hyprctl dispatch "hl.dsp.cursor.move({ x = $cx, y = $cy })" >/dev/null; }
d() { hyprctl dispatch "$1" >/dev/null; }

ws=$(hyprctl activeworkspace -j | jq -r .id)
read -r target side < <(hyprctl clients -j | jq -r --argjson x "$X" --argjson y "$Y" --argjson ws "$ws" --arg self "$WIN" '
  [ .[] | select(.workspace.id == $ws and (.floating | not) and .address != $self
         and .at[0] <= $x and $x < .at[0] + .size[0]
         and .at[1] <= $y and $y < .at[1] + .size[1]) ][0]
  | if . == null then "- -" else "\(.address) \(if $x < .at[0] + .size[0] / 2 then "l" else "r" end)" end')

if [[ $WIN != "-" ]]; then
  # Take the window out, then let it back in beside the target.
  d "hl.dsp.window.move({ workspace = \"special:minimized\", follow = false, window = \"address:$WIN\" })"
  if [[ $target != "-" ]]; then
    d "hl.dsp.focus({ window = \"address:$target\" })"
    d "hl.dsp.layout(\"preselect $side\")"
  fi
  d "hl.dsp.window.move({ workspace = \"$ws\", follow = false, window = \"address:$WIN\" })"
  # a minimized window is parked floating off-screen: put it back in the layout (beside the target)
  d "hl.dsp.window.float({ action = \"off\", window = \"address:$WIN\" })"
  d "hl.dsp.focus({ window = \"address:$WIN\" })"
elif [[ $LAUNCH != "-" ]]; then
  if [[ $target != "-" ]]; then
    d "hl.dsp.focus({ window = \"address:$target\" })"
    d "hl.dsp.layout(\"preselect $side\")"
  fi
  bash -c "$LAUNCH" &
fi
restore_cursor
