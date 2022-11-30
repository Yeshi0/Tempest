@echo off
setLocal enableDelayedExpansion

cls
echo.This will delete and redownload the latest files from GitHub.
echo.Enter "download" to confirm.
echo.
set /p input=Confirm: 

if NOT "!input!"=="download" (
	cls
	echo Cancelled.
	pause
	exit /b 0
)

cls
echo.Updating...

for /f "tokens=1 delims=" %%a in ('curl -kL https://raw.githubusercontent.com/Yeshi0/Tempest/master/fileList 2^>nul') do (
	echo.Updating "%%a"...
	if "%%a"=="temp-update.bat" (
		if exist %%a del %%a
		curl -kL https://raw.githubusercontent.com/Yeshi0/Tempest/master/ -o %%a 2^>nul

	) else echo.Cannot self-update, skipping... ^(ignore this message^)
)

echo.Done.
pause