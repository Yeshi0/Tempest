if NOT "%1"=="noMsg" (
	echo.
	echo Execution halted
)

:halt
pause >nul
goto :halt