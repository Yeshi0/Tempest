@echo off
setLocal enableDelayedExpansion

if NOT exist scripts\main.bat (
	echo.
	echo.  Unable to locate 'scripts\main.bat'.
	goto :halt
)

set nativeBatch=true
for %%a in (
	WINEHOMEDIR
	WINEUSERLOCATE
	WINEUSERNAME
) do if defined %%a set nativeBatch=false
if "!nativeBatch!"=="false" (
	echo.
	echo.  NewEngine is not supported on WINE.
	echo.  This [4mwill not[0m work correctly.
	echo.
	echo.  Don't report bugs caused while using WINE.
	echo.  Press any key to ignore this message and start anyway.
	pause >nul
)
goto :init

:halt
pause >nul
goto :halt

:init
call scripts\init.bat
set title=NewEngine Runtime
set /a debugTitlebar=1

:main
for /l %%. in (1,1,2999) do (
	set /a fixedMouseXpos=mouseXpos+1,fixedMouseYpos=56-mouseYpos,prevMouseClick=mouseClick,mouseClick=click
	set prevKeys=!keys!
	set keys=!keysPressed!

	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "timer_globalTimer_t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, globalTdiff=timer_globalTimer_t2-timer_globalTimer_t1, timer_globalTimer_tDiff+=((~(timer_globalTimer_tDiff&(1<<31))>>31)+1)*8640000, timer_globalTimer_t1=timer_globalTimer_t2"
	for %%a in (
		dispTimer
		timer5cs
		timer100cs
		timer500cs
		tpsTimer
	) do set /a %%a+=globalTdiff
	if !timer100cs! GEQ 100 (
		set /a timer100cs-=100
		if !timer100cs! GEQ 100 set /a timer100cs=0

		set /a fpsFinal=fpsFrames,fpsFrames=0
		set /a tpsFinal=tpsTicks,tpsTicks=0
		set /a yssLinesFinal=yssLinesExecuted,yssLinesExecuted=0

		title NewEngine Editor ^| FPS: !fpsFinal!/25
	)
	if !dispTimer! GEQ 4 (
		set /a dispTimer-=4,fpsFrames+=1
		if !dispTimer! GEQ 4 set /a dispTimer=0
		<nul set /p=[1;1H[48;2;200;200;200m
		for /l %%a in (56,-1,1) do set d=!d!!d%%a:~0,88!
		echo.!d!
		set d=
	)

	if !timer5cs! GEQ 10 (
		set /a timer5cs-=10
		if !timer5cs! GEQ 10 set /a timer5cs=0

		set /a projectsListScrollY+=wheelDelta
		set /a wheelDelta=0
	)

	for /l %%a in (1,1,56) do set d%%a=                                                                                        
	for /l %%a in (1,1,!projectCount!) do (
		set /a renderCurrentY=%%a+projectsListScrollY-1
		set /a renderCurrentY=56-renderCurrentY
		if !renderCurrentY! GEQ 1 if !renderCurrentY! LEQ 56 (
			call scripts\getStringLength.bat "!project%%a_name!"
			set /a lineLength=88-stringLength
			for %%b in (!lineLength!) do set newLine=!line:~0,%%b!
			set d!renderCurrentY!=!project%%a_name!!newLine!
		)
	)
)
goto :main