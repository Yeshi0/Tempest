@echo off 
setLocal
if defined wt_session ( 
	set wt_session=
	start conhost.exe launcher.bat 
	endLocal
	exit /b 0 
) 
cd internal 
call newEngine\scripts\main.bat 
exit /b %errorLevel% 
