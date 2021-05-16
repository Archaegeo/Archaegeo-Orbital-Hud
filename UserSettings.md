# User Settings
* DATABANK USAGE: The hud databank must be manually slotted to the control unit one time and then the HUD Autoconf file re-ran.
When you stand up, all current user settings are saved to a manually linked databank.  When you sit down, the settings on a databank will override those
in Edit Lua Parameters unless useTheseSettings is checked.
## To modify user settings:
* While out of seat, right click the control unit and go to _Advanced_ -> _Edit Lua Parameters_  Mouse over a name to see its default value.
* While in seat, hold SHIFT while not in freelook mode, mouse over View Settings, and release SHIFT (Thats how you click a button)
* While in View Settings mode, you can hold SHIFT and mouse over a true/false value to change it, or mouse over one of the sub
catagories
* Sub catagory values can be changed by hitting Enter, selecting LUA chat, and typing /G VariableName value
# The construct itself must be set to keyboard control.  Then you use this setting to set how the hud controls.
* userControlScheme = "virtual joystick" --  (Default: "virtual joystick") Set to "virtual joystick", "mouse", or "keyboard".  This can be set by holding SHIFT and clicking 
the button in lower left of main Control buttons view.
### True-False Values
* useTheseSettings = false --  (Default: false) Toggle on to use the below preferences.  Toggle off to use saved preferences.  Preferences will save regardless when exiting seat. 
This is only needed if you want to use Edit Lua Parameters to override saved settings already on a databank.  First install, or changing settings via in seat methods, you do not need to set this to true.
* freeLookToggle = true --  (Default: true) Set to false for vanilla DU free look behavior.
* BrakeToggleDefault = true --  (Default: true) Whether your brake toggle is on/off by default. Can be adjusted in the button menu.  Of is vanilla DU brakes.
* RemoteFreeze = false --  (Default: false) Whether or not to freeze your character in place when using a remote controller. 
* RemoteHud = false --  (Default: false) Whether you want to see the full normal HUD while in remote mode.
* brightHud = false --  (Default: false) Enable to prevent hud hiding when in freelook.
* VanillaRockets = false --  (Default: false) If on, rockets behave like vanilla
* InvertMouse = false --  (Default: false) If true, then when controlling flight mouse Y axis is inverted (pushing up noses plane down)  Does not affect selecting buttons or camera.
* autoRollPreference = false --  (Default: false) [Only in atmosphere]<br>When the pilot stops rolling,  flight model will try to get back to horizontal (no roll)
* turnAssist = true --  (Default: true) [Only in atmosphere]<br>When the pilot is rolling, the flight model will try to add yaw and pitch to make the construct turn better<br>
The flight model will start by adding more yaw the more horizontal the construct is and more pitch the more vertical it is
* ExternalAGG = false --  (Default: false) Toggle On if using an external AGG system.  If on will prevent this HUD from doing anything with AGG.
* UseSatNav = false --  (Default: false) Toggle on if using Trog SatNav script.  This will provide SatNav support.
* ShouldCheckDamage = true -- (Default: true) Whether or not damage checks are performed.  Disable for performance improvement on very large ships or if using external Damage Report and you do not want the built in info.
* CalculateBrakeLandingSpeed = false -- (Default: false) Whether BrakeLanding speed at non-waypoints should be calculated (faster) or use the brakeLandingRate user setting (safer).
* AtmoSpeedAssist = true -- (Default: true) Whether or not atmospheric speeds should be limited to a maximum of AtmoSpeedLimit (Hud built in speed limiter)
* ForceAlignment = false -- (Default: false) Whether velocity vector alignment should be forced when in Altitude Hold (needed for ships that drift alignment in altitude hold mode)
* DisplayDeadZone = true -- (Default: true) Virtual Joystick Mode: Set this to false to not display deadzone circle while in virtual joystick mode.
* showHud = true --  (Default: true) Uncheck to hide the HUD screen and only use HUD Autopilot features (AP via ALT+# keys)
* ShowOdometer = true --  (Default: true) Uncheck to hide the odometer panel up top.
* hideHudOnToggleWidgets = true --  (Default: true) Uncheck to keep showing HUD when you toggle on the vanilla widgets via ALT+3.  Note, hiding the HUD with Alt+3 gives a lot of FPS back in laggy areas, so leave true normally.
* ShiftShowsRemoteButtons = true --  (Default: true) Whether or not pressing Shift in remote controller mode shows you the buttons (otherwise no access to them)
* DisplayOrbit = true --  (Default: true) Show Orbit display when valid or not.  May be toggled with shift Buttons
* SetWaypointOnExit = true --export (Default: true) Set to false to not set a waypoint when you exit hud.  True helps find your ship in crowded locations when you get out of seat.
* IntruderAlertSystem = false --export: (Default: false) Set to True to enable Intruder Alert system.
* AlwaysVSpd = false --export: (Default: false) Set to true to make vertical speed meter stay on screen when you alt-3 widget mode.
* BarFuelDisplay = true --export: (Default: true) Set to false to use old non-bar fuel display
* showHelp = true --export: (Default: true) Set to false to hide in hud dynamic help text.
* voice = true --export: (Default: true) Play voice recordings as appropriate if sound files are installed.
* alarms = true --export: (Defatul: true) Play alarm and warning sounds as appropriate if sound files are installed.
### Ship Handling variables
* YawStallAngle = 35 -- (Default: 35) Angle at which the ship stalls when yawing, determine by experimentation.  Higher allows faster AP Bank turns.
* PitchStallAngle = 35 -- (Default: 35) Angle at which the ship stalls when pitching, determine by experimentation.
* brakeLandingRate = 30 --  (Default: 30) Max loss of altitude speed in m/s when doing a brake landing, default 30.  Applied by AP if landing at location added via /addlocation instead of Save/Update button.  
Overriden if `CalculateBrakeLandingSpeed` is true.
* MaxPitch = 30 --  (Default: 30) Maximum allowed pitch during takeoff and altitude changes while in altitude hold.  You can set higher or lower depending on your ships capabilities.
* TargetOrbitRadius = 1.4 --  (Default: 1.4) How tight you want to orbit the planet at end of autopilot.  The smaller the value the tighter the orbit.  1.4 sets an Alioth orbit of 56699m.  1.1 is 18.9k on Alioth
* LowOrbitHeight = 1000 --export: (Default: 1000)  Height of Orbit above top of atmospehre when using Alt-4-4 same planet autopilot or alt-6-6 in space
* AtmoSpeedLimit = 1050 --  (Default: 1050) Speed limit in Atmosphere in km/h. AtmoSpeedAssist will cause ship to throttle back when this speed is reached.  
You can lower or raise (up to this limit) the current value by using Alt+Mousewheel
* SpaceSpeedLimit = 30000 --  (Default: 30000) Space speed limit in KM/H.  If you hit this speed and are not in active autopilot, engines will turn off.
* AutoTakeoffAltitude = 1000 --  (Default: 1000) How high above your ground height AutoTakeoff tries to put you
* TargetHoverHeight = 50 --  (Default: 50) Hover height above ground when G used to lift off, 50 is above all max hover heights.
* LandingGearGroundHeight = 0 -- (Default: 0) Set to AGL-1 when on ground (or 0).  Will help prevent ship landing on ground then bouncing back up to landing gear height.  If too high, engines will not turn off.
* ReEntryHeight = 5000 -- (Default: 5000) Height above a planets maximum surface altitude used for re-entry, if height exceeds min space engine height, then 11% atmo is used instead. (5000 means 11% is used)
* MaxGameVelocity = 8333.00 --  (Default: 8333.00) Max speed for your autopilot in m/s, do not go above 8333.055 (30000 km/hr), can be reduced to save fuel. Use 6944.4444 for 25000km/hr
* AutopilotInterplanetaryThrottle = 1.0 --  (Default: 1.0) How much throttle, 0.0 to 1.0, you want it to use when in autopilot to another planet while reaching MaxGameVelocity
* warmup = 32 --  (Default: 32) How long it takes your space engines to warmup.  Basic Space Engines, from XS to XL: 0.25,1,4,16,32.  Only affects turn and burn brake calculations.
* fuelTankHandlingAtmo = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
* fuelTankHandlingSpace = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
* fuelTankHandlingRocket = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
* ContainerOptimization = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the Container Optimization level of the person who placed the tanks.  Ignored for slotted tanks.
* FuelTankOptimization = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank optimization skill level of the person who placed the tank.  Ignored for slotted tanks.
### HUD Postioning variables - Positions scale to ResolutionX, ResolutionY setting
* ResolutionX = 1920 --  (Default: 1920) Does not need to be set to same as game resolution.  You can set 1920 on a 2560 to get larger resolution
* ResolutionY = 1080 --  (Default: 1080) Does not need to be set to same as game resolution.  You can set 1080 on a 1440 to get larger resolution
* circleRad = 400 --  (Default: 400) The size of the artifical horizon circle, recommended minimum 100, maximum 400.  Looks different > 200. Set to 0 to remove.
* SafeR = 130 --  (Default: 130) Primary HUD color
* SafeG = 224 --  (Default: 224) Primary HUD color
* SafeB = 255 --  (Default: 255) Primary HUD color
* PvPR = 255 --  (Default: 255) PvP HUD color
* PvPG = 0 --  (Default: 0) PvP HUD color
* PvPB = 0 --  (Default: 0) PvP HUD color
* centerX = 960 --  (Default: 960) X postion of Artifical Horizon (KSP Navball), Default 960. Use centerX=700 and centerY=880 for lower left placement.
* centerY = 540 --  (Default: 540) Y postion of Artifical Horizon (KSP Navball), Default 540. Use centerX=700 and centerY=880 for lower left placement. 
* throtPosX = 1300 --  (Default: 1300) X position of Throttle Indicator, default 1300 to put it to right of default AH centerX parameter.
* throtPosY = 540 --  (Default: 540) Y position of Throttle indicator, default is 540 to place it centered on default AH centerY parameter.
* vSpdMeterX = 1525  --  (Default: 1525) X postion of Vertical Speed Meter.  Default 1525
* vSpdMeterY = 325 --  (Default: 325) Y postion of Vertical Speed Meter.  Default 325
* altMeterX = 550  --  (Default: 550) X postion of Altimeter.  Default 550 
* altMeterY = 540 --  (Default: 540) Y postion of Altimeter.  Default 500
* fuelX = 30 --  (Default: 30) X position of fuel tanks, set to 100 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
* fuelY = 700 --  (Default: 700) Y position of fuel tanks, set to 300 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
* DeadZone = 50 --  (Default: 50) Number of pixels of deadzone at the center of the screen
* OrbitMapSize = 250 --  (Default: 250) Size of the orbit map, make sure it is divisible by 4
* OrbitMapX = 75 --  (Default: 75) X postion of Orbit Display Disabled
* OrbitMapY = 0 --  (Default: 0)  Y position of Orbit Display
### Ship flight physics variables - Modify these with care, can have large effects on ship performance
* speedChangeLarge = 5 --  (Default: 5) The speed change that occurs when you tap speed up/down, default is 5 (25% throttle change). 
* speedChangeSmall = 1 --  (Default: 1) the speed change that occurs while you hold speed up/down, default is 1 (5% throttle change).
* MouseYSensitivity = 0.003 -- (Default: 0.003) For virtual joystick only
* MouseXSensitivity = 0.003 --  (Default: 0.003) For virtual joystick only
* autoRollFactor = 2 --  (Default: 2) [Only in atmosphere]<br>When autoRoll is engaged, this factor will increase to strength of the roll back to 0
* rollSpeedFactor = 1.5 --  (Default: 1.5) This factor will increase/decrease the player input along the roll axis<br>(higher value may be unstable)
* autoRollRollThreshold = 180 -- (Default: 180) The amount of roll below which autoRoll to 0 will occur (if `autoRollPreference` is true)
* minRollVelocity = 150 -- (Default: 150) Min velocity, in m/s, over which autorolling can occur
* turnAssistFactor = 2 --  (Default: 2) [Only in atmosphere]<br>This factor will increase/decrease the turnAssist effect (higher value may be unstable)
* TrajectoryAlignmentStrength = 0.002 --  (Default: 0.002) How strongly AP tries to align your velocity vector to the target when not in orbit, recommend 0.002
* torqueFactor = 2 --  (Default: 2) Force factor applied to reach rotationSpeed (higher value may be unstable)
* pitchSpeedFactor = 0.8 --  (Default: 0.8) For keyboard control, affects rate of pitch change
* yawSpeedFactor = 1 --  (Default: 1) For keyboard control, affects rate of yaw change
* brakeSpeedFactor = 3 --  (Default: 3) When braking, this factor will increase the brake force by brakeSpeedFactor * velocity
* brakeFlatFactor = 1 --  (Default: 1) When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction> (higher value may be unstable)
* DampingMultiplier = 40 --  (Default: 40) How strongly autopilot dampens when nearing the correct orientation
* apTickRate = 0.0166667 --  (Default: 0.0166667) Set the Tick Rate for your autopilot features.  0.016667 is effectively 60 fps and the default value. 0.03333333 is 30 fps.  
* hudTickRate = 0.0666667 --  (Default: 0.0666667) Set the tick rate for your HUD. Default is 4 times slower than apTickRate
# NOTE: For engine tags, if changed from "none" then only engines with those tags will fire.
* ExtraLongitudeTags = "none" --  (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "forward faster major"  These will be added to the engines that are control by longitude.
* ExtraLateralTags = "none" --  (Default: "none") Enter any extra lateral tags you use inside '' seperated by space, i.e. "left right"  These will be added to the engines that are control by lateral.
* ExtraVerticalTags = "none" --  (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "up down"  These will be added to the engines that are control by vertical.