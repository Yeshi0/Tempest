title Initializing editor...
call scripts\forceMode.bat

<nul set /p=[1;1H[48;2;0;0;0m
for /l %%a in (1,1,59) do echo.                                                                                                                                              
<nul set /p=[37m
echo Injecting ConsoleUtils DLL...
exe\inject.exe exe\consoleUtils.dll

call scripts\forceMode.bat
<nul set /p=[1;1H[48;2;0;0;0m
for /l %%a in (1,1,56) do echo.                                                                                        
<nul set /p=[37m

for %%a in (
	unload.bat:Unloading...
	miscInit.bat:Setting_miscellaneous_values...
	readWriteTest.bat:Performing_read_write_test...
	discordRpcDefault.bat:Setting_default_values_for_Discord_RPC...
	createDirectories.bat:Creating_directories...
	setMacros.bat:Setting_macros...
) do (
	set initCurrent=%%a
	set initCurrent=!initCurrent:_= !
	for /f "tokens=1-2 delims=:" %%b in ("!initCurrent!") do (
		echo.[54;3H                                                                                                                                              [54;3H%%c
		call scripts\%%b
		call scripts\wait.bat 10

	)
)

for %%a in (
	getInput.dll:Injecting_GetInput_DLL...
	discordRPC.dll:Injecting_DiscordRPC_DLL...
) do (
	set initCurrent=%%a
	set initCurrent=!initCurrent:_= !
	for /f "tokens=1-2 delims=:" %%b in ("!initCurrent!") do (
		echo.[54;3H                                                                                                                                              [54;3H%%c
		exe\inject.exe exe\%%b
		call scripts\wait.bat 10
	)
)

rem this should always be executed last
echo.[54;3H                                                                                                                                              [54;3HInitializing FPS/TPS values...
call scripts\initFpsTps.bat

echo.[54;3H                                                                                                                                              [37m[54;3HEntering editor...[30m
exit /b 0