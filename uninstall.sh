#!/bin/bash
# Undo install.sh for the Metro sidebar.
#   ./uninstall.sh            keep the plugin folder and your Metro layout files
#   ./uninstall.sh --purge    also delete them
# If the classic sidebar (jake.sidebar) is installed, you go back to it and
# notifications go back to its copy; otherwise back to Omarchy's bar and dock.
set -uo pipefail
DEST="$HOME/.config/omarchy/plugins/jake.metro"
SIDEBAR="$HOME/.config/omarchy/plugins/jake.sidebar"
LINK="$HOME/.config/omarchy/plugins/jake.notifications"

bash "$DEST/hypr-link.sh" --remove
rm -f "$DEST/.setup-done"   # so using the Metro sidebar again sets it up again

if [[ -f $SIDEBAR/manifest.json ]]; then
  [[ -L $LINK ]] && ln -sfn "$SIDEBAR/notifications" "$LINK"
  omarchy bar use jake.sidebar
else
  omarchy bar reset
  omarchy plugin enable omarchy.dock >/dev/null 2>&1 || true
  omarchy plugin disable jake.notifications >/dev/null 2>&1 || true
  omarchy plugin enable omarchy.notifications >/dev/null 2>&1 || true
  [[ -L $LINK ]] && rm -f "$LINK"
fi

if [[ ${1:-} == --purge ]]; then
  rm -f "$HOME"/.config/omarchy/metro-*.json
  rm -rf "$DEST"
fi
omarchy restart shell >/dev/null 2>&1 || true
echo "Metro sidebar removed.${1:+ (purged)}"
