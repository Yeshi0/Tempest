for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
	set screenEffect=%%d
	set screenEffectLength=%%e
	if "!screenEffectLength!"=="instant" (
		set checkForInvalidChars=!screenEffect!
		for /l %%f in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%f=§!
		set checkForInvalidChars=!checkForInvalidChars:§=!
		if "!checkForInvalidChars!"=="" (
			set /a diffPerTick=999
			set /a screenColor=%%d
			set /a screenEffectStartingColor=%%d
			set /a screenEffectTargetColor=%%d
		)
	)
)
exit /b 0