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
	call newEngine\scripts\checkString.bat "%~2" "\ - ." allowLetters allowNumbers
	if NOT "!stringHasLetters!.!stringHasUnwantedChars!"=="true.false" (
		call newEngine\scripts\scriptManager.bat kill !newPid!
		exit /b 1
	)
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

	%banner% "Loading script '%~nx2'..."
	set /a currentLine=0
	for /f "tokens=1 delims=" %%a in (newEngineProject\%2) do (
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
		for %%b in (!lineCharLimit!) do if "!lineContent:~%%b!"=="" (
			if "!lineContent:~-1,1!"==" " set lineContent=!lineContent:~0,-1!
			set stringIsSafe=true
			set stringHasUnwantedChars=false
			set "checkString=!lineContent!"

			set string=!checkString!
			set /a stringLength=0
			for /l %%c in (0,1,!lineCharLimit!) do if NOT "!string!"=="" (
				set /a stringLength+=1
				set string=!string:~1!
			)
			if !stringLength! GEQ !lineCharLimit! %rhe% UNSAFE_RESOURCE_BLOCKED

			set space= 
			set equal==
			set semiColon=;
			set quotationMark=^"
			set asterisk=*
			set "tab=	"
			set charIsSafe=false
			set charHasUnwantedChars=true
			rem this is a mess
			if defined checkString set checkString=!checkString:^;=!
			for %%d in (. \ $ : + - / _ ^( ^) § ¤ ' * a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9) do if defined checkString set checkString=!checkString:^%%d=!
			if defined checkString for /f "tokens=1 delims==" %%d in ("!checkString!") do set "checkString=%%d"
			if defined checkString set checkString=!checkString: =!
			if NOT "!checkString!"=="" (
				set stringIsSafe=false
				set stringHasUnwantedChars=true
			)

			set charIsSafe=
			set charHasUnwantedChars=
			set space=
			set equal=
			set semiColon=
			set quotationMark=
			set asterisk=
			set tab=
			set checkChar=
			set checkString=
			set stringLength=
			for %%c in (allowAsterisk allowEqual allowLetters allowNumbers allowQuotationMark allowSpace allowSymbols allowTab) do set arg_%%c=

			if "!stringHasUnwantedChars!"=="true" %rhe% UNSAFE_RESOURCE_BLOCKED
		) else %rhe% UNSAFE_RESOURCE_BLOCKED
	)
	set /a pid!newPid!_lineCount=currentLine
)
<nul set /p=[30m
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