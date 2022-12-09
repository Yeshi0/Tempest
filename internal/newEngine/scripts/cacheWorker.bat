@title %title%
@echo off
setLocal enableDelayedExpansion
chcp 65001 >nul

call newEngine\scripts\checkString.bat "%~1" "\ -"
if NOT "!stringHasLetters!.!stringIsSafe!"=="true.true" exit 1

for /f "tokens=1 delims=" %%a in (newEngineProject\%~1) do (
	set /a currentLine+=1
	set lineContent=%%a
	if "!lineContent:~99!"=="" (
		if "!lineContent:~-1,1!"==" " set lineContent=!lineContent:~0,-1!
		if NOT exist newEngine\temp\caching\%~1\ mkdir newEngine\temp\caching\%~1
		if NOT exist newEngine\temp\safe\%~1\ mkdir newEngine\temp\safe\%~1
		set allowed=
		for /f "tokens=1 delims=\" %%b in ("%~1") do (
			if "%%b"=="levels" (
				set /a lineCharLimit=40
				set "allowedChars=: ."
				set allowed=allowLetters allowNumbers
			)
			if "%%b"=="objects" (
				set allowed=allowLetters allowSymbols allowNumbers allowEqual allowSpace
			)
			if "%%b"=="scripts" (
				set "allowedChars=( )"
				set allowed=allowLetters allowSymbols allowNumbers allowEqual allowSpace allowTab
			)
			if "%%b"=="sprites" (
				set "allowedChars=. ▒ ▓ █"
				set allowed=allowSpace
			)
			if "%%b"=="tiles" (
				set allowed=allowLetters allowSymbols allowNumbers
			)
		)

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
		for /l %%c in (0,1,!stringLength!) do if NOT "!checkString:~%%c!"=="" (
			set charIsSafe=false
			set charHasUnwantedChars=true
			set checkChar=!checkString:~%%c,1!
			for %%d in (Asterisk Equal Space QuotationMark Tab) do (
				if "!arg_allow%%d!"=="true" if "!checkChar!"=="!%%d!" (
					set stringHas%%ds=true
					set charIsSafe=true
					set charHasUnwantedChars=false
				)
			)
			if NOT "!checkChar!"=="!checkChar:;=§§!" (
				set stringHasSymbols=true
				set charIsSafe=true
				if "!arg_allowSymbols!"=="true" set charHasUnwantedChars=false
			)
			for %%d in (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if NOT "!checkChar!"=="!checkChar:%%d=§§!" (
				set stringHasLetters=true
				set charIsSafe=true
				if "!arg_allowLetters!"=="true" set charHasUnwantedChars=false
			)
			for /l %%d in (0,1,9) do if NOT "!checkChar!"=="!checkChar:%%d=§§!" (
				set stringHasNumbers=true
				set charIsSafe=true
				if "!arg_allowNumbers!"=="true" set charHasUnwantedChars=false
			)
			for %%d in (. \ $ : + - / _) do if NOT "!checkChar!"=="!checkChar:%%d=§§!" (
				set stringHasSymbols=true
				set charIsSafe=true
				if "!arg_allowSymbols!"=="true" set charHasUnwantedChars=false
			)
			for %%d in (!allowedChars!) do if NOT "!checkChar!"=="!checkChar:%%d=§§!" (
				set stringHasCustom=true
				set charIsSafe=true
				set charHasUnwantedChars=false
			)
			if "!charIsSafe!"=="false" (
				set stringIsSafe=false
				set stringHasUnwantedChars=true
			)
			if "!charHasUnwantedChars!"=="true" (
				set stringHasUnwantedChars=true
				title !time! !checkChar!
			)
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
		set allowedChars=
		set stringLength=
		for %%c in (allowAsterisk allowEqual allowLetters allowNumbers allowQuotationMark allowSpace allowSymbols allowTab) do set arg_%%a=

		if "!stringHasUnwantedChars!"=="false" (
			echo safe >>newEngine\temp\safe\%~1\isSafe_line!currentLine!.tmp
		) else exit 1
	)
)
if exist newEngine\temp\caching\%~1 rmdir newEngine\temp\caching\%~1 /s /q
exit 0