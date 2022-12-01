@echo off
setLocal enableDelayedExpansion

cd ..
cd ..
call newEngine\scripts\init.bat
color 70

set level=c1m1.dat

:loadLevel
set exec=loadLevel !level!
call newEngine\scripts\ic-loadLevel.bat
set exec=renderLevel !level!
call newEngine\scripts\ic-renderLevel.bat

set /a cameraXpos=1
set /a cameraYpos=1

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
	set /a offset=cameraXpos-1
	set /a renderEndY=cameraYpos+55
	set /a renderLine=0
	for %%a in (!offset!) do for /l %%b in (!cameraYpos!,1,!renderEndY!) do (
		set /a renderLine+=1
		for %%c in (!renderLine!) do set d%%c=!lrb_l%%b:~%%a,88!
	)

	<nul set /p=[1;1H
	for /l %%a in (56,-1,1) do echo.!d%%a!
	set /a fpsFrames+=1

	if defined keys (
		if NOT "!keys!"=="!keys:-65-=§!" set /a cameraXpos-=2
		if NOT "!keys!"=="!keys:-68-=§!" set /a cameraXpos+=2
		if NOT "!keys!"=="!keys:-83-=§!" set /a cameraYpos-=2
		if NOT "!keys!"=="!keys:-87-=§!" set /a cameraYpos+=2
		if NOT "!keys!"=="!keys:-16-=§!" (
			if NOT "!keys!"=="!keys:-83-=§!" (
				call :saveLevel
				set exec=renderLevel !level!
				call newEngine\scripts\ic-renderLevel.bat
			)
			if NOT "!keys!"=="!keys:-82-=§!" (
				call :saveLevel
				goto :loadLevel
			)
		)
	)

	set /a hoverTileX=cameraXpos+fixedMouseXpos+6
	set /a hoverTileX/=8
	set /a hoverTileY=cameraYpos+fixedMouseYpos+6
	set /a hoverTileY/=8

	if "!mouseClick!"=="1" (
		set /a offset=hoverTileX-1
		for /f "tokens=1-3 delims= " %%a in ("!hoverTileX! !hoverTileY! !offset!") do set lcm_l%%b=!lcm_l%%b:~0,%%c!0!lcm_l%%b:~%%a!
	)
	if "!mouseClick!"=="2" (
		set /a offset=hoverTileX-1
		for /f "tokens=1-3 delims= " %%a in ("!hoverTileX! !hoverTileY! !offset!") do set lcm_l%%b=!lcm_l%%b:~0,%%c! !lcm_l%%b:~%%a!
	)
)
goto :main

:saveLevel
if exist newEngineProject\levels\backup.dat del newEngineProject\levels\backup.dat
copy newEngineProject\levels\!level! newEngineProject\levels\backup.dat >nul
del newEngineProject\levels\!level!
for /l %%a in (1,1,50) do for /l %%b in (1,1,20) do (
	set /a offset=%%a-1
	for %%c in (!offset!) do if "!lcm_l%%b:~%%c,1!"=="0" echo.tile:genericSolid.dat:%%a:%%b >>newEngineProject\levels\c1m1.dat
)
exit /b 0