:main
call newEngine\scripts\wait.bat 50
set /a scriptCount=0
set scripts=
for /f %%a in ('dir /b /a-d newEngine\temp\cacheSafety\ 2^>nul') do (
	set /a scriptCount+=1
	if defined scripts (
		set scripts=!scripts!, '%%~nxa'
	) else set scripts='%%~nxa'
)

if NOT defined scripts if "!scriptCount!"=="0" (
	echo.[55;3H                                                                                        [55;3H
	call newEngine\scripts\wait.bat 10
	exit /b 0
)
echo.[54;3H                                                                                        [54;3HWaiting for script safety cache... ^(!scriptCount! left^)
if NOT "!scripts:~84!"=="" (
	set scripts=!scripts:~0,80! ...
)

echo.[55;3H                                                                                        [55;3H!scripts!
goto :main