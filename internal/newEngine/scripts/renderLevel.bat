if NOT defined levelSizeX exit /b 1

set string1=%~1
if NOT exist newEngineProject\!string1! exit /b 1

rem create an empty level render buffer
set string2=
set /a num1=levelSizeY*8
for /l %%a in (1,1,!levelSizeX!) do set string2=!string2!        
for /l %%a in (1,1,!num1!) do set lrb_l%%a=!string2!
for /f "tokens=1-4 delims=: " %%a in (newEngineProject\!string1!) do (
	if "%%a"=="tile" (
		if NOT exist newEngineProject\tiles\%%b exit /b 1
		for /f "tokens=1-2 delims=: " %%e in (newEngineProject\tiles\%%b) do (
			if "%%e"=="collisionGroup" (
				rem we dont need to load collision data
				rem it has already been loaded by loadLevel
				break

			) else if "%%e"=="sprite" (
				if NOT exist newEngineProject\sprites\%%f exit /b 1
				set spriteContent=
				for /f "tokens=1 delims=." %%f in (newEngineProject\sprites\%%f) do (
					set "lineContent=%%f"
					if NOT defined lineContent exit /b 1
					if "!lineContent:~7,1!"=="" exit /b 1
					if NOT "!lineContent:~8!"=="" exit /b 1
					set spriteContent=!spriteContent!!lineContent!
				)

				rem render the sprite into the level render buffer
				set /a startX=%%c*8-8
				set /a endX=startX+8
				set /a startY=%%d*8-7
				set /a endY=startY+7
				set /a currentLine=0
				for /l %%g in (!endY!,-1,!startY!) do (
					set /a currentLine+=1
					set /a spriteOffset=currentLine*8-8
					for /f "tokens=1-3 delims= " %%i in ("!spriteOffset! !startX! !endX!") do (
						set lrb_l%%g=!lrb_l%%g:~0,%%j!!spriteContent:~%%i,8!!lrb_l%%g:~%%k!
					)
				)

			) else exit /b 1
		)
	)
)
set spriteContent=
exit /b 0