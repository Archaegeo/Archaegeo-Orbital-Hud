@echo %EchoPrefix%off
setlocal

:: setup directory structure
SET "ROOTDIR=%CD%\"
SET "FILENAME=ArchHUD.lua"
SET "ScriptDir=%ROOTDIR%scripts\"
SET "LuaCDir=%ScriptDir%LuaC\"
SET "LuaCInputDir=%LuaCDir%src\"
SET "LuaCOutputDir=%LuaCDir%out\release\"
SET "WorkDir=%ScriptDir%work\"


:: setup directory pointers for npm
SET "NPM_BASE_PATH=%ScriptDir%npm\"
SET "NPM_BIN_PATH=%NPM_BASE_PATH%node_modules\.bin\"


:: setup pointers to scripts
SET "REPL=%ScriptDir%repl.bat"
SET "LUA_PATH=%ScriptDir%Lua\lua53.exe"
SET "WRAP_PATH=%ScriptDir%wrap.lua"


:: where to download script files from if you don't have them
SET "GITHUB_BASE=https://raw.githubusercontent.com/Dimencia/Archaegeo-Orbital-Hud/master/"


:: setup files we will use.  One file to hold the merged lua, one to hold exports from it (and later have the minified file added to it), one to hold the merged lua with exports extracted, one to hold the minified file, and one for the conf
SET "MergedFile=%LuaCOutputDir%%FILENAME%"
SET "ExportsFile=%WorkDir%exports.lua"
SET "ExtractFile=%WorkDir%extract.lua"
SET "MiniFile=%WorkDir%minified.lua"
SET "WrapFilePath=%ROOTDIR%..\"
:: we later modify this into WrapFile once we know a version to give for the name


:: Slots - if you want to change slot config, edit this
SET "SLOTS=core:class=CoreUnit radar:class=RadarPVPUnit,select=manual,type=radar antigrav:class=AntiGravityGeneratorUnit warpdrive:class=WarpDriveUnit gyro:class=GyroUnit weapon:class=WeaponUnit,select=manual dbHud:class=databank,select=manual telemeter:class=TelemeterUnit,select=manual vBooster:class=VerticalBooster hover:class=Hovercraft door:class=DoorUnit,select=manual switch:class=ManualSwitchUnit,select=manual forcefield:class=ForceFieldUnit,select=manual atmofueltank:class=AtmoFuelContainer,select=manual spacefueltank:class=SpaceFuelContainer,select=manual rocketfueltank:class=RocketFuelContainer,select=manual shield:class=ShieldGeneratorUnit,select=manual"


:: setup a few functions
:strlen
if [%1] EQU [] goto end
:: This prevents it from executing if we didn't actually call it
:loop
	if [%1] EQU [] goto end
	set _len=0
	set _str=%1
	set _subs=%_str%

	:getlen		
		if not defined _subs (
			set /a _len-=2
			exit /B 0
		)
		:: remove first letter until empty
		set _subs=%_subs:~1%
		set /a _len+=1
		goto getlen


:runbackspace
set /a loopEx=0
set len=%_len%
set "content="
:startbackspace
set "content=%content%%BS% %BS%"
set /a loopEx+=1
IF %loopEx% LSS %len% goto startbackspace
set /p "=%content%" <NUL
exit /B 0
:end

    

:: Make directories if they don't exist.  These cover all the important ones
mkdir "%NPM_BASE_PATH%" 1>NUL 2>NUL
mkdir "%WorkDir%" 1>NUL 2>NUL
IF NOT EXIST "%ScriptDir%/LuaC" mkdir "%ScriptDir%/LuaC" 1>NUL 2>NUL
IF NOT EXIST "%ScriptDir%/Lua" mkdir "%ScriptDir%/Lua" 1>NUL 2>NUL

:: Setup echo prefix
SET "EchoPrefix=[[36mBATCH COMPILER[0m] "


:: Find and install npm if not accessible, restarting CMD after installation
WHERE npm >NUL
IF %ERRORLEVEL% NEQ 0 ( 
	echo %EchoPrefix%Performing first time setup for npm - You should see an install window with progress.  If you see this more than once, something is wrong with the install - install the latest version of npm yourself, and/or contact Dimencia#0614 on Discord
	start /wait msiexec.exe /i "https://nodejs.org/dist/v16.13.2/node-v16.13.2-x86.msi" /passive /norestart
	echo %EchoPrefix%Restarting install in new CMD window to accept the new path vars
	start cmd /c "%ROOTDIR%compile.bat"
	exit
)

