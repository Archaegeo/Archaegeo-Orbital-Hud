## How to Install
1. Scroll down the the **Assets** and click on **`ArchHUD.zip`**, this should trigger a download for this file.
1. NOTE: When extracting ZIP file, be sure to check option to keep directory structure if available.
1. Unzip the file to %ProgramData%\Dual Universe\Game\data\lua\autoconf\custom (or equivalent directory if you did not do default install), this will create an `ArchHUD.conf` file and a `archhud` sub directory in `..\custom`
1. (NOTE: This will also create an ArchHUDGFN.conf for use on GeForce Now or without the require files.  It will have a version number starting with 0.7XX when installed, the Modular will be 1.7XX+)
1. If using a databank, manually link the databank to the control unit(s) that will be running the HUD PRIOR to the next step.
1. In-game, right click your seat and go to Advanced -> Update custom autoconf list - If you get a YAML error, you did not follow the above directions correctly.
1. IMPORTANT: Right click the seat and set the user control scheme to Keyboard (Advanced -> Change Control Scheme -> Keyboard). This is necessary for the HUD to work, but you can change the actual control scheme in the hud - fear not virtual joystick aces!
1. Again, right click your seat and select Advanced -> Run Custom Autoconfigure -> ArchHudX.XXX
1. To most easily set up user preferences the first time, right click the seat and choose Edit Lua Parameters. Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for how to change settings otherwise.
1. If you have a Databank installed on your vehicle your parameters will save when you stand up. Saved parameters will be restored any time you upgrade the HUD to a new version. 
1. Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for an explanation of all settings.
1. Keybindings are described at: https://docs.google.com/spreadsheets/d/1r0yxjozlpa7SXZM_wLtOmIoG-8DXc6-buFe2Pz_OpM0/edit?usp=sharing 

FOR SOUND SUPPORT:
1. Download the archHudSoundPack.zip file found at https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/archHudSoundPack.zip. 
1. Extract the `archHudSoundPack.zip` to Documents\NQ\DualUniverse\audio folder (you might need to create the audio sub folder).  This should result in a subfolder named `archHUD`
1. NOTE: Any sound file in the audiopack may be replaced with a different sound file using same filename if you choose to personalize.
1. NOTE: If you dislike any particular sound and do not want to replace it but still want the other sounds, simply remove its .mp3 file from the soundpack folder.
1. Voices can be turned off by setting `voices` user variable to false.  Alerts can be turned off by setting `alerts` to false.
1. Sound volumes can be controlled by the `soundVolume` setting, which defaults to 100.
1. `Alt-7` will toggle all sounds on or off
1. ***IMPORTANT:*** You MUST change the name of the soundpack subfolder and the userVariable `soundFolder` to something other than "archHUD". Use /G soundFolder NewName in lua chat once changed or update in globals.lua
This is to prevent others from making your PC play sounds they think you have installed.

At this point you should be ready to fly!

# Latest Changes
