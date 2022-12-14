if NOT exist newEngine\temp\caching\ mkdir newEngine\temp\caching

for %%z in (objects sprites tiles) do (
	for /f "tokens=1 delims=" %%a in ('dir /b /a-d newEngineProject\%%z 2^>nul') do (
		set /a currentLine=0
		if NOT "!dispCurrent:~84!"=="" set dispCurrent=!dispCurrent:~0,81!...
		if NOT exist newEngine\temp\caching\%%z\%%a\ mkdir newEngine\temp\caching\%%z\%%a
		start /b newEngine\scripts\cacheWorker.bat "%%z\%%a"
	)
)
call newEngine\scripts\waitForCaches.bat

for /f %%a in ('dir /b /ad newEngineProject\scenes') do (
	set /a currentLine=0
	if NOT "!dispCurrent:~84!"=="" set dispCurrent=!dispCurrent:~0,81!...
	if NOT exist newEngine\temp\caching\scenes\%%a\ mkdir newEngine\temp\caching\scenes\%%a
	start /b newEngine\scripts\cacheWorker.bat "scenes\%%a\onLoad.yss"

	if exist newEngineProject\scenes\%%a\objects\ for /f %%b in ('dir /b /a-d newEngineProject\scenes\%%a\objects 2^>nul') do (
		set /a currentLine=0
		if NOT "!dispCurrent:~84!"=="" set dispCurrent=!dispCurrent:~0,81!...
		if NOT exist newEngine\temp\caching\scenes\%%a\objects\%%b\ mkdir newEngine\temp\caching\scenes\%%a\objects\%%b
		start /b newEngine\scripts\cacheWorker.bat "scenes\%%a\objects\%%b"
	)
)
call newEngine\scripts\waitForCaches.bat

for %%z in (scripts levels) do (
	for /f "tokens=1 delims=" %%a in ('dir /b /a-d newEngineProject\%%z 2^>nul') do (
		set /a currentLine=0
		if NOT "!dispCurrent:~84!"=="" set dispCurrent=!dispCurrent:~0,81!...
		if NOT exist newEngine\temp\caching\%%z\%%a\ mkdir newEngine\temp\caching\%%z\%%a
		start /b newEngine\scripts\cacheWorker.bat "%%z\%%a"
	)
)
call newEngine\scripts\waitForCaches.bat
exit /b 0