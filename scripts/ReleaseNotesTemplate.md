## How to Install
1. Scroll down the the **Assets** and click on **`ArchHUD.conf`**, this should trigger a download for this file.
1. Save the file to %ProgramData%\Dual Universe\Game\data\lua\autoconf\custom (or equivalent directory if you did not do default install), the filename does not matter (as long as it's still .conf)
1. If using a databank, manually link the databank to the control unit(s) that will be running the HUD PRIOR to the next step.
1. In-game, right click your seat and go to Advanced -> Update custom autoconf list - If you get a YAML error, you did not follow the above directions correctly.
1. Again, right click your seat and select Advanced -> Run Custom Autoconfigure -> ArchHud - Archaegeo
1. IMPORTANT: Right click the seat and set the user control scheme to Keyboard (Advanced -> Change Control Scheme -> Keyboard). This is necessary for the HUD to work, but you can change the actual control scheme in the next step - fear not virtual joystick aces!
1. To most easily set up user preferences the first time, right click the seat, choose Advanced -> Edit LUA Parameters. You may also change control scheme using a Button while seated and change all other user parameters. NOTE: Edit LUA Parameters is broken right now (NQ Bug).  Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for how to change settings.
1. If you have a Databank installed on your vehicle your parameters will save when you stand up. Saved parameters will be restored any time you upgrade the HUD to a new version. 
1. Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for an explanation of all settings.

FOR SOUND SUPPORT:
1. Download and place to location of your choice the exe file found at https://github.com/ZarTaen/DU_logfile_audioframework/releases 
1. Download the archHudSoundPack.zip file found at https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/archHudSoundPack.zip. 
1. Run the `DU_logfile_audioframework.exe` file and leave running. This will create an `audiopacks` subfolder 
1. Extract the `archHudSoundPack.zip`.  This should result in a subfolder named in the `audiopacks` folder named `archHUD`
1. NOTE: Any sound file in the audiopack may be replaced with a different sound file using same filename if you choose to personalize.
1. NOTE: If you dislike any particular sound and do not want to replace it but still want the other sounds, simply remove its .mp3 file from the soundpack folder.
1. NOTE: The `DU_logfile_audioframework.exe` must be left running.  It reads the DU log file and plays the appropriate sound (source code in Rust is available at the above github site for those who are concerned)
1. Voices can be turned off by setting `voices` user variable to false.  Alerts can be turned off by setting `alerts` to false.
1. Sound volumes can be controlled by the `soundVolume` setting, which defaults to 100.
1. `Alt-7` will toggle all sounds on or off
1. ***IMPORTANT:*** You MUST change the name of the soundpack subfolder and the userVariable `soundFolder` to something other than "archHUD". Use /G soundFolder NewName in lua chat for existing systems.
This is to prevent others from making your PC play sounds they think you have installed.
1. STREAMERS ONLY:  For your viewers to hear the sounds/voices, you will need to add the `DU_logfile_audioframework.exe` as an audio source for your stream.


At this point you should be ready to fly!

# Latest Changes
