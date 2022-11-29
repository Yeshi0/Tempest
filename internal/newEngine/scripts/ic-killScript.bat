for /f "tokens=2 delims= " %%d in ("!exec!") do for /l %%e in (1,1,!scriptCount!) do if "%%d"=="!pid%%e_name!" call newEngine\scripts\scriptManager.bat kill %%e
exit /b 0