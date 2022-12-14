for /f "tokens=2-6 delims= " %%d in ("!exec!") do (
	set /a objId=-1
	for /l %%h in (1,1,!objectCount!) do if "%%e"=="!obj%%h_name!" set /a objId=%%h
	if NOT "!objId!"=="-1" (
		if "%%d"=="applyLogic" (
			if "%%f"=="applyPlayerController" (
				if "%%g"=="sideScroller" (
					set obj!objId!_playerController=sideScroller
					set obj!objId!_useCollisions=true
					set /a obj!objId!_playerController_speedX=0
					set /a obj!objId!_playerController_speedY=0
					set obj!objId!_playerController_grounded=true
				)
				if "%%g"=="topDown" (
					set obj!objId!_playerController=topDown
					set obj!objId!_useCollisions=true
				)
				if "%%g"=="none" (
					set obj!objId!_playerController=none
					set obj!objId!_useCollisions=false
					set /a obj!objId!_playerController_speedX=0
					set /a obj!objId!_playerController_speedY=0
				)
			)
			if "%%f"=="applyKeybinds" (
				for /f "tokens=1-5 delims=:" %%i in ("%%g") do (
					if defined kcl_%%i set obj!objId!_keyUp=!kcl_%%i!
					if defined kcl_%%j set obj!objId!_keyDown=!kcl_%%j!
					if defined kcl_%%k set obj!objId!_keyLeft=!kcl_%%k!
					if defined kcl_%%l set obj!objId!_keyRight=!kcl_%%l!
					if defined kcl_%%m set obj!objId!_keyJump=!kcl_%%m!
				)
			)
			if "%%f"=="applyCollision" (
				set obj%%a_cg_%%g=%%h
			)
		)
	)
)
exit /b 0