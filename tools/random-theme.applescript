-- Opens a new Terminal window/tab using a randomly chosen theme from themes/.
-- On first run (or whenever new themes have been added to the repo), it
-- also imports any theme that isn't yet registered as a Terminal profile,
-- the same way tools/import-themes.sh does - so this app is the only thing
-- someone needs to run after cloning the repo.
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

tell application "Terminal"
	activate
	set knownThemes to name of every settings set
end tell

set missingThemes to {}
repeat with themeName in themeFiles
	if knownThemes does not contain (themeName as string) then
		set end of missingThemes to (themeName as string)
	end if
end repeat

if (count missingThemes) > 0 then
	display notification ("Importing " & (count missingThemes) & " theme(s) into Terminal - this only happens once and may take a minute...") with title "Random Terminal Theme"

	repeat with themeName in missingThemes
		set themePath to themesFolder & "/" & themeName & ".terminal"
		tell application "Terminal" to set beforeCount to count windows
		do shell script "open " & quoted form of themePath
		repeat 50 times
			tell application "Terminal" to set afterCount to count windows
			if afterCount > beforeCount then exit repeat
			delay 0.1
		end repeat
		delay 0.2
		tell application "Terminal" to close front window
	end repeat

	display notification "All themes imported." with title "Random Terminal Theme"
end if

set themeCount to count themeFiles
set randomTheme to item (random number from 1 to themeCount) of themeFiles

tell application "Terminal"
	activate
	set newWindow to make new window
	set current settings of newWindow to settings set randomTheme
	do script ("echo " & quoted form of ("Terminal profile: " & randomTheme)) in newWindow
end tell
