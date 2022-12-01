:wait
if NOT defined timer_wait_final for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "timer_wait_t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "timer_wait_t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, timer_wait_final=timer_wait_t2-timer_wait_t1, timer_wait_tDiff+=((~(timer_wait_tDiff&(1<<31))>>31)+1)*8640000, timer_wait_t1=timer_wait_t2"
set /a waited+=timer_wait_final

if %waited% GEQ %1 (
	set timer_wait_final=
	set waited=
	exit /b
)
goto :wait