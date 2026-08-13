#!/usr/bin/env bash
#
# One-time setup after cloning or downloading this repo. Clears the macOS
# quarantine flag from the whole repo (not just the app - every .terminal
# file gets quarantined too, which otherwise blocks the app's own theme
# importer partway through) and re-signs the app, so everything opens
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

xattr -cr "$REPO_ROOT"
codesign --force --deep -s - "$APP"

echo "Done. '$APP' and every theme in themes/ should now open normally."
