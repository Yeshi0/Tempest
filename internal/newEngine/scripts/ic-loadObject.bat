for /f "tokens=2 delims= " %%d in ("!exec!") do call newEngine\scripts\objectManager.bat loadObject scenes\!currentScene!\objects\%%d
exit /b 0