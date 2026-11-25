#!/bin/bash
# Keep your sidebar layout in sync between machines through this repo.
#   ./sync.sh save   copy this machine's layout into layout/, commit and push
#   ./sync.sh load   pull, then apply layout/ to this machine
#   ./sync.sh update pull the latest plugin/Hyprland changes (keeps this machine's layout)
# The layout is the sidebar-*.json files in ~/.config/omarchy (sections and their
# order, pins, hidden icons, profiles). Per-machine display scales are left out.
set -euo pipefail
DEST="$HOME/.config/omarchy/plugins/jake.metro"
CFG="$HOME/.config/omarchy"
FILES=(metro-settings.json metro-pins.json metro-hidden.json metro-profiles.json)
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
cd "$DEST"
case "${1:-}" in
  save)
    for f in "${FILES[@]}"; do [[ -e $CFG/$f ]] && cp "$CFG/$f" layout/; done
    git add layout
    if git diff --cached --quiet; then echo "Layout unchanged."; else git commit -qm "Layout from $(hostname)"; fi
    git push
    ;;
  load)
    git pull --ff-only; link_notifications
    for f in "${FILES[@]}"; do
      [[ -e layout/$f ]] || continue
      [[ -e $CFG/$f ]] && ! cmp -s "layout/$f" "$CFG/$f" && cp "$CFG/$f" "$CFG/$f.bak.$(date +%s)"
      cp "layout/$f" "$CFG/$f"
    done
    hyprctl reload >/dev/null; omarchy restart shell >/dev/null 2>&1 || true
    echo "Layout applied."
    ;;
  update)
    git pull --ff-only; link_notifications; hyprctl reload >/dev/null; omarchy restart shell >/dev/null 2>&1 || true
    echo "Updated."
    ;;
  *) sed -n '2,7p' "$0"; exit 1 ;;
esac
