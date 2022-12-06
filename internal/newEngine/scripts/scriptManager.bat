if "%1"=="killAll" (
	for /l %%a in (1,1,!scriptCount!) do (
		if defined pid%%a_path (
			set /a scriptCount-=1
			set /a num1=0
			for /l %%a in (1,1,!scriptCount!) do if defined pid%%a_path set /a num1=%%a
			set /a scriptCount=num1
			for /f "tokens=1 delims==" %%a in ('set pid%%a_') do set %%a=
		)
	)
)

if "%1"=="kill" (
	if NOT defined pid%2_path exit /b 1
	for /f "tokens=1 delims==" %%a in ('set pid%2_ 2^>nul') do set %%a=
	if NOT "%3"=="noDefragment" call :defragmentPids
	set /a scriptCount-=1
)

if "%1"=="start" (
	set /a scriptCount+=1
	set /a newPid=scriptCount
	set pid!newPid!_path=%2
	set pid!newPid!_name=%~nx2
	set pid!newPid!_skipUntilParenthesis=false
	set /a pid!newPid!_execLine=0
	set /a pid!newPid!_linesThisTick=maxLinesPerFrame
	set /a pid!newPid!_sleepTicks=0
	set "startArgument=%~3"
	if NOT "!startArgument!"=="" (
		call newEngine\scripts\checkString.bat "!startArgument!" allowLetters allowNumbers
		if NOT "!stringHasUnwantedChars!"=="false" (
			call newEngine\scripts\scriptManager.bat kill !newPid!
			exit /b 1

		) else set rtVar_startArgument=!startArgument!
	)
	if NOT exist newEngineProject\%2 (
		call newEngine\scripts\scriptManager.bat kill !newPid!
		exit /b 1
	)

	set /a currentLine=0
	for /f "delims=" %%a in (newEngineProject\%2) do (
		set /a currentLine+=1
		set lineContent=%%a
		if NOT "!lineContent:~199!"=="" (
			call newEngine\scripts\scriptManager.bat kill !newPid!
			exit /b 1
		)
		set "tab=	"
		if "!lineContent:~-1,1!"==" " set lineContent=!lineContent:~0,-1!
		set pid!newPid!_l!currentLine!=!lineContent!
		if "!lineContent:~0,1!"=="!tab!" set lineContent=!lineContent:~1!
		set pid!newPid!_l!currentLine!=!lineContent!
		if "!lineContent:~0,1!"=="!tab!" (
			call newEngine\scripts\scriptManager.bat kill !newPid!
			exit /b 1
		)
		if NOT exist newEngine\cache\safe\%2\ mkdir newEngine\cache\safe\%2\
		if NOT exist newEngine\cache\safe\%2\isSafe_line!currentLine!.tmp (
			call newEngine\scripts\checkString.bat "!lineContent!" "( )" allowAsterisk allowEqual allowSpace
			if NOT "!stringHasUnwantedChars!"=="true" (
				call newEngine\scripts\scriptManager.bat kill !newPid!
				exit /b 1

			) else (
				echo safe >newEngine\cache\safe\%2\isSafe_line!currentLine!.tmp
			)
		)
	)
	set /a pid!newPid!_lineCount=currentLine
)
exit /b 0

:defragmentPids
for /l %%a in (1,1,!scriptCount!) do if NOT defined pid%%a_path (
	set /a num1=-1
	for /l %%b in (%%a,1,!scriptCount!) do if "!num1!"=="-1" if defined pid%%b_path set /a num1=%%b
	if NOT "!num1!"=="-1" (
		for /f "tokens=1* delims==" %%c in ('set pid!num1!_') do for %%e in (!num1!) do (
			for /f "tokens=2 delims=_" %%f in ("%%c") do set string1=%%f
			set pid%%a_!string1!=%%d
		)
		set /a num2=scriptCount
		call newEngine\scripts\scriptManager.bat kill !num1! noDefragment
		set /a scriptCount=num2
		call :defragmentPids
	)
)
exit /b 0