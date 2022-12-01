for /f "tokens=2-4 delims= " %%d in ("!exec!") do for /l %%e in (1,1,!objectCount!) do if "%%d"=="!obj%%e_name!" (
	if defined obj%%e_%%f set rtVar_result=!obj%%e_%%f!
)
exit /b 0