for /f "tokens=2 delims= " %%d in ("!exec!") do call newEngine\scripts\objectManager.bat loadObject objects\%%d
exit /b 0