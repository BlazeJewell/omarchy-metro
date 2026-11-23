#!/bin/bash
# Keep your sidebar layout in sync between machines through this repo.
#   ./sync.sh save   copy this machine's layout into layout/, commit and push
#   ./sync.sh load   pull, then apply layout/ to this machine
#   ./sync.sh update pull the latest plugin/Hyprland changes (keeps this machine's layout)
# The layout is the sidebar-*.json files in ~/.config/omarchy (sections and their
# order, pins, hidden icons, profiles). Per-machine display scales are left out.
set -euo pipefail
DEST="$HOME/.config/omarchy/plugins/jake.sidebar"
CFG="$HOME/.config/omarchy"
FILES=(sidebar-settings.json sidebar-pins.json sidebar-hidden.json sidebar-profiles.json)
cd "$DEST"
case "${1:-}" in
  save)
    for f in "${FILES[@]}"; do [[ -e $CFG/$f ]] && cp "$CFG/$f" layout/; done
    git add layout
    if git diff --cached --quiet; then echo "Layout unchanged."; else git commit -qm "Layout from $(hostname)"; fi
    git push
    ;;
  load)
    git pull --ff-only
    for f in "${FILES[@]}"; do
      [[ -e layout/$f ]] || continue
      [[ -e $CFG/$f ]] && ! cmp -s "layout/$f" "$CFG/$f" && cp "$CFG/$f" "$CFG/$f.bak.$(date +%s)"
      cp "layout/$f" "$CFG/$f"
    done
    hyprctl reload >/dev/null; omarchy restart shell >/dev/null 2>&1 || true
    echo "Layout applied."
    ;;
  update)
    git pull --ff-only; hyprctl reload >/dev/null; omarchy restart shell >/dev/null 2>&1 || true
    echo "Updated."
    ;;
  *) sed -n '2,7p' "$0"; exit 1 ;;
esac
