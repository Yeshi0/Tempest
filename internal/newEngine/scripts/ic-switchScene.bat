for /f "tokens=2 delims= " %%d in ("!exec!") do call newEngine\scripts\switchScene.bat %%d
call newEngine\scripts\initFpsTps.bat
exit /b 0