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

		if "!debugTitlebar!"=="0" (
			title !title! ^| Press {TAB} to toggle debug.

		) else (
			set dispKeyPressed=0
			if defined keyPressed set dispKeyPressed=!keyPressed!
			title !persistent_engineRuntimeVersion! RT ^| FPS: !fpsFinal!/!maxFps! ^(!tpsFinal!/!maxTps!^) ^| OBJ: !objectCount! ^| YSS: !scriptCount! ^(LPS: !yssLinesFinal!^) ^| !pid1_linesLastTick!
		)

		if "!exitGame!"=="true" exit /b 0
	)
	if !timer500cs! GEQ 500 (
		set /a timer500cs-=500
		if !timer500cs! GEQ 500 set /a timer500cs=0

		set discordState=FPS: !fpsFinal!/!maxFps!
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
			call newEngine\scripts\scriptManager.bat start temp\devConsoleCommand.yss
		)
	)

	if !dispTimer! GEQ !csPerFrame! (
		set /a dispTimer-=csPerFrame,fpsFrames+=1
		if !dispTimer! GEQ !csPerFrame! set /a dispTimer=0
		<nul set /p=[1;1H[48;2;!screenColor!;!screenColor!;!screenColor!m
		for /l %%a in (56,-1,1) do set d=!d!!d%%a:~0,88!
		echo.!d!
		set d=
	)

	if !tpsTimer! GEQ 50 set /a tpsTimer=0
	set /a ticksToExecute=tpsTimer/csPerTick
	if !ticksToExecute! GEQ 1 for /l %%z in (1,1,!ticksToExecute!) do (
		if defined screenEffect call newEngine\scripts\screenEffect.bat
		set /a tpsTicks+=1,tpsTimer-=csPerTick
		for /l %%a in (1,1,!scriptCount!) do (
			if !pid%%a_sleepTicks! GEQ 1 (
				set /a pid%%a_sleepTicks-=1

			) else (
				set stopExec=false
				set foundEndFrame=false
				set /a pid%%a_linesLastTick=pid%%a_linesThisTick,pid%%a_linesThisTick=0
				for /l %%z in (1,1,!pid%%a_linesLastTick!) do if NOT "!stopExec!"=="true" (
					set /a pid%%a_linesThisTick+=1,pid%%a_execLine+=1
					for %%b in (!pid%%a_execLine!) do (
						set exec=!pid%%a_l%%b!
						rem move this later
						if "!pid%%a_skipUntilParenthesis!"=="true" (
							for /f "tokens=1 delims= " %%c in ("!exec!") do if "%%c"==")" (
								set pid%%a_skipUntilParenthesis=false
								set /a pid%%a_supc_l!pid%%a_ifStartLine!=pid%%a_execLine
							)

						) else (
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
									if defined pid%%a_oc_l%%b (
										set /a rtVar_!variableName!!pid%%a_oc_l%%b!=pid%%a_on_l%%b

									) else if NOT defined pid%%a_cm_l%%b (
										set /a currentPid=%%a,currentLine=%%b
										call newEngine\scripts\variableMathOperationCache.bat
									)
									for %%g in (!variableName!) do (
										if NOT defined number (
											set /a offset=variableLength+variableOffset
											for %%h in (!offset!) do (
												set exec=!exec:~0,%%d!!rtVar_%%g!!exec:~%%h!
											)
										) else set exec=!exec:~0,%%d!!rtVar_%%g!
									)
									set checkExec=!exec:$=hasVariable!
									if NOT "!exec!"=="!checkExec!" (
										call newEngine\scripts\scriptManager.bat kill %%a
										set stopExec=true
									)
								)
							)

							for /f "tokens=1 delims= " %%c in ("!exec!") do (
								if "%%c"=="waitForEffects" (
									set stopExec=true
									if defined screenEffect set /a pid%%a_execLine-=1

								) else if "%%c"=="endFrame" (
									set foundEndFrame=true
									set stopExec=true

								) else if "%%c"=="checkCollision" (
									for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
										for /f "tokens=1-2 delims=:" %%g in ("%%e") do (
											if "%%g"=="tileGroup" (
												for /l %%i in (1,1,!objectCount!) do if "!obj%%i_name!"=="%%d" (
													if "!obj%%i_collisionList!"=="!obj%%i_collisionList:-%%h-=§!" set pid%%a_skipUntilParenthesis=true
												)
											)
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

										) else if "%%e"=="VX=" (
											set ifSuccess=true
											if NOT "!rtVar_%%d!"=="!rtVar_%%f!" set pid%%a_skipUntilParenthesis=false
										)
									)
									if "!pid%%a_skipUntilParenthesis!"=="true" if defined pid%%a_supc_l!pid%%a_execLine! (
										set pid%%a_skipUntilParenthesis=false
										set /a pid%%a_execLine=pid%%a_supc_l!pid%%a_execLine!
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
										for /f "tokens=1-2 delims==" %%g in ("%%e") do set obj%%f_%%g=%%h
									)

								) else if exist newEngine\scripts\ic-%%c.bat (
									set /a currentPid=%%a
									title !time!
									call newEngine\scripts\ic-%%c.bat
								)
							)
						)
					)
				)
				if NOT "!foundEndFrame!"=="true" (
					set foundEndFrame=
					set /a pid%%a_linesThisTick=maxLinesPerFrame
				)
				if !pid%%a_execLine! GEQ !pid%%a_lineCount! call newEngine\scripts\scriptManager.bat kill %%a
			)
		)

		if "%%z"=="!ticksToExecute!" for /l %%a in (1,1,!objectCount!) do (
			if "!obj%%a_type!"=="button" (
				set obj%%a_prevHover=!obj%%a_hover!
				set obj%%a_hover=false
				if !fixedMouseXpos! GEQ !obj%%a_xpos! if !fixedMouseXpos! LEQ !obj%%a_endXpos! if !fixedMouseYpos! GEQ !obj%%a_ypos! if !fixedMouseYpos! LEQ !obj%%a_endYpos! set obj%%a_hover=true
				if NOT "!obj%%a_hover!.!staticButtons!"=="!obj%%a_prevHover!.true" (
					set /a renderLine=0
					for /l %%b in (!obj%%a_ypos!,1,!obj%%a_endYpos!) do if defined d%%b (
						set /a renderLine+=1,offset1=obj%%a_xpos-1,offset2=offset1+obj%%a_dLength
						for /f "tokens=1-3 delims= " %%c in ("!offset1! !renderLine! !offset2!") do (
							set new=!obj%%a_dl%%d!
							if "!obj%%a_hover!"=="true" (
								set new=!new: =E!
								set new=!new:█= !
								set new=!new:E=█!
							)
							set d%%b=!d%%b:~0,%%c!!new!!d%%b:~%%e!
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
					for /l %%b in (!num2!,1,!num3!) do if defined d%%b (
						set /a num1+=1,num2=obj%%a_xpos+2,num3=num2+obj%%a_dLength-4
						for /f "tokens=1-3 delims= " %%c in ("!num2! !num1! !num3!") do set d%%b=!d%%b:~0,%%c!!obj%%a_dl%%d:~2,-2!!d%%b:~%%e!
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

				set /a num1=obj%%a_ypos+obj%%a_height-1,num2=obj%%a_xpos-1,num3=obj%%a_width,num4=88-num2-num3,num4=88-num4,num5=obj%%a_viewXpos-1
				for /f "tokens=1-4 delims= " %%c in ("!num2! !num3! !num4! !num5!") do for /l %%b in (!obj%%a_ypos!,1,!num1!) do (
					set /a num6=%%b+obj%%a_viewYpos-1
					for %%g in (!num6!) do set d%%b=!d%%b:~0,%%c!!lrb_l%%g:~%%f,%%d!!d%%b:~%%e!
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

				if "!obj%%a_playerController!"=="topDown" if "%%z"=="1" (
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
					if defined collisionType set obj%%a_collisionList=-!collisionType!!obj%%a_collisionList!
					if "!collisionType!"=="solid" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX-1-ccSpeedX,ccDistY=obj%%a_ypos+1-ccDistY-ccSpeedY
						if !ccDistX! GTR !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos+=1,obj%%a_speedX=0
						)
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
					if defined collisionType set obj%%a_collisionList=-!collisionType!!obj%%a_collisionList!
					if "!collisionType!"=="solid" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX+1-obj%%a_speedX,ccDistX=-6-ccDistX,ccDistY=obj%%a_ypos-ccDistY+1-obj%%a_speedY-2
						if !ccDistX! GEQ !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos-=7,obj%%a_speedX=0
						)
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
					if defined collisionType set obj%%a_collisionList=-!collisionType!!obj%%a_collisionList!
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
					if defined collisionType set obj%%a_collisionList=-!collisionType!!obj%%a_collisionList!
					if "!collisionType!"=="solid" (
						set /a ccSpeedX=obj%%a_speedX/8,ccSpeedY=obj%%a_speedY/6,ccDistX=ccXpos*8,ccDistY=ccYpos*8,ccDistX=obj%%a_xpos-ccDistX+1-obj%%a_speedX,ccDistX=-6-ccDistX,ccDistY=obj%%a_ypos-ccDistY-ccSpeedY,ccDistY=-6-ccDistY
						if !ccDistX! GEQ !ccDistY! (
							set /a obj%%a_xpos=ccXpos*8,obj%%a_xpos-=7,obj%%a_speedX=0
						)
						if !ccDistX! LSS !ccDistY! (
							set /a obj%%a_ypos=ccYpos*8,obj%%a_ypos-=7,obj%%a_speedY=0
						)
					)
				)

				if "%%z"=="!ticksToExecute!" (
					set /a num1=-1
					for /l %%b in (1,1,!objectCount!) do if "!obj%%b_name!"=="!obj%%a_renderInto!" if "!obj%%b_type!"=="viewport" set /a num1=%%b
					if NOT "!num1!"=="-1" (
						set /a num2=obj%%a_xpos-obj!num1!_viewXpos+1,num3=obj%%a_ypos-obj!num1!_viewYpos+1,num4=num3+7,num5=0,num6=num2-1,num7=num6+8
						for /f "tokens=1-3 delims= " %%c in ("!num1! !num6! !num7!") do for /l %%f in (!num3!,1,!num4!) do (
							set /a num5+=1,num8=num5*8-8,num8=obj!num1!_height-num8
							for /f "tokens=1-2 delims= " %%g in ("!num5! !num8!") do (
								set d%%f=!d%%f:~0,%%d!!obj%%a_spriteContent:~%%h,8!!d%%f:~%%e!
							)
						)
					)
				)
			)
		)
	)
)
goto :main