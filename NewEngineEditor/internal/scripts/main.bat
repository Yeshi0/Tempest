@echo off
setLocal enableDelayedExpansion

call scripts\init.bat
goto :main

:halt
pause >nul
goto :halt

:main
for /l %%. in (1,1,2999) do (
    <nul set /p=[1;1H
    for /l %%a in (56,-1,1) do echo.!d%%a!
)
goto :main