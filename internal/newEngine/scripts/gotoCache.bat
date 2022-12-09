set /a gotoLine=-1
for /f "tokens=1-3 delims= " %%d in ("!exec!") do (
	set checkLabel=%%e
	if "!checkLabel:~25!"=="" (
		set labelValid=true
		for /l %%g in (1,1,25) do if NOT "!checkLabel:~%%g,1!"=="" (
			set valid=false
			for %%h in (a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 .) do if /i "!checkLabel:~%%g,1!"=="%%h" set valid=true
			if "!valid!"=="false" set labelValid=false
		)
		if NOT "!checkLabel:~0,1!"==":" set labelValid=false
		if "!labelValid!"=="true" (
			set gotoLabel=%%e
			for /l %%g in (1,1,!pid%%a_lineCount!) do (
				if "!pid%%a_l%%g:~0,1!"==":" (
					if "!pid%%a_l%%g!"=="!checkLabel!" (
						if "!gotoLine!"=="-1" (
							set /a gotoLine=%%g
							set /a pid%%a_gotoCache_l!pid%%a_execLine!=gotoLine
						)
					)
				)
			)
		)
	)
)
exit /b 0