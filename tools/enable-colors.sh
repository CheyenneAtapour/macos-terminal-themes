#!/usr/bin/env bash
#
# Terminal themes only override the ANSI color palette - commands like `ls`
# still need color output turned on separately to actually use it. This
# appends that one-time shell config to your rc file (detected from $SHELL),
# skipping it if it's already there.

set -euo pipefail

case "$SHELL" in
	*/zsh) RC_FILE="$HOME/.zshrc" ;;
	*/bash) RC_FILE="$HOME/.bash_profile" ;;
	*)
		echo "Unrecognized shell '$SHELL' - add this to your shell's rc file by hand:" >&2
		echo "  export CLICOLOR=1" >&2
		echo "  export LSCOLORS=ExFxBxDxCxegedabagacad" >&2
		echo "  alias ls='ls -GFh'" >&2
		exit 1
		;;
esac

MARKER="# macos-terminal-themes: enable color output"

if [ -f "$RC_FILE" ] && grep -qF "$MARKER" "$RC_FILE"; then
	echo "Already set up in $RC_FILE - nothing to do."
	exit 0
fi

{
	echo ""
	echo "$MARKER"
	echo "export CLICOLOR=1"
	echo "export LSCOLORS=ExFxBxDxCxegedabagacad"
	echo "alias ls='ls -GFh'"
} >> "$RC_FILE"

echo "Added color settings to $RC_FILE."
echo "Run 'source $RC_FILE' or open a new terminal tab to pick them up."
