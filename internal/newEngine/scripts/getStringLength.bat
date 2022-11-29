set string=%~1
set /a maxStringLength=lineCharLimit
if NOT "%2"=="" set /a maxStringLength=%2

set /a stringLength=0
for /l %%a in (0,1,!maxStringLength!) do if NOT "!string!"=="" (
	set /a stringLength+=1
	set string=!string:~1!
)
exit /b 0