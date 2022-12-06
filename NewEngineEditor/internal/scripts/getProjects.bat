if NOT exist projects\ (
	%error% localizedText.hardError.noProjectsFolder
) else (
	break
)
exit /b 0