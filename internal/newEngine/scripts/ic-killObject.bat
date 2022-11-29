for /f "tokens=2 delims= " %%d in ("!exec!") do for /l %%e in (1,1,!objectCount!) do if "%%d"=="!obj%%e_name!" call newEngine\scripts\objectManager.bat kill %%e
exit /b 0