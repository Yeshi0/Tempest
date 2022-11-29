@echo off
setLocal enableDelayedExpansion

set /a lines=0
for /f %%a in ('dir /b /a-d scripts\*.bat') do (
	echo.Counting lines of code for 'scripts\%%a'...
	for /f "delims=" %%b in (scripts\%%a) do set /a lines+=1
)

echo.
echo Lines of code: !lines!
pause
exit /b 0