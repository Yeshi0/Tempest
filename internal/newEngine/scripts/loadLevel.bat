set /a levelSizeX=11
set /a levelSizeY=7
for %%a in (lcm_ lcg_) do for /f "tokens=1 delims==" %%b in ("set %%a") do set %%b=

set string1=%~1
call newEngine\scripts\checkString.bat "!string1!" "\ ." allowNumbers allowLetters
if NOT "!stringHasLetters!.!stringHasUnwantedChars!"=="true.false" exit /b 1
if NOT exist newEngineProject\!string1! exit /b 1

for /f "tokens=1-4 delims=: " %%a in (newEngineProject\!string1!) do (
	rem these variables cannot be made temporary
	rem theyre required for stopping viewports from scrolling past the level
	if %%c GEQ !levelSizeX! set /a levelSizeX=%%c
	if %%d GEQ !levelSizeY! set /a levelSizeY=%%d
	set /a levelEndX=levelSizeX*8
	set /a levelEndY=levelSizeY*8
)

if !levelSizeX! GEQ 1000 exit /b 1
if !levelSizeY! GEQ 1000 exit /b 1

rem create an empty collision map
set string2=
for /l %%a in (1,1,!levelSizeX!) do set string2=!string2! 
for /l %%a in (1,1,!levelSizeY!) do set lcm_l%%a=!string2!

for /f "tokens=1-4 delims=: " %%a in (newEngineProject\!string1!) do (
	if "%%a"=="tile" (
		if NOT exist newEngineProject\tiles\%%b exit /b 1
		for /f "tokens=1-2 delims=: " %%e in (newEngineProject\tiles\%%b) do (
			if "%%e"=="collisionGroup" (
				rem find object group id
				set num1=-1
				for /l %%g in (0,1,9) do if "!lcg_%%g!"=="%%f" set /a num1=%%g
				if "!num1!"=="-1" (
					set /a num1=-1
					for /l %%g in (9,-1,0) do if NOT defined lcg_%%g set /a num1=%%g
				)
				if "!num1!"=="-1" exit /b 1
				set lcg_!num1!=%%f
	
				rem insert the new collision type id into the collision map
				set /a num2=%%c-1
				for %%g in (!num2!) do (
					rem goofy ass substringing
					set lcm_l%%d=!lcm_l%%d:~0,%%g!!num1!!lcm_l%%d:~%%c!
				)

			) else if "%%e"=="sprite" (
				rem we dont need to load sprite data
				rem it will be loaded when renderLevel is called
				break

			) else exit /b 1
		)
	)
)
exit /b 0