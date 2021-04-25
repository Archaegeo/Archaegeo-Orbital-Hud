
<!--Intro information-->
# Arch-Orbital-HUD
## A general purpose HUD for Dual Universe, based on DU Orbital Hud 5.450 and earlier
#### Cockpits are *NOT* supported.
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

##### :warning: Autopilot (Space) - Ensure you have LOS (line of sight) to the target body before engaging as autopilot is direct flight and does not detect bodies (will fly into a planet / body if in between starting position and destination).
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

## 2) On the right side of this page, locate and click on "Releases" or select the "Release" listed as the latest. Detailed changelog and installation instructions are located there.

##### 3) Post-installation Note:
##### :black_small_square: This HUD uses on-screen buttons, and so needs to be able to use your mouse. The only way to keep DU from trying to use your mouse for input is to set the Control Scheme to Keyboard. You can then right click the seat, Advanced -> Edit LUA Parameters and find the checkboxes to choose which control scheme you would actually like to use.

[Return to Table of Contents](#table-of-contents)
<!--Table so user can quickly find keys to use-->
# Usage
#### The HUD makes use of on-screen buttons and keyboard controls. An overview followed by more detailed descriptions are below:

| Item | Key(s) | Brief Description|
| --- | --- | --- |
|UI Overlay|Hold __SHIFT__|Displays the UI overlay with mouse-over buttons. Hover with mouse over a button (not click!) and let go of SHIFT to select it.|
|Save Location|Hold __SHIFT__ then selecting the __Save Position__ mouseover| Will save the current location in the databank (if installed). This location may be selected by the autopilot option to automatically fly to the destination.  It will _not_ monitor for impeeding structures or ships. Monitor during use. Locations will be named by planet/moon and a number.|
|Update Location|Hold __SHIFT__ then selecting the __Update Position__ mouseover| Select a previously saved location in the Interplanetary Helper to change its name with the name of the closest atmo radar target name. This is a workaround until manual editing/naming of locations is available.|
|Freelook|__Option 3__, or __ALT-3__|Toggles freelook camera|
|Autopilot Destination / Destination Select|__Option 1__ and __Option 2__, <br/>__ALT-1__ and __ALT-2__ or <br>__SHIFT-R__ and __SHIFT-T__|Cycles through autopilot destinations (planets / bodies / saved waypoints).|
|Autopilot|__Option 4__, or __ALT-4__|Alt-4 will fly to selected waypoint. Alt-4-4 will perform orbital hop to same player waypoint.|
|Lock Pitch|__Option 5__, or __ALT-5__|Will lock your target pitch at current pitch and attempt to maintain that pitch (this is different from Altitude Hold) Most other AP features will cancel Lock Pitch.
|Altitude Hold|__Option 6__, or __ALT-6__|Toggles the altitude hold functionality. Tries to keep the current altitude in spite of planetary curvatore. Depending on ship's lift/force, the actual height may be less than the targeted height! Adjust altitude with (left) __ALT-C__ (down) and (left) __ALT-SPACE__ (up) in increments (growing increments if key is kept held down).|
|Vanilla Widget Look|__Option 7__, or __ALT-7__|Toggles vanilla widget look|
|Follow Me|__Option 8__, or __ALT-8__|Engage follow mode if you are using Remote Control.|
|Anti-Gravity Generator|__ALT-G__ (default mapping) or <br/>HUD button|Once engaged, hold __ALT-C__ to lower target height or __ALT-Space__ to raise target height. The AGG's actual height will only change at 4m/s up or down toward the target altitude. Initiate new target altitude before leaving seat and AGG will continue changing.|
<!--Messy Messy details. This needs to be cleaned up.-->
| Item | Detailed Description|
| --- | --- |
|User text input|To use, hit __TAB__ and then __ENTER__ to send messages to LUA Chat (this will not cause the known tab fps slideshow if the chat tab is open first).<br>*Currently supported commands:*<br>__/commands__ - shows command list and help<br>__/G *VariableName value*__ - changes the global variablename (corresponding to the same-named LUA parameter) to the specified new *value*. Note: names are case-sensitive!<br>Examples:<br>__/G AtmoSpeedLimit 1300__ sets that LUA parameter to 1300km/h or __/G circleRad 100__ would shrink the artifical horizon down to 100 from default 400.<br>__/agg *height*__ - Sets the AGG target height to *height* (in meters). Note that it must still move to this height at 4m/s like normal.<br>__/addlocation *savename waypointpaste*__ - Adds a new saved location based on waypoint. The *savename* must not contain spaces/blanks! Not as accurate as going to location and using Save button.<br>__/setname *name*__ - renames the current selected saved postion to "name"|
|UI Overlay|Hold __SHIFT__ to show the UI overlay with buttons (not in freelook!). Mouse over a button and let go of __SHIFT__ to select it (not clicking it). While holding SHIFT, press R/T (speedup/speeddown) to cycle between autopilot targets.|
|Free Look|__ALT__ is now a toggle for free-look. Because of the way we had to use Keyboard mode, it can't re-center when you lock it back, but that can be desirable in some situations|
|Autopilot Destination / Destination Select|__ALT-1__ and __ALT-2__ (__Option1__ and __Option2__) to scroll between target planets for Autopilot and display. This also works using SHIFT-R and SHIFT-T to scroll. This widget will not display if no planet is selected (ie you must press one of these hotkeys after entering the seat in order to show the widget)|
|HUD Toggle|__ALT-3__ toggles the HUD and other widgets off/on. Orbital display and autopilot information will still show if HUD is off. There is a parameter you can set to have HUD and Widgets on at same time.|
|Autopilot|__ALT-4__ to engage Autopilot for interplanetary travel, if you are in space and have a planet targeted. Ensure you have a clear line of sight to the target. This will align to the target, realign slightly to point 200km to the side of the target, accelerate, cut engines when at max, start braking when appropriate, and hopefully achieve a stable orbit around the target. You can set your target orbit distance in parameters, default is 100km. Recommend do not go less then 35km.
|Lock Pitch|__ALT-5__ (__Option 5__) will lock your pitch at current pitch and attempt to maintain that pitch (this is different from Altitude Hold) Most other AP features will cancel Lock Pitch.|
|Altitude Hold - |__ALT-6__ to toggle Altitude Hold. 
|Follow Mode|__ALT-8__ will toggle Follow Mode when using a Remote Controller. This makes your craft lift off and try to follow you wherever you go via hover/vBooster engines and tilting the ship. It will not go below ground unless you dig out a big enough hole that it would naturally go down while hovering.|
|Toggle Gyro|__ALT-9__ to toggle a linked gyro on or off. If a gyro is installed on your ship, this will change your ships perceived orientation from Core to Gyro. This is used to allow you to control flight based on gyro orientation and not core orientation.|
|Radar|Radar indicates below minimap number of targets or if it is jammed (atmosphere in space or space in atmosphere). The radar widget only pops up if targets are detected. The periscope widget only pops up if you click a target and successfully identify it. All widgets close automagically.|
[Return to Table of Contents](#table-of-contents)

<!--This should go somewhere else, I'm not sure where yet.-->
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

