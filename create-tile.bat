@echo off
setlocal EnableDelayedExpansion

set basefile=%1

rem Reopen as admin, if not already admin
if '%1' NEQ 'am_admin' (
	set basefile=%basefile: =--%
	powershell start -verb runas '%0' 'am_admin !basefile!'
	exit
)

set basefile=%2
set basefile=%basefile:--= %

echo Creating a custom tile for the file: %basefile%

set basefile=%basefile:/=\%
set basefile=%basefile:~0,-4%
set visualfile=%basefile%.VisualElementsManifest.xml

echo %visualfile%

set /p image="Image: "
set imageext=%image:~-4%

set imagefile=%basefile%.tile%imageext%

copy /y "%image%" "%imagefile%" > nul

for /f %%i in ("%imagefile: =--%") do set imagefile=%%~nxi

set imagefile=%imagefile:--= %

set /p text="Text (light/dark): "
set /p background="Background (hex color): #"


echo ^<?xml version='1.0' encoding='utf-8'?^> > "%visualfile%"
echo ^<Application xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'^> >> "%visualfile%"
echo ^<VisualElements >> "%visualfile%"
echo ForegroundText='%text%' >> "%visualfile%"
echo BackgroundColor='#%background%' >> "%visualfile%"
echo ShowNameOnSquare150x150Logo='on' >> "%visualfile%"
echo Wide150x300Logo='%imagefile%' >> "%visualfile%"
echo Wide150x310Logo='%imagefile%' >> "%visualfile%"
echo Square300x300Logo='%imagefile%' >> "%visualfile%"
echo Square310x310Logo='%imagefile%' >> "%visualfile%"
echo Wide300x150Logo='%imagefile%' >> "%visualfile%"
echo Wide310x150Logo='%imagefile%' >> "%visualfile%"
echo Square150x150Logo='%imagefile%' >> "%visualfile%"
echo Square70x70Logo='%imagefile%' >> "%visualfile%"
echo Square44x44Logo='%imagefile%'/^> >> "%visualfile%"
echo ^</Application^> >> "%visualfile%"

pause

:end