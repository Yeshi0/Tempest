for %%a in (
	newEngine\temp\caching
	newEngine\temp\caching\levels
	newEngine\temp\caching\objects
	newEngine\temp\caching\scenes
	newEngine\temp\caching\scripts
	newEngine\temp\caching\sprites
	newEngine\temp\caching\tiles
	newEngine\temp\safe\levels
	newEngine\temp\safe\objects
	newEngine\temp\safe\scenes
	newEngine\temp\safe\scripts
	newEngine\temp\safe\sprites
	newEngine\temp\safe\tiles
) do (
	if exist %%a\ rmdir %%a /s /q
	if NOT exist %%a\ mkdir %%a
)
exit /b 0