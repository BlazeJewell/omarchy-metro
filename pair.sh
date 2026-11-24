#!/bin/bash
# Tile two windows side by side on a workspace, everything else there minimized.
# usage: pair.sh <target-address> <dragged-address> <l|r> <workspace-id>
# The dragged window ends up on the given side of the target.
set -u
t=$1; w=$2; side=$3; ws=$4
here=$(dirname "$0")
# dispatches are queued and sent to Hyprland in one batch (flush)
q=()
d() { q+=("dispatch $1"); }
. "$here/hbatch.sh"
flush() { hbatch "${q[@]}"; q=(); }

# clear the workspace except these two (they slide out to the left)
bash "$here/solo.sh" --clear "$ws" "$t" "$w"

# the target: onto the workspace and into the layout (minimized ones are parked floating)
tws=$(hyprctl clients -j | jq -r --arg a "$t" 'first(.[] | select(.address == $a) | .workspace.id) // empty')
[[ $tws != "$ws" ]] && d "hl.dsp.window.move({ workspace = \"$ws\", follow = false, window = \"address:$t\" })"
d "hl.dsp.window.float({ action = \"off\", window = \"address:$t\" })"

# the dragged window: taken out and let back in on the chosen side of the target
d "hl.dsp.window.move({ workspace = \"special:minimized\", follow = false, window = \"address:$w\" })"
d "hl.dsp.focus({ window = \"address:$t\" })"
d "hl.dsp.layout(\"preselect $side\")"
d "hl.dsp.window.move({ workspace = \"$ws\", follow = false, window = \"address:$w\" })"
d "hl.dsp.window.float({ action = \"off\", window = \"address:$w\" })"
d "hl.dsp.focus({ window = \"address:$w\" })"
flush
