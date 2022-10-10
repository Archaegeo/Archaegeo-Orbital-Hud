## ChangeLog - Most recent changes at the top

Version 2.005
- HUD now accounts for docked ships mass and boarded players mass. (Did not previously) 
    Boarded players mass only counts after 20 tons.  NOTE: I do not think offline boarded player mass is retrievable.
- Ship now sets docking mode when you sit down, default to automatic.
- New User variable `DockingMode` (Default: 2) Docking mode of ship, default is 2 (Automatic), options are Manual = 1, Automatic = 2, Semi-automatic = 3 
- Added Safe Atmo Mass, Safe Space Mass, and Safe Hover Mass to INFO panel.
    These values are 50% of what could be barely moved (Atmo and Space) or just get off pad (hover) (i.e. 50% of m=F/a)
    Exceeding the Safe values will affect AP performance, know your ship's limits before exceeding.
    NOTE: Values are only shown when moving < 5m/s, best used when on ground at heaviest gravity.
- Fixed hud to account for docked ships mass, not previously added to total mass.
- Removed fuel used from INFO panel, still tracked and printed out in lua chat when you exit seat.

Version 2.004
- Fixed radar issue that was preventing periscope view opening for id'd targets.  Periscope gadget will open if target is id'd and selected.  
    Will close if no target id'd.
- Fixed issue with unslotted fuel tank time remaining continuing to show after engine shutoff.

Version 2.003
- Clicking LMB will now make the Buttons pop up, clicking LMB again will make them vanish (old shift key functionality)
    This works whether in freelook or fixed view.  This will not work if mouse is over something that takes priority (other NQ UI features)
    (Thanks to Dimencia for the idea and code)
- You no longer need to be out of freelook mode to click buttons.
- Shift key no longer does buttons, now just a modifier for other keys as shown in keybinds section of manual.
- Fixed fuel tanks showing huge number of days time remaining
- Remove `FullRadar` user variable, no longer needed.
- Remove `Collision On` tag up top of hud if no working radar attached.

Version 2.002

- Modified private locations support to require a user variable called privateFile.  Was pointed out that people could use a PB to get the private locations 
    of anyone who flew by just by checking for the old file name.  File will still be looked for in "autoconf/custom/archhud/"
- New User Variabe `privateFile` (Default value "name") Set to the name of the file for private locations to prevent others from getting your private locations. Filename should end in .lua
- Removed SatNav support - not longer maintained since May and saves me 3kb of code for GFN
- Fixed occasional radar error when sitting down
- If not doing Turn and Burn braking, ship will align prograde and roll to 0 when shifting from Aut0pilot cruising to Autopilot braking to make smoother re-entry setup

Version 2.001

- Fuel time remaining updates 8 times faster
- Fix hover/vbooster distance returns affecting flight mechanics
- Fix radar type detection with only space radar

Version 2.000
- Works with Demo/Release.  No major changes from 1.805, just minor internal to reflect new atlas.lua
- Fix GFN issue from 1.800

Version 1.805
- More Radar refactor 
    - Positions for Static, Space, and Abandoned cores now 100% accurate with no trilateration.
    - Dynamic M+ still trilaterated in case they are stationary AGG for collision avoidance.
- Fix (G) Brake Landing not applying brakes if withing ground height when applied.

Version 1.800 
- No Atmo (MOON) IMPROVEMENTS 
    - Alt-6 is now safe to use from no-atmo surface, will not instant take off at current height.  Once clear of ground detect range
        will attempt to establish orbit at indicated height (max surface height+100 if on moon)
    - Brake Landing now works on no atmo surfaces.  Ships with vertical space engines (that push ship downward) will use them when brake landing 
        without atmosphere.  You must be less than 20000m altitude to activate this.
- REFACTOR RADAR TO USE RADAR API 
    - Changed FullRadar to control if Radar Widget is shown.  With FullRadar off, widget is never displayed, but all other radar functions 
        are supported (Abandoned, collision, emergency warp, etc). For FPS gain, FullRadar should be off before getting in seat.
- New user variable, MaintainOrbit, default true, will keep adjusting orbit if it decays when not orbiting to a landing point. 
    (I.e. when you want to stay in current orbit, uses VERY little fuel once orbit established)
- Changed ExtraEscapeThrust to use friction burn speed as your max speed when escaping atmosphere if set to 1.0 
    Setting other than 1.0 will be the value multiplied by your friction burn speed. (Defaults to 1.0)
- Changed Alt-3 from Toggle Widget/HUD mode to Toggle HUD on/off.  With HUD off, only IPH and messages will be shown.
- Fixed ExtraEngineTags having no effect if set to default "none"
- RELEASE CHANGES
    - Measured min space engine heights by hand for the 5 starting atmo planets
    - Added filtering out of Thades Asteroids from IPH if desired.


Version 1.750
- Fix: Alt-4 while in ground detect range will not enter hovermode.
- Fix follow mode to work again (Remote control only)
- If MMB pressed while in throttle mode and holding alt, speed limit will adjust to 0 if > 0 or to AtmoSpeedLimit if 0.
- Cleanup code in numerous places.

Version 1.749 - Enhanced Hover Mode
- If Altitude hold is engaged (alt-6) while in the air but within ground detection height (AGL shows under altitude) 
    the hud will enter Hover mode.  The ship will attempt to maintain the same height above ground rather 
    than a fixed altitude.  This can be cancelled by any of the normal alt-hold cancellation methods, or by raising or
    lowering desired height with alt-spacebar/C or alt-shift-spacebar/C.
    WARNING: It is recommended to only use this mode on agile ships. Speeds > 300k/hr can be dangerous at low heights.
- Fix depreciated function

Version 1.748
- Update the installation instructions shown at the release page.
- Update the user settings page.
- Remove `soundVolume` user variable as is no longer used with NQ sound system.
- Creation of User's Manual https://docs.google.com/document/d/13-Kz1pqbbIHq8HTFLVG1r58D9zxsJe8_eTXezuryfPg/edit?usp=sharing 

Version 1.747
- Fixed buttons not being clickable if freeLookToggle is off (and other keyboard mode issues)
- Fix ECU support to auto-activate AGG if ECU being used as normal ECU and not full HUD ECU and AGG is linked.

Version 1.746 - Full HUD ECU
- Full HUD ECU support: Connect archhud databank to ECU (same one connected to seat/remote). Install ArchHUD Autoconf on ECU.  Activate ECU
    NOTE: ECU's cannot do cruise mode, so some hud features will not function in ECU control (orbital hop, etc)
    When ECU is activated: When you exit seat, if on ground, ECU will activate then turn off, otherwise:
    1) If `ECUHud` set to false, then ECU will behave like normal ArchHUD ECU and Brakeland if in Atmo above ground, or stop if in space.
    2) if `ECUHud` set to true, then ECU will continue normal flight in full hud mode. (This means continuing alt-hold or autopilot if in progress, etc)
    In `ECUHud` mode, throttle will maintain based on what it was when you activated ECU or when you resit if ECU was active in last 3 seconds.
    Also in `ECUHud` mode it appears you can only control bank/pitch/yaw with Autopilot functions (Alt-4, Alt-6, etc)
- New User Variable `ECUHud` Default is false
- Added blinking ECU warning when control is via ECU.
- If ORBIT selected top left, ORBIT screen will only show if coreAltitude > minSpaceEngineAltitude for current planet.
- Created base `blankhudclass.example`.  Rename to `hudclass.lua` to make your own gui for the system. (or delete hudclass.lua to fly with no GUI)
- Fix Yaw bar not showing in space
- Fix ArchHUD-ECU (the old script) turning off if in space near a planet.


Version 1.745 
- Fix for Haven Atmo change, now at 7700m where it goes to 0 (was 15000)

Version 1.744 - Return of Arch ECU
- A new file in the .zip called Arch-ECU.conf.  To use: Install on a ECU and Arm the ECU.
    REMINDER: ECU only works if someone is near it when it activates.  Activates when a control unit (Chair or remote) deactivates.
    If AGG installed, will turn on AGG
    If in atmosphere, will perform a normal ArchHUD brake landing (if no AGG or not at AGG height)
    If in space, will attempt to bring ship to a stop.
- Changed radar and periscope widgets to use preferred creation/destroy method recommended by Ligo vice the autoconf creation.
- Fixed an issue causing a load error if no existing databank in the GFN version.

Version 1.743 - RADAR FPS "bandaid"
- New Global `FullRadar` = true --export: (Default: true) If set to false, radar will not be activate on sitting down.  
    This will result in a much higher fps in crowded areas with radar hooked up while still allowing V to show contacts on screen.
- Added LALT-LSHIFT-LMB action that will toggle radar off and set `FullRadar` to false while in flight or toggle it back on if previously off
    This will result in a large fps increase, but not as large as sitting down with FullRadar already false.
Results: 1318 contacts at Alioth - Mkt 6 sitting on pad
With full normal radar - 8 FPS.
With LALT-LSHIFT-LMB to kill it (FullRadar to false and close widget) while seated - 15 FPS
Getting in seat with FullRadar false (but radars still linked) - 40 FPS
Getting in seat with radars completely disconnected  - 52 fps

Version 1.742 
- Fixed - Shift will no longer press buttons, only leftmouse click.
- Changed EmergencyWarp to work for anytime all conditions met (not just when contact first appears on radar)
- Added FPS to INFO panel. Shown as # (#). # is an 1 second average based on hudTickRate. (#) is a 30 second rolling average


Version 1.741 - Now with Leftmouse Button support
- While not in free look (normal), tap left shift to toggle on buttons and mouse pointer.  Move pointer over button and use LMB to press it. 
    Buttons will turn off. You can tap left shift without pressing lmb to turn buttons back off.
- Emergency Warp Initiation - If in pvp space, and you have a warp target, and enough cells in container, and a radar contact appears 
that is closer than `EmergencyWarp` distance, ship will initiate warp.  (Will still take at least 20 seconds)
- New Global `EmergencyWarp` = 0 (Default: 0) If > 0 and a radar contact is detected in pvp space and the contact is closer than EmergencyWarp value, and all other warp conditions met, will initiate warp.
- Added Friction Burn Speed to INFO panel
- Fixed long term Radar issure of not showing list of friendlies in range (matching tags on active transponders)
- Changed default AtmoSpeedLimit to 1175 (1200 is the floor speed for friction burn damage)
- Modified safezone determination to use new construct function calls.

Version 1.740 - UPDATED FOR Mercury Update (PLEASE LET ME KNOW IF YOU SEE ANY DEPRECIATED MESSAGES)
- Fixed all depreciated functions.
- Fixed: Issue where changing resolutionX and Y in edit lua parameters would not apply if no databank
- Fixed: Moved Vertical Takeoff Button to center to not overlap Route button in some resolutions.
- Updated Radar performance and messages

Version 1.739 - User issue Fixes
- (MODULAR ONLY) Fixed userglobals.lua not having effect (was due to restoring Edit Lua Parameters support)
    Load Order when you sit down: Values from ArchHUD.conf (Edit Lua Parameters) and globals.lua, values from userglobals.lua, values from databank. 
    (So `useTheseSettings` must still be true to override databank).  When you stand up if databank present values save to databank.
- Changed default `MaxGameVelocity` to -1.  If its -1, the first time you sit down it will be set to actual MaxSpeed minus 0.1m/s
- Fixed: During autopilot acceleration, if ships `MaxGameVelocity` > ships actual MaxSpeed, `MaxGameVelocity` will be set to MaxSpeed - 0.2m/s
    This will allow engines to turn off during acceleration phase and enter cruise mode for ships that have too high of a `MaxGameVelocity` set.
- Fixed: Prevent `AutoShieldToggle` turning on shields in pvp space if shield is currently venting.
- Fixed: Incorrect reported distance to Atmosphere when vector would collide with atmosphere

Version 1.738 - Fix Radar for Obstructed changes
- Added support for Obstructed radar, will say Obstructed if that is the issue, Jammed if thats the issue an no opposite radar, or Destroyed if thats the issue.
(If you get Destroyed and its not, it indicates a Radar bug (isOperational() returning 0 when its not Jammed or Obstructed), let NQ know)
- Fixed "Abandoned Radar Contact" sound announcement to only play once ever 5 seconds max.
- Cleaned up active radar determination.
- Added size of abandoned radar contacts to the position printout to help you determine if you should investigate.

Version 1.737 - Edit Lua Parameter support (MODULAR) and Keybindings Doc
- Restored `Edit Lua Parameters` capability (MODULAR ONLY - adds too many bytes to the GFN/Standalone version)
 (userglobals.lua will still override if used as described below in 1.733)
- Using ALT-SPACEBAR while on ground will not make you take off but will change target hover height when you do (instead of default)
- Using alt-shift-2 will now also stop session for boarded vr players as well as booting boarded players (except pilot)
- New Keybindings doc: https://docs.google.com/spreadsheets/d/1r0yxjozlpa7SXZM_wLtOmIoG-8DXc6-buFe2Pz_OpM0/edit?usp=sharing 

Version 1.736
- Fix shield control/info in GFN version.  NOTE: Shield now automatically slots if present in both versions as `shield` vice `shield_1`
- Fix missing damage report info if damage checking is on.
- Fix lua chat error `autoPilotTargetPlanet` in 1.735

Version 1.735 - Fix for Optional Hud
- Fixed missing items that caused errors if no HUD

Version 1.734 - Optional HUD!
- (MODULAR ONLY) - Removed the need for hudclass.lua meaning you can fly without it completely or substitute your own.
Note: To initiate execution of your own you will either need to put it in userbase.ExtraOnStart() in userclass.lua (see help in userclass.example)
and make it call functions in your hud or define function HudClass() in your new hud.  If HudClass is defined in your new hud,
then ArchHUD will try to execute: ButtonSetup(), FuelUsed(), TenthTick(), OneSecondTick(), MsgTick(), AnimateTick(), hudtick() which must all exist even if they 
do nothing.
- Fixed speed overshoot when shifting from cruise to throttle mode during AP re-entry.
- Added HELP window info for ALT-W/S while in space.

Version 1.733
- (MODULAR ONLY) Added support for a custom globals file that is executed after the default globals.lua
    It is looked for in `autoconf/custom/archhud/custom/` and should be named userglobals.lua
- ALT-W in space, not in Autopilot, will toggle Prograde alignment
- ALT-S in space, not in Autopilot, will toggle retrograde alignment
- ALT-S in space, while in Autopilot, will toggle Turn and Burn braking.
- Changed `SpaceSpeedLimit` default to 66000 so engines do not auto turn off in space if not in AP.
    (This limit is so if set lower and you go away from keyboard, your engines will turn off and not
    use all your fuel)
- Changed `MaxGameVelocity` global from 8366 m/s (30k k/hr) to 13888.87 m/s (50k k/hr) (Really this time)
    (You can change MaxGameVelocity now by ALT-MOUSEWHEEL while in space, it will limit you to actual max speed but save if set lower)

Version 1.732
- RADAR CHANGE: Fixed CPU Overload due to too many radar contacts.  Triangulation is only performed if:
    1) AbandonedRadar is true and contact is abandoned OR
    2) Target is within 10s at current speed AND is M+ dynamic, static, or space core.
- New globals `radarX` and `radarY` to let you move radar info.
- Fixed erroneous Finalizing Approach during orbital hops.
- Ships MaxSpeed in space determined every 1 second.  When changing `MaxGameVelocity` it will be limited to MaxSpeed-0.2 m/s
    This means in space you can alt-mousewheel up to change Set max speed to actual max speed as fuel is depleted if desired.
- Changed determination of warping to 27777m/s (100k k/hr) instead of 50k k/h

Version 1.731 - Athena fixes
NOTE: Due to file size limits for the GFN version, ArchHUD is not restoring exported variables for Edit Lua Parameters.
NOTE: Be sure to use /G to change `MaxGameVelocity` to the max speed your ship can go (you can use km/hr with /G or its in m/s if you edit globals.lua)
NOTE: Be sure to use /G to change `SpaceSpeedLimit` to speed you want engines to stop firing if not in autopilot (default 60000, meaning wont turn off if not in autopilot)
- Once a second Max Speed is updated in INFO panel
- Changed `MaxGameVelocity` global from 8366 m/s (30k k/hr) to 13888.87 m/s (50k k/hr)
- When using /G MaxGameVelocity xxxx, the xxxx is inputed in km/hr and stored in m/s.  This is to make it easy to match INFO panel Max Speed.
- Change `SpaceSpeedLimit` global from 30000 k/hr to 50000 k/hr (meaning they will not turn off when not in AP, set lower to make engines turn off if you forget)
- Changed C in Kinematics to 100k k/hr - (Since there appears to be no relativistic mass effect anymore)
- Changed getTime to getArkTime since getTime depreciated.
- Determined actual no atmo height and min space engine for haven (15554,8437)
- Double middle mouse button (clears all AP) no long turns off brakes. (non-Athena bug)
- Fix rockets stopping when in space greater than max atmo speed (non-Athena bug)
- Possible fix for finalizing landing issue (non-Athena bug)


Version 1.730 - Re-Entry and Atmo
- Visited every planet with atmosphere to get actual no atmosphere height. (large difference from official atlas.lua in some cases)
    Updated hud to use measured no atmo heights for low orbit, 11% atmo.
    No Atmo Heights for Madis, Alioth, Thades, Talemai, Feli, Sicari, Sinnen, Teoma, Jago, Sanctuary, Lacobus, Symeon, Ion.
    local noAtmoAlt = {[1]=8041,[2]=6263,[3]=39281,[4]=10881,[5]=78382,[6]=8761,[7]=11616,[8]=6272,[9]=10891,[26]=7791,[100]=12511,[110]=7792,[120]=11766} 
- Fixed re-entry speed braking to prevent element damage.
- Fixed cruise control sometimes not setting properly when AP set.
- Fixed damage report to not report < 1hp of damage.

Version 1.729
- Fix landing gear issues.

Version 1.728 - HUD efficiency improvements (many thanks to Dimencia)
- Updated hud actions for better efficiency including mouse movement.
- Updated virtual joystick responsiveness.
- Removed `apTickRate` user variable as no longer applicable.
- Fix: Fixed AP not resetting after warp arrival.
- Fix: Fixed longtime issue with boosters/hovers not turning off when landed on some ships.  `LandingGearGroundHeight` should now be set
equal to AGL (shown below altitude) when fully landed.  When the ship senses you are within 5M of that height it will completely
shut off hovers/boosters till you hit G, alt-4, alt-6, alt-spacebar, mousewheel up or some other form of taking off.
Note: `TargetHoverHeight` still controls how high you go up when you take off from landed.
- Fix: Fixed mousewheel throttle control being too erratic (move check back to aptick instead of flush)
- Fix: userclass.lua renamed to userclass.example to prevent overwrite when updating.

