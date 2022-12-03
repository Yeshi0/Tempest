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
					set /a screenColor=screenEffectTargetColor,screenEffectStartingColor=screenColor
					set screenEffect=
				)
			)
			if !screenEffectStartingColor! LSS !screenEffectTargetColor! (
				set /a screenColor+=diffPerTick
				if !screenColor! GEQ !screenEffectTargetColor! (
					set /a screenColor=screenEffectTargetColor,screenEffectStartingColor=screenColor
					set screenEffect=
				)
			)
			if "!screenEffectStartingColor!"=="!screenEffectTargetColor!" (
				set screenEffect=
			)
		)
	)
)
exit /b 0