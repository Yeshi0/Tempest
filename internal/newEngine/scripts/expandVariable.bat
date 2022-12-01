set "expand=%~1"
if NOT "!expand!"=="" if NOT "!expand!"=="!expand:$=hasVariable!" (
	set /a variableOffset=-1
	for /l %%c in (0,1,!lineCharLimit!) do if "!expand:~%%c,1!"=="$" set /a variableOffset=%%c
	if "!variableOffset!"=="-1" exit /b 1

	set /a variableLength-=1
	for %%d in (!variableOffset!) do (
		set checkVariableName=!expand:~%%d!
		for /l %%e in (30,-1,1) do if NOT "!checkVariableName:~%%e,1!"=="" (
			set end=true
			for %%f in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do if /i "!checkVariableName:~%%e,1!"=="%%f" set end=false
			if "!end!"=="false" (
				set /a checkEndOfString=%%e+1
				for %%f in (!checkEndOfString!) do if /i "!checkVariableName:~%%f,1!"=="" set /a variableLength=%%e+1
			)
			if "!end!"=="true" set /a variableLength=%%e
		)
		if "!variableLength!"=="-1" exit /b 1
	)
	set /a variableNameEnd=variableLength+variableOffset+1
	for /f "tokens=1-3 delims= " %%d in ("!variableOffset! !variableLength! !variableNameEnd!") do (
		set variableName=!expand:~%%d,%%e!
		if "!variableName:~0,1!"=="$" set variableName=!variableName:~1!
			for %%g in (!variableName!) do (
				set /a offset=variableLength+variableOffset
				rem the value of '!rtVar_%%g!' can only be accessed if expanded first using a for loop
				rem why? idk ¯\_(ツ)_/¯
				for /f "tokens=1-2 delims= " %%h in ("!offset! !rtVar_%%g!") do set expand=!expand:~0,%%d!%%i!expand:~%%h!
			)
			set checkExpand=!expand:$=hasVariable!
			if NOT "!expand!"=="" if NOT "!expand!"=="!checkExpand!" exit /b 1
		)
	)
)
exit /b 0