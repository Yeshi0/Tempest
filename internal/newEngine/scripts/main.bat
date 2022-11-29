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

		set /a fpsFinal=fpsFrames
		set /a fpsFrames=0

		set /a tpsFinal=tpsTicks
		set /a tpsTicks=0

		if "!debugTitlebar!"=="0" (
			title !title! ^| Press {TAB} to toggle debug.

		) else (
			set dispKeyPressed=0
			if defined keyPressed set dispKeyPressed=!keyPressed!
			title !persistent_engineRuntimeVersion! RT ^| FPS: !fpsFinal!/!maxFps! ^(!tpsFinal!/!maxTps!^) ^| OBJ: !objectCount! ^| YSS: !scriptCount! ^| Press {BACKSPACE} to show dev console.
		)
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

	if !skipDisp! GEQ 1 (
		if NOT "!screenColor!"=="0" set /a skipDisp-=1

	) else (
		if !dispTimer! GEQ !csPerFrame! (
			set /a dispTimer-=csPerFrame
			if !dispTimer! GEQ !csPerFrame! set /a dispTimer=0
			if "!displayMode!"=="dynamicHalfRenderMode" (
				set halfRender=false
				set /a enableDHRM=csPerFrame+1
				if !globalTdiff! GTR !enableDHRM! set halfRender=true
			)
			if "!halfRender!"=="false" (
				set /a fpsFrames+=1
				<nul set /p=[1;1H[48;2;!screenColor!;!screenColor!;!screenColor!m
				set renderLines=56,-1,1

			) else (
				set /a halfToRender+=1
				if "!halfToRender!"=="2" set /a halfToRender=0
				if "!halfToRender!"=="0" (
					set /a fpsFrames+=1
					<nul set /p=[29;1H[48;2;!screenColor!;!screenColor!;!screenColor!m
					set renderLines=28,-1,1

				) else (
					<nul set /p=[1;1H[48;2;!screenColor!;!screenColor!;!screenColor!m
					set renderLines=56,-1,29
				)
			)

			for /l %%a in (!renderLines!) do (
				set d=!d%%a:~0,88!
				echo.!d!
			)
		)
	)

	if !tpsTimer! GEQ 50 set /a tpsTimer=0
	set /a ticksToExecute=tpsTimer/!csPerTick!
	if !ticksToExecute! GEQ 1 for /l %%z in (1,1,!ticksToExecute!) do (
		if defined screenEffect (
			if NOT defined screenEffectLength (
				set screenEffect=

			) else (
				if NOT "!screenEffectLength!"=="!prevScreenEffectLength!" (
					if defined sll_!screenEffectLength! set /a diffPerTick=sll_!screenEffectLength!
					set prevScreenEffectLength=!screenEffectLength!
				)

				set effectExists=false
				set checkForInvalidChars=!screenEffect!
				for /l %%b in (0,1,9) do set checkForInvalidChars=!checkForInvalidChars:%%b=§!
				set checkForInvalidChars=!checkForInvalidChars:§=!
				if "!checkForInvalidChars!"=="" (
					set effectExists=true
					set /a screenEffectTargetColor=screenEffect

				) else set screenEffect=

				if "!effectExists!"=="true" (
					if !screenEffectStartingColor! GTR !screenEffectTargetColor! (
						set /a screenColor-=diffPerTick
						if !screenColor! LEQ !screenEffectTargetColor! (
							set /a screenColor=screenEffectTargetColor
							set screenEffect=
							set /a screenEffectStartingColor=screenColor
						)
					)
					if !screenEffectStartingColor! LSS !screenEffectTargetColor! (
						set /a screenColor+=diffPerTick
						if !screenColor! GEQ !screenEffectTargetColor! (
							set /a screenColor=screenEffectTargetColor
							set screenEffect=
							set /a screenEffectStartingColor=screenColor
						)
					)
					if "!screenEffectStartingColor!"=="!screenEffectTargetColor!" (
						set screenEffect=
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
				for /l %%z in (1,1,!pid%%a_lineCount!) do if NOT "!stopExec!"=="true" (
					set /a pid%%a_execLine+=1
					for %%b in (!pid%%a_execLine!) do (
						set exec=!pid%%a_l%%b!
						if "!pid%%a_skipUntilParenthesis!"=="true" (
							for /f "tokens=1 delims= " %%c in ("!exec!") do if "%%c"==")" (
								set pid%%a_skipUntilParenthesis=false
								set /a pid%%a_supc_l!pid%%a_ifStartLine!=pid%%a_execLine
							)

						) else (
							if NOT "!exec!"=="!exec:$=hasVariable!" (
								if defined pid%%a_vo_l!pid%%a_execLine! (
									set /a variableOffset=pid%%a_vo_l%%b
									set /a variableLength=pid%%a_vl_l%%b
									set variableName=!pid%%a_vn_l%%b!

								) else (
									set /a currentPid=%%a
									set /a currentLine=%%b
									call newEngine\scripts\variableExpansionCache.bat
								)
								set /a variableNameEnd=variableLength+variableOffset+1
								for /f "tokens=1-3 delims= " %%d in ("!variableOffset! !variableLength! !variableNameEnd!") do (
									if defined pid%%a_oc_l%%b (
										set /a rtVar_!variableName!!pid%%a_oc_l%%b!=pid%%a_on_l%%b

									) else if NOT defined pid%%a_cm_l%%b (
										set /a currentPid=%%a
										set /a currentLine=%%b
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

								) else if "%%c"=="endFrame" (
									set stopExec=true

								) else if "%%c"=="goto" (
									if defined pid%%a_gotoCache_l!pid%%a_execLine! (
										set /a gotoLine=pid%%a_gotoCache_l!pid%%a_execLine!

									) else call newEngine\scripts\gotoCache.bat
									if NOT "!gotoLine!"=="-1" (
										set pid%%a_skipUntilParenthesis=false
										set /a pid%%a_gotoReturn=pid%%a_execLine
										set /a pid%%a_execLine=gotoLine
										set /a pid%%a_sleepTicks=1
									)

								) else if "%%c"=="gotoReturn" (
									set /a pid%%a_execLine=pid%%a_gotoReturn

								) else if "%%c"=="loadObject" (
									for /f "tokens=2 delims= " %%d in ("!exec!") do call newEngine\scripts\objectManager.bat loadObject scenes\!currentScene!\objects\%%d

								) else if "%%c"=="loadGlobalObject" (
									for /f "tokens=2 delims= " %%d in ("!exec!") do call newEngine\scripts\objectManager.bat loadObject objects\%%d

								) else if "%%c"=="modifyObjectProperty" (
									for /f "tokens=2-3 delims= " %%d in ("!exec!") do for /l %%f in (1,1,!objectCount!) do if "%%d"=="!obj%%f_name!" (
										for /f "tokens=1-2 delims==" %%g in ("%%e") do set obj%%f_%%g=%%h
									)

								) else if "%%c"=="exitGame" (
									exit /b 0

								) else if exist newEngine\scripts\ic-%%c.bat (
									set /a currentPid=%%a
									call newEngine\scripts\ic-%%c.bat
								)
							)
						)
					)
				)
				if !pid%%a_execLine! GEQ !pid%%a_lineCount! call newEngine\scripts\scriptManager.bat kill %%a
			)
		)

		for /l %%a in (1,1,!objectCount!) do (
			if defined obj%%a_type (
				if "!obj%%a_type!"=="button" (
					if "%%z"=="1" (
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
								set /a prevButtonMouseClick=0
								set /a mouseClick=0
								set /a scriptCount+=1
								set /a pid!scriptCount!_lineCount=1
								set /a pid!scriptCount!_execLine=0
								set pid!scriptCount!_l1=!obj%%a_onClick!
								set pid!scriptCount!_path=TEMP
							)
							set /a prevButtonMouseClick=mouseClick
						)
					)

				) else if "!obj%%a_type!"=="text" (
					if "%%z"=="1" (
						if NOT "!obj%%a_textLabel!.!staticText!"=="!obj%%a_prevTextLabel!.true" (
							set obj%%a_prevTextLabel=!obj%%a_textLabel!
							set /a num1=0
							for /l %%b in (!obj%%a_ypos!,1,!obj%%a_endYpos!) do if defined d%%b (
								set /a num1+=1,num2=obj%%a_xpos-1,num3=num2+obj%%a_dLength
								for /f "tokens=1-3 delims= " %%c in ("!num2! !num1! !num3!") do set d%%b=!d%%b:~0,%%c!!obj%%a_dl%%d!!d%%b:~%%e!
							)
						)
					)

				) else if "!obj%%a_type!"=="dummy" (
					if "!obj%%a_playerController!"=="sideScroller" (
						if NOT "!keys!"=="" (
							for /f "tokens=1-5 delims= " %%b in ("!obj%%a_keyUp! !obj%%a_keyDown! !obj%%a_keyLeft! !obj%%a_keyRight! !obj%%a_keyJump!") do (
								if NOT "!keys:-%%d-=§!"=="!keys!" if !obj%%a_speedX! GTR -24 (
									set /a obj%%a_speedX-=2
									if !obj%%a_speedX! GTR 0 if !obj%%a_speedX! LEQ 6 set /a obj%%a_speedX-=4
								)
								if NOT "!keys:-%%e-=§!"=="!keys!" if !obj%%a_speedX! LSS 24 (
									set /a obj%%a_speedX+=2
									if !obj%%a_speedX! LSS 0 if !obj%%a_speedX! GEQ -6 set /a obj%%a_speedX+=4
								)

								if "!obj%%a_collideSide!"=="bottom" set obj%%a_grounded=true
								if NOT "!keys:-%%f-=§!"=="!keys!" if "!obj%%a_grounded!"=="true" (
									set obj%%a_grounded=false
									set /a obj%%a_speedY=36
								)
							)
						)
						set /a obj%%a_xpos+=obj%%a_speedX/8
						if !obj%%a_speedY! GTR -40 set /a obj%%a_speedY-=4
						set /a obj%%a_ypos+=obj%%a_speedY/6

						if "!obj%%a_grounded!"=="true" (
							set string1=true
							if defined keys set string1=false
							if NOT "!keys:-%%d-=§!!keys:-%%e-=§!"=="!keys!!keyS!" set string1=true
							if "!string1!"=="true" (
								if !obj%%a_speedX! LEQ -1 set /a obj%%a_speedX+=1
								if !obj%%a_speedX! GEQ 1 set /a obj%%a_speedX-=1
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
						if !obj%%a_ypos! LEQ 17 (
							set /a obj%%a_ypos=17
							set /a obj%%a_speedY=0
							set obj%%a_grounded=true
						)
					)

					if "%%z"=="!ticksToExecute!" (
						set /a num1=-1
						for /l %%b in (1,1,!objectCount!) do if "!obj%%b_name!"=="!obj%%a_renderInto!" if "!obj%%b_type!"=="viewport" set /a num1=%%b
						if NOT "!num1!"=="-1" (
							set /a num2=obj%%a_xpos-obj!num1!_viewXpos+1
							set /a num3=obj%%a_ypos-obj!num1!_viewYpos+1
							set /a num4=num3+7
							set /a num5=0
							for /l %%b in (!num3!,1,!num4!) do (
								set /a num5+=1
								set /a num6=num2-1
								set /a num7=num6+8
								set /a num8=num5*8-8
								set /a num8=56-num8
								for /f "tokens=1-5 delims= " %%c in ("!num6! !num5! !num7! !num1! !num8!") do (
									set d%%b=!d%%b:~0,%%c!!obj%%a_spriteContent:~%%g,8!!d%%b:~%%e!
								)
							)
						)
					)

				) else if "!obj%%a_type!"=="viewport" (
					if "%%z"=="!ticksToExecute!" (
						set /a num1=-1
						for /l %%b in (1,1,!objectCount!) do if "!obj%%b_name!"=="!obj%%a_focusObject!" set /a num1=%%b
						if NOT "!num1!"=="-1" (
							set /a num2=obj%%a_width/2
							set /a obj%%a_viewXpos=obj!num1!_xpos-num2+4
							set /a num2=obj%%a_height/2
							set /a obj%%a_viewYpos=obj!num1!_ypos-num2+4
							if !obj%%a_viewXpos! LEQ 1 set /a obj%%a_viewXpos=1
							if !obj%%a_viewYpos! LEQ 1 set /a obj%%a_viewYpos=1
						)

						set /a num1=obj%%a_ypos+obj%%a_height-1
						set /a num2=obj%%a_xpos-1
						set /a num3=obj%%a_width
						set /a num4=88-num2-num3
						set /a num4=88-num4
						set /a num5=obj%%a_viewXpos-1
						for /f "tokens=1-4 delims= " %%c in ("!num2! !num3! !num4! !num5!") do for /l %%b in (!obj%%a_ypos!,1,!num1!) do (
							set /a num6=%%b+obj%%a_viewYpos-1
							for %%g in (!num6!) do set d%%b=!d%%b:~0,%%c!!lrb_l%%g:~%%f,%%d!!d%%b:~%%e!
						)
					)
				)
			)
		)
	)
)
goto :main