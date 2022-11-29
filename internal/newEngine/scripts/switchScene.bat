set resetTpsTimer=true
set currentScene=%1
call newEngine\scripts\objectManager.bat killAll
for /l %%a in (1,1,56) do set d%%a=                                                                                        
if exist newEngineProject\scenes\%1\onLoad.yss (
	call newEngine\scripts\scriptManager.bat start scenes\%1\onLoad.yss

) else exit /b 1
exit /b 0