Version 1.727 - Radar Refactor
- Move radar to once every other flush call performance.  Greatly improved accuracy and timing to resolve position.
- Fix: Radar known position.  Now only true if target pos if within 10m of radar distance to target 
    It was reporting true on first check before due to the abandonded check.
- Fix: Fixed collision action while collision detected in space.  Should no longer continue trying to AP and then collide over and over.
NOTE: If your max brake distance > 2SU (radar range) or it doesnt resolve the contact in time (due to high speed) to brake, 
    you'll still get warning to kiss your butt goodbye.
- Fix: Fixed issue with `PreventPvP` not completely cancelling Autopilot when triggered approaching PvP line.


Version 1.726
- Enhance: AGG on, if not moving, agg base altitude will be treated like ground level by hud.
- Fix: AGG on, will not avoid braking if still aligning on AP arrival.
- Fix: AGG on, Alt-Hold settting to current singularity height if not already in alt-hold
- Fix: AGG on, Alt-C and Alt-Spacebar will lock alt-hold to AGG Target if they start within 10m (fixed alt-c not working)
- Fix: AGG on, Parked at AGG height, will not release brakes when you alt-4 (acts like takeoff, throttle up and disengage brakes)

Version 1.725
- Fix: Fixed mouse cursor rate when using Buttons or virtual joystick due to new flush calculations.
- Enhance: Prevent low Orbit hops resulting in drifting on out to space.  Orbit will re-establish if you drift out of orbit 
    (line turns purple and you exceed initial orbit height) while orbiting to target.
- Change: Altitude Hold altitude will show in meters, not rounded (for ease of comparison with AGG height and others)
- Change: Atmosphere is now determined by the official atlas.lua in all cases as NQ determined that even though planets like 
    Thades has atmosphere() report > 0 till 39000 it is negligble at 31200.  This means alt-4-4 will work on planets like 
    Thades now and your low orbit height will be lower on some planets.
- Fix: Issue with planet not being set causing error when sitting down (deep space issue)

Version 1.724 - MAJOR REFACTOR OF AP FOR RELIABILITY
- Moved almost all AP functionality thats allowed into flush to allow for more reliable performance.
- Added support for user extra functionality for OnStart, OnStop, OnFlush, and OnUpdate - This is instead of 
overriding the base functions and is called when the normal function finishes.  See userclass.lua for more.
- Fix: Brake Landing starting during a low orbit hop sometimes when target is on opposite side of planet.

Version 1.723 - More refactoring for perfomance and cleanliness.
- FIX: Alt 4-4 without any space engines will now default to 11% atmo vice telling you no orbital hop.
- FIX: While AGG is on, Alt Hold (Alt-6 and Alt-6-6) will not auto apply brakes if already at altitude of AGG but moving more than 72k/hr
- REFACTOR: Override and AddOns are now handled in the userclass.lua file.  See the file provided for example usage and instructions.
    You can now override or addon to any of the classes.

Version 1.722
- Enhance: AddOn - Added `userScreen` - If set, userScreen is added to the setScreen diplay info.
- Remove extra `hover` variable from call and receive of userclass functions
- Example waypointeruserclass.lua in the RequireRepositor at github, rename to userclass.lua and put in archhud with other requires to have built in waypointer.

Version 1.721 - Userclass (AddOns) support
- Feature (MODULAR ONLY): if `userclass.lua` is present in the `archhud` subfolder with other requires, it will be loaded during startup.
    At the end of the normal script events (startup, flush, update, stop, control start/stop/loop, radar enter/leave, tick)  
    the script will check if the associated function exists from userclass and if present will call the function with the slotted variables
    passed (since they are not considered global for some reason). This will allow users to add on any additional functionality they wish 
    An example userclass.lua is provided but does nothing.  
    Note: This is not meant for overriding portions of an existin class (already supported) nor for replacing a class (you can do that if you wish)
    Note: In the passed variables, c = core, u = unit, s = system 
- Enhance: Abandoned message will indicate type of contact found.
NOTE: Abandonded ::pos accuracy is intentionally off to be sure to catch as many as possible rather than worry with 2m accuracy.
You can change this at line 132 in radarclass.lua by adding `and construct.skipCalc` to the if line if desired.

Version 1.720 - Abandonded Construct Notification, Radar Brake Landing
- Feature: If `CollisionSystem` is true then during Brake Landing any contact detected below the ship will have its altitude used as brake landing height.
- Feature: If `AbandonedRadar` is true and `CollisionSystem` is true, then all radar contacts will be checked for abandoned status.  Any found will provide a 
    (optional) voice alert and print out the calculated ::pos{} to lua chat.  (Thanks to Wulfrick for the idea)
- New: `AbandonedRadar` user variable. (Default: false) If true, and CollisionSystem is true, all radar contacts will be checked for abandoned status.
- (Optional) New: `abRdr.mp3` added to sound pack to support new Abandoned feature. YOU WILL NEED TO GRAB THE NEW SOUNDPACK (or at least this file out of it and add to existing)
NOTE: In crowded areas Abandoned hunting could have a large impact as all contacts are triangulated instead of all statics and M+ dynamics.  Leave False if not hunting.
- Replaced solarsystem.json with waypointer.json for those who want AR in atmo (EasternGamer script, place on PB, link to core and ArchHUD databank (optional))

Version 1.719 - Panacea Sound Support
- Fixed HUD to support sounds under Panacea.  To use you must download and extract the updated archHudSoundPack.zip to
the Documents\NQ\DualUniverse\audio folder (might need to create audio folder).  This will create a subfolder named 
archHUD which must be renamed (to prevent others from playing sounds in it).  Once you rename it, in game in seat, 
use /G soundFolder NameOfFolder

Version 1.718 - AGG, Route, Brake Landing, Pre Panacea
- Enhance: Brake Landing from high altitudes will now be MUCH faster till you reach a specific height. 
    For Unknown Altitude landings (you hit G while flying), this occurs down to the max surface altitude of the planet you are on. 
    Then `brakeLandingRate` will take over.  For Known locations, `brakeLandingRate` will takeover 1000m over the target location.
- Fix: Tapping G while already brake landing will toggle drift limit on and off
- Enhance: "Brake Engaged" down bottom now has support to show reason brake is on.
- FEATURE: Route Pause.  Routes in progress save when getting out and back into seat to allow for stops along the way, or refueling/repairing without losing route progress.
- Change: Routes unload route leg on arrival rather than on starting the route leg.
- Overhaul: AGG system overhauled, should perform as shown in AGG Scenarios below.
- FEATURE: For any custom save point (private or databank) you can select it in IPH and hold shift to choose Save AGG Alt button. (If AGG on ship)
    This will save the current altitude of your ship (minimum 1000m) to the selected IPH WP as the AGG height.  (Will not change position or alignment if on)
    Anytime you AP to a waypoint with a saved AGG Altitude the ship will turn on AGG if off and set AGG Target Altitude to that value.
    If a WP already has a AGG Altitude, you will see a Clear AGG Alt button instead to remove it.
    NOTE: It is assumed if you AP to a wp with a saved AGG height, you want to arrive at AGG height.  You can turn AGG off after it gets turned on if desired.
- Enhance: Added indication if brake landing has drift limit on (0.5m/s horizontal movement causes brakes to engage even if not at brake fall rate)
- PANACEA: Soundpack will not work till first patch after panacea.  Also removed logging of private locations to logfile, so will need screen now.
- Removed: STARTINGPOINT feature removed.  Too clunky and not enough use to justify, niche feature.
- Remvoed: User variable `CalculateBrakeLandingRate` - Depreciated (and didnt work properly before.)
- More Cleanup

AGG Scenarios
NOTE: Alt-4 to a WP with a Saved AGG Altitude (new Feature) will turn on AGG (if off), set the target height to the saved value, and use that height.
NOTE: Anytime AGG is on and Altitude Hold is engaged, Hold Altitude will be set to current base agg altitude and change with it if agg altitude is changing.
- 1) On ground, AGG off, Alt-4 to same planet WP.  User throttles up and released brake, normal takeoff.  Turn on AGG prior to arrival:
    a) Current height above AGG height, Brake Landing use AGG height as target landing height and turn off with brake on at that height.
    b) If current height is below AGG height, ship will do normal brake landing.
    c) Turning on AGG during takeoff changes takeoff height to AGG height.
- 2) On Ground, AGG on, Alt-4 to same planet WP.  Same as 1c.
- 3) In air at AGG height, AGG on, Alt-4 to same planet WP.  Brake releases, levels pitch and aligns, waits for pilot throttle up. Ship heads for WP at current AGG height. Performs as #2 above.
- 4) In air at AGG height, AGG on, Alt-4-4 same planet. Performs as #3 using Orbital Hop.  Comes in at 11% atmo till at target then AGG Brake Lands.
- 5) On Ground, AGG on, Alt-4 to other planet WP.  Ship takes off to other planet as normal.  Arrival is per #4.
- 6) On Ground, AGG on, Alt-4-4. Ship takes off to low orbit height.  Arrival is per #4.
- 7) In Air at AGG height, Alt-4 to another planet.
- Note: Alt-6 from ground with AGG on takes off to AGG height. Alt-6-6 is same as Alt-6 with AGG on intentionally.

Version 1.717 - Enable Space engines to work in <10% atmo with no Atmo engines
- FEATURE: Space Engines will now work in atmosphere if no atmosphere engines are attached, down to normal 9.89% (they turn off at 9.9% normally)
- NEW: axiscommandoverride.lua file contains the override function to support the above feature.
NOTE - This is correcting a vanilla DU issue.
    To use this feature you must either use Modular ArchHUD 1.717 (and the new require file) or you must edit the default AxisCommand.lua in
    `ProgramData\Dual Universe\Game\data\lua` and replace the `function AxisCommand.composeAxisAccelerationFromThrottle(self, tags)` with the one 
    found in axiscommandoverride.lua
- FIX: Issue with landing when aligning.

Version 1.716 - Shield, Cleanup, and AGG.
- FEATURE: Hud will adjust shield resists once per minute to the ratio of damage done if shield percent remaining is < `AutoShieldPercent`
- NEW: User variable `AutoShieldPercent` (Default: 0) Automatically adjusts shield resists once per minute if shield percent is less than this value. (0 means off)
- NEW: shieldclass.lua file and class in standalone
- FEATURE: If ExternalAGG is off, and AGG is activated, Brake Landing will use AGG Current Base Height for landing altitude if it is below current altitude (vice ground).
- ENHANCE: Added `Aligning` after Brake Landing if ship is aligning.
- CLEANUP: radarclass.lua and shieldclass.lua are only looked for if a radar or shield are slotted
- CLEANUP: Removed variables from globals.lua that are not user variables and that are not used outside of one class.
- CLEANUP: Moved onFlush to apclass from baseclass
- FIX: STARTINGPOINT saves as a known location.
- FIX: STARTINGPOINT does not save out to privatelocations.lua dump (it does save to databank which is intentional)
- FIX: Saved locations gravity will all use same value going forward (core.g()) (update locations you care about, value is not used at this time)
- FIX: Double tapping G during Autopilot Brake Landing to turn off and back on Brake Landing will clear the limit on horizontal speed (Brakes on less)
    For when you want to get down faster and don't care about accuracy as much.w


Version 1.715
- CHANGE: Routes now save location name vice index number.  This means routes will continue to work if you add or remove 
    locations not in the route from the custom waypoints.  This does mean old saved routes will no longer function.
- CHANGE: /createPrivate now takes and arguement of all, if all is used, it saves private and databank locations to the 
    output log/screen for cut and paste into privatelocations.lua
- FIX: Official Atlas has wrong atmosphere data for Lacobus.  Added a line to fix till NQ updates official Atlas.lua
- FIX: Added check for SetupComplete to prevent user input prior to hud finishing loading.  (prevents bugs)
- FIX: Made private locations save heading if present

Version 1.714 - Urgent fix for `ExtraEscapeThrust`
- FIX: Prevent `ExtraEscapeThrust` being applied during Reentry or if vSpd < -50 m/s.

Version 1.713
- CHANGE: If `ExtraEscapeThrust` > 0 then AtmoSpeedLimit when <10% atmosphere will now slowly increase actual speed till you hit 0.05% atmosphere where it turns off completely.
    (Formula of extra speed in m/s:  addThrust = (0.1 - atmosDensity)*adjustedAtmoSpeedLimit*ExtraEscapeThrust)
- USERSETTING: New variable `ExtraEscapeThrust` defaults to 0.  If set to > 0, the above CHANGE takes effect.  This is in physics area meaning tweak
    slowly cause large changes might burn you up
- FIX: Fixed time remaining on fuel bars, been gone since 1.707 :(

Version 1.712 - Landing Alignment, Starting Point, and Relativism
- FEATURE: For any custom save point (private or databank) you can select it in IPH and hold shift to choose Save Heading button.
    This will save the current heading of your ship to the currently selected IPH WP.  Anytime you AP to a waypoint with a saved heading
    the ship will try to align to that heading after it finalizes braking as it begins landing. Hitting A or D (manual yaw) will 
    cancel the alignment but not the brake landing.  Saved Heading Brake Landing will be slower due to alignment while keeping accuracy.
    If a WP already has a heading, you will see a Clear Heading button instead to remove it.
- FEATURE: When you hit Alt-4 to start an autopilot, STARTINGPOINT is saved to your databank if on/near ground for ease of return to
    your starting point. It remains in your databank SavedLocations until you clear it or use it. Select the STARTINGPOINT waypoint 
    and hit Alt-4 to go back  to where you began your trip.  This will clear STARTINGPOINT when you arrive. (Will not be created if flying a route)
- FEATURE: When going > 3000k/hr, the INFO panel will show your relativistic mass
- User Variable: `SaveStartLocation` (Default: true) If true, when a user first hits alt-4 to AP somewhere, his current location is saved if on ground.
- FIX: Added fix during brake landing (after finalizing) for correcting horizontal drift by applying brakes on an AP landing.
- FIX: Adjusted alignment requirements when arriving at a planet to be less strict before establishing orbit.
- FIX: /createPrivate now adds line breaks to the log/screen dump to make a readable cut and paste for easy editing.

Version 1.711 - PrivateLocations and Databank together.
- OVERHAUL: PrivateLocations
    - If privatelocations.lua exists, both Private locations and databank locations are used.  Only databank locations are saved.
    - Private locations have a * at the start of their name in the IPH. (any existing privatelocations.lua files will need * added to start of each name field)
    - When adding a location with /addlocation name ::pos{} if name starts with * it is added to private locations.
    - Locations added via the Save button will be added as databank locations.  You can then use /iphWP to get the ::pos and the /addlocation command to add it to private then Clear the databank entry.
    - Use /setname to change names of private or databank locations. Private names should start with *.  Do not use /setname to try to change a databank to a private, use /addlocation as shown above.
    - Use /createPrivate command to output privatelocations in a ready format to logfile or screenHud_1 to cut and paste into a privatelocations.lua
    - Remember clearing a private location does not remove it from the privatelocations.lua file, you must use the /createPrivate command as shown in previous line.
- REMOVED: `PrivateLocations` user setting
- FIX: screenHud_1 is cleared when you sit down.  Be sure to clear it after standing if used for privatelocations so it doesnt save to repair snapshots.
- FIX: When using AGG, hitting alt-spacebar or alt-c to change height will no longer turn off brakes. (AGG moves at same vSpeed brakes or not)
- FIX: Remove outputting privatelocation from /iphWP.

Version 1.710 - Screen support
- Added initial screen support, not required but if a screen is manually slotted it will be available in hud as screenHud_1
- Added /createPrivate command.  If used will dump all customlocations to logfile (till Panacea) and screenHud_1 (if present)
    in a format that can be cut and pasted into a privatelocations.lua file.  For screen, right click screen->advanced->edit
    and copy the material in local text = "" to privatelocations.lua.  For Logfile, find PRIVATELOCATIONS: and copy everything
    after that up to "<\message>" to privatelocations.lua.  See privatelocations.sample for example.
NOTE: If privatelocations.lua exists, the custom saved locations in it will override databank custom saved locations when you sit down.
- Moved more things into hudclass.lua that belong there out of baseclass.lua

Version 1.709 - Feature - PrivateLocations (Modular version only)
- (MODULAR ONLY) If privatelocations.lua exists in the require folder, they are loaded instead of locations on databank.
    USES:   1) Prevents theft of custom wp locations by aggressors who take your ship and use repair feature.
            2) Use same locations on all ships using ArchHUD without copying databank by sharing privatelocations.lua file.
            3) Share locations with others by giving them your privatelocations.lua file.
