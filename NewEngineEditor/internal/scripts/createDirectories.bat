for %%a in (
    projects
) do if NOT exist %%a\ mkdir %%a
exit /b 0