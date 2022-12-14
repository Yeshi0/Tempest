for %%a in (
	newEngine\temp\caching
	newEngine\temp\safe
) do (
	if exist %%a\ rmdir %%a /s /q
	if NOT exist %%a\ mkdir %%a
)
exit /b 0