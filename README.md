
<!--Intro information-->
# Arch-Orbital-HUD
## A general purpose HUD for Dual Universe, based on DU Orbital Hud 5.450 and earlier

### NOTE: Version 1.6XX+ is a modular version that uses require files and will not work on GeForce Now. Use version ArchHUDGFN.conf for GEForce Now.

###### For assistance, see my personal [Discord](https://discord.gg/CNRE45xRu7) or the OSIN discord channel [Discord](https://discord.gg/9RD3xQfYXG)
###### Donations are accepted but not expected. You may donate to Archaegeo in game via Wallet or to https://paypal.me/archaegeo for Paypal.
<!--TOC-->
# Table of Contents
| |
|------|

|[Change Log](./ChangeLog.md) |
|[Warnings](#warnings)
|[Installation](#installation)|
|[Usage / Hotkey Reference](#Usage)
|[Variable Persistence](#variable-persistence)
|[Customization](./UserSettings.md)
|[Examples and Tutorials](#examples-and-tutorials)
|[Credits](#credits) |
<!--List of features both shorlist and expanded details-->
# Features List (More coming, for now use this link)
https://docs.google.com/document/d/1HcoCwX9QqZt6SBJYQAZOf7sYLWXVJeUnE68RndYnPDY/

[Return to Table of Contents](#table-of-contents)
<!--Warnings and disclaimers-->
# Warnings
##### DISCLAIMER: We do not accept any responsibility for incorrect use of the autopilot, which may result in fiery reentry, mountain impacts or undesired entrance into PvP. Read and heed the warnings below!
#### :warning: Auto-Rentry - Not suitable for bodies without atmosphere. 

[Return to Table of Contents](#table-of-contents)
<!--Basic install instructions / point them towards real install instructions-->
# Installation

|This section is broken down into three parts.|
| --- |
|1) Pre-installation notes.|
|2) Instructions to locate the release (which also contains install instructions).|
|3) Post-installation notes.|
|Please read this section in its entirety before proceeding with the installation.|

##### 1) Pre-installation Notes:

##### :black_small_square: Button - If manually connected to the seat, will be pressed when you enter (sit), and open / extend when you exit (stand).
##### :black_small_square: Databank - Although not required, we recommend a databank to be used. This allows the HUD to save your user preferences and some long-term variables.  In addition, flight status is saved if you leave and return to the seat.  Databanks must be manually slotted the first time you install script.
##### :black_small_square: Doors / Forcefields - If manually connected to the seat, will close / retract when you enter (sit), and open / extend when you exit (stand). Ensure they are closed / retracted before connecting to the seat.
##### :black_small_square: Fuel tanks - If _not_ manually connected provide a rough estimate of fuel levels (set parameters for fuel tank handling, fuel tank optimization, and container optimization). If manually connected, more accurate readings are provided and a non-HUD widget is updated.

## How to Install
1. Scroll down the the **Assets** and click on **`ArchHUD.zip`**, this should trigger a download for this file.
1. NOTE: When extracting ZIP file, be sure to check option to keep directory structure if available.
1. Unzip the file to %ProgramData%\Dual Universe\Game\data\lua\autoconf\custom (or equivalent directory if you did not do default install), this will create an `ArchHUD.conf` file and a `archhud` sub directory in `..\custom`
1. If using a databank, manually link the databank to the control unit(s) that will be running the HUD PRIOR to the next step.
1. In-game, right click your seat and go to Advanced -> Update custom autoconf list - If you get a YAML error, you did not follow the above directions correctly.
1. IMPORTANT: Right click the seat and set the user control scheme to Keyboard (Advanced -> Change Control Scheme -> Keyboard). This is necessary for the HUD to work, but you can change the actual control scheme in the next step - fear not virtual joystick aces!
1. Again, right click your seat and select Advanced -> Run Custom Autoconfigure -> ArchHudvX.XXX
1. To most easily set up user preferences the first time, edit the `globals.lua` file inside the `archhud` sub folder. You may also change control scheme using a Button while seated and change all other user parameters. Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for how to change settings.
1. If you have a Databank installed on your vehicle your parameters will save when you stand up. Saved parameters will be restored any time you upgrade the HUD to a new version. 
1. Please see https://github.com/Archaegeo/Archaegeo-Orbital-Hud/blob/master/UserSettings.md for an explanation of all settings.

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

##### 3) Post-installation Note:
##### :black_small_square: This HUD uses on-screen buttons, and so needs to be able to use your mouse. The only way to keep DU from trying to use your mouse for input is to set the Control Scheme to Keyboard. You can change the control scheme once in seat using SHIFT while not in freelook.

[Return to Table of Contents](#table-of-contents)

# Usage
#### The HUD makes use of on-screen buttons and keyboard controls. An overview followed by more detailed descriptions are below:
See in game HELP for basic controls.
This section to be updated later.

[Return to Table of Contents](#table-of-contents)
## Variable Persistence
As mentioned briefly above, your custom variables are saved between reloading configurations if you attach a databank to the ship. However, all variables in the program are saved in the databank when you exit the seat. This means it will be exactly as you left it - if you were landed when you got out, it won't jump off the ground when you get it.

This also means that when using autopilot, you can relatively easily move between a seat and Remote Controller; it will be down for a short time while you swap, but everything is saved and it will pick up where it left off.|

[Return to Table of Contents](#table-of-contents)
<!--Does this really need to be in the readme, or some other file? Not sure how often a user would need this information.-->
# Examples and Tutorials

[Return to Table of Contents](#table-of-contents)

# No Autopilot Version
#### There is not currently a working No Autopilot version

[Return to Table of Contents](#table-of-contents)

### Credits

Rezoix and his HUD - https://github.com/Rezoix/DU-hud

JayleBreak and his orbital maths/atlas - https://gitlab.com/JayleBreak/dualuniverse/-/tree/master/DUflightfiles/autoconf/custom

Dimencia and all of his hard math work on the autopilot and other features.

[Return to Table of Contents](#table-of-contents)