NOTE: X, Y, and Z must be in world coordinates.  See the privatelocations.sample file for examples.
NOTE: Using privatelocations does NOT overwrite your databank custom locations unless you turn off `PrivateLocations` before standing  up.
- Modified /iphWP command to output both ::pos and world X, Y, Z to lua chat window and to logfile after word PRIVATELOCATION.
    Logfile ability will go away with Panacea patch.
    (privatelocations.lua can be populated by copying the info between [] after PRIVATELOCATIONS: including the {} and replacing
        colons (:) with equal (=) and removing all quotes (") before an equal (=) (i.e. "postion": should be position =))
- User variable: `PrivateLocations` - Default false.  If true, locations do not save to databank when you stand up.
- Enhance: Fuel usage will print out to lua chat when you exit seat for easy of tracking.
- If not flying in AtmoSpeedAssist, speedChangeLarge is divided by 10 to lower mousewheel throttle adjust rate.

Version 1.708 - New Feature, Major Fix.
- FEATURE: INFO panel now shows amount of atmo, space, and rocket fuel used during current flight session.
NOTE: To be accurate `ContainerOptimization` and `FuelTankOptimization` settings must be set to values of person who placed tanks.
- CHANGE: Added `ShouldCheckDamage` button to Control panel above Settings button.
- CHANGE: `ShouldCheckDamage` now defaults to false.  Recommend turning to false unless you are flying a smaller ship (<2-300 elements) or if you suspect you have damage.
- FIX (MAJOR): Fixed issue with ArchHUD flooding logfile with warnings about `setAxisCommandValue` being used in flush.

Version 1.7071 
- FIX: Fixed mouse speed control to be more reliable.
`speedChangeLarge` = 5 -- (Default: 5) The speed change that occurs when you tap speed up/down(R/T) or mousewheel, default is 5%
`speedChangeSmall` = 1 -- (Default: 1) the speed change that occurs while you hold speed up/down(R/T), default is 1%
- FIX: /copydatabank command not working.
- CHANGE: Parachute "deploy" at slightly higher height on parachute re-entry.

Version 1.707 - Finish MAJOR Refactor of ArchHUD.lua
- All code removed from ArchHUD.lua into the various modular files.  ArchHUD.lua is 8kb now and just handles the initial structure and loading of requires.
This requires a replacement of all require files.
- Fixed gyro support in controlclass.lua
- Fixed/Improved: Glide Re-Entry and Parachute Re-Entry
Glide re-entry works like normal.  Parachute re-entry works again and pops the chute at an altitude equal to
(planet.surfaceMaxAltitude+(planet.atmosphereThickness-planet.surfaceMaxAltitude)*0.2), bring your brown pants.

Version 1.706 - Refactor and final modular class definitions
(Recopy all files, existing databank should function normally)
- Moved JayleBrake functions and AtlasClass to atlasclass.lua modular file.
- Refactor: User global variables now minimize shrinking Standalone by 15k minimized. NO END USER IMPACT
    Scripters will notice the format in for databank stored globals in the list variables has changed.
- Updated dynamic help

Version 1.705 (Changed version numbers on Standalone to 0.705 to reflect version number in Modular)
- Fix: Standalone will not unload from seat when exit game or away from ship
- Fix: Mousewheel throttle control
- Fix: Virtual Joystick not working if not in SCOPE mode.
- Removed LastVersionUpdate support (developer use)
NOTE: Throughout code, system, core, and unit have been replaced by s, c and u for space saving in Standalone and consistency in Modular.

Version 1.704 - AP Route Support
- New Featue: Route support - Load, Clear, Save 1 route.
To Setup:  Select a custom wp in IPH.  Press ALT-SHIFT-8 to add it to route.  Keep selecting custom wps and adding to route.
To Save: Click Save Route button
To Clear: Click Clear Route button
To Load Saved route: Clock Load Route button
To Use: Hit Alt-4 to begin route.  If two points are on same planet and more than 50k apart it will try to low orbit hop.
Ship will begin route and will only stop or land at final point.  IPH will update to show leg of route you are on.
Holding SHIFT with a loaded route will display the route or remaining legs if already in progress.
NOTE: If a route is loaded, alt-4 (and AP Button) will ignore IPH selected target and perform the route instead.
NOTE: Route is based off of IPH index position of wp when route created, if you add or remove (not update) custom wp's, 
    route could become invalid.
NOTE: Standalone version (1.5204) might unload from seat for some people

Version 1.7031 - New ControlClass.  All code now readable lua
(all requires updated for consistancy, update all)
- As of this version, in the modular version all code including the ArchHUD.conf is no longer minimized
- create controlclass.lua to contain in readable lua all start, stop, loop, and inputText controls.
- Standalone version (ArchHUDGFN.conf) is now version 1.503

Version 1.7021 - Radar Class modularization
(hudclass.lua, apclass.lua, globals.lua and radarclass.lua (NEW) updated)
- Restructure RADARCLASS to support modularizaion and override
- FIX: Fixed issue with virtual joystick when NOT in SCOPE mode.

Version 1.701 - SCOPE feature - View of all planets in space around you.
(Updates to hudclass.lua, apclass.lua, globals.lua and base ArchHUD.lua)
- New Feature: SCOPE - To use, hold SHIFT and mouseover SCOPE in upper left, release shift to "click"
This will show you all planets in your ship's field of view.  Control the view by maneuvering your ship.
You can zoom in by holding SHIFT and mousing over +. Zoom out by mousing over - or 0 while holding shift.  
While zoomed in you can get info on the distance to your cursor.
- FIX: Prevent hud being off due to settings view when exiting seat preventing hud on return to seat.
- Fixed Alt-3 to swap to complete vanilla view hiding everything unless `hideHudOnToggleWidgets` is false.  Will still show vSpd Meter if `AlwaysVSpd` is true.
- User variable `DisplayOdometer` is back default true, set to false to hide top bar (but not the upper left tab buttons)
- Setting `circleRad` to 0 will make NavBall go away.  Setting `fuelX` and `fuelY` to 0 will make fuel bars go away.  Etc for other positions.

Version 1.700
- Update to increment version number to clean point after rollback from 1.606 to 1.604
- Include fuel cell appeareance and flightStyle tags.

Version 1.604 - Localization of main .conf and require files
- MANDATORY UPDATE: hudclass.lua, apclass.lua, customapclass.lua and customhudclass.lua (If using modular)

Version 1.603 - Override Function support for require files
(Default hudclass.lua and apclass.lua updated)
- FEATURE: Provided support for Override require files to override specific functions without changing the default require file. (Thanks Davemane42 for format)
To Use: Uncomment the line at the bottom of the default require file, then put things in the custom/override file.  See files for more info.
This is an advanced flexibilty feature that is provided for those who want to change stuff in the default require files but not lose their
changes when the default files are updated.
- hudclass.lua FEATURE: Changed fuel tank display to color code bars by type and to put a small gap between types. (Thanks Zrips!)
- hudclass.lua FIX: Fixed issue with buttons not being showable if in keyboard mode and freelook toggle is off.  (Hold alt-shift to see buttons)
- apclass.lua: Moved more AP features out of .conf into apclass.lua, exposing a lot more to end user modification if they wish.
- Removed user variable `WipeDamage` and its code support since a repair unit can roll back a databank to last autosnapshot.

Version 1.602 - New Dynamic Orbit Map
REMINDER - For GEForce Now you need to use the provided ArchHUDGFN.conf standalone version which will install with the modular version.
It has a version number when loaded of 1.51X+ where the modular one is 1.6XX+
- New Feature - Dynamic Orbit Panel. When the Orbit panel is selected, it is now dynamic, showing more when in atmo, going to orbit, and if you escape orbit, the galaxy.
- hudclass.lua FIX: Typo in hudclass.lua that caused text not to line up properly up top at higher resolutions.
- New Folder on github: RequireRepository - has working replacements for the require files.

Version 1.600 - Modularization of ArchHUD for easy user changes. DOES NOT WORK ON GEFORCE NOW (use 1.515 for GFN)
- Major overhaul to code structure to support modularization. NOTE: Change to any "require" file does not require recompiling or reloading
of the autoconf file.  "Require" files are loaded each time you get into the seat.
PROS:
    + Allows users to easily modify or replace anything in the require files
    + Allows for easy updating without needing to recompile autoconf
    + In plain "lua" vice minimized so easy to understand and modify.
    + Error reports are much easier to analyze and track.
CONS:
    - Cannot be used on Geforce Now.  Continue to use the GeForce Now version (1.515)
The following "require" files have been created:
    * globals.lua - Has all user settings in it for easy modification and contain different position settings for 1920x1080 and 2560x1440.
    * apclass.lua - This is the file that has all of the Autopilot handling
    * hudclass.lua - This contains all of the material dealing with the appearance of the hud and buttons
    * hudclassOrig.lua - This is the previous look to the hud. Just rename it to hudclass.lua to have it be in effect.
    * globals2560x1440.lua - This is an example globals set up for 2560x1440 resolution.  Just rename it to globals.lua to have it be in effect.
To USE:  Download the ArchHUD.zip on the Release page and extract it in your %ProgramData%\Dual Universe\Game\data\lua\autoconf\custom directory.
This should create an `ArchHUD.conf` like normal, and a subfolder named `archhud` that has the 3 require files in it.
NOTE: When extracting ZIP file, be sure to check option to keep directory structure if available.

Version 1.515 - MAJOR Update to HUD appears (Thanks Dimencia!!)
- Major: Change to appearance of HUD
- Removed depreciated user settings of `showHelp`, `ShowOdometer`, and `DisplayOrbit`
- Fix: Moved Toggle shield from `LALT-LSHIFT-5` to `LALT-LSHIFT-7` - This lets `LALT-LSHIFT-5` work again to set locked pitch to 
        user value of `LockPitchTarget`.  Normal `LALT-5` still does lock pitch to current pitch.
- Fix: Buttons do not pop up when doing `LALT-LSHIFT-#` only when holding `LSHIFT` and not in freelook.

Version 1.513
- FIX: AP to non Custom Waypoints works again (was throwing errors when braking and circulizing orbit was supposed to begin if non custom waypoint)
- CHANGE/FIX: If WipeDamage is reached, HUD will delete all saved locations and then update databank (all other settings remain).

Version 1.512 Handbrake, Scrolling AP, Databank Security
- New user variable: `WipeDamage` default of 0
- Feature: If `CheckDamage` is true, and ships percent damage gets < `WipeDamage` then the ship will wipe the databank 
to protect against pirated waypoints.  Set `WipeDamage` to the %damage below which you want the databank to wipe.
- Feature: You can now see 10 IPH targets at a time and mouse over to start/change AP destination while not in freelook.
To Use: Hold shift and mouse over the "Engage Autopilot: Target" button top center.  This will present a list of 10 targets
from the IPH.  While holding shift you can scroll by mousewheel in first person, or R/T in third person.  Release shift to
start Autopilot to the target under the dot cursor.
- Feature: Handbrake - For those who like vanilla brake mode but sometimes want to lock brakes on, if 
`BrakeToggleDefault` is set to false (vanilla braking) alt-ctrl will toggle brakes on till you hit ctrl again
- HUD Enhancement: Gradiant fog in the Odometer section up top and slight outligning of text to make it stand out better.
- FIX: Fix issue when only 1 radar installed not indicating jammed
- FIX: Issue where Index of IPH was out of bounds causing HUD not to show (but still function)
- FIX: Hitting ALt-4 to stop Autopilot will cancel everything that tapping brakes on does.
- FIX: Fixed rare speed control issue
- FIX: If you change `AtmoSpeedLimit` with /G the new value will become the current limit (no need to alt-mousewheel up/down to change it)
- CHANGE: AP close to planet will use normal AP if > 1.5 time TargetOrbit shown on IPH.  This should not cause any issue
unless you lower your TargetOrbitRadius < 1.2 and are heavy or have a poorly braked ship. 

Version 1.511 - Fix issue on new installs
- Fixed issue with new installs not showing hud if no target selected in IPH.  (Alt-1/2 will fix 1.510)

Version 1.510 - AP Fix and InHud Dynamic Help
- Change/Fix: Changed autopilot activation to use quicker normal autopilot vs slower orbit re-entry if greater than 2 times 
Target Orbit shown on IPH to save time and prevent strange behavior at some planets.  This means that hitting alt-4 after 
warp arrival will do a normal AP approach versus starting trying to slow orbital entry from 100k out at Talemai warp arrival 
for instance.
- Default `TargetOrbitRadius` changed to 1.2 from 1.4. Can be reduced more base on your ships performance.
REMINDER: A default `TargetOrbitRadius` of 1.4 is a target orbit of 55k over alioth, where 1.1 is 17.6k.  1.25 is safe for most 
ships.  You can lower it based on your ships ability to stop.
- Restored and enhanced in hud dynamic help system.  Can be turned off with button in upper left of control button panel or setting
`showHelp` to false. Let me know if i missed any you feel need to be there.

Version 1.507
- Fixed: `PreventPvP` if true will no longer stop you LEAVING PvP space, only from entering.
- Fixed: Burning up components on re-entry due to being stuck in cruise control at higher than throttle limit speed in low gravity planets (Lacobus)

Version 1.506 - Thanks to Dimencia for AP enhancement/fixes.
- Corrected space waypoint autopilot stop distance to work more accurately and reliably
Example: With a space wp saved at 3.2 SU from Alioth, taking off from alioth to it stopped 5.7k from it with the
default `AutopilotSpaceDistance` setting of 5000.  (The .7k is due to Alioth gravity pulling from behind) 
Hitting Alt-4 again after first stop will take you to the `AutopilotSpaceDistance` setting.  You can consider
lowering the setting, but bear in mind if approaching a savepoint in space near a planet the planet could pull
you in closer.  Also bad brakes or being very overweight might cause an issue.
- Fixed issue where you couldn't AP to destination if there was a planet behind it
- Fixed issue where during low-speeds, autopilot would not turn to face the target
- Allowed autopilot realignment to occur at much lower speeds (50m/s instead of 300m/s)
- Fixed issue with radar being mislabled on No Contacts line in some startup cases. (Radar was working fine)

Version 1.505
- Added text indication of which radar is running when No Contacts shown.
- Fixed errors of 1 radar ships
- Removed 1.501 Lacobus change since data now in official atlas.lua


Version 1.504 - Dual radars support on same control unit
- Fixes to roll control and autopilot accuracy by Dimencia
- Added support for autoswap between atmo/space radar on same seat/control unit.
    To use: connect both radars to seat, rerun hud, look at seat and hit CTRL-L, you should see radar_1 and radar_2
    Ship will use the appropriate radar based on in atmo or in space.
- Removed `Cockpit` user variable and cockpit code and cockpitPB.json since cockpit works with the hud now.

Version 1.502
- Added support for XS space fuel tank.
- Added user variable `AutoShieldToggle` set to true.
- Added autotoggle of shield if ship has shield, `AutoShieldToggle` is true, and ship crosses PvP line.  
    Will toggle on when crossing into PvP, off when crossing out.
- Added user variable `PreventPvP` set to true
- If `PreventPvP` is on, Autopilot will disable and brake if you get within brakedistance + 10km of the pvp line.
    This should help both new players and those going to asteroids but not knowing wp is across line.
    Toggling PreventPvP off or going 10km beyond the PvP line into PvP space manually will let you restart AP.
    This will NOT prevent you from manually crossing the PvP line, just from AP taking you into PvP unintentionally.

Version 1.501
- Added /deletewp command to delete current selected custom wp.
- Added planet data that was missing from official atlas.lua for Lacobus

Version 1.500 - Overhaul to use New Atlas
NOTE: Possible that existing save points might throw an error when you try to select them on the IPH. 
If it does, you can resave it (and live with the one that wont come up) or make a new databank.
Any save location that shows will work fine.
- Added version check capability to force updates that can be overridden.
- Updated HUD to utilize the new atlas.lua provided by NQ

Version 1.414 - Demeter update
WARNING - Autopilot was tested on Alioth, and Alioth to Sanctuary and back.  
Use unattended Autopilot at your own risk the first time going to any location.
- Removed build helper.
- Removed coreoffset (fixes repair arrows)
- Fixed depreciated functions

Version 1.413 - Reminder: Alt-T docks/undocks your ship, this is vanilla default.
- Removed dynamic in hud help stuff to save script space.
- Added LALT+LSHIFT+1 to see all passengers on board and their mass in lua chat.
- Added LALT+LSHIFT+2 to Deboard all passengers on board (will not boot you from seat)
- Added LALT+LSHIFT+3 to see all docked ships and their mass in lua chat.
- Added LALT+LSHIFT+4 to undock all docked ships.

Version 1.412 - NOTE-ARES patch causes a HARD Crash To Desktop with no crash detection if you Edit Lua Parameters on the seat/remote with ArchHUD installed
- Fix shield hitpoint bar change for changes to shield variable call.
- Added shield widget support when alt-3 widget mode is on
- Added core stress widget support when alt-3 widget mode is on
- Added /resist command to set shield resistances.  Values must total 0.6 or less.  Format is /resist 0.15, 0.15, 0.15, 0.15
- LALT+LSHIFT+6 will initiate venting of shields if shield hit points < max hit points and you are not in the venting cooldown timer.
(As a reminder LALT+LSHIFT+5 toggles shield on or off)
- Added new user variable `AutopilotSpaceDistance` default is 5000.  This is the distance you want the autopilot to stop from a space waypoint (useful for asteroid hunting)

Version 1.411
- Added Brake Distance and Time to top Odometer, values are to 0 speed.
- Added extra braking on re-entry if still > AtmoSpeedLimit when you hit atmo.

Version 1.410
- Changed pitch on glide re-entry to user variable `ReEntryPitch` - Default is -30.
ReEntry now will use 'ReEntryPitch' when you are in Freefall height, this will control your approach to atmosphere.  Once at atmo, 'MaxPitch' will take over again.

Version 1.409
TIP: If you are spiraling or flipping on AP or manual button re-entry, its lack of adjustors to stop you when you pitch to -60 initially.
- Changed display values in odometer to G instead of newtons, cleaned up mass numbers to be more readable.
- Fixed collision detect during autopilot start to ignore starting planet AND destination planet
- Fix possible issue with friendly contact list not clearing.

Version 1.408 - Faster Re-Entry and Potentially fixed Madis and other wierd planet approaches
- More improvements to glide re-entry for safer and faster re-entry.  Recommend brown shorts if starting outside low orbit height.
- Change nearPlanet check to be nearPlanet = unit.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000) in attempt to solve some of the wierd planet issues.
Before getClosestPlanetInfluence would return 0 even though right on top of some planets (no gravity felt from planet)

Version 1.407
- Added support for pvpTimer to shield status display.
- Added shield widget when in widget mode (alt-3)
- Added support for shield events to wrap.sh. Only care if you use wrap feature.

Version 1.406 - Engine control and removal of Intruder Alert
- Added toggle support for the `ExtraLongitudeTags`, `ExtraLateralTags`, and `ExtraVerticalTags` engine tag variables.
To use: LALT-LSHIFT-9 will toggle extra tags between states: All, Longitude, Lateral, Vertical, Off.
If not "Off" then up top you will see (All) or (Longitude) etc beside travel mode
Example Use: "/G ExtraLongitudeTags light" in LUA Chat will make only engines with where you have added tag of "light" fire in longitudinal direction if in mode All or Longitude
NOTE: When toggled on, only Engines WITH those extra tags will fire, others will not.
NOTE: If toggled, all engines are turned off, otherwise the ones without tag will keep firing at current strength.  Recommend toggling when stopped or can safely glide a moment.
Remember you can MMB to jump from 0 to 100% throttle.
- Given that boarding another players construct without permission is now an Exploit, removed Intruder Alert system from HUD
https://discord.com/channels/184691218184273920/748512451967975424/868105796297306172

Version 1.405
- Added Shield support for PTS.  Display in upper right.  `shieldX` and `shieldY` user variables to move it. LAlt-LShift-5 will toggle shield off and on.
NOTE: Shield is manually slotted, this means you must hook it up to chair one time like with fuel tanks or databanks or radar.  Then HUD will remember.

Version 1.404
- Fixed Glide Re-entry to not spam throttle/cruise modes and to properly switch back to throttle mode when doign AP Re-Entry (already did manual)

Version 1.403
- Alt-6 and alt-4 combos will not initiate autotakeoff (brake and wait for power up) if moving > 70k/hr while AGL detects something. (Before if you alt-4 low altitude it would brake and set up for takeoff).
- Changed Glide re-entry height to be either SurfaceMaxAltitude+ReEntryHeight or planet.spaceEngineMinAltitude - 50, which ever is lower.
- Changed manually initiated (button) glide re-entry to not align to selected IPH target (use Autopilot to align to target if desired)
- Changed user variable `ReEntryHeight` = 100000 so that it will always use 11% atmosphere for re-entry UNLESS you want to set it lower. 
NOTE: Existing installs will require manually changing that variable. In the LUA chat window, type "/G ReEntryHeight 100000" 
NOTE: `ReEntryHeight` is added to surface max altitude so setting it to 0 would mean you want to potentially hit a mountain.  if Re-Entry height + surface max altitude > space engine kick on point, it uses
11% atmosphere instead.
- Fixed AP Re-entries to indicate re-entry still in progress rather than looking like AP is off and just doing Altitude Hold.
- Removed default vanilla "turnAssist" and its associated variables
- Fixed 11% atmosphere calculation to be more accurate for all planets.
- Changed Max Mass display up top (based on forward thrust) and in IPH on right (based on brakes) to 50% of previous value to help show a more realistic limit.
(The previous values were the absolute maxes to move forward at all and brake land against gravity speed only)
- Starting AP with mass > max mass will give a 5 second visual warning message.

Verion 1.402
- Fixed Clear Position intermittant bug
- Fixed /setname showing proper selecting in IPH when complete.

Version 1.401
- Comment out timing checks.

Version 1.400 
- Refactored radar into a class and pass info to hudclass.
- Fix for Update Position bug.

Version 1.358 - Fixes and improvements
- Fixed Autopilot to pause if there isnt a clear LOS between you and target destination (for planet to another planet starting in space).
- Changed /addlocation /::pos and Save and Update buttons to save any point outside a planets atmosphere as Space location for AP purposes.
- Added clamp of 500m max change per tick in alt when holding alt-C or alt-Spacebar to raise and lower set heights. (Help prevent driving -5000m target low)
- Added space autopilot collision automatic brake action.  Should be very hard to trigger.
- Added "-COLLISION ON" beside TRAVEL/CRUISE up top when collision system is actively checking for collisions. (system on and > 20m/s speed)
- Added EliasV's timing stuff to .lua but commented out for use in doing efficiency checks when needed. (only scripters care)


Version 1.357 - Collision detection on M or larger unmoving ships (AGG)
- Collision system now includes checking on all static/space cores and all M+ dynamic cores (to catch AGG collisions)
- For keyboard users with freeLookToggle off, holding alt-shift will show the buttons menu (alt-shift-c/spacebar will still work for preset heights)

Version 1.356
- Added `LockPitchTarget` user variable, default 0, and alt-shift-5 setting to target pitch.  Alt-5 will continue to lock pitch at current pitch.
- Altitude Display is Red if below sea level (0 m), orange if 0 to max surface altitude on current planet, normal hud color if > max surface altitude.
- Changed collision system to only check for collisions on known contacts when moving > 20 m/s (72km/hr) as damage doesnt occur before then.  
- Clean up vSpd meter.
- Updated dynamic help text.

Version 1.355 - Changed limits for counting of contacts when in space to avoid CPU overload while AP in space

Version 1.354 - Fix small issues, massive efficiency improvement of collision
- Numerous improvements to collision detection efficiency.
- Improvement to Flight Assist (Hard bank with Alt-Q/E and 180 with ALT-S).
Now if you hit ALT-Q/E/S while already in a ALT-Q/E/S it cancels and you can then
immeditately ALT-Q/E/S again.

Version 1.353 - Turn off debug info 
- Turned off spaming of ::pos debug info.

Version 1.352 - Space Collision support and intersect refinement
- Added support for collision determination when in space.  Only warnings at this time.
- Change how collision intersect determination is made to 1/2 diagonal of ship size + 1/2 diagonal of
possible collision target size.
- Improved performance of collision recognition


Version 1.351 - Fix AP to another planet issue introduced in 1.350
- AP will now detect intersection like it did in 1.320 and earlier.

Version 1.350 - Collision Detection and Avoidance System (Atmospheric Static Contacts)
(MANY THANKS to both Dimencia and EasternGamer for tons of help over the past week developing this system.)
Collision System is on by Default.  Alt-7 to toggle it on/off.  Also settable by user variable or shift button. 
NOTE: With collision system on, there is very little room for other scripts to avoid CPU overload if in high count contact area.

Collision is detected by your vector of flight, not direction you are facing.
When you get in seat with atmo radar connected you will see X/Y Building : Z Ships.  X is known location, Y is total buildings.
Z is total ships (Y + Z is total contacts).  The system will identify the location of the statics (buildings) and then use them
in the warning and avoidance system.

Manual Flight - 3 Levels of Warning - Dull red with countdown timer.  Bright red if you are within 10 seconds of crash. Sound Alarm
if soundPack is active and within 5 sec of crash
AP Flight Avoidance - If in Altitude Hold, LockPitch, or Vector To Target (AP to save on same planet) and not in Autotakeoff, ship will autostop and 
brakeland if you get within 1.5 x current brake distance or within 1 second at current velocity.
- Added landing gear deployed announcement when doing brake landing from up high AP

Version 1.320 - Randomized sound file support (Requirs 1.1.1+ audioframework if using soundPack features)
- Added support for audioframework 1.1.1 - This will require the new audioPack where sounds are played by folder name.
If more than one soundfile is in the folder the player will randomize which one is played.  Sorry about the change in
structure, but a lot of people wanted this feature.
- Enabled support of looped sounds (stallwarning and intruderalert alarms)

Version 1.318 - Minor cleanups
- Flight Assist (Alt-Q/E/S) limited to inAtmo only.  Use Align Retrograde/Prograde buttons to 180 in space.
- Remove SpeedLimit.mp3 playing when space engines hit speed limit, it was infinitely looping (hud fault, not framework)
- Fixed brakes/landinggear announcements overwriting each other.
- Fixed Orbit sound announcement at end of AP.
- Fixed orbit cleanup at end of AP to orbit.

Version 1.317 - More Flight Assist and improved SolarSystem.json
NOTE: Massive BankRoll improvement.  User setting `PitchStallAngle` default of 35 is absolute lowest safe value. You can raise it while sitting with 
/G PitchStallAngle 55 for example.  Then hold ALT-Q or ALT-E and see how many degrees you can turn before it rolls you out to avoid stall.  If it doesnt,
raise it more.  If it does before 180 degress, lower it.

SolarSystem.json AR system updated by EasterGamer to display ArchHUD saved waypoints along with planets.  To use, put down programming board, connect to core
and then ArchHUD databank.  Right click PB, Edit->Advanced->Paste LUA Configuration from clipboard.  Activate pb.  NOTE:  Can be used on foot, or fixed camera first
person or fixed camera third person when in seat.  Toggle on and off by activating/deactivating PB.

- Drastic improvement to Alt-S/Q/E performance.  No more autostall unless your PitchStallAngle is WAY off and code will still save you (no more YoYoing).
- Holding LALT AND LSHIFT and hitting C or Spacebar will have the following effects (normal LALT+C/Spacebar usage remains the same):
        AGG ON, C, Sets AGG target height to 1000
        In other modes it cycles the target heights between 4 values:
            MaxSurfaceHeight+100, 11% atmo height, Low Orbit Height, Target Orbit Height
        If above atmo an in active orbit approach, value will not lower below Low Orbit Height.
- Fixed manual BrakeLanding to cause you to autoRoll level.
- Changed SetWaypointOnExit default to false.  You can toggle it via settings button, but more people dislike than like it.


Version 1.316 - MISSION AP SUPPORT and instant 100% throttle.
- Pasting a mission waypoint with /<pasted postion> or /addlocation name <pasted postion> for use with Autopilot both work now.
- Using StopEngine (default MMB) will set engine speed to 0 if > 0 or to max if 0.  In Throttle mode, 100% throttle.  In Cruise mode, AtmoSpeedLimit if inAtmo or MaxGameVelocity*3.6 if in space.
- Fixed StopEngine doubleclick to clear all AP functions to need to occur within 1.5s (before it would just wait after first for any length of time)

Version 1.315 - Assisted Flight Controls
New Assisted Flight Controls (Many thanks to Dimencia for helping with the math)
- ALT-Q/E will make you bank hard left/right till you release but still provide stall control.  If you were not in alt-hold before, you will not be in after release.
(NOTE: You can use these to see if your YawStallAngle limit is too severe or too loose.  If STALL limiter kicks in and you arent stalling, raise it.  Also good for
dodging pesky towers)
- ALT-S will make you perform a 180 deg turn. It will also cancel Autopilot, leaving you in ALT-Hold when done.
- Removed Default values showing in Edit Lua Paramters to save code length.  Find all defaults in the `UserSettings.md` file.

Version 1.310 - Major soundpack overhaul (Some soundfile names changed, all replaced, more soundfiles)
- Changed stall warning to a more pleasent constant beep.
- Redid all voice announcements using TTS that match what is really occuring.
- Disabled Radar Contact text/announcement while in atmosphere or safespace.
- Removed brake check before allowing re-entry.  If you got in seat in space it told you not good enough brakes for re-entry.


Version 1.305 - New Radar Contact alert
- If you get a new radar contact, and its been 10 seconds since last notification added notification in text on screen 
and via "Tracking Target" sound warning if using sound pack.  If you dont want it announced, remove TrackingTarget.mp3 from soundpack.

Version 1.304 
- Fixed fuel calculation for unslotted tanks due to formula change in patch 23.5 assuming all talents known. - Thanks SpacemanSpiff and Ystreben

Version 1.303 - Optional SolarSystem Display - Many thanks to EasternGamer for his AR code framework and working to make a demo thats useful when flying
NO HUD CHANGE, just optional SolarSystem.json file
To use - Place a Programming board (preferrably within activation range while sitting in seat).  Connect to core.  Copy SolarSystem.json and right click
programming board, Advanced, Paste lua configuration to clipboard.
Works in seat or out.  If in seat, you must be in first person, or the second fixed 3rd person view (does not work in freelook).
Looking around you will see all major planets (no moons) plotted in space, circle size scaled by distance.

Version 1.302 - Pipe Distance Calculation (Thanks to Tiramon for the idea and the starter code)
- Added display of distance to centerline of closest "pipe" based off either closest planet or off of IPH selected target destination.
This should allow you to better fly "outside the pipe"
- If distance to center of pipe is < radius of planet + 2.5 SU the text will be red as a warning that you are in radar range of pipe (blue if in pvp area)
(For more pipe info see: https://i.redd.it/pdvg4xaabgg61.png)
- Clean up AP re-entry process.
- Changed re-entry height when > min space engine alt to (planet.spaceEngineMinAltitude - (planet.spaceEngineMinAltitude/10)) On alioth this will equal 3070.
This only applies if you set ReEntryHeight > min space engine altitude on a planet with atmo.
- Cleaned up dynamic help text display, added new help text.

Version 1.301 - Improved SoundPack integration
- Made major improvement to the .zip soundPack replacing all sounds. Download the new version.
- Added a couple of new sound support lines.
- Changed some sound callouts, see new filenames in soundPack

Version 1.300 - Added support for ZarTaen's Sound player external addon.
- See Install Instructions on the release page for full explanation of sound support
- `Alt-7` is now used to turn off or on all hud sounds.
- Changed intruder alert to use Sound system vice the setting/clearing of waypoint.  (you will still get text alert without sound pack)
- Removed the defensive "deathblossom" spin untill can be made better.
- Fixed bug with IPH all filter needing to be done twice

Version 1.200 - Now with Cockpit support (V 1.0 - Note: You will see about a 10-13 FPS hit possibly when using cockpit mode)
- Added cockpit support.  Requires databank.  To use:
1) Manually connect databank to cockpit.  Run the ArchHUD on the cockpit per normal install instructions.
2) Install a Programming Board on ship.
3) Manually connect same databank connected to cockpit to programming board.
4) Edit Lua Parameters and set Cockpit to true (This can be done from another control unit via buttons to support both cockpit and chair/remote flying) 
5) Paste the CockpitPB.json script to the programming board.  Activate programming board before getting in cockpit (or after if visible from cockpit)
- Fixed VTO message to not say AGG if not doing AGG VTO.

