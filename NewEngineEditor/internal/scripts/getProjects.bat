if NOT exist projects\ (
	%error% localizedText.hardError.noProjectsFolder
) else (
	set /a projectCount=0
	for /f %%a in ('dir /b /ad projects 2^>nul') do (
		set /a projectCount+=1
		set project!projectCount!_name=%%a
	)
)
exit /b 0