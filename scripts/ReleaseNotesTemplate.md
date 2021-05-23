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

FOR COCKPIT USAGE:
1. Manually connect databank to cockpit.  Run the ArchHUD on the cockpit per normal install instructions above.
1. Install a Programming Board on ship.
1. Manually connect same databank connected to cockpit to programming board.
1. Edit Lua Parameters and set Cockpit to true (This can be done from another control unit via buttons to support both cockpit and chair/remote flying) 
1. Paste the **`CockpitPB.json`** script to the programming board.  Activate programming board before getting in cockpit (or after if visible from cockpit)

FOR SOUND SUPPORT:
1. Download and extract to location of your choice the ZIP file found at https://github.com/ZarTaen/DU_logfile_audioframework/releases 
1. In the `audiopacks` folder of the above extraction, extract the `archHudSoundPack.zip` file found here.  Should result in a subfolder named `archHUD`
1. Any sound file in the audiopack may be replaced with a different sound file using same filename if you choose to personalize.
1. If you dislike any particular sound and do not want to replace it but want other sounds, simply remove its .mp3 file from the soundpack folder.
1. Run the `DU_logfile_audioframework.exe` file found in the extract file, source code is available at the above github site.
1. Voices can be turned off by setting `voices` user variable to false.  Alerts can be turned off by setting `alerts` to false.
1. Sound volumes can be controlled by the `soundVolume` setting, which defaults to 100.
1. `Alt-7` will toggle all sounds on or off
1. ***NOTE:*** You MUST change the name of the subfolder and the userVariable `soundFolder` to something other than "archHUD". This is to prevent others from making your PC play sounds they think you have installed.


At this point you should be ready to fly!

# Latest Changes
