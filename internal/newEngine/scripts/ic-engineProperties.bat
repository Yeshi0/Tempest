for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
	if "%%d"=="disableStaticButtons" set staticButtons=false
	if "%%d"=="enableStaticButtons" set staticButtons=true
	if "%%d"=="disableStaticText" set staticText=false
	if "%%d"=="enableStaticText" set staticText=true
	if "%%d"=="disableButtons" set buttonsDisabled=true
	if "%%d"=="enableButtons" set buttonsDisabled=false
	if "%%d"=="setTargetFps" (
		set checkForInvalidChars=%%e
		for /l %%f in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%f=§!
		set checkForInvalidChars=!checkForInvalidChars:§=!
		if "!checkForInvalidChars!"=="" set /a maxFps=%%e
	)
	if "%%d"=="setTargetTps" (
		set checkForInvalidChars=%%e
		for /l %%f in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%f=§!
		set checkForInvalidChars=!checkForInvalidChars:§=!
		if "!checkForInvalidChars!"=="" set /a maxTps=%%e
	)
)
set /a csPerFrame=100/maxFps
set /a csPerTick=100/maxTps
exit /b 0