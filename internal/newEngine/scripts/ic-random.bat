for /f "tokens=2-3 delims= " %%e in ("!exec!") do (
	for %%g in (%%e %%f) do (
		set checkForInvalidChars=%%g
		for /l %%h in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%h=§!
		set checkForInvalidChars=!checkForInvalidChars:§=!
		if NOT "!checkForInvalidChars!"=="" (
			call newEngine\scripts\scriptManager.bat kill %%a
			set stopExec=true
		)
	)
	if NOT %%f GTR %%e (
		call newEngine\scripts\scriptManager.bat kill %%a
		set stopExec=true
	)
	if %%e LEQ 0 (
		call newEngine\scripts\scriptManager.bat kill %%a
		set stopExec=true
	)
	if %%f GEQ 32000 (
		call newEngine\scripts\scriptManager.bat kill %%a
		set stopExec=true
	)
	set /a getRandomRange=%%f-%%e+1
	set /a getRandom=!random!*getRandomRange/32768+%%e
	set /a rtVar_result=getRandom
)
exit /b 0