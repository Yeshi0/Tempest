if NOT defined levelSizeX (
	set rtVar_result=unloadFailed
	exit /b 1
)

for %%a in (lcm_ lcg_ lrb_) do (
	for /f "tokens=1 delims==" %%b in ('set %%a') do set %%b=
)
set levelSizeX=
set levelSizeY=
set levelEndX=
set levelEndY=

set rtVar_result=unloadedLevel
exit /b 0