Version 1.165 - Underwater (under 0 ground height) flight support
- Added support for flying underwater (finally). For safety reasons you must manually turn off ground stablization with Alt-8 to remove the hover/pop to surface normal behavior.
With ground stablization off: Stopping or Toggle on Brakes will let you float in water at current height. hovers/vBoosters will fire when underwater to simulate water floating flight.
Pressing G will lower you to bottom at brake rate. Ship remembers ground stablization mode if databank installed. 
WARNING: You might hit hard if its very deep or you have poor brakes. You can control your lowering rate by tapping spacebar or toggling G on and off.
- Removed remote control follow mode from alt-8, now on Button on Control view page only.
- Moved showHelp to user editable variable so it saves for people without databanks if they change it in Edit Lua Parameters.
- Moved dynamic help display up to not overwrite default fuel area.

Version 1.164 - AutoRoll overhaul
- FIX/Change: `autoRollRollThreshold` now defaults 180.  This is the value of roll below which autoRoll to 0 will occur if `autoRollPreference` is on.
Note: Autoroll doesnt occur if you are actively rolling (applying roll) or are out of atmosphere and not in certain autopilot modes.
The strength it rolls back is controlled by `autoRollFactor`
If you normally have autoRollPreference on and have a databank, then you will need to set autoRollRollThreshold one time as its old default is 0.
Autoroll will still occur regardless of `autoRollPreference` setting during certain autopilot features.

Version 1.163
- Added `BarFuelDisplay` default true.  If true you get the new fuel display.  New default fuelX and fuelY of 30 and 700 respectively.
If BarFuelDisplay changed to false, you get the old fuel display.
- Fixed getting out of ship in space applying brakes when you get back in (affected ships with no landing gear)  Brakes only applied in space when sitting if going < 50m/s (180k/hr)

Version 1.162
- Added IPH Mode selector button to main Button screen. Modes: All, No Moons, Custom Only.  

Version 1.161
- Temporary AP Waypoints:  Added `/::pos{}` command to add a temporary waypoint to IPH named `0-Temp` that is not saved to databank when you exit seat.  Using it again overwrites the previous value.
This can also be used on ships without databanks to give you one personal AP location that doesnt save but can be used for that flight.
- Documented functions with comments in the source file, doesnt increase conf file size.
- More cleanup of code.

Version 1.160
- Added `ReEntryHeight` default 5000 - Height above a planets maximum surface altitude used for re-entry, if height exceeds min space engine height, then 11% atmo is used instead. (5000 means 11% is used).
For example: Alioth max surface altitude is 1100m, so default would be 6100 which is > min space engine on Alioth of 3410m, so 3310 will be re-entry alt.  If 1000 set for ReEntryHeight, then 2100m would be target.
- Fix to issue with Turn and Burn arrival to Orbit not stopping properly.
- Fix re-entry prograde alignment planet to planet AP with "sloppy" ships not pushing into atmosphere before aligned (depending on arrival height)
- AP to other planets (not to saved locations) will now clean up orbit to TargetOrbit height after arrival.

Version 1.159
- Added Death Blossom (Alt-7) - Will cause ship to randomly spin on its axises.  Intent is to spread out incoming fire.  Will only spin if in PvP Space and either not in Autopilot or in Autopilot but at cruising speed.
- Prevent hitting CTRL (Brake) turning off Alt-Hold and Lock Pitch if AGG is on.
- Fixed Parachute Re-Entry to work again.
- Removed /wipedatabank command.  Not needed, cleaner/easier to pick up databank and remove dynamic properties.  Wipe was only wiping known variables, so not old discontinued ones.
- Cleanup more code.

Version 1.158
- Added `/iphWP` command - Displays current IPH selected target's planet based ::pos waypoint in lua chat. Right Click it in lua chat to copy or bookmark.
- Fixed compass to look more normal with degrees going up left to right. 

Version 1.157
- Added AlwaysVSped defaults to false.  If set to true, vSpd meter will show when you alt-3 change to widget mode.
- Moved location of Collision text so its more easily visable.

Version 1.156 - More AP improvements
- Modified AP to ground on facing side of planet to have arrival speed of 0 vice orbit speed since you will not orbit around planet.

Version 1.155 - Autopilot improvements.
- Low Orbit AP Hops: Only adjust orbit after it's established if orbit periapsis dips < atmo AND time to destination > time to periapsis OR if altitude within 100 of atmosphere.
- Fix AP to waypoint on nearest planet to use normal low orbit hop AP mechanics vice full AP to another planet mechanics if start nearPlanet (altitude shown).
- Changed "Takeoff to 100k" to "Takeoff to <targename>" when doing spacelaunch takeoffs.
- Updated Intruder Alert to report the mass gain that set it off.
- Clean up UserSettings document some more.
- Note: For Intruder Alert, 20T is not needed in pilot inventory.

Version 1.154
- Created a new UserSettings file to explain all user settings.
- Cleaned up Readme file.

Version 1.153 
- Fixed safe mass to update anytime core mass < safe mass in order to not let use of warp cells or fuel in a long flight miss an intruder boarding ship.

Version 1.152 - Intruder Detection System (off by default)
- Added intruder detection system. Based around Safe Mass setting.
    "Safe Mass" is set when you exit control (stand up from seat or exit remote) or use Set Safe Mass button.
    To use: If anyone boards ship, their mass gain (90kg+) will be detected and reported by flashing text and sound alarm.  
    To reset alarm , hold SHIFT while not in freelook and Reset Intruder Alert.  
    Offline intruders will be detected by a mass gain from when you last stood up upon the next time you sit down.
    Resetting intruder alarm also resets Safe Mass to current ship mass.
- Added `IntruderDetectionSystem` user variable, default is false.
- Added soundAlarm for intruder alarm, can be used for other things as well. Sounds the waypoint beep every tenth of a second. (Will restore waypoint when alarm clears.)
- Fix Mass calculations/updates.

