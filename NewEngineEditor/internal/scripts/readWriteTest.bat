if exist readWriteTest.tmp del readWriteTest.tmp
if exist readWriteTest.tmp (
	echo.
	echo Permission check for read/write failed.
	call scripts\halt.bat
)

echo.readWriteTest>>readWriteTest.tmp
if NOT exist readWriteTest.tmp (
	echo.
	echo Permission check for read/write failed.
	call scripts\halt.bat
)

if exist readWriteTest.tmp del readWriteTest.tmp
if exist readWriteTest.tmp (
	echo.
	echo Permission check for read/write failed.
	call scripts\halt.bat
)
exit /b 0