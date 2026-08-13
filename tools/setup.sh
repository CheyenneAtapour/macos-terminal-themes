#!/usr/bin/env bash
#
# One-time setup after cloning or downloading this repo. Run this once and
# everything else in the README just works:
#
#   1. Enables color output for your shell (ls, etc.) - terminal themes only
#      override the ANSI palette, colored output itself is a separate,
#      normally-manual shell config step.
#   2. Clears macOS's Gatekeeper quarantine flag from the whole repo and
#      re-signs the random-theme app, so it (and every .terminal file it
#      imports) opens normally instead of being blocked as being from an
#      "unidentified developer". This flag only gets set if you downloaded
#      a ZIP through a browser - a plain `git clone` never triggers it, so
#      that half is a no-op in that case.
#   3. Launches the app, which imports every theme into Terminal on this
#      first run (takes a minute or two) and opens one at random.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$REPO_ROOT/tools/Random Terminal Theme.app"

# --- 1. Shell color output ---

case "$SHELL" in
	*/zsh) RC_FILE="$HOME/.zshrc" ;;
	*/bash) RC_FILE="$HOME/.bash_profile" ;;
	*)
		RC_FILE=""
		echo "Unrecognized shell '$SHELL' - add this to your shell's rc file by hand:" >&2
		echo "  export CLICOLOR=1" >&2
		echo "  export LSCOLORS=ExFxBxDxCxegedabagacad" >&2
		echo "  alias ls='ls -GFh'" >&2
		;;
esac

COLOR_MARKER="# macos-terminal-themes: enable color output"

if [ -n "$RC_FILE" ]; then
	if [ -f "$RC_FILE" ] && grep -qF "$COLOR_MARKER" "$RC_FILE"; then
		echo "Shell colors already set up in $RC_FILE."
	else
		{
			echo ""
			echo "$COLOR_MARKER"
			echo "export CLICOLOR=1"
			echo "export LSCOLORS=ExFxBxDxCxegedabagacad"
			echo "alias ls='ls -GFh'"
		} >> "$RC_FILE"
		echo "Added color settings to $RC_FILE (run 'source $RC_FILE' or open a new tab to pick them up)."
	fi
fi

# --- 2. Gatekeeper quarantine ---

if [ ! -d "$APP" ]; then
	echo "Couldn't find '$APP'" >&2
	exit 1
fi

xattr -cr "$REPO_ROOT"
codesign --force --deep -s - "$APP"

echo "Cleared quarantine and re-signed '$APP'."

# --- 3. Launch it ---

echo "Opening '$APP' - first launch imports every theme into Terminal, which takes a minute or two; macOS may also ask you to approve it controlling Terminal.app."
open "$APP"
