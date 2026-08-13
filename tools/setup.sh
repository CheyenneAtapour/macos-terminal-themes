#!/usr/bin/env bash
#
# One-time setup after cloning or downloading this repo. Clears the macOS
# quarantine flag on the random-theme app and re-signs it, so it opens
# normally instead of triggering Gatekeeper's "unidentified developer"
# warning.
#
# The quarantine flag only gets set if you downloaded a ZIP through a
# browser (e.g. GitHub's "Download ZIP" button) - a plain `git clone`
# doesn't trigger it, so this is a no-op in that case.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$REPO_ROOT/tools/Random Terminal Theme.app"

if [ ! -d "$APP" ]; then
  echo "Couldn't find '$APP'" >&2
  exit 1
fi

xattr -cr "$APP"
codesign --force --deep -s - "$APP"

echo "Done. '$APP' should now open normally - double-click it in Finder."