:: check if NPM is of an appropriate version
FOR /F "tokens=* USEBACKQ" %%F IN (`npm version ^| findstr /r /c:npm`) DO (
	set "npmVersionBase=%%F"
)
set "npmVersion=%npmVersionBase:~-9,-1%"
:: This looks like "6.14.10", we need to split it on the .'s
FOR /F "tokens=2,3,4 delims=.' USEBACKQ" %%A IN ('%npmVersion%') DO (
	set "npmV1=%%A"
	set "npmV2=%%B"
	set "npmV3=%%C"
)
:: and we're probably safe as long as they're NPM version 6+
echo %npmV1%
IF %npmV1% LSS 6 (
	echo %EchoPrefix%Updating NPM to required version 6+ - You should see an install window with progress
	start /wait msiexec.exe /i "https://nodejs.org/dist/v16.13.2/node-v16.13.2-x86.msi" /norestart
	echo %EchoPrefix%Restarting install in new CMD window to accept the new path vars
	start cmd /c "%ROOTDIR%compile.bat"
	exit
)

echo %EchoPrefix%NPM detected at acceptable version %npmVersion%

:: Move to NPM base path to install LuaC and Luamin
cd "%NPM_BASE_PATH%"
IF NOT EXIST "%NPM_BIN_PATH%du-lua" (
	echo %EchoPrefix%Performing first time setup for LuaC
	call npm install @wolfe-labs/du-luac
	echo %EchoPrefix%Updating Luamin
	call npm install --save https://github.com/Dimencia/luamin/tarball/master
	echo %EchoPrefix%Installed LuaC and Luamin
) ELSE echo %EchoPrefix%LuaC Detected

IF NOT EXIST "%NPM_BIN_PATH%luamin" (
	echo %EchoPrefix%Performing first time setup for Luamin
	call npm install --save https://github.com/Dimencia/luamin/tarball/master
	echo %EchoPrefix%Installed Luamin
) else echo %EchoPrefix%Luamin Detected


echo %EchoPrefix%Checking required scripts
:: Check existence and/or download wrap.lua, project.json, repl.bat, and the lua binaries
:: We cancel first in case there was a leftover one from the user cancelling in mid download
bitsadmin /reset >NUL
bitsadmin /create /download ScriptDownloads >NUL
:: Setup the container in case there will be any downloads, so we can add to them
SET anyDownloads=0
IF NOT EXIST "%WRAP_PATH%" (
	echo %EchoPrefix%Downloading wrap.lua
	bitsadmin /addfile ScriptDownloads "%GITHUB_BASE%scripts/wrap.lua" "%WRAP_PATH%" >NUL
	SET anyDownloads=1
)
IF NOT EXIST "%LuaCDir%project.json" (
	echo %EchoPrefix%Downloading LuaC project file
	bitsadmin /addfile ScriptDownloads "%GITHUB_BASE%scripts/LuaC/project.json" "%LuaCDir%project.json" >NUL
	SET anyDownloads=1
)
IF NOT EXIST "%REPL%" (
	echo %EchoPrefix%Downloading replace tool
	bitsadmin /addfile ScriptDownloads "%GITHUB_BASE%scripts/download/repl.bat" "%REPL%" >NUL
	SET anyDownloads=1
)
IF NOT EXIST "%LUA_PATH%" (
	echo %EchoPrefix%Downloading Lua Binaries ^(1/2^)
	bitsadmin /addfile ScriptDownloads "%GITHUB_BASE%scripts/download/Lua/lua53.exe" "%LUA_PATH%" >NUL
	echo %EchoPrefix%Downloading Lua Binaries ^(2/2^)
	bitsadmin /addfile ScriptDownloads "%GITHUB_BASE%scripts/download/Lua/lua53.dll" "%ScriptDir%Lua\lua53.dll" >NUL
	SET anyDownloads=1
)
IF %anyDownloads%==1 (
	bitsadmin /resume ScriptDownloads >NUL
	for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
	set /p "=%EchoPrefix%Beginning Downloads" <NUL
	CALL :strlen "Beginning Downloads"
	:: sets string length to %_len%, which runbackspace uses
)
:checkDownloads
IF %anyDownloads%==1 (
	:: backspaces %_len% times
	CALL :runbackspace
	FOR /F "USEBACKQ tokens=3,4,5,6,7,8,9,10 delims= " %%A IN (`bitsadmin /info ScriptDownloads /verbose ^| find "PRIORITY"`) DO (
		set /p "=%%A %%B%%C%%D %%E %%F%%G%%H" <NUL
		CALL :strlen "%%A %%B%%C%%D %%E %%F%%G%%H"
	)
	
	bitsadmin /info ScriptDownloads /verbose | find "STATE: TRANSFERRED" >NUL && (
		bitsadmin /complete ScriptDownloads >NUL
		CALL :runbackspace
		echo Download Complete
		GOTO afterDownloads
	)
	bitsadmin /info ScriptDownloads /verbose | find "STATE: SUSPENDED" >NUL && (
		bitsadmin /cancel ScriptDownloads >NUL
		echo %EchoPrefix%ERROR: Downloads could not be completed - exiting
		pause
		exit
	)
	GOTO checkDownloads
)
:afterDownloads
:: just in case it got stuck, reset
bitsadmin /reset >NUL
echo %EchoPrefix%All scripts ready


