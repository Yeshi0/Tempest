if NOT exist newEngine\temp\cacheSafety\ mkdir newEngine\temp\cacheSafety
for /f %%a in ('dir /b /a-d newEngineProject\scripts 2^>nul') do (
	set /a currentLine=0
	set dispCurrent=Caching safety of 'newEngineProject\scripts\%%a'...
	if NOT "!dispCurrent:~84!"=="" set dispCurrent=!dispCurrent:~0,81!...
	echo.[54;3H                                                                                        [54;3H!dispCurrent!
	echo unsafe >>newEngine\temp\cacheSafety\%%a
	start /b newEngine\scripts\cacheScriptSafetyWorker.bat "%%a"
	call newEngine\scripts\wait.bat 3
)
exit /b 0