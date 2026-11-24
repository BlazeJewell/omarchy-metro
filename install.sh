#!/bin/bash
# Install (or update) the jake.sidebar rice on an Omarchy machine.
#
#   gh repo clone BlazeJewell/omarchy-sidebar ~/.config/omarchy/plugins/jake.sidebar && ~/.config/omarchy/plugins/jake.sidebar/install.sh
#   # or, from a checkout:
#   ./install.sh [--keep-layout]
#
# What it does:
#   1. puts the plugin at ~/.config/omarchy/plugins/jake.sidebar (clone, or pull if it's there)
#   2. links the Hyprland side (keybindings, animations, window rules) and loads it
#      from ~/.config/hypr/hyprland.lua with one line
#   3. copies the saved sidebar layout (sections, pins, hidden icons, profiles) from
#      layout/ into ~/.config/omarchy, backing up anything it replaces
#      (skip with --keep-layout)
#   4. switches the bar to the sidebar, turns off Omarchy's dock, and docks
#      notifications top-left (jake.notifications)
set -euo pipefail

REPO_URL="${JAKE_SIDEBAR_REPO:-https://github.com/BlazeJewell/omarchy-sidebar.git}"
DEST="$HOME/.config/omarchy/plugins/jake.sidebar"
HYPR="$HOME/.config/hypr"
CFG="$HOME/.config/omarchy"
KEEP_LAYOUT=false
[[ ${1:-} == --keep-layout ]] && KEEP_LAYOUT=true

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }
need() { command -v "$1" >/dev/null || { echo "Missing $1 — is this an Omarchy machine?" >&2; exit 1; }; }
need git; need jq; need hyprctl; need omarchy

# 1. the plugin
if [[ -d $DEST/.git ]]; then
  say "Updating $DEST"
  git -C "$DEST" pull --ff-only
elif [[ -e $DEST ]]; then
  echo "$DEST exists but isn't a git checkout; move it away first." >&2; exit 1
else
  here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [[ -n $here && -f $here/manifest.json && -d $here/.git ]]; then
    say "Copying this checkout to $DEST"
    mkdir -p "$(dirname "$DEST")"; git clone -q "$here" "$DEST"
    git -C "$DEST" remote set-url origin "$(git -C "$here" remote get-url origin 2>/dev/null || echo "$REPO_URL")"
  else
    say "Cloning $REPO_URL"
    mkdir -p "$(dirname "$DEST")"; git clone -q "$REPO_URL" "$DEST"
  fi
fi

# 2. the Hyprland side
say "Linking the Hyprland config"
ln -sf "$DEST/hypr/init.lua" "$HYPR/jake_sidebar.lua"
if ! grep -q 'require("hypr.jake_sidebar")' "$HYPR/hyprland.lua"; then
  cp "$HYPR/hyprland.lua" "$HYPR/hyprland.lua.bak.$(date +%s)"
  if grep -q '^require("hypr.autostart")' "$HYPR/hyprland.lua"; then
    sed -i '/^require("hypr.autostart")/a require("hypr.jake_sidebar") -- the sidebar rice (jake.sidebar plugin)' "$HYPR/hyprland.lua"
  else
    printf '\nrequire("hypr.jake_sidebar") -- the sidebar rice (jake.sidebar plugin)\n' >> "$HYPR/hyprland.lua"
  fi
fi

# 3. the saved layout
if ! $KEEP_LAYOUT; then
  for f in "$DEST"/layout/sidebar-*.json; do
    [[ -e $f ]] || continue
    name=$(basename "$f")
    [[ -e $CFG/$name ]] && ! cmp -s "$f" "$CFG/$name" && cp "$CFG/$name" "$CFG/$name.bak.$(date +%s)"
    cp "$f" "$CFG/$name"
    say "Layout: $name"
  done
fi

# Notifications dock top-left against the sidebar: notifications/ is a clone of
# omarchy.notifications, linked in as its own plugin (jake.notifications).
link_notifications() {
  local link="$HOME/.config/omarchy/plugins/jake.notifications"
  [[ -L $link || ! -e $link ]] || return 0
  ln -sfn "$DEST/notifications" "$link"
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  for _ in $(seq 40); do omarchy-plugin-list --json 2>/dev/null | jq -e 'any(.[]; .id == "jake.notifications")' >/dev/null && break; sleep 0.05; done
  omarchy plugin enable jake.notifications >/dev/null 2>&1 || true
}

# 4. bar + dock + notifications
say "Switching the bar to the sidebar"
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
omarchy bar use jake.sidebar
omarchy plugin disable omarchy.dock >/dev/null 2>&1 || true
link_notifications

hyprctl reload >/dev/null
errs=$(hyprctl configerrors 2>/dev/null | tr -d '[:space:]')
[[ -n $errs ]] && { echo "Hyprland reported config errors:"; hyprctl configerrors; }
omarchy restart shell >/dev/null 2>&1 || true
say "Done. Undo with: $DEST/uninstall.sh"
