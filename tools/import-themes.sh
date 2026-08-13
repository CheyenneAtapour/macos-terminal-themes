#!/usr/bin/env bash
#
# Imports every .terminal file in themes/ into Terminal.app's profile list
# so they show up in Terminal > Settings > Profiles and the right-click
# "New Window" submenu.
#
# This works by having Terminal.app open each file itself (the same thing
# that happens when you double-click a .terminal file in Finder), then
# closing the window it creates. Editing com.apple.Terminal.plist directly
# doesn't reliably work because Terminal/cfprefsd cache preferences in
# memory and can ignore or clobber changes made outside the app.
#
# Does NOT change your default profile.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="$REPO_ROOT/themes"

if [ ! -d "$THEMES_DIR" ]; then
  echo "themes/ directory not found at $THEMES_DIR" >&2
  exit 1
fi

window_count() {
  osascript -e 'tell application "Terminal" to count windows' 2>/dev/null || echo 0
}

count=0
shopt -s nullglob
for theme in "$THEMES_DIR"/*.terminal; do
  name="$(basename "$theme" .terminal)"
  before="$(window_count)"

  open "$theme"

  # Wait (up to ~5s) for the new window to actually appear before closing it.
  for _ in $(seq 1 50); do
    after="$(window_count)"
    [ "$after" -gt "$before" ] && break
    sleep 0.1
  done

  osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1 || true

  count=$((count + 1))
  echo "Imported: $name"
done

echo
echo "Imported $count theme(s) into Terminal.app's profile list."
echo "No default profile was changed."
echo "(If a 'close window, processes still running' prompt appears, that's your"
echo " Terminal 'Ask before closing' setting - dismiss it and rerun for any that were skipped.)"
