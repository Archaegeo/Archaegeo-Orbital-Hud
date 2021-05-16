## How to Install
1. Scroll down the the **Assets** and click on **`ArchHUD.conf`**, this should trigger a download for this file.
1. Save the file to %ProgramData%\Dual Universe\Game\data\lua\autoconf\custom (or equivalent directory if you did not do default install), the filename does not matter (as long as it's still .conf)
1. If using a databank, manually link the databank to the control unit(s) that will be running the HUD PRIOR to the next step.
1. In-game, right click your seat and go to Advanced -> Update custom autoconf list - If you get a YAML error, you did not follow the above directions correctly.
1. Again, right click your seat and select Advanced -> Run Custom Autoconfigure -> ArchHud - Archaegeo
1. IMPORTANT: Right click the seat and set the user control scheme to Keyboard (Advanced -> Change Control Scheme -> Keyboard). This is necessary for the HUD to work, but you can change the actual control scheme in the next step - fear not virtual joystick aces!
1. To most easily set up user preferences the first time, right click the seat, choose Advanced -> Edit LUA Parameters. You may also change control scheme using a Button while seated and change all other user parameters.
1. If you have a Databank installed on your vehicle your parameters will save when you stand up. Saved parameters will be restored any time you upgrade the HUD to a new version. 
1. Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for an explanation of all settings.
1. To use sound files, download the sound pack and install the files it in a new folder called archHUD in the Sound Player audiopacks directory.  Sound player zip file available at: https://github.com/ZarTaen/DU_logfile_audioframework/releases 
You will then need to edit the audiopacks.toml file in the conf directory and add a line: archHUD = "audiopacks/archHUD"

At this point you should be ready to fly!

# Latest Changes
