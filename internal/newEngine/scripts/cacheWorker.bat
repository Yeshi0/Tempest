@title %title%
@echo off
setLocal enableDelayedExpansion
chcp 65001 >nul

call newEngine\scripts\checkString.bat "%~1" "\ - ." allowLetters allowNumbers
if NOT "!stringHasLetters!.!stringHasUnwantedChars!"=="true.false" exit 1

if NOT exist newEngine\temp\caching\%~1\ mkdir newEngine\temp\caching\%~1
if NOT exist newEngine\temp\safe\%~1\ mkdir newEngine\temp\safe\%~1
set allowed=
for /f "tokens=1 delims=\" %%b in ("%~1") do (
	if "%%b"=="levels" (
		set "allowedChars=: ."
		set allowed=allowLetters allowNumbers
	)
)
for /f "tokens=1 delims=" %%a in (newEngineProject\%~1) do (
	set /a currentLine+=1
	set lineContent=%%a
	for %%b in (!lineCharLimit!) do if "!lineContent:~%%b!"=="" (
		if "!lineContent:~-1,1!"==" " set lineContent=!lineContent:~0,-1!
		set /a num1=0
		for %%c in (!allowed!) do (
			set /a num1+=1
			set cs_arg!num1!=%%c
		)

		set stringHasLetters=false
		set stringHasNumbers=false
		set stringHasSpaces=false
		set stringHasSymbols=false
		set stringIsSafe=true
		set stringHasUnwantedChars=false
		set "checkString=!lineContent!"

		set getArgs=!cs_arg1!-!cs_arg2!-!cs_arg3!-!cs_arg4!-!cs_arg5!-!cs_arg6!-!cs_arg7!-!cs_arg8!
		for %%c in (allowAsterisk allowEqual allowLetters allowNumbers allowQuotationMark allowSpace allowSymbols allowTab) do (
			set arg_%%c=false
			if NOT "!getArgs!"=="!getArgs:%%c=§!" set arg_%%c=true
		)

		set string=!checkString!
		set /a stringLength=0
		for /l %%c in (0,1,!lineCharLimit!) do if NOT "!string!"=="" (
			set /a stringLength+=1
			set string=!string:~1!
		)
		if !stringLength! GEQ !lineCharLimit! exit 1

		set space= 
		set equal==
		set semiColon=;
		set quotationMark=^"
		set asterisk=*
		set "tab=	"
		set charIsSafe=false
		set charHasUnwantedChars=true
		for %%d in (Asterisk QuotationMark Tab) do (
			if "!arg_allow%%d!"=="true" for /f "tokens=1 delims=" %%e in ("!%%d!") do if defined checkString set checkString=!checkString:^%%e=!
		)
		rem this is a mess
		if "!arg_allowSymbols!"=="true" if defined checkString set checkString=!checkString:^;=!
		if "!arg_allowLetters!"=="true" for %%d in (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if defined checkString set checkString=!checkString:^%%d=!
		if "!arg_allowSymbols!"=="true" for %%d in (. \ $ : + - / _) do if defined checkString set checkString=!checkString:^%%d=!
		if "!arg_allowNumbers!"=="true" for %%d in (0 1 2 3 4 5 6 7 8 9) do if defined checkString set checkString=!checkString:^%%d=!
		for %%d in (!allowedChars!) do if defined checkString set checkString=!checkString:^%%d=!
		if "!arg_allowEqual!"=="true" if defined checkString for /f "tokens=1 delims==" %%d in ("!checkString!") do set "checkString=%%d"
		if "!arg_allowSpace!"=="true" if defined checkString set checkString=!checkString: =!
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
		for %%c in (allowAsterisk allowEqual allowLetters allowNumbers allowQuotationMark allowSpace allowSymbols allowTab) do set arg_%%a=

		if "!stringHasUnwantedChars!"=="false" (
			echo safe >>newEngine\temp\safe\%~1\isSafe_line!currentLine!.tmp
		) else exit 1
	)
)
for /f "tokens=1 delims=\" %%a in ("%~1") do if "%%a"=="levels" (
	call newEngine\scripts\loadLevel.bat "%~1"
	call newEngine\scripts\renderLevel.bat "%~1"
)
if exist newEngine\temp\caching\%~1 rmdir newEngine\temp\caching\%~1 /s /q
exit 0