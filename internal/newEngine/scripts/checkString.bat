set stringHasLetters=false
set stringHasNumbers=false
set stringHasSpaces=false
set stringHasSymbols=false
set stringIsSafe=true
set stringHasUnwantedChars=false
set "checkString=%~1"
set allowedChars=%~2

set getArgs=%2-%3-%4-%5-%6-%7-%8-%9
for %%a in (allowAsterisk allowEqual allowLetters allowNumbers allowQuotationMark allowSpace allowSymbols allowTab) do (
	set arg_%%a=false
	if NOT "!getArgs!"=="!getArgs:%%a=§!" set arg_%%a=true
)

set string=!checkString!
set /a stringLength=0
for /l %%a in (0,1,!lineCharLimit!) do if NOT "!string!"=="" (
	set /a stringLength+=1
	set string=!string:~1!
)
if !stringLength! GEQ !lineCharLimit! (
	set stringIsSafe=false
	set charHasUnwantedChars=true
	set checkString=
	set allowedChars=
	set getArgs=
	for %%a in (allowAsterisk allowEqual allowLetters allowNumbers allowQuotationMark allowSpace allowSymbols allowTab) do set arg_%%a=
	exit /b 1
)

set space= 
set equal==
set semiColon=;
set quotationMark=^"
set asterisk=*
set "tab=	"
for /l %%a in (0,1,!stringLength!) do if NOT "!checkString:~%%a!"=="" (
	set charIsSafe=false
	set charHasUnwantedChars=true
	set checkChar=!checkString:~%%a,1!
	for %%b in (Asterisk Equal Space QuotationMark Tab) do (
		if "!arg_allow%%b!"=="true" if "!checkChar!"=="!%%b!" (
			set stringHas%%bs=true
			set charIsSafe=true
			set charHasUnwantedChars=false
		)
	)
	if NOT "!checkChar!"=="!checkChar:;=§§!" (
		set stringHasSymbols=true
		set charIsSafe=true
		if "!arg_allowSymbols!"=="true" set charHasUnwantedChars=false
	)
	for %%b in (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if NOT "!checkChar!"=="!checkChar:%%b=§§!" (
		set stringHasLetters=true
		set charIsSafe=true
		if "!arg_allowLetters!"=="true" set charHasUnwantedChars=false
	)
	for /l %%b in (0,1,9) do if NOT "!checkChar!"=="!checkChar:%%b=§§!" (
		set stringHasNumbers=true
		set charIsSafe=true
		if "!arg_allowNumbers!"=="true" set charHasUnwantedChars=false
	)
	for %%b in (. \ $ : + - / _) do if NOT "!checkChar!"=="!checkChar:%%b=§§!" (
		set stringHasSymbols=true
		set charIsSafe=true
		if "!arg_allowSymbols!"=="true" set charHasUnwantedChars=false
	)
	for %%b in (!allowedChars!) do if NOT "!checkChar!"=="!checkChar:%%b=§§!" (
		set stringHasCustom=true
		set charIsSafe=true
		set charHasUnwantedChars=false
	)
	if "!charIsSafe!"=="false" (
		set stringIsSafe=false
		set stringHasUnwantedChars=true
	)
	if "!charHasUnwantedChars!"=="true" set stringHasUnwantedChars=true
)

set charIsSafe=
set charHasUnwantedChars=
set space=
set equal=
set semiColon=
set quotationMark=
set asterisk=
set tab=
exit /b 0