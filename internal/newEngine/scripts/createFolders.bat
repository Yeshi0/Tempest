for %%a in (
	newEngine\cache
	newEngine\cache\safe
	newEngine\temp
	newEngineProject\temp
) do (
	if exist %%a\ rmdir %%a /s /q
	if NOT exist %%a\ mkdir %%a
)
exit /b 0