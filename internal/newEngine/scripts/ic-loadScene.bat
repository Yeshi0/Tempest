for /f "tokens=2 delims= " %%d in ("!exec!") do call newEngine\scripts\loadScene.bat %%d
exit /b 0