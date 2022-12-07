@echo off
setLocal enableDelayedExpansion

cd ..
exe\inject.exe exe\consoleUtils.dll
exe\inject.exe exe\getInput.dll
mode 88,57
chcp 65001 >nul
color 70

:loadLevel
set /p level=Level: 
if NOT exist "!level!" exit /b 1

for /l %%a in (1,1,100) do set li_l%%a=0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
for /l %%a in (1,1,400) do set rb_l%%a=                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

set tid_empty.dat=1
set idt_1=empty.dat
set ids_1=tile-empty.spr
set /a currentId=1
for /f %%a in ('dir /b /a-d ..\tiles') do (
	set /a currentId+=1
	set tid_%%a=!currentId!
	set idt_!currentId!=%%a
	set ids_!currentId!=tile-%%~na.spr
)

set prevTile=
for /f "tokens=1-4 delims=: " %%a in (!level!) do (
	if "%%a"=="tile" (
		if %%c GEQ 1 if %%c LEQ 100 if %%d GEQ 1 if %%d LEQ 50 (
			echo Loading ^(x=%%c^)
			set /a offset=%%c-1
			for %%e in (!offset!) do (
				set li_l%%d=!li_l%%d:~0,%%e!!tid_%%b!!li_l%%d:~%%c!
			)
			set /a renderStartX=%%c*8-8
			set /a renderEndX=renderStartX+8
			set /a renderStartY=%%d*8-7
			set /a renderEndY=renderStartY+7
			set /a renderLine=0
			if NOT "%%b"=="!prevTile!" (
				set prevTile=%%b
				set /a currentLine=9
				for %%e in (!tid_%%b!) do for /f "tokens=1 delims=." %%f in (..\sprites\!ids_%%e!) do (
					set /a currentLine-=1
					set spriteContent_l!currentLine!=%%f
				)
			)
			for /f "tokens=1-2 delims= " %%e in ("!renderStartX! !renderEndX!") do for /l %%g in (!renderStartY!,1,!renderEndY!) do (
				set /a renderLine+=1
				for %%h in (!renderLine!) do set rb_l%%g=!rb_l%%g:~0,%%e!!spriteContent_l%%h!!rb_l%%g:~%%f!
			)
		)
	)
)

:prepareMain
set /a cameraXpos=1
set /a cameraYpos=1
for /l %%a in (1,1,56) do set d%%a=                                                                                        
set /a objId=2

:main
for /l %%. in (1,1,2999) do (
	set /a fixedMouseXpos=mouseXpos+1,fixedMouseYpos=56-mouseYpos,prevMouseClick=mouseClick,mouseClick=click
	set prevKeys=!keys!
	set keys=!keysPressed!

	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "timer_globalTimer_t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, globalTdiff=timer_globalTimer_t2-timer_globalTimer_t1, timer_globalTimer_tDiff+=((~(timer_globalTimer_tDiff&(1<<31))>>31)+1)*8640000, timer_globalTimer_t1=timer_globalTimer_t2"
	for %%a in (
		timer100cs
	) do set /a %%a+=globalTdiff

	if !timer100cs! GEQ 100 (
		set /a timer100cs-=100
		if !timer100cs! GEQ 100 set /a timer100cs=0

		set /a fpsFinal=fpsFrames
		set /a fpsFrames=0

		title NewEngine Level Editor ^| FPS: !fpsFinal! ^| H: !hoverTileX!, !hoverTileY!
	)

	set /a fpsFrames+=1
	set /a offset=cameraXpos-1
	set /a renderEndY=cameraYpos+55
	<nul set /p=[1;1H
	for %%a in (!offset!) do for /l %%b in (!renderEndY!,-1,!cameraYpos!) do echo(!rb_l%%b:~%%a,88!

	if defined keys (
		if NOT "!keys!"=="!keys:-9-=§!" (
			cls
			echo List:
			for /l %%a in (1,1,50) do if defined idt_%%a echo.OBJ %%a: '!idt_%%a!'
			echo.
			set objId=none
			set /p objId=Select OBJ ID: 
			if NOT defined idt_!objId! (
				echo OBJ ID '!objId!' is invalid.
				echo Selected OBJ ID has been reset to '0'.
				pause
			)
		)
		if NOT "!keys!"=="!keys:-65-=§!" set /a cameraXpos-=2
		if NOT "!keys!"=="!keys:-68-=§!" set /a cameraXpos+=2
		if NOT "!keys!"=="!keys:-83-=§!" set /a cameraYpos-=2
		if NOT "!keys!"=="!keys:-87-=§!" set /a cameraYpos+=2
		if NOT "!keys!"=="!keys:-16-=§!" (
			if NOT "!keys!"=="!keys:-83-=§!" (
				call :saveLevel
			)
		)
		if !cameraXpos! LEQ 1 set /a cameraXpos=1
		if !cameraYpos! LEQ 1 set /a cameraYpos=1
	)

	set /a hoverTileX=cameraXpos+fixedMouseXpos+6
	set /a hoverTileX/=8
	set /a hoverTileY=cameraYpos+fixedMouseYpos+6
	set /a hoverTileY/=8
	if "!mouseClick!"=="1" (
		set /a offset=hoverTileX-1
		for /f "tokens=1-3 delims= " %%a in ("!hoverTileX! !hoverTileY! !offset!") do set li_l%%b=!li_l%%b:~0,%%c!!objId!!li_l%%b:~%%a!
		set renderTile=true
		set /a renderId=objId
	)
	if "!mouseClick!"=="2" (
		set /a offset=hoverTileX-1
		for /f "tokens=1-3 delims= " %%a in ("!hoverTileX! !hoverTileY! !offset!") do set li_l%%b=!li_l%%b:~0,%%c!0!li_l%%b:~%%a!
		set renderTile=true
		set renderId=1
	)
	if "!renderTile!"=="true" (
		set renderTile=false
		for %%a in (!renderId!) do for /f "tokens=1-3 delims= " %%b in ("!idt_%%a! !hoverTileX! !hoverTileY!") do (
			set /a renderStartX=%%c*8-8
			set /a renderEndX=renderStartX+8
			set /a renderStartY=%%d*8-7
			set /a renderEndY=renderStartY+7
			set /a renderLine=0
			if NOT "a%%b"=="!prevTile!" (
				set prevTile=%%b
				set /a currentLine=9
				for %%e in (!tid_%%b!) do for /f "tokens=1 delims=." %%f in (..\sprites\!ids_%%e!) do (
					set /a currentLine-=1
					set spriteContent_l!currentLine!=%%f
				)
			)
			for /f "tokens=1-2 delims= " %%e in ("!renderStartX! !renderEndX!") do for /l %%g in (!renderStartY!,1,!renderEndY!) do (
				set /a renderLine+=1
				for %%h in (!renderLine!) do set rb_l%%g=!rb_l%%g:~0,%%e!!spriteContent_l%%h!!rb_l%%g:~%%f!
			)
		)
	)
)
goto :main

:saveLevel
if exist backup.dat del backup.dat
copy !level! backup.dat >nul
del !level!
for /l %%a in (1,1,100) do (
	echo Saving ^(x=%%a^)
	for /l %%b in (1,1,50) do (
		set /a offset=%%a-1
		for %%c in (!offset!) do if NOT "!li_l%%b:~%%c,1!"=="0" (
			set string1=!li_l%%b:~%%c,1!
			for %%d in (!string1!) do (
				echo.tile:!idt_%%d!:%%a:%%b >>!level!
			)
		)
	)
)
exit /b 0