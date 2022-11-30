for /f "tokens=2 delims= " %%d in ("!exec!") do (
	set checkForInvalidChars=%%d
	for /l %%e in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%e=§!
	set checkForInvalidChars=!checkForInvalidChars:§=!
	if "!checkForInvalidChars!"=="" (
		set /a pid%%a_sleepTicks=%%d
		set stopExec=true
	)
)
exit /b 0