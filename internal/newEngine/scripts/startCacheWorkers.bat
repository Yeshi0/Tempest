if NOT exist newEngine\temp\caching\ mkdir newEngine\temp\caching
for %%z in (levels objects scripts sprites tiles) do (
	for /f "tokens=1 delims=" %%a in ('dir /b /a-d newEngineProject\%%z 2^>nul') do (
		set /a currentLine=0
		if NOT "!dispCurrent:~84!"=="" set dispCurrent=!dispCurrent:~0,81!...
		if NOT exist newEngine\temp\caching\%%z\%%a\ mkdir newEngine\temp\caching\%%z\%%a
		start /b newEngine\scripts\cacheWorker.bat "%%z\%%a"
	)
)
exit /b 0