for /f "tokens=2 delims= " %%d in ("!exec!") do (
	set rtVar_result=failed
	call newEngine\scripts\loadLevel.bat "levels\%%d"
	if "!errorLevel!"=="0" (
		set rtVar_result=loadedLevel
	) else set rtVar_result=failed
)
exit /b 0