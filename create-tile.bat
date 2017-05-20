@echo off
setlocal EnableDelayedExpansion

set basefile=%1
set basedir=%~p1
set arg2=%2
set cwd=%~dp0

rem If not already admin
if '%1' NEQ 'am_admin' (
	rem Check if this directory is writable
	copy /Y NUL "%basedir%\.writable" > NUL 2>&1 && set writable=1
	if NOT DEFINED writable ( 
		rem This directory isn't writable, so request admin and reopen
		set basefile=%basefile: =--%
		powershell start -verb runas '%0' 'am_admin !basefile!'
		exit
	)
	del "%basedir%\.writable"
) else (
	set basefile=!arg2:--= !
)

echo Creating a custom tile for the file: %basefile%

set basefile=%basefile:"=%
set basefile=%basefile:/=\%
for /f %%i in ("%basefile: =--%") do (
	set basedir=%%~dpi
	set basefile=%%~ni
	set baseext=%%~xi
	set basedir=!basedir:--= !
	set basefile=!basefile:--= !
	set baseext=!baseext:--= !
	set basefile=!basedir!!basefile!
)

if "%baseext%" NEQ ".exe" (
	echo Start-Process "%basefile%%baseext%" > launch.ps1
	powershell -executionpolicy remotesigned -File %cwd%\ps2exe.ps1 -inputFile launch.ps1 "%basefile%.exe" > nul
	del launch.ps1
	del "%basefile%.exe.config"
)

set visualfile=%basefile%.VisualElementsManifest.xml


set /p image="Image: "
for %%i in ("%image%") do set imageext=%%~xi

set imagefile=%basefile%.tile%imageext%

copy /y "%image%" "%imagefile%" > nul

for /f %%i in ("%imagefile: =--%") do (
	set imagefile=%%~nxi
	set imagefile=!imagefile:--= !
)

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