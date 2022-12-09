:main
call newEngine\scripts\wait.bat 50
set /a textYpos=54
set /a totalCount=0
for %%z in (level object script sprite tile) do (
	set /a textYpos-=3
	set /a textYpos2=textYpos+1
	set /a %%zCount=0
	set %%zs=
	for /f %%a in ('dir /b /ad newEngine\temp\caching\%%zs 2^>nul') do (
		set /a %%zCount+=1
		set /a totalCount+=1
		if defined %%zs (
			set %%zs=!%%zs!, '%%~nxa'
		) else set %%zs='%%~nxa'
	)

	echo.[!textYpos!;3H                                                                                        [!textYpos!;3HWaiting for %%z cache... ^(!%%zCount! left^)
	if NOT "!%%zCount!"=="0" (
		if NOT "!%%zs:~84!"=="" (
			set %%zs=!%%zs:~0,80! ...
		)
	) else set %%zs=Done, waiting for others to finish...
	echo.[!textYpos2!;3H                                                                                        [!textYpos2!;3H!%%zs!
)

if "!totalCount!"=="0" (
	<nul set /p=[1;1H[48;2;0;0;0m
	for /l %%a in (1,1,53) do echo.                                                                                        
	echo.[55;3H                                                                                        [55;3H
	call newEngine\scripts\wait.bat 25
	exit /b 0
)
goto :main