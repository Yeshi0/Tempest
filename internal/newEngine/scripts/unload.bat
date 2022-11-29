for /f "tokens=1 delims==" %%a in ('set') do (
	set unload=true
	for %%b in (
		comSpec
		neRuntimeEnv
	) do if /i "%%a"=="%%b" set unload=false
	set checkVar=%%a
	if "!checkVar:~0,11!"=="persistent_" set unload=false
	if "!checkVar:~0,1!"=="#" set unload=false
	if "!unload!"=="true" set %%a=
)
set Path=C:\Windows\system32
exit /b 0