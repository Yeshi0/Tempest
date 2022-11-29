if "%2"=="button" goto :buttons
if "%2"=="viewport" goto :viewports
exit /b 0

:buttons
for /l %%a in (1,1,!objectCount!) do if NOT "%1"=="%%a" if defined obj%%a_xpos (
	set dontOverlap=false
	if "!obj%%a_type!"=="button" set dontOverlap=true
	if "!obj%%a_type!"=="text" set dontOverlap=true
	if "!dontOverlap!"=="true" (
		set overlapX=false
		set overlapY=false
		if !newXpos! GEQ !obj%%a_xpos! if !newXpos! LEQ !obj%%a_endXpos! set overlapX=true
		if !newXpos! LEQ !obj%%a_xpos! if !newEndXpos! GEQ !obj%%a_xpos! set overlapX=true

		if "!overlapX!"=="true" (
			if !newYpos! GEQ !obj%%a_ypos! if !newYpos! LEQ !obj%%a_endYpos! set overlapY=true
			if !newYpos! LEQ !obj%%a_ypos! if !newEndYpos! GEQ !obj%%a_ypos! set overlapY=true

			if "!overlapY!"=="true" (
				if "!newProperty_moveTo!"=="left" set /a newXpos-=2
				if "!newProperty_moveTo!"=="right" set /a newXpos+=2
				if "!newProperty_moveTo!"=="bottom" set /a newYpos-=5
				if "!newProperty_moveTo!"=="top" set /a newYpos+=5
				set /a newEndXpos=newXpos+textWidth+2
				set /a newEndYpos=newYpos+8
				if !newEndXpos! GEQ 88 (
					set /a newXpos=2
					set /a newYpos-=5
					set /a newEndXpos=newXpos+textWidth+2
					set /a newEndYpos=newYpos+8
				)
				goto :buttons
			)
		)
	)
)
exit /b 0

:viewports
for /l %%a in (1,1,!objectCount!) do if NOT "%1"=="%%a" if defined obj%%a_xpos (
	set dontOverlap=false
	if "!obj%%a_type!"=="viewport" set dontOverlap=true
	if "!dontOverlap!"=="true" (
		set overlapX=false
		set overlapY=false
		if !newXpos! GEQ !obj%%a_xpos! if !newXpos! LEQ !obj%%a_endXpos! set overlapX=true
		if !newXpos! LEQ !obj%%a_xpos! if !newEndXpos! GEQ !obj%%a_xpos! set overlapX=true

		if "!overlapX!"=="true" (
			if !newYpos! GEQ !obj%%a_ypos! if !newYpos! LEQ !obj%%a_endYpos! set overlapY=true
			if !newYpos! LEQ !obj%%a_ypos! if !newEndYpos! GEQ !obj%%a_ypos! set overlapY=true

			if "!overlapY!"=="true" (
				if "!newProperty_moveTo!"=="left" (
					set /a newXpos-=1
					set /a newEndXpos-=1
				)
				if "!newProperty_moveTo!"=="right" (
					set /a newXpos+=1
					set /a newEndXpos+=1
				)
				if "!newProperty_moveTo!"=="bottom" (
					set /a newYpos-=1
					set /a newEndYpos-=1
				)
				if "!newProperty_moveTo!"=="top" (
					set /a newYpos+=1
					set /a newEndYpos+=1
				)
				goto :viewports
			)
		)
	)
)
exit /b 0