:: Setup complete, time to compile.  Copy the source files to the LuaC directory so that it can merge them
:: We can't guarantee anyone has xcopy or robocopy so we do this the hard way

:: Note that below, 1>NUL 2>NUL is just hiding the output.  If you need to debug, you can remove those

echo %EchoPrefix%Copying files to work directory: %WorkDir%
:: remove old ArchHUD.lua in LuaC directory if it exists
del "%LuaCInputDir%%FILENAME%" 1>NUL 2>NUL
:: copy main file to main source directory for LuaC
copy /Y "%ROOTDIR%%FILENAME%" "%LuaCInputDir%%FILENAME%" 1>NUL 2>NUL
:: delete old modules folder in LuaC output if it exists
rmdir /S /Q "%LuaCInputDir%autoconf" 1>NUL 2>NUL
:: setup file structure for LuaC to detect them, which should match the game's
mkdir "%LuaCInputDir%autoconf\custom\archhud\custom" 1>NUL 2>NUL
:: copy files from user-defined Modules folder
copy "%ROOTDIR%Modules\*.*" "%LuaCInputDir%autoconf\custom\archhud" 1>NUL 2>NUL
:: copy files from user custom folder
copy "%ROOTDIR%Modules\custom\*.*" "%LuaCInputDir%autoconf\custom\archhud\custom" 1>NUL 2>NUL

echo %EchoPrefix%Running LuaC to merge files to %MergedFile%
:: Run du-lua build from the scripts/LuaC directory
cd "%LuaCDir%"
call "%NPM_BIN_PATH%du-lua" build
cd "%ROOTDIR%"
:: now we have a combined, unminified file in scripts/LuaC/production/out (%MergedFile%)
:: Take that file and run the old .sh processing on it

echo %EchoPrefix%Extracting exports to preserve them from minify
:: clear old export file if it exists
del "%ExportsFile%" 1>NUL 2>NUL
:: extract exports so minify doesn't get them
findstr /r /c:"-- *export:" "%MergedFile%" > "%ExportsFile%"

echo %EchoPrefix%Finding Version
:: find version number - Note, max 5 chars in the version number.  Or rather, always exactly 5
FOR /F "tokens=* USEBACKQ" %%F IN (`findstr /r /c:"VERSION_NUMBER *= *" "%MergedFile%"`) DO (
SET versionFull=%%F
)
set version=%versionFull:~-5%
echo %EchoPrefix%Found Version ArchHUDv%version%


:: prepare the WrapFile path now that we know a version.  CD to it so we get a nicer name without ../ in it
cd "%WrapFilePath%"
SET "WrapFile=%CD%\ArchHUD v%version% MiniModular.conf"
:: and then go back for posterity
cd "%ROOTDIR%"



echo %EchoPrefix%Extracting non-export lines to %ExtractFile%
:: remove old extract file if it exists
del "%ExtractFile%" 1>NUL 2>NUL
:: remove all --export lines and the `require 'src.slots'` line from the file and copy to ExtractFile
:: uses repl.bat, an amazing pure-bat solution to do this quickly and allow large lines
type "%MergedFile%" | call "%repl%" "(--export:.*)|(require 'src.slots')" "" > "%ExtractFile%"


echo %EchoPrefix%Minifying extracted file to %MiniFile%
:: remove old minified file if it exists
del "%MiniFile%" 1>NUL 2>NUL
:: Note: No quotes around this %extractFile% because it's being piped and they get captured
echo %ExtractFile% | "%npmPath%luamin" --file > "%MiniFile%"


echo %EchoPrefix%Adding exports back to the minified file
:: Put the minified lua after the exports.  Note that this means all exports should be on the top level scope
type "%MiniFile%" | call "%repl%" "" "" >> "%ExportsFile%"


echo %EchoPrefix%Wrapping %ExportsFile%
del "%wrapFile%" 1>NUL 2>NUL
"%LUA_PATH%" "%WRAP_PATH%" --handle-errors-min --output yaml --name "ArchHUD - Archaegeo v%version% (ModMini)" "%ExportsFile%" "%WrapFile%" --slots %slots%

echo %EchoPrefix%Compiled v%version% at %WrapFile%

pause
