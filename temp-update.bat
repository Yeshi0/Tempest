@echo off
setLocal enableDelayedExpansion

cls
echo This will delete and redownload the latest files from GitHub.
echo Enter "download" to confirm.
echo.
set /p input=Confirm: 

if NOT "!input!"=="download" (
    cls
    echo Cancelled.
    pause
    exit /b 0
)

cls
echo Downloading file list...

for /f "delims=1 tokens=" %%a in ('curl -kL https://raw.githubusercontent.com/Yeshi0/Tempest/master/fileList ^2>nul') do echo.%%a
pause