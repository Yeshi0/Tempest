if NOT defined levelSizeX (
	set rtVar_result=unloadFailed
	exit /b 1
)

set lcm_temp=temp
set lcg_temp=temp
for %%a in (lcm_ lcg_) do (
	for /f "tokens=1 delims==" %%b in ('set %%a') do set %%b=
)
set /a clearEndY=levelSizeY*8
for /l %%a in (1,1,!clearEndY!) do set al%%a=

set levelSizeX=
set levelSizeY=
set levelEndX=
set levelEndY=

set rtVar_result=unloadedLevel
exit /b 0