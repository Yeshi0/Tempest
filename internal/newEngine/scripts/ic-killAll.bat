for /f "tokens=2 delims= " %%d in ("!exec!") do (
    if "%%d"=="objects" call newEngine\scripts\objectManager.bat killAll
    if "%%d"=="scripts" call newEngine\scripts\scriptManager.bat killAll
)
exit /b 0