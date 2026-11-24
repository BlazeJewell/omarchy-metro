#!/bin/bash
# Update button in quick settings.
#   update.sh check  fetch quietly, print how many new commits are waiting ("0" when none, "?" offline)
#   update.sh run    pull them in (sync.sh update), detached so the shell restart doesn't kill it
cd "$(dirname "$(readlink -f "$0")")" || exit 1
case "${1:-}" in
  check)
    if timeout 15 git fetch -q 2>/dev/null; then
      git rev-list --count HEAD..@{u} 2>/dev/null || echo "?"
    else
      echo "?"
    fi
    ;;
  run)
    setsid -f bash -c '
      if out=$(./sync.sh update 2>&1); then
        notify-send -a "Sidebar" "Rice updated" "$(git log -1 --format=%s)"
      else
        notify-send -u critical -a "Sidebar" "Rice update failed" "$(tail -n 3 <<<"$out")"
      fi' >/dev/null 2>&1
    ;;
  *) sed -n '2,4p' "$0"; exit 1 ;;
esac
