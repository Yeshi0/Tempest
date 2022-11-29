for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
	set rtVar_startArgument=
	if "%%e"=="" (
		call newEngine\scripts\scriptManager.bat start scripts\%%d
	) else call newEngine\scripts\scriptManager.bat start scripts\%%d "%%e"
)
exit /b 0