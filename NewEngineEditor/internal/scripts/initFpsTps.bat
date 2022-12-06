set /a maxFps=25
set /a maxTps=25
set /a csPerFrame=100/maxFps
set /a csPerTick=100/maxTps
for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "timer_globalTimer_t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
set /a timer_globalTimer_t2=timer_globalTimer_t1
set /a fpsFinal=0
set /a tpsFinal=0
set /a execTdiff=0
set /a globalTdiff=0
set /a tpsTimer=0
exit /b 0