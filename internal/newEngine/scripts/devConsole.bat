echo.
echo This is the dev console, it will be improved upon later.
echo Sorry for lack of documentation at the moment.
echo.
echo Good luck figuring this out on your own.
echo.
echo.
echo.

<nul set /p=[?25h
set /p dev=Dev: 
echo !dev! >newEngineProject\temp\devConsoleCommand.yss
<nul set /p=[?25l

exit /b 0