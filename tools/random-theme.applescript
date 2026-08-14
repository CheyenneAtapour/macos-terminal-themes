-- Opens a new Terminal window using a randomly chosen theme from themes/.
-- Opens the .terminal file directly (see below), so it works whether or not
-- that theme has ever been imported into Terminal's profile list - use
-- tools/import-themes.sh separately if you want every theme registered
-- there too (e.g. to see them all in Terminal > Settings > Profiles).
--
-- Compiled with:
--   osacompile -o "tools/Random Terminal Theme.app" tools/random-theme.applescript

-- Resolve themes/ relative to this app's own location (repo-root/tools/this.app),
-- so it works regardless of where the repo was cloned to. Falls back to a fixed
-- path if the app has been moved out of the repo (e.g. into /Applications).
set posixAppPath to POSIX path of (path to me)
set themesFolder to ""
try
	set themesFolder to do shell script "cd " & quoted form of (posixAppPath & "/../../themes") & " && pwd"
end try
if themesFolder is "" then
	set themesFolder to "/Users/cheyenne/Documents/github/random/macos-terminal-themes/themes"
end if

set themeFiles to paragraphs of (do shell script "ls " & quoted form of themesFolder & " | sed 's/\\.terminal$//'")

set themeCount to count themeFiles
set randomTheme to item (random number from 1 to themeCount) of themeFiles
set randomThemePath to themesFolder & "/" & randomTheme & ".terminal"

-- Open the .terminal file directly (same as double-clicking it) rather than
-- using Terminal's "make new window" / "settings set" AppleScript commands,
-- which have proven unreliable (intermittent "AppleEvent handler failed").
-- This is the same open-a-file mechanism the import loop above already uses.
tell application "Terminal" to set beforeCount to count windows
do shell script "open " & quoted form of randomThemePath
repeat 50 times
	tell application "Terminal" to set afterCount to count windows
	if afterCount > beforeCount then exit repeat
	delay 0.1
end repeat

tell application "Terminal"
	activate
	-- CLAUDE_CODE_DISABLE_TERMINAL_TITLE keeps the theme name in the title bar
	-- even if `claude` is run in this window - without it, Claude Code's own
	-- task-status title updates (OSC escape sequences) overwrite the custom
	-- title we set below. Exported only in this shell, not globally, so other
	-- Claude Code windows keep their normal live task-status titles.
	do script ("export THEME_PROFILE=" & quoted form of randomTheme & " CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1; echo " & quoted form of ("Terminal profile: " & randomTheme)) in front window
	-- Also surface the theme name in the window's title bar (alongside the
	-- existing echo/env var), so it's visible without looking at the shell.
	set custom title of front window to randomTheme
end tell