Version 1.151
- Changed Interplanetary Helper Brake distance to return time/distance to 0 k/h if not in Autopilot and in space, 
    otherwise in Autopilot it's time/distance to orbit speed at destination orbit altitude.
- Change Lifetime Distance from megameters to kSU on Odometer.
- Fixed throttle to hard stop at 0 when manually changed from pos to neg or neg to pos throttle with mousewheel.
- Fixed overlap of some displayed values on VTOL takeoff.


Version 1.150
- Added `LowOrbitHeight` user variable, default 1000.  Height above atmosphere or planet that autopilot orbit will attempt to achieve (Alt-4-4 on planet, Alt-6-6 in space)
- Fixed alt-4 while low orbit hop autopilot not cancelling autopilot
- Modified to support no vBooster/hover ships.  NOTE: If no hover/vBooster, will need a telemeter facing down slotted to control unit for many hud functions.
- Fixed some errors with gravity calculation for odometer.
- Fixed wrapping of invalid user control scheme message.

Version 1.149
Beginning more in-depth testing and adjustment of features for no atmo planets/situations.
- Fix G use out of atmo to only lower/raise landing gear and set hoverheight to LandingGearGroundHeight (no more erratic pitch/roll)
- Fixed repair arrows not showing when using remote.
- Fixed command help to show / as command precursor.
- Fixed needing to double tap alt for freelook on first sitting (single tap like normal now)

Verison 1.148
- Fix AP issues cased in previous versions due to due to reorganization of AP into class.

Version 1.147
- Fixed changes to BrakeToggleDefault to update on the fly without exiting seat (vanilla vs toggle brakes)
- Fixed brake being on when getting in seat while within ground detection
- Removed support for Screens in remote mode and the galaxymap.  Beyond the scope of the hud  
(There are other screen scripts for these purposes)
- Further organization of code into classes.

Version 1.146
- Fixed virtual joystick reset after freelook.
- Fixed issue with wrong message display if useTheseSettings checked.
- Fixed TargetOrbitRadius missing from saved user variables.

Version 1.144
- Fix minor hud display errors that came with svg refactor.

Version 1.143
- In Hud Settings control - version 2: Not in freelook, hold LShift and release over Settings button in upper left to swap buttons to boolean settings.
hold LShift and release over boolean value to change.  hold Lshift and release of type of non-boolean to see current values.  Use /G VariableName Value to update
- More cleanup

Version 1.142
- First pass on in hud settings control.  Hold LShift and release over Settings to swap buttons to settings.  Hold LShift and mouse over a button to toggle true/false.
Hold LShift and release over Control to swap back to normal.
- Added missing user variables to databank save list.
- AP same Planet w/ Orbital hop: After achieving orbit, if periapsis altitude drops into atmosphere, orbit will adjust.
- More cleanup

Version 1.139
- Added `SetWaypointOnExit` user variable.  Default true.  If true, waypoint is set when you exit hud.
- Imported Dimencia fix of runaway alt adjustment
- More refactoring for cleaner code.
- More reduction of duplicated code

Version 1.135
- Re-enabled LockPitch in space
- Changed text input commands back to / from ah-   it was too confusing.  / will only respond to recognized commands.
To see a list, type /help or /commands
- Fixed Turn and Burn braking to not mess with alignment going out
- Changed indication that Turn and Burn is on to TB- in front of Travel mode
- More cleaning

Version 1.134
- Fixed AGG ON Alt-4 takeoff to not brake or kill engines once AGG height is reached
- Fixed AGG ON Alt-4 AP same planet to stop over target waypoint till AGG manually disabled.
- Fixed no argument text command input. (ah-copydatabank and ah-wipedatabank)
- More cleaning and localization of code.
- Fixed planet atmosphere save value to use max atmosphere density if not using update position (fix SatNav issue)
- Fixed PlayerThrottle value being set incorrectly.
- Fixed cmdThrottle setting throttle to 1000 sometimes.
- Integrated DU Orbital improved AP < 100k code (code by Dimencia)

Version 1.130 
- Exiting ship sets waypoint to ship location
- Full Harrier VTO automation - Alt-6 will VTO to normal auto-takeoff height then commence forward flight using vanilla cruise control.
    Alt-6-6 will VTO to 11% then commence forward flight using vanilla cruise control.
    To VTO to orbit, just use alt-spacebar to set height > atmosphere.
- VTOL Autopilot is allowed but needs fine tuning, use alt-4 AP takeoff with close attention.
- Cleaned up AGG code
- Fixed VertEngine thinking on when no vertical engines (removed since last sit down)
- more code reduction/cleanup

Version 1.110 - In Hud Help
- Revert `alt-3` to Widget toggle, revert `lalt` to camera freelook toggle.  (ALt-3 to toggle camera was too slow when needed)
- First passd on in hud help list - Toggled on or off by Button (hold shift while not in freelook to see buttons)
- Prevent changing autopilot target if in any form of autopilot without turning off autopilot first.
- Changed LockPitch (`alt-5`) to only work in atmosphere (it aleady didnt in space). 
- Prevent Autopilot VTO for now.  VTO then Autopilot once VTO is cancelled or finished. 

Version 1.100 - MAJOR REFACTOR, code cleanup, enhancements (Harrier Takeoff).
- Note that max mass shown up top is based on thrust at current planet (takeoff).  Max Mass shown in Interplanetary Helper is based on brakes at target planet (landing)
- Re-ordered user variables to group them better in Edit Lua Parameters.
- Changed command lines to start with ah- instead of / to avoid conflict with other scripts listening for text.
- Fix erroneous warning message about wrong control scheme.
- Removed initial dump of variables to Lua chat, use ah-G dump to see all user variables.
- Removed Alt-7-7 to wipe databank.. Use ah-wipedatabank command instead. (reclaiming hotkeys)
- Moved Alt-3 (widget vanilla view toggle) to Alt-7. Not needed to fix the old tab slideshow anymore, but still needed sometimes (busy marketplace)
- Changed Freelook toggle from Alt to Alt-3.  This should prevent inadvertantly changing out of ship or camera control when alt-tabbing.
- Removed `ReentrySpeed` - AtmoSpeedLimit used instead.
- Removed `ReentryAtltitude` - Calculated variable used instead.
- Removed `VerticalTakeoffEngines` as a uservariable
- Added safety check to not show Glide or Parachute re-entry buttons over planets without atmosphere or if in Atmosphere
- Removed butttons that already have a hotkey (code space savings)
- Changed Vert Takeoff button to a toggle between Vertical Takeoff and Horizontal Takeoff modes.
    - Changed Alt-6 to do takeoff based on mode.
    - Cancelling Vert Takeoff with Alt-6 before reaching end of atmosphere will engage horizontal alt-hold (Harrier takeoff)
- Change Alt-4 when < 100k from planet to align to waypoint and then orbit in. (Idea by Dimencia, coded differently)
- Major refactoring of script.
- Cleaned up tab and commenting to allow for vscode collapse readability.

Version Reset to 1.000
- Reset version to differentiate from DU Orbtial Hud version.

Version 5.450
- Orbiting
    - Improved efficiency of achieving orbit
    - Improved accuracy with final orbit
    - When in space near a planet, `Alt-6` now orbits you at the altitude you activated at.
    - When in space near a planet, `Alt-6-6` now orbits you at 1km above atmosphere. This will take you into near planet orbit.
    - Limit for orbital hop using `Alt-4` has been removed. Autopilot will recover if you overshoot your target.
    - When on ground in atmo, `Alt-4-4` will perform orbital hop to target at 1000m above atmosphere.
    - Added space engine check for `Alt-4-4` to be allowed.

Version 5.442
- Orbiting
    - Adjusted tolerances. Should orbit better at tight orbits

Version 5.44
- Orbiting (note: Trying to establish super low orbits (i.e. 7000m at Alioth) could result in achieving luminary status (burning up))
    - `Alt-6` (Altitude Hold): If target altitude changed (`alt-spacebar`) to above the atmosphere will now establish orbit at that height.
    - `Alt-6-6` while in space within a planet's influence: Will establish orbit at the height of activation in the direction you are facing.
    - `Alt-4` (Autopilot) with a custom target over 0.5SU away on the same planet and set with target altitude above the atmosphere will now orbit to destination. 
              (If you set height over atmosphere and your target is too close, normal climb and reentry will be used.)
    - Using the HUD button `Engage Orbiting` establishes orbit at height determined by your `TargetOrbitRadius`.
- Glide Entry
    - When target is set to planet or not set, glide entry now glides in and holds altitude only.
    - When a custom target is selected, glide entry now lands your ship at your custom destination.
- New user Variable: DisplayDeadZone, defaults true.  If set to false, deadzone circle and line to cursor will not be drawn when in virtual joystick mode..
- Bugfix
    - When using `Alt-6` without a target selected (using `Alt-1` or `Alt-2`) no longer gives an error.

Fixed script unloading when away from control unit.  Note: We are now at our script limit even minimized.  We are trying to clean up to give more room, 
but this might be the limit of everything in the hud meaning new features would remove old features or we might have to get creative on some things.

Version 5.43
- Removed `VertTakeOffMode` user variable.  Mode determined by checking to see if AGG is on prior to beginning ascent.
- If AGG is on when doing a AutoTakeOff or Vertical takeoff, ship will go to singularity altitude and stop engines and engage brakes.
- If AGG not present or off and do Vertical Takeoff, ship will vertically thrust to achieve Orbit.
- Removed description of user variables from code to Readme.md to free up code space and prevent unloading of script. File size reduced from 192k to 184k minimized.

Version 5.42 - VTO to Orbit or AGG Height, ATO to AGG, and Same Planet Orbital Hops.
- Vertical Takeoff v3 - (`VertTakeOffEngine` must be set to True for the below to work)
    - When `VertTakeOffMode` is set to *"AGG"*, it will now activate AGG and vertically fly up just above AGG Singularity height and stay in the air until the Singularity is at your height, then the engines are turned off and the brakes are engaged. *Not available if you use ExternalAGG.*
    - When `VertTakeOffMode` is set to *"Orbit"*, it will vertically fly up and out of atmosphere. If there is not enough force to lift you out, Brake Landing is triggered. If you reach space, it will fly you forward using space engines to the distance set by `TargetOrbitRadius` and then cut off engines and you will be in orbit.
- Auto Takeoff changes
    - When Altitude Hold is set above atmospheric height (alt-spacebar) and is in space, orbiting will engaged once out of atmosphere. Your ship will orbit at the altitude hold height. **Set this with care, too low and you risk burning up or will yo-yo trying to achieve orbit**
    - If Agg is turned on first (alt-g default) then autotakeoff (alt-6 default) will take you up to current singularity altitude, turn off engines, and engage brake.
- Autopilot changes
    - While in space, activating autopilot when your target is the same nearby planet (not a custom waypoint), you will begin orbiting to height determined by `TargetOrbitRadius`.
    - On ground, if a custom target is selected and Altitude Hold is raised (alt-spacebar) above atmo height, autopilot will take off and orbit at the configred height. Once orbited, autopilot will reengage and reenter you close to your target. Recommended minimum distance for this feature is a waypoint at least 0.5SU away.  **Set this with care, too low and you risk burning up or will yo-yo trying to achieve orbit**
    - Target locked when Autopilot is engaged (in space). Disengaging Autopilot allows you to select a new target.
- Script cleanup
    - Cleaned up repetative functions and removed unused variables.


Version 5.41
- Vertical Engines Detection developed
    - Currently for changing how Vertical Takeoff works, but can be extended in the future. You still need to enable VertTakeOffEngine to activate.
- Vertical Takeoff v2
    - Now has three options set by VertTakeOffMode: "Orbit" to engage orbiting, and "AGG" to engage the AGG at AGG minimum height (1km or AGG Base Alt, whichever is higher), 
    or higher if set (Not available when ExternalAGG set to true)
    - Protection against mispelling or wrong option in VertTakeOffMode. Does not enable if the option is wrong
    - Using Vertical Engine Detection, now makes use of vertical engines in space if equiped. If not, will pitch 35 deg up and will move forward. **Will not activate Vertical Takeoff.**
    - Saftey Net added to Vertical Takeoff. If you don't reach out of atmo and begin falling, BrakeLanding is enabled for a smooth fall back to ground
    - If you cancel Vertical Takeoff mid sequence, BrakeLanding is enabled
    
Version 5.4
- Updates via ShadowMage, many thanks!:
    Initial Pass on Vertical Takeoff
    - Engage Vertical Takeoff button now available if you set VertTakeoffEngine to True (see below)  This will lift you via VTO till upward velocity falls off or you clear atmosphere
    - User Parameter: VertTakeOffEngine = false --export: (Default: false) Set this to true if you have VTOL engines on your construct.
    New Button - Achieve Orbit
    - Button to achieve orbit, usable from space.  Uses TargetOrbitRadius to determine the orbital height based on planet values (radius, atmosphere height, and TargetOrbitRadius)

Version 5.341
- Fix no planet LUA error

Version 5.340 - PvP Distance flagging
- Hud now monitors for PvP space or not.  If in PvP Space, hud will change to PvP color (red default), if in safe space or atmo, Safe color (the pale blue default)
- Added pvpHud colors.  If you dont want the change, set them the same value as Safe.
- Hud colors will update on the fly if you use the /G command while in seat (i.e. /G SafeB 0 will turn the hud green)
- SafeR, SafeG, SafeB and PvPR, PvPG, PvPB are now the RGB definers for the two hud colors.  You will need to change them if you do not use default colors.
- FYI, you can use /addlocation SafeZoneCenter ::pos{0,0,13771471,7435803,-128971}  to set a saved location of the center of the SafeZone.
- Distance to PvP Boundary displayed above Radar Jammed / Radar Contacts in upper right if > 50km from boundary.  (otherwise the vanilla game displays the distance top right if < 50km)
- Removed extra function round declaration

Version 5.336
- Added assistance to fix a DU bug with space engines engaging at low or no power
- Adjusted speed limiting when leaving/exiting atmo to occur down to 0.5% atmo instead of 5%

Version 5.335
- Fixed stupid version number

Version 5.334
- Removed print leftover from 5.333

Version 5.333
- User Parameter: minRollVelocity = 150 --export: (Default: 150) Min velocity, in m/s, over which advanced rolling can occur
- Fixed excessive yawing during autopilot causing it to overshoot target angle and trigger stalls

Version 5.332
- Fix for lateral strafe engines

Version 5.331
- Fixed issue with space vertical thrusters introduced in 5.33

Version 5.33
- Fixed vertical adjustments affecting yaw unnecessarily

Version 5.32 - Fix VTOL performance.
- Strengthened convergence of velocity vector to ship forward in atmosphere
- Fixed issue allowing 'Finalizing Approach' to occur when the ship was not on target yet
- Fixed erratic yaw behavior while rolling in atmosphere
- User Parameter: ForceAlignment = false --export: (Default: false) Whether velocity vector alignment should be forced when in Altitude Hold

Version 5.31
- Improved autopilot trajectory alignment weirdness that happened sometimes
- Added ForceAlignment parameter to return to old AltitudeHold behavior of forcing the ship to face the velocity vector
- Fixed cruise not swapping to throttled mode during reentry without a target
- Fixed vertical/lateral engines firing against gravity at all times
- 'Proceeding to Waypoint' only engages after reentry if you are at least 2km horizontally from the target, to give space to turn
- Fixed atmospheric exit waypoints from being unable to use pitch properly when rolling in atmosphere

Version 5.300 - Surface-To-Surface Overhaul
- Throttle Cruise system complete
    - Alt+Mousewheel changes max speed in atmosphere, with a maximum of AtmoSpeedLimit (user parameter)
    - Alt+Mousewheel changes shutoff velocity when in Autopilot in space
    - Max speed shown as Limit: beside throttle above current speed
- Autopilot to waypoints on other planets overhauled
    - Aims at the correct yaw during takeoff
    - Aims the trajectory directly at the target
    - Begins autopilot as soon as there is line of sight to the target
    - Brakes just before it reaches atmosphere
    - Orbit to reach waypoints on the far sides of planets
- Reentry Overhaul
    - Smooth reentry
    - Uses gravity for speed assist when high above atmosphere
    - Aims for a reentry height where atmosphere is at 10%
- Autopilot no longer has to do the 'Aligning' phase, and chooses an orbit point closest to your velocity vector
- Autopilot now uses waypoints to interactively show you its targets through each phase
- Better Autopilot trajectory convergence
- New indicator for atmospheric/planetary collisions
- Safer rolling in atmosphere
- PARAMETER MODIFIED: StallAngle is now YawStallAngle and PitchStallAngle.  You will need to re-enter these

Version 5.233
- Fixed issue with displaying cruise throttle while in prograde alignment
- Waypoints now only brake based on horizontal speed until they are on target
- Autotakeoff now only engages when hovers detect ground
- Min roll speed increased to 150m/s
- Surface to surface waypoints now have a more consistent approach - they should arrive at AutopilotTargetOrbit
- Reentry now uses gravity for higher approach speeds and can be engaged further from the planet
- Autoroll no longer applies when pitch is +/-85 degrees, where rolling becomes meaningless
- Interplanetary waypoints now correctly aim at the edge of the planet if the waypoint is on the far side
- Interplanetary waypoints to targets on the far side will orbit until close to the target
- Yawing to waypoints now no longer bounces when the target is nearly directly above or below
- Warning added to indicate when your ship is on a collision course with a planet or atmosphere
- Added on-the-fly adjustment for AtmoSpeedLimit and MaxGameVelocity (during autopilot) with Alt+ScrollWheel
- Improved Autopilot Convergence over short distances
- Reentry throttle limiting can now happen at atmo values above 1% if descending
- Reentry smoothed significantly
- Atmo exits now pitch up when atmosphere gets low to prevent burning

Version 5.232
- Fixed a potential issue with aligning prograde when not near a planet
- Removed prints

Version 5.231
- Autoroll in space has been dampened, and occurs when aligning prograde near a planet
- Stalling is ignored when atmo is below 1%
- Glide reentry button fixed to align prograde first
- Stall axis is now independent so will avoid realigning pitch when yaw stalling, for example
- Reentry to a waypoint should reenter in the correct direction for that waypoint
- Reentry height is now always 11% atmosphere level
- Reentry will now stabilize more completely before swapping to autopilot, if targeting a waypoint
- Prograde/waypoint alignment on reentry cancels as soon as it is aligned rather than when speed is low enough

