if "!hideNamesDuringInit!"=="true" exit /b 0
set bannerText=%~1
call newEngine\scripts\getStringLength.bat "!bannerText!"
if !stringLength! GEQ 87 set bannerText=!bannerText:~0,82! ...

echo.[2;2H[40m[97m                                                                                      
echo.[2;2H!bannerText!
exit /b 0