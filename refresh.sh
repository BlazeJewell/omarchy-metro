#!/bin/bash
# Resolution / refresh rate of the focused monitor.
#   refresh.sh status            -> "mode <w> <h> <hz>", "rates <hz>..." (at the current resolution),
#                                   "resolutions <WxH>..." (largest first)
#   refresh.sh set <WxH> <hz>    -> switch now and save it in ~/.config/hypr/monitors.lua
#   refresh.sh set <WxH> best    -> the highest rate that resolution offers
#   refresh.sh <hz>              -> same resolution, new rate
set -u
mon=$(hyprctl monitors -j | jq -c '.[] | select(.focused == true)')
name=$(jq -r .name <<<"$mon"); w=$(jq -r .width <<<"$mon"); h=$(jq -r .height <<<"$mon")
scale=$(jq -r .scale <<<"$mon")

if [[ ${1:-status} == status ]]; then
  echo "mode $w $h $(jq -r .refreshRate <<<"$mon")"
  echo "rates $(jq -r --arg p "${w}x${h}@" '[.availableModes[] | select(startswith($p)) | sub(".*@"; "") | sub("Hz"; "")] | unique | sort_by(tonumber) | reverse | join(" ")' <<<"$mon")"
  echo "resolutions $(jq -r '[.availableModes[] | sub("@.*"; "")] | unique | sort_by(split("x") | (.[0] | tonumber) * (.[1] | tonumber)) | reverse | join(" ")' <<<"$mon")"
  exit 0
fi

if [[ $1 == set ]]; then res=$2; rate=$3; else res="${w}x${h}"; rate=$1; fi
[[ $name =~ ^[A-Za-z0-9._-]+$ && $res =~ ^[0-9]+x[0-9]+$ ]] || { echo "bad input" >&2; exit 1; }
if [[ $rate == best ]]; then
  rate=$(jq -r --arg p "${res}@" '[.availableModes[] | select(startswith($p)) | sub(".*@"; "") | sub("Hz"; "")] | sort_by(tonumber) | last // empty' <<<"$mon")
fi
[[ $rate =~ ^[0-9]+(\.[0-9]+)?$ ]] || { echo "bad rate" >&2; exit 1; }
# Only modes the monitor reports.
jq -e --arg m "${res}@${rate}Hz" '.availableModes | index($m)' <<<"$mon" >/dev/null || { echo "unsupported mode" >&2; exit 1; }

mode="${res}@${rate}"
hyprctl eval "hl.monitor({ output = \"$name\", mode = \"$mode\", position = \"auto\", scale = $scale })" >/dev/null

# The monitor's own preferred mode (listed first) is saved as "preferred", so a
# dual-mode monitor keeps following whichever mode its hardware is switched to.
[[ "$(jq -r '.availableModes[0]' <<<"$mon")" == "${res}@${rate}Hz" ]] && mode="preferred"

# Persist: rewrite the mode on this monitor's line, or add a line for it.
lua="$HOME/.config/hypr/monitors.lua"
[[ -f $lua ]] || exit 0
target=$(readlink -f "$lua")
if grep -q "^hl\.monitor({ output = \"$name\"," "$target"; then
  sed -i -E "/^hl\.monitor\(\{ output = \"$name\",/ s/mode = \"[^\"]*\"/mode = \"$mode\"/" "$target"
else
  printf 'hl.monitor({ output = "%s", mode = "%s", position = "auto", scale = %s })\n' "$name" "$mode" "$scale" >>"$target"
fi
