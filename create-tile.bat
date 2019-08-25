@echo off
setlocal EnableDelayedExpansion

rem Check if called with no arguments
set args=%*
if NOT DEFINED args (
	rem Might as well see if they want an easier way to use this script
	set /p choice="Add 'Create Custom Tile' to context menu? (y/n): "
	if "!choice!" EQU "y" (
		
		rem Write the registry changes to a .reg file
		set basedir=%~dp0
		set tempfile=!basedir!custom-tiles.reg
		
		echo Windows Registry Editor Version 5.00 > "!tempfile!"

		echo [HKEY_CURRENT_USER\Software\Classes\exefile\shell\CreateCustomTile] >> "!tempfile!"
		echo @="Create Custom Tile" >> "!tempfile!"
		echo [HKEY_CURRENT_USER\Software\Classes\exefile\shell\CreateCustomTile\command] >> "!tempfile!"
		echo @="\"!basedir:\=\\!create-tile.bat\" \"%%1\"" >> "!tempfile!"

		echo [HKEY_CURRENT_USER\Software\Classes\lnkfile\shell\CreateCustomTile] >> "!tempfile!"
		echo @="Create Custom Tile" >> "!tempfile!"
		echo [HKEY_CURRENT_USER\Software\Classes\lnkfile\shell\CreateCustomTile\command] >> "!tempfile!"
		echo @="\"!basedir:\=\\!create-tile.bat\" \"%%1\"" >> "!tempfile!"

		echo [HKEY_CURRENT_USER\Software\Classes\Application.Reference\shell\CreateCustomTile] >> "!tempfile!"
		echo @="Create Custom Tile" >> "!tempfile!"
		echo [HKEY_CURRENT_USER\Software\Classes\Application.Reference\shell\CreateCustomTile\command] >> "!tempfile!"
		echo @="\"!basedir:\=\\!create-tile.bat\" \"%%1\"" >> "!tempfile!"

		echo [HKEY_CURRENT_USER\Software\Classes\batfile\shell\CreateCustomTile] >> "!tempfile!"
		echo @="Create Custom Tile" >> "!tempfile!"
		echo [HKEY_CURRENT_USER\Software\Classes\batfile\shell\CreateCustomTile\command] >> "!tempfile!"
		echo @="\"!basedir:\=\\!create-tile.bat\" \"%%1\"" >> "!tempfile!"
		
		rem Run and delete the temporary .reg file
		start !tempfile!
	)
	pause
	del !tempfile!
	exit
)

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

rem Clean up the input, separate it to three variables
rem   basefile (file without extension)
rem   basedir (file's folder)
rem   baseext (file's extension)
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

rem If the extension isn't .exe, we create an exe that launches their file
if "%baseext%" NEQ ".exe" (
	
	echo Start-Process "%basefile%%baseext%" > launch.ps1
	rem Uses Ps2exe
	set ps2exe=%cwd%\dependencies\ps2exe.ps1
	
	rem $PSVersionTable.PSVersion.Major -eq 4
	if NOT EXIST !ps2exe! (
		set tempzip=%temp%\ps2exe.zip
		wget -O !tempzip! "https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-Convert-PowerShell-ab973757/file/174729/1/PS2EXE.v0.5.1.0.zip" --no-check-certificate
		call :unzip "%cwd%dependencies" "!tempzip!"
	)
	
	powershell -executionpolicy remotesigned -File !ps2exe! -inputFile launch.ps1 "%basefile%.exe" > nul
	
	rem Cleanup
	del launch.ps1
	del "%basefile%.exe.config"
)

rem The path to the VisualElementsManifest file
set visualfile=%basefile%.VisualElementsManifest.xml


rem Getting the logo/image for the tile
set /p image="Image: "
rem Get the extension of the image they requested
for %%i in ("%image%") do set imageext=%%~xi

rem Create a new path for the image, using the exe's folder and the image's extension
set imagefile=%basefile%.tile%imageext%

rem Copy their requested icon to the exe's folder
copy /y "%image%" "%imagefile%" > nul

rem Remove the directory path from the image path, making it relative, instead of absolute
for /f %%i in ("%imagefile: =--%") do (
	set imagefile=%%~nxi
	set imagefile=!imagefile:--= !
)


rem Configure a couple more VisualElements options
set /p text="Text (light/dark): "
set /p background="Background (hex color): #"


rem Generate the VisualElementsManifest
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
exit

:unzip <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
echo %1 %2
> %vbs% echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%