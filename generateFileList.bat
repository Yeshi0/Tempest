@echo off
setLocal enableDelayedExpansion

cls
echo Generating file list...

if exist fileList del fileList
for /f "tokens=1 delims=" %%b in ('dir /b /a-d 2^>nul') do echo.%%b>>fileList
for %%a in (
    internal
    internal\newEngine
    internal\newEngine\config
    internal\newEngine\exe
    internal\newEngine\fonts
    internal\newEngine\scripts
) do for /f "tokens=1 delims=" %%b in ('dir /b /a-d %%a 2^>nul') do echo.%%a\%%b>>fileList

echo Done.
pause
exit /b 0