for /f "tokens=2-3 delims= " %%d in ("!exec!") do (
	set exec=raiseHardError DISCORDRPC_NOT_IMPLEMENTED
	call newEngine\scripts\ic-raiseHardError.bat
)
exit /b 0