@echo off
setLocal enableDelayedExpansion

cls
echo.Creating package...
echo.

if exist package.nea del package.nea
for %%a in (
	config
	levels
	objects
	scripts
	sprites
	tiles
) do for /f "tokens=1 delims=" %%b in ('dir /b /a-d internal\newEngineProject\%%a 2^>nul') do (
	echo.Packing '\%%a\%%b'...
	echo.§§FILE:\%%a\%%b >>package.nea
	for /f "tokens=1 delims=" %%c in (internal\newEngineProject\%%a\%%b) do echo.%%c >>package.nea
)
pause