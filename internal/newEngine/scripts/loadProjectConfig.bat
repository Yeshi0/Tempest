for %%a in (
	newEngineProject\config\allowDevConsole.conf:allowLetters
	newEngineProject\config\engineVersion.conf:allowLetters_allowNumbers_allowSymbols
	newEngineProject\config\gameName.conf:allowLetters
	newEngineProject\config\useDiscordRPC.conf:allowLetters
	newEngineProject\config\hideNamesDuringInit.conf:allowLetters
) do (
	set checkCurrent=%%a
	set checkCurrent=!checkCurrent:_= !
	for /f "tokens=1-2 delims=:" %%b in ("!checkCurrent!") do (
		if NOT exist %%b (
			echo.
			echo.[54;3H                                                                                        [54;3HFailed to locate config file at '%%b'.
			call newEngine\scripts\halt.bat

		) else (
			echo.[54;3H                                                                                        [54;3HLoading config at '%%b'...
			set dataParsed=false
			for /f "tokens=1-2 delims= " %%d in (%%b) do (
				set dataParsed=true
				if "%%d"=="" (
					echo.
					echo.[54;3H                                                                                        [54;3HConfig at '%%b' has no value.
					call newEngine\scripts\halt.bat

				) else (
					if NOT "%%e"=="" (
						echo.
						echo.[54;3H                                                                                        [54;3HConfig at '%%b' has trailing data after first word.
						call newEngine\scripts\halt.bat

					) else (
						call newEngine\scripts\checkString.bat "%%d" %%c
						if "!stringHasUnwantedChars!"=="false" (
							set %%~nb=%%d

						) else (
							echo.
							echo.[54;3H                                                                                        [54;3HConfig at '%%b' has an invalid value.
							call newEngine\scripts\halt.bat
						)
					)
				)
			)
		)
		if "!dataParsed!"=="false" (
			echo.
			echo.[54;3H                                                                                        [54;3HFailed to parse data from config at '%%b'.
			call newEngine\scripts\halt.bat
		)
	)
)
exit /b 0