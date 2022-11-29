for /f "tokens=1-2 delims= " %%a in ("!currentPid! !currentLine!") do (
	set variableName=
	set /a variableOffset=-1
	for /l %%c in (0,1,%lineCharLimit%) do if "!exec:~%%c,1!"=="$" set /a variableOffset=%%c
	if "!variableOffset!"=="-1" (
		call newEngine\scripts\scriptManager.bat kill %%a
		set stopExec=true

	) else (
		set /a variableLength-=1
		for %%d in (!variableOffset!) do (
			set checkVariableName=!exec:~%%d!
			for /l %%e in (30,-1,1) do if NOT "!checkVariableName:~%%e,1!"=="" (
				set end=true
				for %%f in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do if /i "!checkVariableName:~%%e,1!"=="%%f" set end=false
				if "!end!"=="false" (
					set /a checkEndOfString=%%e+1
					for %%f in (!checkEndOfString!) do if /i "!checkVariableName:~%%f,1!"=="" set /a variableLength=%%e+1
				)
				if "!end!"=="true" set /a variableLength=%%e
			)
			if "!variableLength!"=="-1" (
				call newEngine\scripts\scriptManager.bat kill %%a
				set stopExec=true

			) else (
				set /a pid%%a_vo_l%%b=!variableOffset!
				set /a pid%%a_vl_l%%b=!variableLength!
			)
		)
	)
)
exit /b 0