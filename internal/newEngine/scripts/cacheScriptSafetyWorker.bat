@title %title%
@echo off
setLocal enableDelayedExpansion

call newEngine\scripts\checkString.bat "%~1" "\"
if NOT "!stringHasLetters!.!stringIsSafe!"=="true.true" exit 1

for /f "delims=" %%a in (newEngineProject\scripts\%~1) do (
	set /a currentLine+=1
	set lineContent=%%a
	if "!lineContent:~99!"=="" (
		if "!lineContent:~-1,1!"==" " set lineContent=!lineContent:~0,-1!
		if NOT exist newEngine\cache\safe\scripts\%~1\ mkdir newEngine\cache\safe\scripts\%~1\
		call newEngine\scripts\checkString.bat "!lineContent!" "( ) ' #" allowAsterisk allowEqual allowSpace allowTab
		if "!stringIsSafe!"=="true" echo safe >>newEngine\cache\safe\scripts\%~1\isSafe_line!currentLine!.tmp
	)
)
if exist newEngine\temp\cacheSafety\%~1 del newEngine\temp\cacheSafety\%~1
exit 0