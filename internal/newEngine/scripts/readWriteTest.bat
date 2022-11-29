if exist newEngineProject\readWriteTest.tmp del newEngineProject\readWriteTest.tmp
if exist newEngineProject\readWriteTest.tmp (
	echo.
	echo Permission check for read/write failed.
	call newEngine\scripts\halt.bat
)

echo.readWriteTest>>newEngineProject\readWriteTest.tmp
if NOT exist newEngineProject\readWriteTest.tmp (
	echo.
	echo Permission check for read/write failed.
	call newEngine\scripts\halt.bat
)

if exist newEngineProject\readWriteTest.tmp del newEngineProject\readWriteTest.tmp
if exist newEngineProject\readWriteTest.tmp (
	echo.
	echo Permission check for read/write failed.
	call newEngine\scripts\halt.bat
)
exit /b 0