Version 5.23
- Orbital adjustments can now occur even when not in an escape trajectory
- Planet-To-Planet autopilot overhaul
    Aims at the correct yaw during takeoff
    Aims the trajectory directly at the target
    Begins autopilot as soon as there is line of sight to the target
    Brakes just before it reaches atmosphere

Version 5.224
- Ensures Throttle is set to 0 after entering/exiting cruise
- Speed and Brake limiting for AtmoSpeedAssist now applies up to 5% atmo instead of 10%, unless reentering at more than 80m/s vspeed (up from 5m/s previous)
- When stalling in AltitudeHold, the pitch should now correctly try to point back at velocity vector to get out of the stall
- Changed StallAngle into YawStallAngle and PitchStallAngle.  WARNING: You will need to re-set these variables, though they defualt to a low 35

Version 5.223 - Major flight changes including new "Cruise control" mode when using autopilot, read changelog since 5.11

- Adjusted Waypoints to really land immediately if you pass the location or distance starts getting higher
- IMPORANT:  For any waypoint to be most accurate and use faster brake landing, go to the waypoint and use the Update Position button.

Version 5.222
- Increased minimum roll speed to 100m/s from 50/ms
- Increased roll power to help converge on ships with no tailfins

Version 5.221
- Allowed new waypoints entered from the ship to be considered safe for Extreme Landing

Version 5.22
- Fixed issue causing Cruise to be unable to apply brakes
- Adjusted Cruise mode to brake less aggressively when the velocity angle is far from ship front
- Adjusted Cruise to brake more aggressively when total speed is too high - Beware testing glide reentry
- If AtmoSpeedAssist is enabled, swaps to throttled mode when entering atmosphere from cruise mode
- Adjusted Waypoints to land immediately if you pass the location or distance starts getting higher
- Waypoints will no longer perform Extreme Brake Landings at positions entered on the map - you must land at location and Update Position for these
    Your old waypoints must be updated in this way for them to work with Extreme Landings

Version 5.21
- Removed throttle limiting when atmosphere levels are below 10% for easier atmo escapes, and brake limiting when atmo levels are below 1%
    Note that throttle and brakes will still limit if your vspeed becomes less than -20m/s, to help with entries, and always when atmo is above 10%
- Fixed bug causing no throttle control when in space

Version 5.2
- Replaced Cruise with AtmoSpeedAssist (parameter to enable/disable), a throttled flight overhaul.
Adjusts throttle to limit speed to AtmoSpeedLimit, brakes when necessary (such as reentry) without limiting throttle, and applies all wings to center the velocity vector like Cruise does.  Unlike cruise, it will not cause you to brake just because you are facing the wrong direction - only if your total speed is too high for atmo
This also means that when AtmoSpeedAssist is on, all Atmo Flight Modes no longer put you in Cruise
And consequently and accidentally, the player's throttle is now remembered and re-set when swapping back to Throttle mode from Cruise (in atmo)

Version 5.11
- Improved orbits and waypoints - waypoints may feather brakes again

Version 5.102
- Adjusted pitch and yaw calculations to use a different formula, though it should be equivalent.  Attempt to fix incorrect stall warnings

Version 5.101
- Fixed issue with space waypoints causing an exception

Version 5.100 - INCREDIBLY improved space autopilot to orbit
- Autopilot alignment improved, should now efficiently realign orbits, and more effectively get to the desired Projected Altitude
- Autopilot widget now shows target orbit altitude
- AtmoSpeedLimit no longer brakes upon reaching max speed, but goes into cruise.  This saves fuel and works smoothly.  As always, alt+r cancels cruise mode
- Fixed a ship with active AGG to not do Takeoff on sitting into seat and activating alt-hold
- Fixed startup sequence to recognize gear or no gear amoung other things.

Version 5.002
- When activating autopilot, the on-screen waypoint is changed to show the autopilot destination.  This is a show thing only, no effect on AP destination, so can be changed if wanted via normal waypoint usage.
- Hitting alt-6 2x withing 1.5 seconds will set HoldAltitude to 50m below space engine min atmosphere height (generally 11% atmo density).

Version 5.001
- Readded autoRollThreshold parameter

Version 5.000 - Major Atmo autopilot overhaul including bank turns, smoother autotakeoff, and improved braking features
- Factor for low FPS situations to help mechanics perform better due to the high element ships losing FPS while flying.
- Smooth takeoffs that only pitch up once you have momentum and aren't stalled
- Better yawing to target to not stall when at low speeds and proceeding to waypoint
- Will now roll to turn when at high speeds (>100m/s) and proceeding to waypoint, respecting stall limits
- Improved waypoint accuracy with better yaw/roll convergence
- Further improved BrakeLanding + Waypoint.  If you are going to a waypoint and it accurately gets within 100m of that waypoint, and that waypoint has a valid Altitude that's above 0, it will do an Extreme Brake Land.  Since it knows the altitude it's landing at, it will descend in free-fall until 100m before it reaches the landing area.
- New User Variable: CalculateBrakeLandingSpeed = false --export: (Default: false) Whether BrakeLanding speed at non-waypoints should be Calculated or use the existing BrakeLandingRate user value
- Orbit Height is now calculated rather than set.  This allows better support for different planets and moons
- New User Variable: TargetOrbitRadius = 1.4 -- export: (Default: 1.4) How many planet radiuses you want Autopilot to orbit above any given planet.  Values below 1 imply orbiting inside of the planet - do not do this.  Default of 1.4 should result in Alioth orbit of 56699m.  Atmosphere and mountains on moons are handled automatically

Version 4.935
- Extremely dangerous BrakeLanding changes.  Brakelanding is now, again, faster - but attempts to put you at effectively 0m above the ground.  Please let me know if this breaks your ship so I can adjust it, but it works fine on all of mine.  May cause issues if things are under your ship when landing and aren't detected by your hovers/vboosters

Version 4.934
- More BrakeLanding and Waypoint improvements.  Waypoint and space autopilot alignment should now be more aggressive when it is very close to the target.  BrakeLanding should now be slightly safer and slower, particularly on ships that had a telemeter
- BrakeLanding will end and lower you to the ground as soon as your vSpd is no longer negative, instead of waiting until you raise back up

Version 4.933
- Further improved BrakeLanding + Waypoint.  If you entered the ship while it was in atmo with hovers/boosters touching the ground, and if you are going to a waypoint and it accurately gets within 100m of that waypoint, and that waypoint has a valid Altitude that's above 0, it will do an Extreme Brake Land.  Since it knows the altitude it's landing at, it will descend in free-fall until just before it reaches the landing area

Version 4.932
- Changed Prograde and Retrograde from white/red dot to KSP markers
- Changed when prograde is behind to change to Arrow pointing direction
- Added ShouldCheckDamage = true --export: (Default: true) Whether or not damage checks are performed.  Disable for performance on ships with 450+ elements (or if using external damage report)
- Incorporated Hyperion data Atlas for more specifics for each planet, will allow better control on different planets (features coming soon).
- Fixed incorrect calculation of rocket fuel tank % based on rocket fuel tank handling skills (its 10% per vice atmo/space 20% per)
- Added ExternalAGG to databank save.

Version 4.93 - Databank copy and better brake landing
- Added /copydatabank command
To use, put a blank databank on vehicle with existing dbHud databank already linked to chair. 
Link from chair to blank. Rerun hud autoconf. You should see dbHud_1 and dbHud_2 on the slot list now. 
Sit in the chair, type /copydatabank in lua chat, wait for it to say its done, then stand and remove copied databank.
- BrakeLanding will be faster and safer if you start on ground in atmosphere, otherwise will be like normal.
- Fixed Brake values in atmo for BrakeLanding and VectorToTarget (flight to waypoint)
- Adjusted flight to waypoint behavior to no longer feather the brakes when incoming - the calculations are now more accurate at high altitudes when starting from ground.
- Adjusted BrakeLanding behavior to calculate an appropriate brakeLandingRate, if its hovers were in contact with the ground when you entered the seat (so it can measure them)

Version 4.927
- Changed Landing Gear to always extend/retract regardless of height when G pressed.  Note: Pressing G while flying will still initiate Brake Landing when appropriate.
- Changed HUD startup brake status (when you sit in seat) only to be on if ground level is detected.  This should prevent brakes being on when sitting returning from a disconnect.
- Changed AGG to prevent target altitude going < 1000m
- Fixed issues with Landing Gear and Dynamic Core Unit due type name change, landing gear and remote repair arrows should work better now.

Version 4.926
- Fixed movement speed of mouse post 4.924 back to previous rate.
- Added user preference ability to invert mouse Y axis for flight control.
InvertMouse = false -- export: (Default: false) If true, then when controlling flight mouse Y axis is inverted (pushing up noses plane down)  Does not affect selecting buttons or camera.
- Prevent space speed limit activating when warping (had no effect,  just cleanup)


Version 4.925 - Increased FPS when using full HUD
- Changed overlay (hud) to update at 1/4 the speed of autopilot. This also moves hud stuff out of ap area. Gained 10 FPS with little visible impact.
- Added user variable hudTickRate for those who want to fine tune it, default is 4 times slower than ap tick rate (15 times/sec vice 60 times/sec)
hudTickRate = 0.0666667 -- export: (Default: 0.0666667) Set the tick rate for your HUD. Default is 4 times slower than apTickRate. hudTickRate should be >= apTickRate.
The hudTickRate has the biggest impact on FPS as it determines how often the overlay is redrawn(updated).  0.25 gives a 20+ fps gain, but you get 4 fps hud update.

Version 4.924
- Fixed time display for Days - Hours
- Added default values to all user variables (Default: value)
- Added SpaceSpeedLimit user parameter - When you hit the limit, and are not in autopilot mode, engines will turn off.  Default is 30000 (so will never apply)
SpaceSpeedLimit = 30000 -- export: (Default: 30000) Space speed limit in KM/H.  If you hit this speed but are not in active autopilot, engines will turn off.
- Added DisplayOrbit, OrbitMapSize, OrbitMapX, and OrbitMapY to user settings
DisplayOrbit = true -- export: Show Orbit display when valid or not.  May also be toggled with shift Buttons
OrbitMapSize = 250 -- export: Size of the orbit map, make sure it is divisible by 4
OrbitMapX = 75 -- export: X postion of Orbit Display Disabled
OrbitMapY = 0 -- export:  Y position of Orbit Display

Version 4.923
- Cleaned up autopilot performance for various conditions, fixed re-entry to saved location.
- Added /G dump - shows all changable variables and current setting.
- Restored torqueFactor export variable - Force factor applied to reach rotationSpeed
(higher value may be unstable) Valid values: Superior or equal to 0.01
- Slowed approach to 100k when doing autopilot from planet to off before aligning to target to allow more accuracy

Version 4.922 - Now with space! (Space waypoints and autopiloting to them)
WARNING WARNING WARNING - Autopiloting to a point in space that has a physical object at it might end up
with you smeared all over it.  The AP endeavors to stop you in time. Recommend setting a waypoint nearby or 
wear a diaper AND brown pants buttercup.
- Autopilot will now go to a saved location in space.  If on arrival you are too far off, you can Alt-4 again and 
it will close in.
- Added Space as a entry in the Atlas to allow for saving locations in space.
- /addlocation now supports space waypoints.
Save Locations:
To make locations on planets, use either the Save Button or /addlocation Name Waypoint command
To make locations in space, use only the /addlocation Name Waypoint command
To rename a location, select it in the Interplanetary window, then use the /setname Name command
To delete a location, select it in the interplanetary window, then click the Clear button
Do not use Update button for space locations at this time.
KNOWN ISSUES:
- Autopilot from land to space save point may arrive off when first stops, just hit alt-4 again and it will zero in (works best starting in space)
- Autopilot from space to land point SOMETIMES has issues when ready for re-entry, troubleshooting that.  If happens alt-4 to cancel, brake, alt-4 to go on in.


Version 4.921 
- Fixed issue of converting ::pos to WorldCoordinates.  /addlocation Name ::waypoint works now
- Provided feedback when adding a waypoint save location.
- Fixed comment on ExtraVerticalTags to say vertical (no change to performance)

Version 4.920 - Support for user input
- Implemented user text input.  To use, hit tab and hit enter to send messages to Lua Chat.  (this will not cause tab fps slideshow if the chat tab is open first) Currently supported commands:
    - /commands - Shows command list and help
    - /setname name - renames the current selected saved postion to "name"
    - /G variablename value - changes the global variablename to new value, example /G AtmoSpeedLimit 1300 would set that user variable to 1300 or /G circleRad 100 would shrink the artifical horizon
    - /agg height - Sets the AGG target height to height.  Note that it must still move to this height at 4m/s like normal.
    - /addlocation savename waypointpaste - Adds a new saved location based on waypoint.  Not as accurate as going to location and using Save button.
- Added three new user variables for engine control (NOTE: if you fill these in, only engines on that axis that have the extra tags will fire):
    - ExtraLongitudeTags = "none" -- export: Enter any extra longitudinal tags you use inside "" seperated by space, i.e. "forward faster major"  These will be added to the engines that are control by longitude.
    - ExtraLateralTags = "none" -- export: Enter any extra lateral tags you use inside "" seperated by space, i.e. "left right"  These will be added to the engines that are control by lateral.
    - ExtraVerticalTags = "none" -- export: Enter any extra longitudinal tags you use inside "" seperated by space, i.e. "up down"  These will be added to the engines that are control by vertical.
- Fixed buttons not working in remote mode.

Version 4.914
- Fix versioning issue from 4.913 for some reason
- Major refactor of function definitions outside of script.onStart() (users ignore this)
- Begin adding remarks to code to help explain things

Version 4.913
- Added ContainerOptimization user setting in Edit LUA Parameters, default 0.  (This is NOT Fuel Tank Handling, but instead the skill in 
Stock Control of Mining and Industry).  To get accurate values of UNSLOTTED fuel tanks, you must set this, FuelTankOptimization and the 
appropriate fuelTankHandling skill for the person who PLACED the tanks.

Version 4.912
SPECIAL - Introduction of DU-ECU.CONF
First DU emergency control unit version 1.0.  Currently is vanilla ECU but with brake landing.  To use, put in your custom directory and load it onto a placed ECU, the ARM the ECU.
No interaction with databank at this time.  Enhancements to follow.

Version 4.911
- Changed atmosphere speed limit to not apply brakes if atmosphere is < 0.10 (i.e. space engines would kick in)
- Added FuelTankOptimzation user setting in Edit LUA Parameters, default 0.  (This is NOT Fuel Tank Handling, but instead the skill in 
Stock Control of Mining and Industry).
- Fixed fuel tank calculation when tanks placed with FuelTankOptimization skill 

Version 4.910
- Resolution Refactor:  Default postions in Edit LUA Parameters are set for 1920x1080 HUD resolution.
Note: 1920x1080 works even if your game resolution is different (2560x1440), this lets you have bigger text on a higher resolution.
If you change ResolutionX and ResolutionY, everything that does NOT have a X/Y setting in Edit LUA Parameters will shift based on your new resolution.
All other values in Edit LUA Parameters must be shifted to where you want them. (Altitude, fuel, etc). This will of course save on your databank.
i.e. if you set ResolutionX/Y to 2560/1440, you probably want to set centerX/Y to 1280/720, and the other X/Y locations to where you want them.
For the other settable postions, a recommended approach is to take (default value X times Resolution X ) divided by 1920 and (default value Y times Resolution Y ) divided by 1080

Version 4.901
- To help avoid burning up in atmosphere, New User Variable: AtmoSpeedLimit default (1050km/h) - If in atmo and in travel mode, brakes will toggle on and off if you attempt to exceed your atmo speed limit.  
If in cruise mode, brake will come on and can be toggled off to allow continued speed increase.  NOTE: In cruise mode, DU controls brakes and engines, so Brake Engaged
may not slow you or may not come on.

Version 4.900
- Major refactoring of variables in to local unless a savable variable.
- Due to the increased use of databanks on ships, the databank associated with this script must now be manually slotted one time.  
This mean, put down seat, put down databank, slot databank to seat, run hud autoconf like normal.
You should not need to reslot existing databanks used in previous versions.
- Fixed time display for days, hours, minutes, seconds.

Version 4.858
- Added optional telemeter support.  Telemeters are set for manual slotting like fuel tanks, meaning you must manually slot it to chair/remote one time, then run the hud autoconf.  
When you hit CTRL-L looking at control unit, you should see telemeter_1 in a slot.  Telemeter has a range of 100m vice vBooster of 80m.  Above Ground Level will show the lower
of telemeter or hover or vBooster reading.
- Modified hover height to account for ships having hover AND vbooster (before it used vBooster and then didnt check hover) so that if a hover is lower than vBooster and detects ground,
it's height will be used.

Version 4.857
- Added Above Ground Level (AGL) that will display when hover/vBooster that is slotted detects ground level (max about 80m)
- Fixed LandedGroundHoverHeight to work.  Set that user variable to 1m below the AGL shown when on ground.
- Added support for SatNav to DU Orbital Hud - toggle on UseSatNav in Edit Lua Parameters and then you do not need to edit the HUD when using SatNav

Version 4.856
- AGG will continue towards last set Target Height whether off or on.  To stop AGG changing target height, set target height = singularity (basealtitude) height.  
NOTE:  AGG will continue towards its last set target height whether you are in seat or not.  If on, and in AGG control, ship will continue to height as well in seat or out.

Version 4.855
- Added VanillaRockets to user parameter.  If on, rockets will act like vanilla (toggle on/off with B by default)

Version 4.854
- Sync AltitudeHold Target Height and AGG Target Height:  If AltitudeHold is on and AGG is on, and Agg Target Altitude gets within 20m of AltitudeHold target altitude they will couple together and using alt-space or alt-c will change both Target AGG altitude and Altitude Hold target altitude to same value.  Toggle off AGG to decouple target heights (or toggle off Altitude Hold).
- Added more coroutine yeilds during startup every 250 elements processed to help with large ships (maybe, untested, but wont have a negative effect lower count ships)

Version 4.853
- Removed Emergency Warp - ALT-J is hardcoded keybind now to initiate warp jump, no more lua call.

Version 4.852
- Fixed fuel tanks, again (stop changing element names!)
- Restored emergency warp.

Version 4.851
- Fixed Rockets.  Note that rockets will not work in Cruise mode now, thats vanilla.  Normal operation:  If speed > 85% of throttleSetting*1100kph in atmo or > 85% of thottleSetting*MaxVelocity user parameter in space, rockets will turn off.

