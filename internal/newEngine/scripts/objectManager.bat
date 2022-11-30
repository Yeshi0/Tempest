set loadFrom=

if "%1"=="killAll" (
	for /l %%a in (1,1,!objectCount!) do (
		if defined obj%%a_type (
			set /a objectCount-=1
			for /f "tokens=1 delims==" %%b in ('set obj%%a_') do set %%b=
		)
	)
)

if "%1"=="kill" (
	if NOT defined obj%2_type exit /b 1
	for /f "tokens=1 delims==" %%a in ('set obj%2_ 2^>nul') do set %%a=
	if NOT "%3"=="noDefragment" call :defragmentOids
	set /a objectCount-=1
)

if "%1"=="loadObject" (
	set checkObjectPath=%2
	call newEngine\scripts\checkString.bat "!checkObjectPath!"
	if NOT "!stringHasLetters!.!stringHasSpaces!.!stringIsSafe!"=="true.false.true" exit /b 1
	set loadFrom=newEngineProject\%2
	if NOT exist newEngineProject\!checkObjectPath! set loadFrom="%*"
	if NOT defined loadFrom exit /b 1

	set /a newId=objectCount+1
	for /f "delims=" %%a in (!loadFrom!) do (
		call newEngine\scripts\expandVariable.bat "%%a"
		if NOT "!errorLevel!"=="0" exit /b 1
		for /f "tokens=2-11 delims=;" %%b in ("!expand!") do (
			if NOT "%%k"=="" exit /b 1

			set /a objectCount+=1
			set /a newProperty_xpos=1
			set /a newProperty_ypos=1
			set /a newProperty_viewXpos=1
			set /a newProperty_viewYpos=1
			set /a newProperty_endXpos=1
			set /a newProperty_endYpos=1
			set /a newProperty_speedX=1
			set /a newProperty_speedY=1
			set /a newProperty_width=1
			set /a newProperty_height=1
			set newProperty_type=dummy
			set newProperty_alignX=middle
			set newProperty_alignY=middle
			set newProperty_moveTo=bottom
			set newProperty_textLabel=NO_LABEL_GIVEN
			set newProperty_onClick=exitGame
			set newProperty_sprite=placeholder.spr
			set newProperty_hovering=false
			set newProperty_focusObject=none
			set newProperty_renderInto=none

			set obj!newId!_path=%2
			set obj!newId!_name=%~n2

			set parseProperty1=%%b
			set parseProperty2=%%c
			set parseProperty3=%%d
			set parseProperty4=%%e
			set parseProperty5=%%f
			set parseProperty6=%%g
			set parseProperty7=%%h
			set parseProperty8=%%i
			set parseProperty9=%%j

			for /l %%l in (1,1,9) do (
				if "!parseProperty%%l:~0,1!"==" " set parseProperty%%l=!parseProperty%%l:~1!
				if "!parseProperty%%l:~0,1!"==" " (
					call newEngine\scripts\objectManager.bat kill !newId!
					exit /b 1
				)
				if "!parseProperty%%l:~-1,1!"==" " set parseProperty%%l=!parseProperty%%l:~0,-1!
				if "!parseProperty%%l:~-1,1!"==" " (
					call newEngine\scripts\objectManager.bat kill !newId!
					exit /b 1
				)
				for /f "tokens=1-3 delims==" %%m in ("!parseProperty%%l!") do (
					if "%%n"=="" (
						exit /b 1

					) else (
						if NOT "%%o"=="" (
							exit /b 1

						) else (
							for %%p in (
								newProperty_xpos
								newProperty_ypos
								newProperty_viewXpos
								newProperty_viewYpos
								newProperty_endXpos
								newProperty_endYpos
								newProperty_speedX
								newProperty_speedY
								newProperty_width
								newProperty_height
								newProperty_type
								newProperty_alignX
								newProperty_alignY
								newProperty_moveTo
								newProperty_textLabel
								newProperty_onClick
								newProperty_sprite
								newProperty_hovering
								newProperty_focusObject
								newProperty_renderInto
							) do if "newProperty_%%m"=="%%p" (
								set obj!newId!_%%m=%%n
								set newProperty_%%m=%%n
							)
						)
					)
				)
			)

			set useButtonProperties=false
			if "!newProperty_type!"=="button" set useButtonProperties=true
			if "!newProperty_type!"=="text" set useButtonProperties=true
			if "!useButtonProperties!"=="true" (
				set /a newXpos=newProperty_xpos
				set /a newYpos=newProperty_ypos

				call newEngine\scripts\getStringLength.bat "!newProperty_textLabel!" 20
				set /a labelLength=stringLength
				set /a textWidth=stringLength*6
				if !stringLength! GEQ 15 (
					call newEngine\scripts\objectManager.bat kill !newId!
					exit /b 1
				)

				if "!newProperty_alignX!"=="left" set /a newXpos=2
				if "!newProperty_alignX!"=="middle" (
					set /a halfWidth=textWidth/2
					set /a newXpos=88-halfWidth
					set /a newXpos-=45
				)
				if "!newProperty_alignX!"=="right" set /a newXpos=88-textWidth-5
				if "!newProperty_alignY!"=="bottom" set /a newYpos=2
				if "!newProperty_alignY!"=="middle" set /a newYpos=35
				if "!newProperty_alignY!"=="top" set /a newYpos=47

				set /a newEndXpos=newXpos+textWidth+2
				set /a newEndYpos=newYpos+8

				call newEngine\scripts\preventObjectOverlap.bat !newId! button

				set /a obj!newId!_xpos=newXpos
				set /a obj!newId!_ypos=newYpos
				set /a obj!newId!_endXpos=newEndXpos
				set /a obj!newId!_endYpos=newEndYpos

				set line=████████████████████████████████████████████████████████████████████████████████████████EOL
				set emptyLine=                                                                                        EOL
				set /a lineLength=textWidth+3
				set /a obj!newId!_dLength=lineLength
				for %%l in (!lineLength!) do (
					set line=!line:~0,%%l!
					set emptyLine=!emptyLine:~0,%%l!
				)

				if "!newProperty_type!"=="button" (
					for %%l in (1 9) do set obj!newId!_dl%%l=!line!
					for /l %%l in (2,1,8) do set obj!newId!_dl%%l=█!emptyLine:~2!█
				)
				if "!newProperty_type!"=="text" (
					for /l %%l in (1,1,9) do set obj!newId!_dl%%l=!emptyLine!
				)

				if NOT "!newProperty_textLabel!"=="NO_LABEL_GIVEN" (
					set /a offset1=-4
					for /l %%l in (0,1,!labelLength!) do if NOT "!newProperty_textLabel:~%%l,1!"=="" (
						set /a offset1+=6
						set /a offset2=offset1+5
						set fontFilePath=newEngine\fonts\ne-55-c\font_§.spr
						set shitWorkaround=!newProperty_textLabel:~%%l,1!
						if NOT "!shitWorkaround!"==" " (
							if exist newEngine\fonts\ne-55-c\font_!shitWorkaround!.spr set fontFilePath=newEngine\fonts\ne-55-c\font_!shitWorkaround!.spr
							if NOT exist !fontFilePath! exit /b 1

							set /a currentLine=8
							for %%m in (!newId!) do for /f "delims=" %%n in (!fontFilePath!) do (
								set renderCurrent=%%n
								set renderCurrent=!renderCurrent:~1,-2!
								set /a currentLine-=1
								for /f "tokens=1-4 delims=§" %%o in ("!offset1!§!offset2!§!renderCurrent!§!currentLine!") do set obj!newId!_dl%%r=!obj%%m_dl%%r:~0,%%o!%%q!obj%%m_dl%%r:~%%p!
							)
						)
					)
				)
			)
			if "!newProperty_type!"=="viewport" (
				set /a newXpos=newProperty_xpos
				set /a newYpos=newProperty_ypos
				set /a newEndXpos=newXpos+newProperty_width
				set /a newEndYpos=newYpos+newProperty_height-1
				call newEngine\scripts\preventObjectOverlap.bat !newId! viewport
				set /a obj!newId!_xpos=newXpos
				set /a obj!newId!_ypos=newYpos
				set /a obj!newId!_viewXpos=newProperty_viewXpos
				set /a obj!newId!_viewYpos=newProperty_viewYpos
				set /a obj!newId!_width=newProperty_width
				set /a obj!newId!_height=newProperty_height
				set /a obj!newId!_endXpos=newEndXpos
				set /a obj!newId!_endYpos=newEndYpos
				set obj!newId!_focusObject=!newProperty_focusObject!
				for /l %%m in (1,1,56) do set obj!newid!_vpb_l%%m=                                                                                        
			)
			if "!newProperty_type!"=="dummy" (
				set /a obj!newId!_xpos=newProperty_xpos
				set /a obj!newId!_ypos=newProperty_ypos
				set obj!newId!_renderInto=!newProperty_renderInto!
				set /a obj!newId!_speedX=newProperty_speedX
				set /a obj!newId!_speedY=newProperty_speedY
				set obj!newId!_sprite=!newProperty_sprite!
				call newEngine\scripts\loadSprite.bat "!newProperty_sprite!" temp
				set obj!newId!_spriteContent=!tempSpriteContent!
				set tempSpriteContent=
			)
		)
	)
)
exit /b 0

:defragmentOids
for /l %%a in (1,1,!objectCount!) do if NOT defined obj%%a_type (
	set /a num1=-1
	for /l %%b in (%%a,1,!objectCount!) do if "!num1!"=="-1" if defined obj%%b_type set /a num1=%%b
	if NOT "!num1!"=="-1" (
		for /f "tokens=1* delims==" %%c in ('set obj!num1!_') do for %%e in (!num1!) do (
			for /f "tokens=2 delims=_" %%f in ("%%c") do set string1=%%f
			set obj%%a_!string1!=%%d
		)
		set /a num2=objectCount
		call newEngine\scripts\objectManager.bat kill !num1! noDefragment
		set /a objectCount=num2
		call :defragmentOids
	)
)
exit /b 0