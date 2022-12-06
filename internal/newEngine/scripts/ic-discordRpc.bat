for /f "tokens=2* delims= " %%d in ("!exec!") do (
	set "string1=%%e"
	call newEngine\scripts\checkString.bat "!string1!" allowLetters allowSpace
	if NOT "!stringIsSafe!.!stringHasLetters!"=="true.true" %rhe% DISCORDRPC_INVALID_CHARS
	if "%%d"=="title" set discordDetails=%%e
	if "%%d"=="subtitle" set discordState=%%e
)
exit /b 0