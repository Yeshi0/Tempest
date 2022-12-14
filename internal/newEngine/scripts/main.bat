@echo off
setLocal enableDelayedExpansion

if NOT exist newEngine\scripts\main.bat (
	echo.
	echo.  Unable to locate 'newEngine\scripts\main.bat'.
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
set neRuntimeEnv=true
call newEngine\scripts\init.bat
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

		if defined b0 for /l %%a in (-150,1,0) do set b%%a=
		if defined b57 for /l %%a in (57,1,150) do set b%%a=

		if "!debugTitlebar!"=="0" (
			title !title! ^| Press {TAB} to toggle debug.

		) else (
			set dispKeyPressed=0
			if defined keyPressed set dispKeyPressed=!keyPressed!
			title !persistent_engineRuntimeVersion! RT ^| FPS: !fpsFinal!/!maxFps! ^(!tpsFinal!/!maxTps!^) ^| OBJ: !objectCount! ^| YSS: !scriptCount! ^(LPS: !yssLinesFinal!^)
		)
		if "!exitGame!"=="true" exit /b 0
	)
	if !timer500cs! GEQ 500 (
		set /a timer500cs-=500
		if !timer500cs! GEQ 500 set /a timer500cs=0

		set discordUpdate=true
	)

	if defined keys if NOT "!keys:-9-=§!"=="!keys!" if NOT "!keys!"=="!prevKeys!" (
		set /a debugTitlebar+=1
		title !persistent_engineRuntimeVersion! RT ^| FPS: !fpsFinal!/!maxFps! ^(!tpsFinal!/!maxTps!^) ^| OBJ: !objectCount! ^| YSS: !scriptCount! ^| Press {BACKSPACE} to show dev console.
		if "!debugTitlebar!"=="2" (
			set /a debugTitlebar=0
			title !title! ^| Press {TAB} to toggle debug.
		)
	)
	if "!allowDevConsole!"=="true" (
		if defined keys if NOT "!keys:-8-=§!"=="!keys!" if NOT "!keys!"=="!prevKeys!" (
			call newEngine\scripts\devConsole.bat
			if NOT exist newEngine\temp\safe\temp\devConsoleCommand.yss\ mkdir newEngine\temp\safe\temp\devConsoleCommand.yss
			echo safe >>newEngine\temp\safe\temp\devConsoleCommand.yss\isSafe_line1.tmp
			call newEngine\scripts\scriptManager.bat start temp\devConsoleCommand.yss
			if exist newEngine\temp\safe\temp\devConsoleCommand.yss\isSafe_line1.tmp del newEngine\temp\safe\temp\devConsoleCommand.yss\isSafe_line1.tmp
		)
	)

	if !dispTimer! GEQ !csPerFrame! (
		set /a dispTimer-=csPerFrame,fpsFrames+=1
		if !dispTimer! GEQ !csPerFrame! set /a dispTimer=0
		<nul set /p=[1;1H[48;2;!screenColor!;!screenColor!;!screenColor!m
		for /l %%a in (56,-1,1) do echo(!b%%a:~0,88!
	)

	if !tpsTimer! GEQ 50 set /a tpsTimer=0
	set /a ticksToExecute=tpsTimer/csPerTick
	if !ticksToExecute! GEQ 1 for /l %%z in (1,1,!ticksToExecute!) do (
		if defined screenEffect call newEngine\scripts\screenEffect.bat
		if "%%z"=="!ticksToExecute!" for /l %%a in (1,1,!objectCount!) do (
			if "!obj%%a_type!"=="button" (
				set obj%%a_prevHover=!obj%%a_hover!
				set obj%%a_hover=false
				if !fixedMouseXpos! GEQ !obj%%a_xpos! if !fixedMouseXpos! LEQ !obj%%a_endXpos! if !fixedMouseYpos! GEQ !obj%%a_ypos! if !fixedMouseYpos! LEQ !obj%%a_endYpos! set obj%%a_hover=true
				if NOT "!obj%%a_hover!.!staticButtons!"=="!obj%%a_prevHover!.true" (
					set /a renderLine=0
					for /l %%b in (!obj%%a_ypos!,1,!obj%%a_endYpos!) do if defined b%%b (
						set /a renderLine+=1,offset1=obj%%a_xpos-1,offset2=offset1+obj%%a_dLength
						for /f "tokens=1-3 delims= " %%c in ("!offset1! !renderLine! !offset2!") do (
							set new=!obj%%a_dl%%d!
							if "!obj%%a_hover!"=="true" (
								set new=!new: =E!
								set new=!new:█= !
								set new=!new:E=█!
							)
							set b%%b=!b%%b:~0,%%c!!new!!b%%b:~%%e!
						)
					)
				)
				if "!obj%%a_hover!"=="true" (
					if "!mouseClick!.!prevButtonMouseClick!.!buttonsDisabled!"=="0.1.false" (
						set /a prevButtonMouseClick=0,mouseClick=0,scriptCount+=1
						set /a pid!scriptCount!_lineCount=1,pid!scriptCount!_execLine=0,pid!scriptCount!_sleepTicks=0,pid!scriptCount!_linesThisTick=maxLinesPerFrame
						set pid!scriptCount!_l1=!obj%%a_onClick!
						set pid!scriptCount!_path=TEMP
					)
					set /a prevButtonMouseClick=mouseClick
				)

			) else if "!obj%%a_type!"=="text" (
				if NOT "!obj%%a_textLabel!.!staticText!"=="!obj%%a_prevTextLabel!.true" (
					set obj%%a_prevTextLabel=!obj%%a_textLabel!
					set /a num1=2,num2=obj%%a_ypos+2,num3=obj%%a_endYpos-2
					for /l %%b in (!num2!,1,!num3!) do if defined b%%b (
						set /a num1+=1,num2=obj%%a_xpos+2,num3=num2+obj%%a_dLength-4
						for /f "tokens=1-3 delims= " %%c in ("!num2! !num1! !num3!") do set b%%b=!b%%b:~0,%%c!!obj%%a_dl%%d:~2,-2!!b%%b:~%%e!
					)
				)

			) else if "!obj%%a_type!"=="viewport" (
				set /a num1=-1
				for /l %%b in (1,1,!objectCount!) do if "!obj%%b_name!"=="!obj%%a_focusObject!" set /a num1=%%b
				if NOT "!num1!"=="-1" (
					set /a num2=obj%%a_width/2,obj%%a_viewXpos=obj!num1!_xpos-num2+4,num2=obj%%a_height/2,obj%%a_viewYpos=obj!num1!_ypos-num2+4
					if !obj%%a_viewXpos! LEQ 1 (
						set /a obj%%a_viewXpos=1
					) else (
						set /a num2=levelEndX-obj%%a_width+1
						if !obj%%a_viewXpos! GEQ !num2! set /a obj%%a_viewXpos=num2
					)
					if !obj%%a_viewYpos! LEQ 1 (
						set /a obj%%a_viewYpos=1
					) else (
						set /a num2=levelEndY-obj%%a_height+1
						if !obj%%a_viewYpos! GEQ !num2! set /a obj%%a_viewYpos=num2
					)
				)

				if NOT "!obj%%a_fsvp!"=="true" (
					set /a num1=obj%%a_ypos+obj%%a_height-1,num2=obj%%a_xpos-1,num3=obj%%a_width,num4=88-num2-num3,num4=88-num4,num5=obj%%a_viewXpos-1
					for /f "tokens=1-4 delims= " %%c in ("!num2! !num3! !num4! !num5!") do for /l %%b in (!obj%%a_ypos!,1,!num1!) do (
						set /a num6=%%b+obj%%a_viewYpos-1
						for %%g in (!num6!) do set b%%b=!b%%b:~0,%%c!!al%%g:~%%f,%%d!!b%%b:~%%e!
					)
				) else (
					set /a num1=obj%%a_viewXpos-1
					for %%b in (!num1!) do (
						set /a num2=57,num3=obj%%a_viewYpos+55
						for /l %%c in (!num3!,-1,!obj%%a_viewYpos!) do (
							set /a num2-=1
							set b!num2!=!al%%c:~%%b,88!
						)
					)
				)
			)
		)

		for /l %%a in (1,1,!objectCount!) do (
			if "!obj%%a_type!"=="dummy" (
				if "!obj%%a_playerController!"=="sideScroller" (
					if NOT "!keys!"=="" (
						for /f "tokens=1-5 delims= " %%b in ("!obj%%a_keyUp! !obj%%a_keyDown! !obj%%a_keyLeft! !obj%%a_keyRight! !obj%%a_keyJump!") do (
							if NOT "!keys:-%%d-=§!"=="!keys!" if !obj%%a_speedX! GTR -24 (
								set /a obj%%a_speedX-=4
								if !obj%%a_speedX! GTR -8 if !obj%%a_speedX! LEQ 8 set /a obj%%a_speedX-=6
							)
							if NOT "!keys:-%%e-=§!"=="!keys!" if !obj%%a_speedX! LSS 24 (
								set /a obj%%a_speedX+=4
								if !obj%%a_speedX! LSS 8 if !obj%%a_speedX! GEQ -8 set /a obj%%a_speedX+=6
							)

							if "!obj%%a_collideSide!"=="bottom" set obj%%a_grounded=true
							if NOT "!keys:-%%f-=§!"=="!keys!" if "!obj%%a_grounded!"=="true" (
								set obj%%a_grounded=false
								set /a obj%%a_speedY=40
							)
						)
					)
					if !obj%%a_speedY! GTR -32 set /a obj%%a_speedY-=4
					set /a obj%%a_xpos+=obj%%a_speedX/8,obj%%a_ypos+=obj%%a_speedY/6

					if "!obj%%a_grounded!"=="true" (
						set string1=true
						if defined keys set string1=false
						if NOT "!keys:-%%d-=§!!keys:-%%e-=§!"=="!keys!!keyS!" set string1=true
						if "!string1!"=="true" (
							if !obj%%a_speedX! LEQ -1 set /a obj%%a_speedX+=6
							if !obj%%a_speedX! GEQ 1 set /a obj%%a_speedX-=6
						)
					) else set /a obj%%a_decreaseSpeedX=0
				)

				if "!obj%%a_playerController!"=="topDown" (
					if NOT "!keys!"=="" (
						for /f "tokens=1-5 delims= " %%b in ("!obj%%a_keyUp! !obj%%a_keyDown! !obj%%a_keyLeft! !obj%%a_keyRight! !obj%%a_keyJump!") do (
							if NOT "!keys:-%%b-=§!"=="!keys!" set /a obj%%a_ypos+=1
							if NOT "!keys:-%%c-=§!"=="!keys!" set /a obj%%a_ypos-=1
							if NOT "!keys:-%%d-=§!"=="!keys!" set /a obj%%a_xpos-=1
							if NOT "!keys:-%%e-=§!"=="!keys!" set /a obj%%a_xpos+=1
							if !obj%%a_xpos! LEQ 1 set /a obj%%a_xpos=1
							if !obj%%a_ypos! LEQ 1 set /a obj%%a_ypos=1
						)
					)
				)

				if "!obj%%a_useCollisions!"=="true" (
					set obj%%a_collisionList=-
					set obj%%a_grounded=false

					rem bottom left collision
					set /a ccXpos=obj%%a_xpos+7,ccXpos/=8,ccYpos=obj%%a_ypos+7,ccYpos/=8,ccCheckX=ccXpos-1
					set collisionGroupId=
					set collisionType=
					for /f "tokens=1-2 delims= " %%b in ("!ccCheckX! !ccYpos!") do (
						set collisionGroupId=!lcm_l%%c:~%%b,1!
						for %%d in (!collisionGroupId!) do set collisionType=!lcg_%%d!
					)
					if defined collisionType (
						set /a num1=ccCheckX+1
						set obj%%a_collisionList=-!collisionType!-!collisionType!_x!num1!y!ccYpos!-!obj%%a_collisionList!-
					)
					set collide=false
					if "!collisionType!"=="solid" set collide=true
					if "!collisionType!"=="semiSolid" set collide=true
					if "!collide!"=="true" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX-1-ccSpeedX,ccDistY=obj%%a_ypos+1-ccDistY-ccSpeedY
						if NOT "!collisionType!"=="semiSolid" if !ccDistX! GTR !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos+=1,obj%%a_speedX=0
						)
						if "!collisionType!"=="semiSolid" if !obj%%a_speedY! GEQ -6 set /a ccDistX=9999
						if !ccDistX! LSS !ccDistY! (
							set /a obj%%a_ypos=ccYpos*8,obj%%a_ypos+=1,obj%%a_speedY=0
							set obj%%a_grounded=true
						)
					)

					rem bottom right collision
					set /a ccXpos=obj%%a_xpos+6,ccXpos/=8,ccYpos=obj%%a_ypos+7,ccYpos/=8
					set collisionGroupId=
					set collisionType=
					for /f "tokens=1-2 delims= " %%b in ("!ccXpos! !ccYpos!") do (
						set collisionGroupId=!lcm_l%%c:~%%b,1!
						for %%d in (!collisionGroupId!) do set collisionType=!lcg_%%d!
					)
					if defined collisionType (
						set /a num1=ccXpos+1
						set obj%%a_collisionList=-!collisionType!-!collisionType!_x!num1!y!ccYpos!-!obj%%a_collisionList!-
					)
					set collide=false
					if "!collisionType!"=="solid" set collide=true
					if "!collisionType!"=="semiSolid" set collide=true
					if "!collide!"=="true" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX+1-obj%%a_speedX,ccDistX=-6-ccDistX,ccDistY=obj%%a_ypos-ccDistY+1-obj%%a_speedY-2
						if NOT "!collisionType!"=="semiSolid" if !ccDistX! GEQ !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos-=7,obj%%a_speedX=0
						)
						if "!collisionType!"=="semiSolid" if !obj%%a_speedY! GEQ -6 set /a ccDistX=9999
						if !ccDistX! LSS !ccDistY! (
							set /a obj%%a_ypos=ccYpos*8,obj%%a_ypos+=1,obj%%a_speedY=0
							set obj%%a_grounded=true
						)
					)

					rem top left collision
					set /a ccXpos=obj%%a_xpos+7,ccXpos/=8,ccYpos=obj%%a_ypos+6,ccYpos/=8,ccCheckX=ccXpos-1,ccCheckY=ccYpos+1
					set collisionGroupId=
					set collisionType=
					for /f "tokens=1-2 delims= " %%b in ("!ccCheckX! !ccCheckY!") do (
						set collisionGroupId=!lcm_l%%c:~%%b,1!
						for %%d in (!collisionGroupId!) do set collisionType=!lcg_%%d!
					)
					if defined collisionType (
						set /a num1=ccCheckX+1
						set obj%%a_collisionList=-!collisionType!-!collisionType!_x!num1!y!ccCheckY!-!obj%%a_collisionList!-
					)
					if "!collisionType!"=="solid" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX-ccSpeedX,ccDistY=obj%%a_ypos-ccDistY-ccSpeedY,ccDistY=-6-ccDistY
						if !ccDistX! GTR !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos+=1,obj%%a_speedX=0
						)
						if !ccDistX! LSS !ccDistY! (
							set /a obj%%a_ypos=ccYpos*8,obj%%a_ypos-=7,obj%%a_speedY=0
						)
					)

					rem top right collision
					set /a ccXpos=obj%%a_xpos+6,ccXpos/=8,ccYpos=obj%%a_ypos+6,ccYpos/=8,ccCheckY=ccYpos+1
					set collisionGroupId=
					set collisionType=
					for /f "tokens=1-2 delims= " %%b in ("!ccXpos! !ccCheckY!") do (
						set collisionGroupId=!lcm_l%%c:~%%b,1!	
						for %%d in (!collisionGroupId!) do set collisionType=!lcg_%%d!
					)
					if defined collisionType (
						set /a num1=ccXpos+1
						set obj%%a_collisionList=-!collisionType!-!collisionType!_x!num1!y!ccCheckY!-!obj%%a_collisionList!-
					)
					if "!collisionType!"=="solid" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX+1-obj%%a_speedX,ccDistX=-6-ccDistX,ccDistY=obj%%a_ypos-ccDistY-ccSpeedY,ccDistY=-6-ccDistY
						if !ccDistX! GEQ !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos-=7,obj%%a_speedX=0
						)
						if !ccDistX! LSS !ccDistY! (
							set /a obj%%a_ypos=ccYpos*8,obj%%a_ypos-=7,obj%%a_speedY=0
						)
					)

					set /a num1=levelSizeX*8-7
					set /a num2=levelSizeY*8-7
					if !obj%%a_xpos! LEQ 1 set /a obj%%a_xpos=1
					if !obj%%a_xpos! GEQ !num1! set /a obj%%a_xpos=num1
					if defined rtVar_collisions title !obj%%a_collisionList!
				)

				if "%%z"=="!ticksToExecute!" (
					if defined obj%%a_sprite (
						set /a num1=-1
						for /l %%b in (1,1,!objectCount!) do if "!obj%%b_name!"=="!obj%%a_renderInto!" set /a num1=%%b
						if NOT "!num1!"=="-1" (
							set /a num2=obj%%a_xpos-obj!num1!_viewXpos
							if !num2! GEQ 1 if !num2! LEQ 81 (
								set /a num3=obj%%a_ypos-obj!num1!_viewYpos+1,num4=num3+7,num5=0,num7=num2+8,num9=obj!num1!_viewXpos+88-obj%%a_xpos
								if !num9! GEQ 8 set /a num9=8
								if !num9! LEQ 0 set /a num9=0
								for /f "tokens=1-2 delims= " %%d in ("!num2! !num7!") do for /l %%f in (!num3!,1,!num4!) do (
									set /a num5+=1,num8=num5*8-8,num8=obj!num1!_height-num8
									for /f "tokens=1-3 delims= " %%g in ("!num5! !num8! !num9!") do (
										if defined b%%f set b%%f=!b%%f:~0,%%d!!obj%%a_spriteContent:~%%h,%%i!!b%%f:~%%e!
									)
								)
							)
						)
					)
				)
			)
		)
		set /a tpsTicks+=1,tpsTimer-=csPerTick
		for /l %%a in (1,1,!scriptCount!) do (
			if !pid%%a_sleepTicks! GEQ 1 (
				set /a pid%%a_sleepTicks-=1

			) else (
				set stopExec=false
				set foundEndFrame=false
				set /a pid%%a_linesLastTick=pid%%a_linesThisTick+2,pid%%a_linesThisTick=0
				for /l %%z in (1,1,!pid%%a_linesLastTick!) do if NOT "!stopExec!"=="true" (
					set /a pid%%a_linesThisTick+=1,pid%%a_execLine+=1
					for %%b in (!pid%%a_execLine!) do if defined pid%%a_l%%b (
						set exec=!pid%%a_l%%b!
						set /a yssLinesExecuted+=1
						if NOT "!exec!"=="!exec:$=hasVariable!" (
							if defined pid%%a_vo_l!pid%%a_execLine! (
								set /a variableOffset=pid%%a_vo_l%%b,variableLength=pid%%a_vl_l%%b
								set variableName=!pid%%a_vn_l%%b!

							) else (
								set /a currentPid=%%a,currentLine=%%b
								call newEngine\scripts\variableExpansionCache.bat
							)

							set /a variableNameEnd=variableLength+variableOffset+1
							for /f "tokens=1-3 delims= " %%d in ("!variableOffset! !variableLength! !variableNameEnd!") do (
								for %%g in (!variableName!) do (
									set /a offset=variableLength+variableOffset
									for %%h in (!offset!) do (
										set exec=!exec:~0,%%d!!rtVar_%%g!!exec:~%%h!
									)
								)
								set checkExec=!exec:$=hasVariable!
								if NOT "!exec!"=="!checkExec!" (
									call newEngine\scripts\scriptManager.bat kill %%a
									set stopExec=true
								)
							)
						)

						for /f "tokens=1 delims= " %%c in ("!exec!") do (
							if "%%c"=="endFrame" (
								set foundEndFrame=true
								set stopExec=true

							) else if "%%c"=="waitForEffects" (
								set stopExec=true
								if defined screenEffect set /a pid%%a_execLine-=1

							) else if "%%c"=="checkCollision" (
								set pid%%a_skipUntilParenthesis=true
								for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
									for /f "tokens=1-2 delims=:" %%g in ("%%e") do (
										if "%%g"=="tileGroup" (
											for /l %%i in (1,1,!objectCount!) do if "!obj%%i_name!"=="%%d" (
												if defined obj%%i_collisionList if NOT "!obj%%i_collisionList!"=="!obj%%i_collisionList:-%%h-=§!" (
													set pid%%a_skipUntilParenthesis=false
												)
											)
										)
									)
								)
								if "!pid%%a_skipUntilParenthesis!"=="true" (
									if NOT defined pid%%a_supc_l!pid%%a_execLine! for /l %%d in (!pid%%a_execLine!,1,!pid%%a_lineCount!) do if "!pid%%a_skipUntilParenthesis!"=="true" for /f "tokens=1 delims= " %%e in ("!pid%%a_l%%d!") do if "%%e"==")" (
										set pid%%a_skipUntilParenthesis=false
										set /a pid%%a_supc_l!pid%%a_execLine!=%%d
									)
									if defined pid%%a_supc_l!pid%%a_execLine! (
										set pid%%a_skipUntilParenthesis=false
										set /a pid%%a_execLine=pid%%a_supc_l!pid%%a_execLine!
									)
								)

							) else if "%%c"=="math" (
								set string1=!exec:~5!
								if NOT "!string1!"=="" (
									for %%d in (0 1 2 3 4 5 6 7 8 9 + - * /) do if defined string1 set string1=!string1:%%d=!
									if "!string1!"=="" (
										for /f "tokens=2-3 delims=+ " %%d in ("!exec!") do if NOT "%%e"=="" set /a rtVar_result=%%d+%%e
										for /f "tokens=2-3 delims=- " %%d in ("!exec!") do if NOT "%%e"=="" set /a rtVar_result=%%d-%%e
										for /f "tokens=2-3 delims=* " %%d in ("!exec!") do if NOT "%%e"=="" set /a rtVar_result=%%d*%%e
										for /f "tokens=2-3 delims=/ " %%d in ("!exec!") do if NOT "%%e"=="" set /a rtVar_result=%%d/%%e
									)
								)

							) else if "%%c"=="if" (
								set pid%%a_skipUntilParenthesis=true
								set /a pid%%a_ifStartLine=pid%%a_execLine
								set ifSuccess=false
								for /f "tokens=2-4 delims= " %%d in ("!exec!") do (
									if "%%e"=="==" (
										if "%%d"=="keyHeld" (
											set ifSuccess=true
											if defined kcl_%%f for %%h in (!kcl_%%f!) do if defined keys if NOT "!keys:-%%h-=§!"=="!keys!" set pid%%a_skipUntilParenthesis=false

										) else if "%%d"=="keyPressed" (
											set ifSuccess=true
											if defined kcl_%%f for %%h in (!kcl_%%f!) do if defined keys if NOT "!keys:-%%h-=§!"=="!keys!" if NOT "!keys!"=="!prevKeys!" set pid%%a_skipUntilParenthesis=false

										) else (
											set ifSuccess=true
											if "!rtVar_%%d!"=="%%f" set pid%%a_skipUntilParenthesis=false
											if "%%f"=="NUL" if NOT defined rtVar_%%d set pid%%a_skipUntilParenthesis=false
										)

									) else if "%%e"=="X=" (
										set ifSuccess=true
										if NOT "!rtVar_%%d!"=="%%f" set pid%%a_skipUntilParenthesis=false
										if "%%f"=="NUL" if defined rtVar_%%d set pid%%a_skipUntilParenthesis=false

									) else if "%%e"=="V=" (
										set ifSuccess=true
										if "!rtVar_%%d!"=="!rtVar_%%f!" set pid%%a_skipUntilParenthesis=false

									) else if "%%e"=="L=" (
										set ifSuccess=true
										if defined rtVar_%%d if !rtVar_%%d! LEQ %%f set pid%%a_skipUntilParenthesis=false

									) else if "%%e"=="G=" (
										set ifSuccess=true
										if defined rtVar_%%d if !rtVar_%%d! GEQ %%f set pid%%a_skipUntilParenthesis=false

									) else if "%%e"=="VX=" (
										set ifSuccess=true
										if NOT "!rtVar_%%d!"=="!rtVar_%%f!" set pid%%a_skipUntilParenthesis=false
									)
								)
								if "!pid%%a_skipUntilParenthesis!"=="true" (
									if NOT defined pid%%a_supc_l!pid%%a_execLine! for /l %%d in (!pid%%a_execLine!,1,!pid%%a_lineCount!) do if "!pid%%a_skipUntilParenthesis!"=="true" for /f "tokens=1 delims= " %%e in ("!pid%%a_l%%d!") do if "%%e"==")" (
										set pid%%a_skipUntilParenthesis=false
										set /a pid%%a_supc_l!pid%%a_execLine!=%%d
									)
									if defined pid%%a_supc_l!pid%%a_execLine! (
										set pid%%a_skipUntilParenthesis=false
										set /a pid%%a_execLine=pid%%a_supc_l!pid%%a_execLine!
									)
								)
								if NOT "!ifSuccess!"=="true" (
									call newEngine\scripts\scriptManager.bat kill %%a
									set stopExec=true
								)

							) else if "%%c"=="set" (
								set string1=!exec:_==!
								for /f "tokens=1-2 delims= " %%d in ("!string1!") do (
									for /f "tokens=1-2 delims==" %%g in ("%%e") do (
										if "%%h"=="NUL" (
											set rtVar_%%g=
										) else set rtVar_%%g=%%h
									)
								)

							) else if "%%c"=="goto" (
								if defined pid%%a_gotoCache_l!pid%%a_execLine! (
									set /a gotoLine=pid%%a_gotoCache_l!pid%%a_execLine!

								) else call newEngine\scripts\gotoCache.bat
								if NOT "!gotoLine!"=="-1" (
									set pid%%a_skipUntilParenthesis=false
									set /a pid%%a_gotoReturn=pid%%a_execLine,pid%%a_execLine=gotoLine,pid%%a_sleepTicks=1
								)

							) else if "%%c"=="gotoReturn" (
								set /a pid%%a_execLine=pid%%a_gotoReturn

							) else if "%%c"=="modifyObjectProperty" (
								for /f "tokens=2-3 delims= " %%d in ("!exec!") do for /l %%f in (1,1,!objectCount!) do if "%%d"=="!obj%%f_name!" (
									for /f "tokens=1-2 delims==" %%g in ("%%e") do (
										set obj%%f_%%g=%%h
										if "%%g"=="sprite" (
											call newEngine\scripts\loadSprite.bat "%%h" temp
											set obj%%f_spriteContent=!tempSpriteContent!
											set tempSpriteContent=
										)
									)
								)

							) else if "%%c"=="getObjectProperty" (
								for /f "tokens=2-4 delims= " %%d in ("!exec!") do for /l %%g in (1,1,!objectCount!) do if "%%d"=="!obj%%g_name!" (
									set /a rtVar_result=-999999
									if defined obj%%g_%%e set rtVar_result=!obj%%g_%%e!
								)

							) else if exist newEngine\scripts\ic-%%c.bat (
								set /a currentPid=%%a
								call newEngine\scripts\ic-%%c.bat
							)
						)
					)
				)
				if NOT "!foundEndFrame!"=="true" (
					set foundEndFrame=
					set /a pid%%a_linesThisTick+=addLinesPerFrame
				)
				if !pid%%a_execLine! GEQ !pid%%a_lineCount! call newEngine\scripts\scriptManager.bat kill %%a
			)
		)
	)
)
goto :main