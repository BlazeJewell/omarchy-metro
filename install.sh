#!/bin/bash
# Install (or update) the Metro sidebar (jake.metro) on an Omarchy machine.
#
#   ./install.sh                                   from a checkout
#   JAKE_METRO_REPO=<git url> ./install.sh         clone from a repo instead
#
# It can sit beside the classic sidebar (jake.sidebar): switch with
# `omarchy bar use jake.metro` / `omarchy bar use jake.sidebar`.
#
# What it does:
#   1. puts the plugin at ~/.config/omarchy/plugins/jake.metro (clone, or pull if it has a remote)
#   2. loads the Hyprland side (keybindings, animations, window rules) from
#      ~/.config/hypr/hyprland.lua with one line (hypr-link.sh; the sidebar also
#      does this itself when it starts, so `omarchy plugin add` gets it too)
#   3. switches the bar to the sidebar, turns off Omarchy's dock, and docks
#      notifications top-left (jake.notifications)
# The sidebar starts with its default layout (pins from Omarchy's dock). Your own
# layout is never touched; to bring a saved one over from another machine, use
# ./sync.sh load.
set -euo pipefail

REPO_URL="${JAKE_METRO_REPO:-}"
DEST="$HOME/.config/omarchy/plugins/jake.metro"
HYPR="$HOME/.config/hypr"

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }
need() { command -v "$1" >/dev/null || { echo "Missing $1 — is this an Omarchy machine?" >&2; exit 1; }; }
need git; need jq; need hyprctl; need omarchy

# 1. the plugin
if [[ -d $DEST/.git ]]; then
  if git -C "$DEST" remote get-url origin >/dev/null 2>&1; then
    say "Updating $DEST"
    git -C "$DEST" pull --ff-only
  fi
elif [[ -e $DEST ]]; then
  echo "$DEST exists but isn't a git checkout; move it away first." >&2; exit 1
else
  here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [[ -n $here && -f $here/manifest.json && -d $here/.git ]]; then
    say "Copying this checkout to $DEST"
    mkdir -p "$(dirname "$DEST")"; git clone -q "$here" "$DEST"
    up="$(git -C "$here" remote get-url origin 2>/dev/null || echo "$REPO_URL")"
    if [[ -n $up ]]; then git -C "$DEST" remote set-url origin "$up"; else git -C "$DEST" remote remove origin; fi
  elif [[ -z $REPO_URL ]]; then
    echo "Run this from a jake.metro checkout, or set JAKE_METRO_REPO to a git URL." >&2; exit 1
  else
    say "Cloning $REPO_URL"
    mkdir -p "$(dirname "$DEST")"; git clone -q "$REPO_URL" "$DEST"
  fi
fi

# 2. the Hyprland side
say "Loading the Hyprland config"
bash "$DEST/hypr-link.sh"

# 3. bar + dock + notifications
say "Switching the bar to the sidebar"
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
omarchy bar use jake.metro
# dock off, notifications top-left (setup.sh; the sidebar also does this itself
# the first time it starts after `omarchy plugin add`)
bash "$DEST/setup.sh" --force

hyprctl reload >/dev/null
errs=$(hyprctl configerrors 2>/dev/null | tr -d '[:space:]')
[[ -n $errs ]] && { echo "Hyprland reported config errors:"; hyprctl configerrors; }
omarchy restart shell >/dev/null 2>&1 || true
say "Done. Undo with: $DEST/uninstall.sh"
