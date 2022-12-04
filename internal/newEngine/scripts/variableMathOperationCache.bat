rem variable expansion code continues
rem welcome to indentation hell
rem nov 18 2022: attempted to optimize this mess. took an hour and its barely faster. great waste of time 10/10 would reommend
rem nov 22 2022: math operations are broken. again.
rem nov 24 2022: more stuff is cached now. another massive performance increase
rem nov 24 2022: moved to another script entirely. if this still isnt efficient enough, i have no idea what is
rem dec 4 2022: guess whats broken again? this pile of shit is!
set /a variableNameEnd=variableLength+variableOffset+1
for /f "tokens=1-2 delims= " %%a in ("!currentPid! !currentLine!") do (
	for /f "tokens=1-3 delims= " %%d in ("!variableOffset! !variableLength! !variableNameEnd!") do (
		set pid%%a_cm_l%%b=true
		set variableName=!exec:~%%d,%%e!
		set variableName=!variableName:~1!
		set pid%%a_vn_l%%b=!variableName!
		set /a checkOperation=variableLength+variableOffset
		for %%g in (!checkOperation!) do (
			set operationChar=!exec:~%%g,1!
			set performOperation=false
			if "!operationChar!"=="+" set performOperation=true
			if "!operationChar!"=="-" set performOperation=true
			if "!operationChar!"=="*" set performOperation=true
			if "!operationChar!"=="/" set performOperation=true
			if "!performOperation!"=="true" (
				set checkForInvalidChars=!exec:~%%f!
				if NOT "!checkForInvalidChars!"=="" (
					set number=!checkForInvalidChars!
					for /l %%g in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%g=§!
					set checkForInvalidChars=!checkForInvalidChars:§=!
					if "!checkForInvalidChars!"=="" (
						if !number! GEQ -1000000000 if !number! LEQ 1000000000 if NOT "!number!"=="0" (
							if "!operationChar!"=="+" set /a rtVar_!variableName!+=number
							if "!operationChar!"=="-" set /a rtVar_!variableName!-=number
							if "!operationChar!"=="*" set /a rtVar_!variableName!*=number
							if "!operationChar!"=="/" set /a rtVar_!variableName!/=number
							set pid%%a_oc_l%%b=!operationChar!
							set /a pid%%a_on_l%%b=!number!
						)
					)
				)
			) else set number=
		)
	)
)
exit /b 0