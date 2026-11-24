#!/bin/bash
# Remember fullscreen windows the sidebar switches away from, and put them back
# into fullscreen when they're brought forward again.
#   fsmem.sh save [address...]   remember these (or the active workspace's)
#                                fullscreen windows
#   fsmem.sh restore address...  re-fullscreen any of these that were remembered
set -u
mem="${XDG_RUNTIME_DIR:-/tmp}/jake-sidebar-fullscreen"
touch "$mem"
d() { hyprctl dispatch "$1" >/dev/null; }
case "${1:-}" in
  save)
    shift
    if (( $# )); then
      list=$(hyprctl clients -j | jq -r --arg a " $* " '.[] | select((.fullscreen // 0) > 0 and ($a | contains(" " + .address + " "))) | "\(.address) \(.fullscreen)"')
    else
      ws=$(hyprctl activeworkspace -j | jq -r .id)
      list=$(hyprctl clients -j | jq -r --argjson ws "$ws" '.[] | select(.workspace.id == $ws and (.fullscreen // 0) > 0) | "\(.address) \(.fullscreen)"')
    fi
    [[ -z $list ]] && exit 0
    while read -r a m; do
      grep -v "^$a " "$mem" > "$mem.tmp"; mv "$mem.tmp" "$mem"
      echo "$a $m" >> "$mem"
    done <<<"$list"
    ;;
  restore)
    shift
    for a in "$@"; do
      m=$(awk -v a="$a" '$1 == a { print $2 }' "$mem" | tail -1)
      [[ -z $m ]] && continue
      grep -v "^$a " "$mem" > "$mem.tmp"; mv "$mem.tmp" "$mem"
      mode=fullscreen; [[ $m == 1 ]] && mode=maximized
      d "hl.dsp.window.fullscreen({ mode = \"$mode\", action = \"set\", window = \"address:$a\" })"
    done
    ;;
esac
