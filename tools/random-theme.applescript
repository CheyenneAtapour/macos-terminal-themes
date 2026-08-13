-- Opens a new Terminal window using a randomly chosen theme from themes/.
-- Compiled into a double-clickable app by tools/build-random-theme-launcher.sh.

set themesFolder to "/Users/cheyenne/Documents/github/random/macos-terminal-themes/themes"
set themeFiles to paragraphs of (do shell script "ls " & quoted form of themesFolder & " | sed 's/\\.terminal$//'")
set themeCount to count themeFiles
set randomTheme to item (random number from 1 to themeCount) of themeFiles

tell application "Terminal"
	activate
	set newTab to do script ""
	set current settings of newTab to settings set randomTheme
	do script ("echo " & quoted form of ("Terminal profile: " & randomTheme)) in newTab
end tell
