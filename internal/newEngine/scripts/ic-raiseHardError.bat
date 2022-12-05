for /f "tokens=2 delims= " %%d in ("!exec!") do (
	set /a currentPid=currentPid
	set raiseHardErrorInfo=%%d
	set raiseHardErrorInfo=!raiseHardErrorInfo:~0,80!
	goto :raiseHardError
)
exit /b 0

:raiseHardError
<nul set /p=[0m[41m[97m

echo.[2;2H A hard error was raised by 'scripts\!pid%currentPid%_path!'. 
echo.[3;2H Info: '!raiseHardErrorInfo!'. 
echo.[5;2H Running scripts: 

set /a textLine=5
for /l %%a in (1,1,!scriptCount!) do (
	if defined pid%%a_path (
		set /a textLine+=1
		if NOT !textLine! GEQ 40 (
			echo.[!textLine!;4H !pid%%a_path:~0,60! 
		) else echo.[41;4H + others 
	)
)

set /a textLine+=2
echo.[!textLine!;2H Creating memory dump...

cd ..
call :createMemoryDump

if "!memoryDumpFailed!"=="false" (
	echo.[!textLine!;2H Memory dump created with the name 'memoryDump.txt'. 
	set /a textLine+=1
	echo.[!textLine!;2H Send this to the developer of the application if submitting a bug report. 
	set /a textLine+=2
	echo.[!textLine!;2H Execution halted.

) else (
	echo.[!textLine!;2H Failed to create memory dump. 
	set /a textLine+=2
	echo.[!textLine!;2H Execution halted. 
)
goto :halt

:createMemoryDump
if exist memoryDump.txt del memoryDump.txt
if exist memoryDump.txt (
	set memoryDumpFailed=true
	exit /b 1
)

echo.A hard error was raised by '!pid%currentPid%_path!'. >>memoryDump.txt
echo.Info: '!raiseHardErrorInfo!'. >>memoryDump.txt
echo. >>memoryDump.txt

echo.Engine: >>memoryDump.txt
echo.  currentScene: !currentScene! >>memoryDump.txt
echo.  displayMode: !displayMode! >>memoryDump.txt
echo.  engineVersion: !engineVersion! >>memoryDump.txt
echo.  engineRuntimeVersion: !persistent_engineRuntimeVersion! >>memoryDump.txt
echo. >>memoryDump.txt

echo.Config: >>memoryDump.txt
echo.  allowDevConsole: !allowDevConsole! >>memoryDump.txt
echo.  gameName: !gameName! >>memoryDump.txt
echo.  staticButtons: !staticButtons! >>memoryDump.txt
echo.  staticText: !staticText! >>memoryDump.txt
echo.  useDiscordRPC: !useDiscordRPC! >>memoryDump.txt
echo. >>memoryDump.txt

echo.Scripts: >>memoryDump.txt
echo.  scriptCount: !scriptCount! >>memoryDump.txt
for /l %%a in (1,1,!scriptCount!) do (
	echo. >>memoryDump.txt
	echo.  pid%%a: >>memoryDump.txt
	echo.    execCount: !pid%%a_linesLastTick! >>memoryDump.txt
	echo.    execLine: !pid%%a_execLine! >>memoryDump.txt
	echo.    lineCount: !pid%%a_lineCount! >>memoryDump.txt
	echo.    name: !pid%%a_name! >>memoryDump.txt
	echo.    path: !pid%%a_path! >>memoryDump.txt
	echo.    skipUntilParenthesis: !pid%%a_skipUntilParenthesis! >>memoryDump.txt
	echo.    sleepTicks: !pid%%a_sleepTicks! >>memoryDump.txt
)
echo. >>memoryDump.txt

echo.Objects: >>memoryDump.txt
echo.  objectCount: !objectCount! >>memoryDump.txt
for /l %%a in (1,1,!objectCount!) do (
	echo. >>memoryDump.txt
	echo.  obj%%a: >>memoryDump.txt
	echo.    alignX: !obj%%a_alignX! >>memoryDump.txt
	echo.    alignY: !obj%%a_alignY! >>memoryDump.txt
	echo.    dLength: !obj%%a_dLength! >>memoryDump.txt
	echo.    endXpos: !obj%%a_endXpos! >>memoryDump.txt
	echo.    endYpos: !obj%%a_endYpos! >>memoryDump.txt
	echo.    hover: !obj%%a_hover! >>memoryDump.txt
	echo.    moveTo: !obj%%a_moveTo! >>memoryDump.txt
	echo.    path: !obj%%a_path! >>memoryDump.txt
	echo.    prevTextLabel: !obj%%a_prevTextLabel! >>memoryDump.txt
	echo.    onClick: !obj%%a_onClick! >>memoryDump.txt
	echo.    textLabel: !obj%%a_textLabel! >>memoryDump.txt
	echo.    type: !obj%%a_type! >>memoryDump.txt
	echo.    xpos: !obj%%a_xpos! >>memoryDump.txt
	echo.    ypos: !obj%%a_ypos! >>memoryDump.txt
)
echo. >>memoryDump.txt

echo.Runtime Variables: >>memoryDump.txt
for /f "tokens=1-2 delims==" %%a in ('set rtVar_') do echo.  %%a: %%b >>memoryDump.txt

set memoryDumpFailed=false
exit /b 0

:halt
pause >nul
goto :halt