Version 4.850 - fixes for 0.23 DU update
- Removed emergency warp support
- Moved agg target height adjustment while agg is off to 

Version 4.846
- Added support for manually linked switch and set to toggle.  When you activate or deactivate control unit, it toggles any connected switch.  This can be used to activate multiple forcefields or doors off a single slot.
Link the items to a relay, link the relay to a manual switch unit, link the switch to your control unit (seat/remote).
- Changed manually linked Forcefield and Door to toggle, so when you activate control unit or deactive, it toggles any connected forcefields or doors
- Made localized functions available globally

Version 4.845
- Changed Rocket Boost in atmo from 1050 max speed cutoff to ReentrySpeed max speed cutoff

Version 4.844 
- Fix in atmo max brake value, more reliable use of brake landing

Version 4.843
- Fixed erroneous pitch when rolled hard.
- Fixed max brake values to save highest seen in atmo (> 0.10) unless out of seat for more than 3 min. (So swapping seat to remote or remote back to seat wotn reset it)

Version 4.842
- Fixed (I hope) the occasional DrawThrottle bug report.
- Moved stall warning to not overlap AGG info

Version 4.841
- Fixed Align Retrograde turning off if you dip into atmosphere
- Minimized atmosphere calls to use a preset atmosphere check.

Version 4.84
- Bug fix of Artificial Horizon error when entering planet area from space.  Important bug fix (didnt notice it till approaching Feli)

Version 4.8395
- Added ResolutionX and ResolutionY to user variables, default 1920x1080.  You do NOT need to change these for normal aspect ratios.

Version 4.839
- Fixed vector to target when doing autotakeoff.  Ship will now swivel to target as soon as you hit alt-4 while on ground.
- Fixed Interplanetary Helper infor when targeting Saved Locations.  Note that time to target will show 0 when same planet autopilot.

Version 4.838
- Updated Readme File - MANY thanks to THB for the effort on updating and cleaning up the file!
- ExternalAGG = false -- export: Toggle On if using an external AGG system.  If on will prevent this HUD from doing anything with AGG.

Version 4.837
- MANUAL CONTROL HOTKEY: Pressing Stop engines (Z by default) 2x within 1 second will clear ALL AP / special functions.  You will be at 0 engine in throttle mode with brakes off. (normal Z behavior)
but all special features like altitude hold, or brake landing or anything else will turn off.  (Give me manual control key)  Pressing it just once is normal vanilla stop all engines.
NOTE: This will NOT turn off antigrav or stop a warp in progress.  It does turn off emergency warp active.
- LOCK PITCH FEATURE: Changed Alt-5 from Turn/Burn toggle (still available as button) to Lock Pitch toggle.  Will lock your target pitch at current pitch and attempt to maintain that pitch (this is different from Altitude Hold) Most other AP features will cancel LockPitch.
- Removed automatic braking from AGG operation, it was interfering too much with pilot desired braking.  
Will monitor for overshoot / yoyo and revisit if necessary, meantime toggle on brakes to prevent yoyo if at desired height.
- Cleaned up static level bar in Artificial Horizon.

Version 4.836
- Added user variable ShowOdometer default true.  If you toggle it off then the Odometer panel doesnt show up top.
- Added Yaw to center of AH when in atmo and moving fast enough.

Version 4.835
- With NQ concurrence - Modified AGG so that when you turn it OFF, the BaseAltitude will rapidly reach the TargetAltitude, 
allowing you to resume using your AGG without waiting for the Base Altitude to reach Target Altitude at 3.8m/s.  Speed while AGG 
is on remains at intended vanilla rate.

Version 4.834
- More vertical engine modification, now they should only come on if you are holding spacebar/c or if you are brake landing and Brakes are engaged to help slow your decent.
This should fix the problem with landing in low g environments with vertical engines.

Version 4.833
- Any engine tagged with hover will not fire in cruise control unless spacebar/c used.  If they dont stop, tap c/spacebar (opposite direction) and they should.
- Removed speed multiplier based on height when using re-entry to account for planets with very high atmosphere.
- Modified userControlScheme to not care about upper/lowercase and to check for typos.
- Validated all user LUA Parameter descriptions.  Mouse over a name to see what it does.


Version 4.832
- Clean up some variable naming
- Autopilot on arrival to orbit at new planet will only align prograde if proceeding to land
- Vertically mounted engine performance (no gyro activated) changed (NOTE: For the moment, if in cruise control (ALT-Hold turns this on too) vertical engines will fire to help maintain altitude)
1) Will always fire (or stop) if you hit spacebar/c (as appropriate for up/down mounted engines)
2) If not in atmosphere, they will not fire unless you hit spacebar/c (this helps prevent them from autofiring in space and wrecking orbit)
3) If in atmosphere, they will fire automagically if BrakeLanding and Brakes are on (assist brake landing) OR if < detectible hover height but > landinggear height +5 (assist landing)


Version 4.831
- Only show weapons panel if radar is not jammed or if you have gear extended (landed) otherwise hide for clean screen.

Version 4.83
- Autopilot to another planet now works starting from ground.
- Autopilot to saved location on another planet now works starting ground or space.
For both cases:  Pick target like normal, hit autopilot (button or alt-4).  
Ship will tilt up at preset max angle (30 by default) and fly to 100km then engage autopilot to selected planet. 
Once it arrives it will establish orbit and align prograde.  If saved location chosen, it will glide entry in and
then autopilot to location. NOTE: It does not check to see if anything is in front of you on ground (like normal) nor 
if your target planet is behind current planet even 100km in space.  DO NOT USE if your ship cannot power out of 
atmosphere at 30 deg with 100% engines. USE WITH CAUTION FIRST TIME.
Tested Alioth to Sanct and Sanct to Alioth repeatedly.
- Added check to help prevent autopilot to saved location in atmosphere causing stall if facing too many degrees out at start.
- Added Stall Warning if your alignment drops below StallAngle (35 by default) - EVERY SHIP WILL BE DIFFERENT
- Changed end of Autopilot to turn on Align to Prograde by default.
- Credit for heading code to tomisunlucky
- Change vSpd calculation, same results.
- Removed 5 second delay on activation of Emergency Warp.  If you turn it on, you want it to activate when any of the conditions are met.
- Changed tilt on Follow Mode to 20 deg to allow better following.  Note: Very light or single hover ships cannot utilize Follow Mode.
- Changed default max pitch to 30 (most ships will handle this fine, change if needed, recommend not less than 20)
- Added user variable StallAngle = 35 --export: Determines how much Autopilot is allowed to make you yaw/pitch in atmosphere.  Also gives a stall warning.  (default 35, higher = more tolerance for yaw/pitch/roll)
Lower this value (or raise it) based on how well your ship handles yaw/roll/pitch without stalling.
- Changed default Orbit Height to 50km (from 100km)


Version 4.823
- Fix wrong landing height when hitting G

Version 4.822
- Re-add currentGroundAltitudeStabilization back to up and down to see if fixes anything :)
- Attempt to let vertical engines autofire in atmosphere like vanilla so they work to assist hover if installed.
- Change G key to turn off throttle if pressed regardless if in hover height or not. (i.e. press it when landing) 

Version 4.821
- Fixed DrawThrottle bug not receiving throttle value if just starting up.
- First try on fixing roll/pitch/yaw getting stuck on.

Version 4.82 
- Removed structural integrity - Too hard to caclulate due to how ships mass vs elements is updated, makes it think voxel damage when none.
- Updated Emergency Warp to ignore any contact that is < IgnoreEmergencyWarpDistance
- Updated Emergency Warp to ignore a target with a transponder that matches your transponder.
- Added user option (IgnoreEmergencyWarpDistance) where targets within this distance are ignored for emergency warp purposes (500 by default)
- Added user option (RequireLock) to only Emergency Warp if someone is within EmergencyWarpRange and has target lock on you (off by default) - NOT TESTED BUT SHOULD WORK.  ANYONE WHO TESTS PLEASE TELL ME.

Version 4.811 - Change brake behavior
- When you hit G already within hover distance, brake is applied assuming  you want to extend gear and land.  if you just want gear down, hit CTRL to toggle off brake.

Version 4.81 - Cleanup of hud performance in space
- Hud now behaves/looks different in atmosphere, out of atmosphere but within planetary influence, and outside of planetary influence.

Version 4.80 - Updated HUD, now with a compass
- Reformat HUD for a cleaner experience (F-16 style).  cirleRad now sizeable from 100 to 400 with different looks < or > 200

Version 4.793 
- Reverted save change.  ALT-7 will only wipe databank of saved variables.  To fully wipe a databank, pick it up, right click it, Remove Dynamic Properties, then put it back down.  
This way you can wipe variables without wiping save location.  Note:  useTheseSettings button in Edit Lua Parameters makes the hud use the parameters vice what is on the databank.
When you stand up, it will save those new settings.
- Fixed useTheseSettings message when you sit down with it toggled on


Version 4.792
- Fixed Update Position
    If you used Update Position previously, you need to clear your databank.  Thus... 
- Alt+7 now fully clears the databank, since it's not really used anymore and databanks don't clear when you pick up and replace them anymore
    **Important** This means that pressing alt+7 is always a databank clear, not a save.  Check the 'useTheseSettings' checkbox to save settings

Version 4.791 - Bugfixes and adjustments
- Fixed hitting G not making you go  up to max height if you are already within hover/vBooster range and not landed.  G now performs:  If on ground, takes you up to max hover height (TargetHoverHeight).
If in air and within hover range, lands, if in air and above hover range, brake lands
- More cleanup of AGG.  Will not worry about yoyo in atmosphere (doesnt tend to happen).  setBaseAltitude called during change of target height if it changes.  While off, singularity will progress to last set target height.
- Added parameter to show full HUD while in Remote Controller
- Adjusted 'Update Position' to update planet and atmo levels
- Fixed follow mode hover height to use parameter

Version 4.79 - AGG Performance cleanup (no more yoyo)
- Removed fuelTankOptimization from user parameters since we dont care about it anymore when calculating unslotted tanks.
- Fixed AGG to prevent yoyo'ing while going up or going down. Brakes will toggle to prevent passing the singularity unless under throttle power or outside range of singularity.
- Changed displayed message while AGG is on to show both target height and singularity height.  Message will be red if outside singularity range of attraction (5oom) (meaning no support from AGG)

An Explanation - The way the AGG works is by creating a singularity at a certain height.  Once it is created at that height, it can only be moved up or down at a set pace from its current height.  During normal vanilla operation
the ship will begin moving towards the singularity, but if it passes it, it will then slow, stop, and reverse, creating a yo-yo effect as you go up or down using the AGG.  In order to make this cleaner, the HUD will now apply
brakes IF you are not using throttle or cruise control and if your ship starts to pass the current singluarity height in the direction the sigularity is heading.  This will result in motion dropping to 0, but will prevent reversing.
Rate of change is: 3.7m/s going up.  Note: It is faster to go down via gravity unless using the AGG for high mass loads.


Version 4.78 - Goodbye speedy AGG, we barely knew ye
- Per official request from NQ, AGG features in DU Orbital Hud now just provide easy method to change target height (Alt-C and Alt-Spacebar).  All other AGG functionality is vanilla.
- Changed damage report to show honeycomb damage (structural integrity) only when stopped.  Update rate of construct mass is different timing than element mass, which is only way to get honeycomb mass, so was making it flash.
- If fuelX and fuelY are both set to 0, the HUD will not show fuel tank status.  Use if using an external fuel display system.
- Added opacityTop (0.1 default) and opacityBottom (0.3 default) to allow control of AH background opacity 0.0 to 1.0

Version 4.77
- Fixed AGG button showing wrong state...again, no really.
- Changed AGG behavior so brake toggles on when you reach target height.  Brake toggles off if you raise or lower target height.  (you can always toggle brake with CTRL like normal)
- Improved performance of AGG by helping keep singularity location near ship when AGG is off so that when turned on if you changed height without AGG you dont have to wait for it to catch up as much.
- Fixed bug where some buttons could trigger while not visible
- Fixed distance readout for autopilot
- Reduced somersaults
- Brake is now used to help redirect AP trajectory if fuel would be wasted thrusting backwards
- AP drops to Cruise mode if you throttle down and shows cruise time for current speed (predicted times will be wrong if you go lower speed)

Version 4.76
- Slightly reduced multiple for Parachute Re-Entry initial speed when > 15000m
- Fixed AGG button showing wrong state action.
- Fix structural integrity 99% flashing, i hope.

Version 4.75
- Fine tuned emergency warp to not try if PLANET TOO CLOSE error condition. So - Must have Emergency Warp enabled, must not be too close to planet, must have a space radar contact within EmergercyWarpDistance, then it will try to warp if all other conditions met.
- Parachute Re-Entry now with more butt-clenching goodness.  Starts at higher speed based on initial height if > 20000m.  (Still ends up at Re-Entry speed when you hit atmo)

Version 4.74 - MAJOR fix to wings and aerilons - Upgrade strongly recommended
- It turns out that when we made the change to prevent vertical space engines firing randomly decaying orbits, we also removed Wing Engines.  This has been restored and you should see vastly improved performance from your lift surfaces, especially if you hit spacebar.  Ask Dimencia for more info.
- Changed warp widget to show up if a target is selected and it is more than 2 SU away.
- Added retrograde red dot to AH while in space.  Smaller dots.  Show prograde dot in atmo when going fast enough for it to matter.
- Added support for Fuel Tank Handling talen for unslotted fuel tank calculation.  Must use value of person who placed the tank, 1-5 for each type of tank.  This is in addition to Fuel Tank Optimization.  Unslotted fuel tank percentage will closely match slotted if values of Handling and Optimization are correct.
- Fixed Elemental Damage sometimes reporting 99% when fully healed and no damaged componet total listed.
- Moved throttle, default position, to right side of AH to make room for Roll value.  Added throttle position x and y user parameters.
- Updated formattime to show days and hours, or hours and min, or min and sec, or sec
- Fixed issue with ships that had landing gear but no longer have it but databank still thought they did.

Version 4.73 - Atmosphere Rocket Engine assist
- Changed landed ground target height to user variable instead of 0 if landing gear used.  Set to hover height reported - 1 when you use alt-spacebar to just lift off ground from landed postion.  4 is M size landing gear, not countersunk, on bottom of ship.  14 appears to be Large landing gear setting.
- Restored Glide Re-Entry as option to Parachute Re-Entry.  Still will not work well for some ships.
- Enhanced AGG when toggling on after already in use so it reacts faster.
- Altimeter support for negative altitude, turns red when < 0 m and counts up as you go down
- Added atmospheric rocket engine assist, code provided by Azraeil.  Lets rockets assist in atmosphere while in throttle mode without firing constantly and wasting fuel, same as with cruise control already.  Rocket will toggle off automatically when at 85% of target speed as determined by either throttle setting * max speed in atmo (1050) or MaxGameVelocity parameter.  In cruise control mode it will toggle at 85% of desired cruise speed.
- Added notification if Rockets are on down bottom.

Version 4.72 - Variable Updates
- IMPORTANT: Databank Wipe is advised. (You will not lose saved locations)
- Proper formatting of local and global variables for consistency.  
- Fixed databank wipe to not wipe saved locations.
- Autopilot locations now in alphabetical order.
- Changed new save locations to be named as PlanetName.# or PlanetName.# "Nearest Atmo Contact" to work with new sorting.
- Reordered button locations to clean up around some that show conditionally.

Version 4.71 - Bug Fixes
- Fixed Interplanetary display updating with change from custom to planet and atmo to space (again)
- Changed upper Warning Messages to not be hidden when Buttons shown
- Fixed script error when using button to cancel Parachute Re-Entry
- Added planet.atmos = true/false and planet.gravity = X.XX (in g) to Atlas for calculations about planets when not there.
- Changed Strongbrakes to StrongBrakes = ((planet.gravity * 9.80665 * core.getConstructMass()) < LastMaxBrake)
- Fixed Landing Gear sensing and operation
- Fixed emergency warp to cancel if Emergency Warp mode toggled off or cancellation key is pressed.
- Fixed hover engines performing brake landing.

Version 4.70 - Updates And Bug Fixes
- Changed Glide Re-Entry to Parachute Re-Entry.  Recommend brown pants.  Do NOT use if you have not performed a Brake Landing in Atmosphere
- Fixed Interplanetary display when shifting atmo to space and custom to target
- removed currentGroundAltitudeStabilization undefined variable
- fuelX and fuelY user positions provided, sets fuel tank text location, (default 100, 350) setting both to 0 turns off fuel tank text display. 
- removed seconds from formattime strings to clean up displays
- changed fueltankoptimization value from 20% per level to 5% per level to reflect actual skill effect (affects unslotted tank amounts only)
- Fixed re-entry button not being able to initiate re-entry
- Fixed issue with AGG Button display and with Repair Arrow button location.

Version 4.693 - Bugfix
- Fixed Saving of Variables
- Removed final references to AutoBrake

Version 4.692 - Bugfix
- Repair arrows should now work for all size cores
- Restored Navbal (Artifical Horizon) to center by default.  Use centerX=700 and centerY=980 for lower left placement.

Version 4.691 - Bugfix
- Fixed bug causing hovers to not fire when not using a landing mode
- Synchronized AH to ticker

Version 4.69 - Cleaning up Local-Global declaration
- Added support for BrightHUD toggle to prevent AH vanishing if toggled on
- Modified Reentry button to engage re-entry vice needing to press G after button.\
- Added E-Warp Engaged message to remind you if it is on

Version 4.68 - Clean up release conf generation
- Update Readme
- Fix version to be pulled from .conf
- Fixes all remaining warnings using vscode

Version 4.67
- Changed interpretation of Autopilot Throttle rate
- Made interplaneterary panel update itself 10 times faster
- Added variables for user to move vSpeed Meter, and Altimter/Speed indication

Version 4.63 - Cleared a lot of unused and misnamed variables.

Version 4.62 - HUD Redesign continued, KSP navball
- The Artificial Horizon is more of a KSP Navball now.  You may put it anywhere with centerX and centerY setting (use 1920x1080, it will scale).  circleRad must either be 0 (off) or 100 right now. Resizing coming.
- Added prograde dot to AH
- Moved most HUD items out of center for cleaner view
- No functionality has been lost.  Just cleaned up the HUD and made the Artifical Horzion much more dynamic.

