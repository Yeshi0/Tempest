set rtVar_result=
for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
	if "%%d"=="readValue" (
		set valueValid=true
		set checkValue=%%e
		if "!checkValue:~40!"=="" (
			for /l %%f in (1,1,40) do if NOT "!checkValue:~%%f,1!"=="" (
				set valid=false
				for %%g in (a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9) do if /i "!checkValue:~%%f,1!"=="%%g" set valid=true
				if "!valid!"=="false" set valueValid=false
			)
			if "!valueValid!"=="true" if exist newEngineProject\saveData\%%e (
				for /f "tokens=1 delims= " %%f in (newEngineProject\saveData\%%e) do (
					set newValue=%%f
					call newEngine\scripts\checkString.bat "!newValue!" allowLetters allowNumbers
					if "!stringIsSafe!.!stringHasUnwantedChars!"=="true.false" (
						set rtVar_%%e=%%f
						set rtVar_result=%%f
					)
				)
			)
		)
											
	) else if "%%d"=="writeValue" (
		set valueValid=true
		set checkValue=!rtVar_%%e!
		if "!checkValue:~40!"=="" (
			for /l %%f in (1,1,40) do if NOT "!checkValue:~%%f,1!"=="" (
				set valid=false
				for %%g in (a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9) do if /i "!checkValue:~%%f,1!"=="%%g" set valid=true
				if "!valid!"=="false" set valueValid=false
			)
			if "!valueValid!"=="true" (
				set nameValid=true
				set checkValue=%%e
				if "!checkValue:~40!"=="" (
					for /l %%f in (1,1,40) do if NOT "!checkValue:~%%f,1!"=="" (
						set valid=false
						for %%g in (a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9) do if /i "!checkValue:~%%f,1!"=="%%g" set valid=true
						if "!valid!"=="false" set nameValid=false
					)
					if "!nameValid!"=="true" (
						if exist newEngineProject\saveData\%%e del newEngineProject\saveData\%%e
						if NOT exist newEngineProject\saveData\%%e (
							echo.!rtVar_%%e! >>newEngineProject\saveData\%%e
							if exist newEngineProject\saveData\%%e set rtVar_result=valueWritten
						)
					)
				)
			)
		)
	)
)
exit /b 0