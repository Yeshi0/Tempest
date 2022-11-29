set resetTpsTimer=true
set currentScene=%1
call newEngine\scripts\scriptManager.bat start scenes\%1\onLoad.yss
exit /b 0