Version 4.61 - HUD Redesign - Update the hud to be more minimalist yet still provide all the information, shooting for a more KSP Navball
- Moved placement of data to support new AH view
- Replaced altimeter tape with rolling number altimeter
- Replaced roll tape with rolling ticks on artificial horizon
- Replaced pitch tape with pitch lines on artificial horizon
- Moved fuel tank information from right side to left to avoid widget overwrite.
- Fixed Orbit being displayed when stationary (plantets dont rotate here)
- Fix AGG script error when setting value lower via holding alt-c

Version 4.60

- Added AGG support.  Engage AGG > 1000m with ALT-G or Button.  Use alt-c and alt-space to change AGG target height.  NOTE:  turning on brake does not cancel agg for obvious reasons.  You must toggle it off to cancel.
- Updated Save mechanics. Please READ the SAVE section of the README
- Changed emergency warp retry to every second if enabled
- fixed autoroll setting issue
- Brake Toggle or Default mode user variable restored to remember setting
- Testing braking after emergency warp and re-engage of autopilo

Version 4.58
- Change Emergency Warp to retry every 30 seconds if enabled.

Version 4.57
- Glide ReEntry is on a Button now.  Default is off.  If enabled, hitting G will attempt to put you into a glide reentry to ReentryAltitude at ReentrySpeed (2500m and 1050km/hr default, user settable)

Version 4.56
- Damaged components indicated by arrows while in Remote mode.  Allows you to walk around and repair being shown where next one is located.  Toggled on by Button while in remote mode (hold shift to see buttons)
- Removed EmergencyWarp as a user variable. Now toggled by a Button.  Default is off.  If you toggle it on, then when conditions met, EmergencyWarp.  EmergencyWarpRange remains a user variable.
- Removed BrakeToggle as a user variable.  Now toggled by a Button.  Default is Toggle Brakes.  Toggle to enable vanilla Brakes.
- Removed DisplayOrbit as a user variable.  Now toggled by a Button.  Default is on.

Version 4.555
- Fix Cruise text to not be huge.

Version 4.55
- Transponder IFF.  If any radar contacts have a matching transponder tag, they are listed at the top of the screen

Version 4.54
- Emergency Warp support. Set EmergencyWarp to true (default false).  Set EmergencyWarpRange to distance (default 320000 km, farthest default large ship lock range with large radar).  If you have a radar, and a warp engine, and if a target gets within EmergencyWarpRange and all other conditions to warp are met, EmergencyWarp to target will activate.  If it fails to activate, it will not retry.  You can hit ALT-J to stop it within 5 seconds.  NOTE: You can set EmergencyWarp to true and intentionally not put cells in its container and use it as a warning when someone gets within EmergencyWarpRange
- Restored structural integrity (voxel damage).  HUD assumes when you sit down your voxels are at 100% and reports any damage.  Element damage report unchanged.
- Added check for databank before allowing save of locations
- Fixed display of integrity reports.
- Added LastMaxBrake to saved variables to have initial brake value before brakes used if databank used.
- Fixed interplanetary values display when normal planet shown after a local save location.

Version 4.53
- Fixed HUD Color preference not loading from databank properly.

Version 4.52
- Removed structural integrity - too unreliable at this time.  Elemental Intregrity remains.
- Added current acceleration in g's.  Changed gravity reading to g. Currently these are based on 1g earth normal.
- Moved acceleration, gravity, and atmosphere updates to once per second.

Version 4.51 
- Fix for display errors that might have caused control issues.
- Coast Landing will only display if moving at high speed when using gear

Version 4.5 - Autopilot to saved location in atmosphere
- Minified conf file to avoid overflow script limit.  Added a readable version for editing/understanding.
- Initial Pass: Autopilot to a presaved waypoint in atmosphere.  Use: Go to location you wish to mark.  In seat, hold shift and click Save Location.  When wishing to return to a saved point, use ALT-1/2 or SHIFT T/R till you see saved location.  If not on ground, be sure to be pointing in general direction to avoid yaw stall.  Hit Alt-4 to engage.  You may use yaw once brake landing begins to spin in place.  Saved locations may be deleted by selecting it as target and the holding shift and choosing Clear Position.  It is fairly accurate and you should arrive within 15m of marked location assuming good brakes (brake landing).  If you see Coast Landing, be prepared to take over the arrival.  If atmo radar installed, saved location will use nearest target for naming, otherwise will be named #.planet (i.e. 0.Alioth)

Version 4.37
- Fixed damaged display to be visable and color shaded by % damage.

Version 4.36
- Pulled fuel tank fixes
- Pulled mass calculation fixes

Version 4.35
- Initial Warpdrive support.  Warp Widget hidden by default.  Warp Hotkey (default Alt-J) will toggle the widget on if off, off if on, and initiate Warp Jump if conditions met or give message if not.  Widget will autoshow if conditions met to jump.

Version 4.34
- Moved Interplanetary Widget info to slower update (once per second) to save on performance.

Version 4.33
- Fixed throttle arrow to always stay in range for positive and negative throttle.  Throttle color changes to red if in reverse.  Bar removed if in cruise.
- Fixed alt key not to toggle freelook if using alt+# option.  Tapping alt will toggle freelook like normal.

Version 4.32
- Fixed new bug preventing Reentry from occurring

Version 4.31 - Bugfixes and Performance
- On a planet with no atmo, re-rentry will no longer engage if below the designated reentry height (pressing G will enage brake-landing instead)
- Attempt to resolve recent issues - forced garbage collection every second, moved screen drawing to Update instead of on a fixed tick

Version 4.3 - Now with re-entry
- Hitting G while over a planet will attempt to do reentry to a designated altitude hold (default 2500m) at a designated max speed (default 1050km/hr) to avoid re-entry burnup.  ReentrySpeed is user value for speed, ReentryAltitude for height.
- interpret linebreaks for msgText

Version 4.22
- Added MaxPitch as user variable, default value 20 degrees.  Sets max pitch autopilot will use during takeoff and altitude changes while in altitude hold or for re-entry.
- Fixed text display on Orbit panel

Version 4.21 
- Updated non-widget fuel tank display to use slotted tank values (more accurate) for slotted tanks.
- Updated G key to always brake land if gear is up and within capacity of brakes.  Otherwise gear down and manual landing required.

Version 4.2
- Refactored display to more pure CSS for smaller filesize and more efficient frames
- Show Orbit display only if speeds are within max speed and if periapsis and apoapsis exist.
- Modified all automated landings to use brake landing.  This is much safer than the previous autoland, but use under supervision.  Hit G to initiate landing any time.

Version 4.181
- Fixed script error
- Fixed a minor inaccuracy in brake time calculation

Version 4.18
- Added max mass on target planet to Interplanetary info.  Note:  If target planet has atmo, you must be in atmo to get an accurate reading.  The formula is MaxBrakeNewtons / PlanetGravityAtSeaLevel, shown in tons.  So if you are going to a planet with no atmosphere, you must get a reading while in no atmosphere.

Version 4.174
- Added DU version number in lower right hand corner of screen.

Version 4.173
- added displayOrbit user variable for those who do not want the KSP style orbit in upper corner.  Default true (to show)

Version 4.172
- Save autoroll preference when using Brake Landing
- Fix shifting to Cruise Control on autotakeoff.

Version 4.171 
- Added safety check to Brake landing.  If current mass * gravity at sea level > maxBrake power, it will not try an automatic Brake Landing.
- Added user variable for loss of altitude rate, brakeLandingRate, when using brake landing. Default is 30 m/s

Version 4.17 - Brake Landing
- While flying, if you have hover or vertical boosters, and you hit G, your ship will attempt to brake land.  If you are at max load of low altitude lift, or of brakes, do not use.  This does not replace hitting G for autoland while in altitude hold.  To brake land you must cancel altitude hold first.  As with most auto features, toggle brakes to turn off.

Version 4.162
- localized Nav.control.isRemoteControlled() function in unit.start and apTick 
- Only show Follow Mode button if on a Remote.  Alt-8 while on seat will give message only works when on remote.
- Hide autopilot engage button in atmo, give message if use alt-4 in atmo.
- Hide retrograde button if in atmo
- Shift to cruise control once reach takeoff altitude.

Version 4.161
- Updated new values to show n/a if out of gravity.

Version 4.16
- Ship now shows Required forward thrust for current mass at current gravity and Max Mass for max available forward thrust in current gravity.  Note this does not consider lift, just values if you pointed 90deg up.

Version 4.15
- Gyro's autoconnect again.  If you have a gyro on ship and run autoconf after it is placed, this will let you hit alt-9 the gyro will activate.  This can be used to change your controls perceived orientation from Core orientation to Gyro orientation.

Version 4.146
- Must press alt-7 2 times to wipe databank.  A wiped databank prevents saving of flight status variable.
- Attempt to fix calculation of fuelTankOptimization when setting up fuel tanks.

Version 4.145
- Fixed bugs with dimming, more elements are now undimmed when in freelook, dimmed elements are dimmer, artifical horizon is not displayed in freelook
- Fixed fuel display problem with remote control
- Readded brighthud

Version 4.144
- Track trip time and total run time on ship.

Version 4.143
- More optimization refactoring
- Fixed new DU bug with vertical engines firing constantly

Version 4.142
- More optimization refactoring from Chronos.

Version 4.141
- Fix for structural damage showing 99% when no voxels damaged.  Damage report only appears if any damage.

Version 4.14
- Updated damage report to show Structural Integrity (Voxel damage) and Element Integrity (Element damage). Element integrity still shows # of disabled and # of damaged elements.
Max Voxel integrity is set when you sit in the seat and autosaved if you have a databank attached.  To reset it you must perform normal save wipe (ALT-7) per Readme.

Version 4.13
- Added maxBrake to odometer
- Added maxThrust to odometer
- Modified mass to use function call, no need for extraMass anymore.

Version 4.126
- localized unit.getAtmosphereDensity

Version 4.125
- Added to user variables: brightHud = false --export: Enable to prevent hud dimming when in freelook.

Version 4.12
- Optimizations and fix save feature

Version 4.11
- Optimaztions with function localizations

Version 4.1 
- Major change in how html text is formatted, should result in improved performance but report any bugs.

Version 4.065
- Bug fixes.

Version 4.06
- added player variables speedChangeLarge and speedChangeSmall so you can control the rate of throttle change.  Large happens when you tap speed up or down, small happens when you hold speed up or down.
- doors and ramps will not auto open when exiting seat/remote while in space 

Version 4.05 - Odometers, Mass, and Rocket change
- Added a Trip and Lifetime odometer.  Note that trip resets if you get out of seat.  Lifetime doesnt reset unless you clear databank (and only saves with databank)
- Added Total Mass of ship, and a new user parameter extraMass because i cannot calculate honeycomb mass.  set extraMass to honeycomb mass as shown in Builder info
- Modified Rocket Engine performance.  In Cruise Mode it will fire till you reach cruise speed and then again to keep you at that speed till toggled off.  In Travel Mode it will fire continuous till you toggle it back off.

Version 4.04 - Cruise Control with Altitude Hold
- Modified alt-6 to turn on cruise control and altitude hold at same time.  Cruise speed set to current speed, altitude to current altitude.
- Use ALT-C and ALT-SPACE to change set altitude height.
- Hitting G while in altitude hold will start an autolanding like normal, but will also cancel cruise control for you.
-- Reverted 4.05 due to issues with AutoLand caused by fixing vertical engine problems

Version 4.03 More cleanups
- Cleaned  up code
- Removed vertical speed change if altitude is gone (200km)
- Cleaned up time displays and fuel location to account for planet name when in space.

Version 4.02
- Cleaned up comment lines to reduce code size.

Version 4.01
- Fixed time remaining when using multiple tanks.
- Fixed script limit issue where other players couldn't use the seat (and you had to reload it every time you relog)

Version 4.0 - More slots please  
(NOTE: This change means the default vanilla fuel widgets will no longer be shown unless you manually link fuel tanks to control chair/remote)
- Removed automatic slotting of all fuel tanks, freeing up slots for other items. Fuel percentages and time remaining are still shown.  The value for 100% will be the larger of vanilla volume or your current fuel volume when you get in the seat. 
- Added fuelTankOptimization = 0 For accurate fuel levels, set this to the fuel tank optimization level * 0.05 (so level 1 = 0.05, level 5 = 0.25) of the PERSON WHO PLACED the tank. This will be 0 for most people for now.

- Minor bugfix for when that DU bug starts your ship spinning, the ship should stop when you get out now

Version 3.97 -
- Moved functions back to unit.start

Version 3.96 -
- Changed altitude rate of change to meter vice just number
- Moved functions to system.start() that are not affected by a reset

Version 3.95 - I love merges
- Readded more things that got lost in the merge
- Fixed altitude
- Adjusted rate to be negative when toward the planet

Version 3.94 - Minor fixes
- Remerged some things that got lost from 3.93
- Adjusted vspeed to be in km/h like the rest of the readouts
- Radar checks moved to a less demanding timer

Version 3.93 - I honestly don't remember anymore
- Adjusted changing of altitude-hold (With Alt+C/Space while in Alt Hold or Takeoff) to be exponential to more easily altitude-hold to space
- Better smoothing for altitude hold
- Increased update rate of vertical speed and adjusted to use vector math
- Added galaxy map to Remote Controller buttons screen
- Lots of fixes for some of the buttons not enabling/disabling related programs
- IDK a lot of stuff I've been holding on to for a while

Version 3.92
- Radar periscope only opens when locked target
- Added toggle that supports having hud and widgets open at same time

Version 3.91
- Added constant damage check.  Shows Structural Integrity (percentage of total of max hit points of all elements versus current hit points) and the number of disabled or damaged elements.
- Added Radar: No Contacts message or total contacts shown under minimap above fuel status.

Version 3.90
- Initial Damage reporting in place, currently does a check of all elements hp's when you get in seat and reports as a percent

Version 3.88
- Moved fuel tank info under minimap

Version 3.87
- Renamed fuel tanks will display their name on the fuel status (up to 12 characters)

Version 3.86
- Added initial pass on rate of change of altitude
- Fixed locations of tank information

Version 3.85
- Added support for rocketfuel tanks
- Fuel Tank Name blinks if < 5% fuel or less than 2 min burn time left

Version 3.84
- Adjusted so keyboards have viewlock again so they can see the buttons.  Woops.

Version 3.83 - Fixed altitude not showing when in space.

Version 3.82 - 
- Adjusted so keyboards no longer have their view locked when pressing alt
- Fixed a potential issue that might have caused autopilot to abort before achieving orbit

Version 3.81 - Fixed BrakeToggle() error
- Was unrelated to brake, assigning a nil value to targetGroundAltitude

Version 3.80 - Cleanup
- Moved collectgarbage to end of unit.start
- Consolidated widgets into ToggleWidgets (still alt-3 to show/hide hud/widgets)

Version 3.799 - Minor Tweaks
- Tried changing a few miscellaneous things to try to find and address some users having script errors
- Fixed an issue with remembering variables during autopilot

Version 3.79 - What do you think
- Fixed an issue when brakeToggle was off
- Changed brake button on HUD to be a Brake Toggle On/Off button so you can change this on the fly

Version 3.78 - More fixes
- Fixed issues with the new buttons (that were unintentionally released early because other bugs were found)
- Added parameter to set your target hover height when retracting landing gear
- Added parameter to set your target throttle amount when engaging interplanetary autopilot
- Adjusted Autopilot behavior to no longer lock the throttle; it will set it once for each stage, and you can then change it as desired

Version 3.77 - TurnBurn and Brake bugfixes
- Fixed a problem where brake toggle wasn't being reliable
- Fixed TurnBurn calculations (hopefully)
- Removed buttons from Remote Controller again because they're just, not good like that.  Investigating other options.

Version 3.76 - Fixes and cleanups
- Fixed radar to only turn on if it senses someone

Version 3.75 - Fixes and requests
- Allowed altimeter to show negative values (make your submarine, but i think you'll blow up)
- Fixed altimeter to be same size as pitch bar (was blocking altitude and atmosphere)

Version 3.7 - Radar updates
- Modified hud to hide space radar in atmo and atmo radar in space.

Version 3.61 - Fix for braking values disappearing

Version 3.6 - Optimisation
- Resolved framerate issues entirely (excluding the tab-click-slideshow bug)
- Created persistent state; ship remembers how you left it when you exit and re-enter, or swap to a remote controller
- Resolved many problems with autotakeoff: You now control your speed and when to takeoff, and the ascent is much smoother
- Increased descent rate on autolanding to -10degrees
- Removed minor lines on meters (for FPS reasons), other minor HUD tweaks such as fonts
- Ability to adjust Hold Altitude with Alt+C and Alt+Space while in Altitude Hold mode
- Auto-landing will now cancel if you hit the brake while it's running, as will all Altitude Hold modes

Version 3.5 - Atmospheric Autopilot
- Added Altitude Hold, Auto Takeoff, Auto Landing modes
- Adjusted databank to no longer have to clear the entire bank
- Adjusted LAlt-3 to toggle between HUD and normal widgets on one key

Version 3.0 - Follow her to school one day!
- Added autofollow when on foot if using remote unit
- Added ability to hide hud and still have all other features available. LALT-3
- Moved AutoBrake to LAlt-9
- LALT-6 now shows or hides all normal widgets (not radar, weapons, or periscope)
- Added all variables shown in Advanced-Edit LUA Parameters to save values (25 now)

Version 2.07 - Hide Hude
- Added ability to not show (or calculate) hud but still use autopilot
- Added autoRoll and showHud to saved variables.

Version 2.06 - Follow Mode
- Added follow mode to allow a remote controller to call their ship to them

Version 2.05 - Remote Controller
- Updated HUD to recognize when a Remote Controller is used and move information out of the way

Version 2.04 - Altimeter
- Updated altimeter to not be so spastic by changing its scale.

Version 2.03 - Save work
- Updated saveable variables and ones that show in Edit LUA Parameters.  You will need to hit alt-7 to delete current and restave them

Version 2.02 - Player Feedback
- Added ability for messages to pop up on screen for limited time to provide user feedback.

Version 2.01 - Minor fixes
- Fixed padding problems with orbit map
- Fixed AutoBrake to use current brake instead of max brake

Version 2.0 - MAJOR change to code, please report any issues.
- Moved all system.start() code to unit.start()
- Made HUD update rate editable with apTickRate in Edit Lua Parameters
- Added apTickRate to save variables to keep track of user preferred tick rate
- Added PrimaryR, PrimaryG, PrimaryB to save to track preferred HUD color

Version 1.1
- Added fix for nil error when processing total fuel tanks
- Added ability to use default braking, plus added that to save variables.
