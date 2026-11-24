#!/bin/bash
# solo.sh --clear <workspace> [address to keep ...]
# Minimize the tiled windows on a workspace before the sidebar brings an app
# forward or restores it there, so it comes up full instead of tiling first.
# minimize.sh lifts them out of the layout where they stand and starts them
# sliding off to the left before this returns; hiding them finishes in the
# background. SIDEBAR_THEN (see minimize.sh) rides along in the same batch.
# (New windows are handled by hypr/solo.lua.)
[[ ${1:-} == --clear ]] || exit 1
exec bash "$(dirname "$0")/minimize.sh" "$@"
