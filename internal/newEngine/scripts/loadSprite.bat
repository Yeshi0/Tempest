set string1=%~1
if NOT exist newEngineProject\sprites\!string1! exit /b 1

set spriteContent=
set tempSpriteContent=
for /f "tokens=1 delims=." %%a in (newEngineProject\sprites\!string1!) do (
	rem check the current line to load
	set "lineContent=%%a"
	call newEngine\scripts\checkString.bat "!lineContent!" "▒ ▓ █" allowSpace
	if NOT "!stringHasUnwantedChars!"=="false" %rhe% UNSAFE_RESOURCE_BLOCKED
	if NOT defined lineContent %rhe% UNSAFE_RESOURCE_BLOCKED
	if "!lineContent:~7,1!"=="" %rhe% UNSAFE_RESOURCE_BLOCKED
	if NOT "!lineContent:~8!"=="" %rhe% UNSAFE_RESOURCE_BLOCKED
	set spriteContent=!spriteContent!!lineContent!
)

rem check whether the sprite data is persistent or not
if "%2"=="temp" (
	set tempSpriteContent=!spriteContent!
	set spriteContent=
	exit /b 0
)
if "%2"=="persistent" exit /b 0
exit /b 1