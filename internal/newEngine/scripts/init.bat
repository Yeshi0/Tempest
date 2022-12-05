title Initializing runtime...
set persistent_engineRuntimeVersion=NE_1.0.0-r1
call newEngine\scripts\forceMode.bat

<nul set /p=[1;1H[48;2;0;0;0m
for /l %%a in (1,1,56) do echo.                                                                                        
<nul set /p=[37m
echo Injecting ConsoleUtils DLL...
newEngine\exe\inject.exe newEngine\exe\consoleUtils.dll

call newEngine\scripts\forceMode.bat
<nul set /p=[1;1H[48;2;0;0;0m
for /l %%a in (1,1,56) do echo.                                                                                        
<nul set /p=[37m

for %%a in (
	unload.bat:Unloading...
	miscInit.bat:Setting_miscellaneous_values...
	readWriteTest.bat:Performing_read_write_test...
	discordRpcDefault.bat:Setting_default_values_for_Discord_RPC...
	loadProjectConfig.bat:Loading_project_configuration...
	cleanTemp.bat:Cleaning_temp...
	createFolders.bat:Creating_folders...
	cacheScriptSafety.bat:Creating_script_safety_cache...
	waitForSafetyCache.bat:Waiting_for_script_safety_cache...
	setKeycodeLookupTable.bat:Setting_keycode_lookup_table...
	setScreenEffectLengthLookupTable.bat:Setting_screen_effect_length_lookup_table...
	switchScene.bat_defaultScene:Loading_default_scene...
	garbageCollector.bat:Running_garbage_collector...
) do (
	set initCurrent=%%a
	set initCurrent=!initCurrent:_= !
	for /f "tokens=1-2 delims=:" %%b in ("!initCurrent!") do (
		echo.[54;3H                                                                                        [54;3H%%c
		set skipInit=false
		if "%%b"=="discordRpcDefault.dll" if NOT "!useDiscordRPC!"=="true" set skipInit=true
		if "!skipInit!"=="false" (
			call newEngine\scripts\%%b
			call newEngine\scripts\wait.bat 10
		) else (
			echo.[54;3H                                                                                        [54;3H%%c - Disabled, skipping...
			call newEngine\scripts\wait.bat 50
		)
	)
)

for %%a in (
	getInput.dll:Injecting_GetInput_DLL...
	discordRPC.dll:Injecting_DiscordRPC_DLL...
) do (
	set initCurrent=%%a
	set initCurrent=!initCurrent:_= !
	for /f "tokens=1-2 delims=:" %%b in ("!initCurrent!") do (
		echo.[54;3H                                                                                        [54;3H%%c
		set skipInject=false
		if "%%b"=="discordRPC.dll" if NOT "!useDiscordRPC!"=="true" set skipInject=true
		if "!skipInject!"=="false" (
			newEngine\exe\inject.exe newEngine\exe\%%b
			call newEngine\scripts\wait.bat 10
		) else (
			echo.[54;3H                                                                                        [54;3H%%c - Disabled, skipping...
			call newEngine\scripts\wait.bat 50
		)
	)
)

rem this should always be executed last
echo.[54;3H                                                                                        [54;3HInitializing FPS/TPS values...
call newEngine\scripts\initFpsTps.bat

echo.[54;3H                                                                                        [37m[54;3HPerforming initial tick...[30m
exit /b 0