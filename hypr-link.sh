#!/bin/bash
# Load the sidebar's Hyprland side (hypr/: keybindings like Super+Space,
# one-app-at-a-time, animations) from ~/.config/hypr/hyprland.lua.
#
# Run by the sidebar every time it starts, so `omarchy plugin add` is enough;
# install.sh runs it too. It adds one line, once, and reloads Hyprland only
# when it changed something. The line skips itself when the plugin folder is
# gone, and hypr/init.lua loads nothing unless the sidebar is the bar in use,
# so removing or disabling the plugin can't leave Hyprland broken.
#   hypr-link.sh            add the line (if missing)
#   hypr-link.sh --remove   take it out again (uninstall.sh)
set -u
HYPR="$HOME/.config/hypr"
conf="$HYPR/hyprland.lua"
mark='-- jake.sidebar plugin'
line='do local f = (os.getenv("HOME") or "") .. "/.config/omarchy/plugins/jake.sidebar/hypr/init.lua" local h = io.open(f) if h then h:close() dofile(f) end end '"$mark"' (skipped when the plugin is removed)'
[[ -f $conf ]] || exit 0
# one at a time (the sidebar starts once per shell, install.sh may run too)
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/jake-sidebar-hypr-link.lock"
flock 9

if [[ ${1:-} == --remove ]]; then
  grep -qF -- "$mark" "$conf" || grep -q 'require("hypr.jake_sidebar")' "$conf" || exit 0
  sed -i -e "\|$mark|d" -e '/require("hypr.jake_sidebar")/d' "$conf"
  rm -f "$HYPR/jake_sidebar.lua"
  hyprctl reload >/dev/null 2>&1 || true
  exit 0
fi

grep -qF -- "$mark" "$conf" && exit 0
cp "$conf" "$conf.bak.$(date +%s)"
# an older install.sh loaded it with require() through a link: swap that for this line
if grep -q 'require("hypr.jake_sidebar")' "$conf"; then
  sed -i '/require("hypr.jake_sidebar")/d' "$conf"
  rm -f "$HYPR/jake_sidebar.lua"
fi
# after the user's own files, so its bindings win
if grep -q '^require("hypr.autostart")' "$conf"; then
  awk -v l="$line" '{ print } /^require\("hypr.autostart"\)/ { print l }' "$conf" > "$conf.tmp" && mv "$conf.tmp" "$conf"
else
  printf '\n%s\n' "$line" >> "$conf"
fi
hyprctl reload >/dev/null 2>&1 || true
