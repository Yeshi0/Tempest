set string1=%~1
if NOT exist newEngineProject\sprites\!string1! exit /b 1

set spriteContent=
set tempSpriteContent=
for /f "tokens=1 delims=." %%a in (newEngineProject\sprites\!string1!) do (
	rem check the current line to load
	set "lineContent=%%a"
	if NOT defined lineContent exit /b 1
	if "!lineContent:~7,1!"=="" exit /b 1
	if NOT "!lineContent:~8!"=="" exit /b 1
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