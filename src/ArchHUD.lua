require 'src.slots'
local s=system
local c=core
local u=unit

local Nav = Navigator.new(s, c, u)
local atlas = require("atlas")

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 0.745
-- These values are a default set for 1920x1080 ResolutionX and Y settings. 

-- User variables. Must be global to work with databank system
useTheseSettings = false --  Change this to true to override databank saved settings
userControlScheme = "virtual joystick" -- (Default: "virtual joystick") Set to "virtual joystick", "mouse", or "keyboard". This can be set by holding SHIFT and clicking the button in lower left of main Control buttons view.
soundFolder = "archHUD" -- (Default: "archHUD") Set to the name of the folder with sound files in it. Must be changed from archHUD to prevent other scripts making your PC play sounds.
-- True/False variables
    -- NOTE: saveableVariablesBoolean below must contain any True/False variables that needs to be saved/loaded from databank.

    freeLookToggle = true -- (Default: true) Set to false for vanilla DU free look behavior.
    BrakeToggleDefault = true -- (Default: true) Whether your brake toggle is on/off by default. Can be adjusted in the button menu. False is vanilla DU brakes.
    RemoteFreeze = false -- (Default: false) Whether or not to freeze your character in place when using a remote controller.
    RemoteHud = false --  (Default: false) Whether you want to see the full normal HUD while in remote mode.
    brightHud = false -- (Default: false) Enable to prevent hud hiding when in freelook.
    VanillaRockets = false -- (Default: false) If on, rockets behave like vanilla
    InvertMouse = false -- (Default: false) If true, then when controlling flight mouse Y axis is inverted (pushing up noses plane down) Does not affect selecting buttons or camera.
    autoRollPreference = false -- (Default: false) [Only in atmosphere] - When the pilot stops rolling, flight model will try to get back to horizontal (no roll)
    ExternalAGG = false -- (Default: false) Toggle On if using an external AGG system. If on will prevent this HUD from doing anything with AGG.
    UseSatNav = false -- (Default: false) Toggle on if using Trog SatNav script. This will provide SatNav support.
    ShouldCheckDamage = false -- (Default: true) Whether or not damage checks are performed. Disable for performance improvement on very large ships or if using external Damage Report and you do not want the built in info.
    AtmoSpeedAssist = true -- (Default: true) Whether or not atmospheric speeds should be limited to a maximum of AtmoSpeedLimit (Hud built in speed limiter)
    ForceAlignment = false -- (Default: false) Whether velocity vector alignment should be forced when in Altitude Hold (needed for ships that drift alignment in altitude hold mode due to poor inertial matrix)
    DisplayDeadZone = true -- (Default: true) Virtual Joystick Mode: Set this to false to not display deadzone circle while in virtual joystick mode.
    showHud = true -- (Default: true) False to hide the HUD screen and only use HUD Autopilot features (AP via ALT+# keys)
    hideHudOnToggleWidgets = true --  (Default: true) Uncheck to keep showing HUD when you toggle on the vanilla widgets via ALT+3. Note, hiding the HUD with Alt+3 gives a lot of FPS back in laggy areas, so leave true normally.
    ShiftShowsRemoteButtons = true -- (Default: true) Whether or not pressing Shift in remote controller mode shows you the buttons (otherwise no access to them)
    SetWaypointOnExit = false -- (Default: true) Set to false to not set a waypoint when you exit hud. True helps find your ship in crowded locations when you get out of seat.
    AlwaysVSpd = false -- (Default: false) Set to true to make vertical speed meter stay on screen when you alt-3 widget mode.
    BarFuelDisplay = true -- (Default: true) Set to false to use old non-bar fuel display
    voices = true -- (Default: true) Set to false to disable voice sounds when using sound pack
    alerts = true -- (Default: true) Set to false to disable alert sounds when using sound pack
    CollisionSystem = true -- (Default: true) If True, system will provide collision alerts and abort vector to target if conditions met.
    AbandonedRadar = false -- (Default: false) If true, and CollisionSystem is true, all radar contacts will be checked for abandoned status.
    AutoShieldToggle = true -- (Default: true) If true, system will toggle Shield off in safe space and on in PvP space automagically.
    PreventPvP = true -- (Default: true) If true, system will stop you before crossing from safe to pvp space while in autopilot.
    DisplayOdometer = true -- (Default: true) If false the top odometer bar of information will be hidden.
    FullRadar = true -- (Default: true) If set to false, radar will not be activate on sitting down.  This will result in a much higher fps in crowded areas with radar hooked up while still allowing V to show contacts on screen.
 
    saveableVariablesBoolean = {userControlScheme={set=function (i)userControlScheme=i end,get=function() return userControlScheme end}, soundFolder={set=function (i)soundFolder=i end,get=function() return soundFolder end}, freeLookToggle={set=function (i)freeLookToggle=i end,get=function() return freeLookToggle end}, BrakeToggleDefault={set=function (i)BrakeToggleDefault=i end,get=function() return BrakeToggleDefault end}, RemoteFreeze={set=function (i)RemoteFreeze=i end,get=function() return RemoteFreeze end}, brightHud={set=function (i)brightHud=i end,get=function() return brightHud end}, RemoteHud={set=function (i)RemoteHud=i end,get=function() return RemoteHud end}, VanillaRockets={set=function (i)VanillaRockets=i end,get=function() return VanillaRockets end},
    InvertMouse={set=function (i)InvertMouse=i end,get=function() return InvertMouse end}, autoRollPreference={set=function (i)autoRollPreference=i end,get=function() return autoRollPreference end}, ExternalAGG={set=function (i)ExternalAGG=i end,get=function() return ExternalAGG end}, UseSatNav={set=function (i)UseSatNav=i end,get=function() return UseSatNav end}, ShouldCheckDamage={set=function (i)ShouldCheckDamage=i end,get=function() return ShouldCheckDamage end}, 
    AtmoSpeedAssist={set=function (i)AtmoSpeedAssist=i end,get=function() return AtmoSpeedAssist end}, ForceAlignment={set=function (i)ForceAlignment=i end,get=function() return ForceAlignment end}, DisplayDeadZone={set=function (i)DisplayDeadZone=i end,get=function() return DisplayDeadZone end}, showHud={set=function (i)showHud=i end,get=function() return showHud end}, hideHudOnToggleWidgets={set=function (i)hideHudOnToggleWidgets=i end,get=function() return hideHudOnToggleWidgets end}, 
    ShiftShowsRemoteButtons={set=function (i)ShiftShowsRemoteButtons=i end,get=function() return ShiftShowsRemoteButtons end}, SetWaypointOnExit={set=function (i)SetWaypointOnExit=i end,get=function() return SetWaypointOnExit end}, AlwaysVSpd={set=function (i)AlwaysVSpd=i end,get=function() return AlwaysVSpd end}, BarFuelDisplay={set=function (i)BarFuelDisplay=i end,get=function() return BarFuelDisplay end}, 
    voices={set=function (i)voices=i end,get=function() return voices end}, alerts={set=function (i)alerts=i end,get=function() return alerts end}, CollisionSystem={set=function (i)CollisionSystem=i end,get=function() return CollisionSystem end}, AbandonedRadar={set=function (i)AbandonedRadar=i end,get=function() return AbandonedRadar end},AutoShieldToggle={set=function (i)AutoShieldToggle=i end,get=function() return AutoShieldToggle end}, PreventPvP={set=function (i)PreventPvP=i end,get=function() return PreventPvP end},
    DisplayOdometer={set=function (i)DisplayOdometer=i end,get=function() return DisplayOdometer end},FullRadar={set=function (i)FullRadar=i end,get=function() return FullRadar end}}

-- Ship Handling variables
    -- NOTE: savableVariablesHandling below must contain any Ship Handling variables that needs to be saved/loaded from databank system

    YawStallAngle = 35 -- (Default: 35) Angle at which the ship stalls when yawing, determine by experimentation. Higher allows faster AP Bank turns.
    PitchStallAngle = 35 -- (Default: 35) Angle at which the ship stalls when pitching, determine by experimentation.
    brakeLandingRate = 30 -- (Default: 30) Max loss of altitude speed in m/s when doing a brake landing. 30 is safe for almost all ships.  
    MaxPitch = 30 -- (Default: 30) Maximum allowed pitch during takeoff and altitude changes while in altitude hold. You can set higher or lower depending on your ships capabilities.
    ReEntryPitch = -30 -- (Default: -30) Maximum downward pitch allowed during freefall portion of re-entry.
    LockPitchTarget = 0 -- (Default: 0) Target pitch ship tries to hold when LALT-LSHIFT-5 is pressed.
    AutopilotSpaceDistance = 5000 -- (Default: 5000) Target distance AP will try to stop from a custom waypoint in space.  Good ships can lower this value a lot.
    TargetOrbitRadius = 1.2 -- (Default: 1.2) How tight you want to orbit the planet at end of autopilot.  The smaller the value the tighter the orbit.  Value is multiple of Atmospheric Height
    LowOrbitHeight = 2000 -- (Default: 2000) Height of Orbit above top of atmospehre when using Alt-4-4 same planet autopilot or alt-6-6 in space.
    AtmoSpeedLimit = 1175 -- (Default: 1175) Speed limit in Atmosphere in km/h. AtmoSpeedAssist will cause ship to throttle back when this speed is reached.
    SpaceSpeedLimit = 66000 -- (Default: 66000) Space speed limit in KM/H. If you hit this speed and are NOT in active autopilot, engines will turn off to prevent using all fuel (66000 means they wont turn off)
    AutoTakeoffAltitude = 1000 -- (Default: 1000) How high above your ground height AutoTakeoff tries to put you
    TargetHoverHeight = 50 -- (Default: 50) Hover height above ground when G used to lift off, 50 is above all max hover heights.
    LandingGearGroundHeight = 0 -- (Default: 0) Set to AGL when on ground. Will help prevent ship landing on ground then bouncing back up to landing gear height. 
    ReEntryHeight = 100000 -- (Default: 100000) Height above a planets maximum surface altitude used for re-entry, if height exceeds min space engine height, then 11% atmo is used instead. (100000 means 11% is used)
    MaxGameVelocity = -1.00 --export: (Default: -1.00) Max speed for your autopilot in m/s.  If -1 then when you sit down it will set to actual max speed.
    AutopilotInterplanetaryThrottle = 1.0 -- (Default: 1.0) How much throttle, 0.0 to 1.0, you want it to use when in autopilot to another planet while reaching MaxGameVelocity
    warmup = 32 -- How long it takes your space engines to warmup. Basic Space Engines, from XS to XL: 0.25,1,4,16,32. Only affects turn and burn brake calculations.
    fuelTankHandlingAtmo = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
    fuelTankHandlingSpace = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
    fuelTankHandlingRocket = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
    ContainerOptimization = 0 -- (Default: 0) For accurate estimates on unslotted tanks, set this to the Container Optimization level of the person who placed the tanks. Ignored for slotted tanks.
    FuelTankOptimization = 0 -- (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank optimization skill level of the person who placed the tank. Ignored for slotted tanks.
    AutoShieldPercent = 0 -- (Default: 0) Automatically adjusts shield resists once per minute if shield percent is less than this value.
    EmergencyWarp = 0 -- (Default: 0) If > 0 and a radar contact is detected in pvp space and the contact is closer than EmergencyWarp value, and all other warp conditions met, will initiate warp.

    savableVariablesHandling = {YawStallAngle={set=function (i)YawStallAngle=i end,get=function() return YawStallAngle end},PitchStallAngle={set=function (i)PitchStallAngle=i end,get=function() return PitchStallAngle end},brakeLandingRate={set=function (i)brakeLandingRate=i end,get=function() return brakeLandingRate end},MaxPitch={set=function (i)MaxPitch=i end,get=function() return MaxPitch end}, ReEntryPitch={set=function (i)ReEntryPitch=i end,get=function() return ReEntryPitch end},LockPitchTarget={set=function (i)LockPitchTarget=i end,get=function() return LockPitchTarget end}, AutopilotSpaceDistance={set=function (i)AutopilotSpaceDistance=i end,get=function() return AutopilotSpaceDistance end}, TargetOrbitRadius={set=function (i)TargetOrbitRadius=i end,get=function() return TargetOrbitRadius end}, LowOrbitHeight={set=function (i)LowOrbitHeight=i end,get=function() return LowOrbitHeight end},
    AtmoSpeedLimit={set=function (i)AtmoSpeedLimit=i end,get=function() return AtmoSpeedLimit end},SpaceSpeedLimit={set=function (i)SpaceSpeedLimit=i end,get=function() return SpaceSpeedLimit end},AutoTakeoffAltitude={set=function (i)AutoTakeoffAltitude=i end,get=function() return AutoTakeoffAltitude end},TargetHoverHeight={set=function (i)TargetHoverHeight=i end,get=function() return TargetHoverHeight end}, LandingGearGroundHeight={set=function (i)LandingGearGroundHeight=i end,get=function() return LandingGearGroundHeight end}, ReEntryHeight={set=function (i)ReEntryHeight=i end,get=function() return ReEntryHeight end},
    MaxGameVelocity={set=function (i)MaxGameVelocity=i end,get=function() return MaxGameVelocity end}, AutopilotInterplanetaryThrottle={set=function (i)AutopilotInterplanetaryThrottle=i end,get=function() return AutopilotInterplanetaryThrottle end},warmup={set=function (i)warmup=i end,get=function() return warmup end},fuelTankHandlingAtmo={set=function (i)fuelTankHandlingAtmo=i end,get=function() return fuelTankHandlingAtmo end},fuelTankHandlingSpace={set=function (i)fuelTankHandlingSpace=i end,get=function() return fuelTankHandlingSpace end},
    fuelTankHandlingRocket={set=function (i)fuelTankHandlingRocket=i end,get=function() return fuelTankHandlingRocket end},ContainerOptimization={set=function (i)ContainerOptimization=i end,get=function() return ContainerOptimization end},FuelTankOptimization={set=function (i)FuelTankOptimization=i end,get=function() return FuelTankOptimization end},AutoShieldPercent={set=function (i)AutoShieldPercent=i end,get=function() return AutoShieldPercent end},
    EmergencyWarp={set=function (i)EmergencyWarp=i end,get=function() return EmergencyWarp end}}


-- HUD Postioning variables
    -- NOTE: savableVariablesHud below must contain any HUD Postioning variables that needs to be saved/loaded from databank system

    ResolutionX = 1920 -- (Default: 1920) Does not need to be set to same as game resolution. You can set 1920 on a 2560 to get larger resolution
    ResolutionY = 1080 -- (Default: 1080) Does not need to be set to same as game resolution. You can set 1080 on a 1440 to get larger resolution
    circleRad = 400 -- (Default: 400) The size of the artifical horizon circle, recommended minimum 100, maximum 400. Looks different > 200. Set to 0 to remove.
    SafeR = 130 -- (Default: 130) Primary HUD color
    SafeG = 224 -- (Default: 224) Primary HUD color
    SafeB = 255 -- (Default: 255) Primary HUD color
    PvPR = 255 -- (Default: 255) PvP HUD color
    PvPG = 0 -- (Default: 0) PvP HUD color
    PvPB = 0 -- (Default: 0) PvP HUD color
    centerX = 960 -- (Default: 960) X postion of Artifical Horizon (KSP Navball), Default 960. Use centerX=700 and centerY=880 for lower left placement.
    centerY = 540 -- (Default: 540) Y postion of Artifical Horizon (KSP Navball), Default 540. Use centerX=700 and centerY=880 for lower left placement.
    throtPosX = 1300 -- (Default: 1300) X position of Throttle Indicator, default 1300 to put it to right of default AH centerX parameter.
    throtPosY = 540 -- (Default: 540) Y position of Throttle indicator, default is 540 to place it centered on default AH centerY parameter
    vSpdMeterX = 1525  -- (Default: 1525) X postion of Vertical Speed Meter. Default 1525
    vSpdMeterY = 325 -- (Default: 325) Y postion of Vertical Speed Meter. Default 325
    altMeterX = 550  -- (Default: 550) X postion of Altimeter. Default 550
    altMeterY = 540 -- (Default: 540) Y postion of Altimeter. Default 500
    fuelX = 30 -- (Default: 30) X position of fuel tanks, set to 100 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
    fuelY = 700 -- (Default: 700) Y position of fuel tanks, set to 300 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
    shieldX = 1750 -- (Default: 1750) X position of shield indicator
    shieldY = 250 -- (Default: 250) Y position of shield indicator
    radarX = 1750 -- (Default 1750) X position of radar info
    radarY = 350 -- (Default: 350) Y position of radar info
    DeadZone = 50 -- (Default: 50) Number of pixels of deadzone at the center of the screen
    OrbitMapSize = 250 -- (Default: 250) Size of the orbit map, make sure it is divisible by 4
    OrbitMapX = 0 -- (Default: 0) X postion of Orbit Display 
    OrbitMapY = 30 -- (Default: 30) Y position of Orbit Display
    soundVolume = 100 -- (Default: 100) Set to value (0-100 recommended) to control volume of voice and alerts. Alerts will automatically lower other hud sounds 50% if needed.

    savableVariablesHud = {ResolutionX={set=function (i)ResolutionX=i end,get=function() return ResolutionX end},ResolutionY={set=function (i)ResolutionY=i end,get=function() return ResolutionY end},circleRad={set=function (i)circleRad=i end,get=function() return circleRad end},SafeR={set=function (i)SafeR=i end,get=function() return SafeR end}, SafeG={set=function (i)SafeG=i end,get=function() return SafeG end}, SafeB={set=function (i)SafeB=i end,get=function() return SafeB end}, 
    PvPR={set=function (i)PvPR=i end,get=function() return PvPR end}, PvPG={set=function (i)PvPG=i end,get=function() return PvPG end}, PvPB={set=function (i)PvPB=i end,get=function() return PvPB end},centerX={set=function (i)centerX=i end,get=function() return centerX end}, centerY={set=function (i)centerY=i end,get=function() return centerY end}, throtPosX={set=function (i)throtPosX=i end,get=function() return throtPosX end}, throtPosY={set=function (i)throtPosY=i end,get=function() return throtPosY end},
    vSpdMeterX={set=function (i)vSpdMeterX=i end,get=function() return vSpdMeterX end}, vSpdMeterY={set=function (i)vSpdMeterY=i end,get=function() return vSpdMeterY end},altMeterX={set=function (i)altMeterX=i end,get=function() return altMeterX end}, altMeterY={set=function (i)altMeterY=i end,get=function() return altMeterY end},fuelX={set=function (i)fuelX=i end,get=function() return fuelX end}, fuelY={set=function (i)fuelY=i end,get=function() return fuelY end},
    shieldX={set=function (i)shieldX=i end,get=function() return shieldX end}, shieldY={set=function (i)shieldY=i end,get=function() return shieldY end}, radarX={set=function (i)radarX=i end,get=function() return radarX end}, radarY={set=function (i)radarY=i end,get=function() return radarY end},DeadZone={set=function (i)DeadZone=i end,get=function() return DeadZone end},
    OrbitMapSize={set=function (i)OrbitMapSize=i end,get=function() return OrbitMapSize end}, OrbitMapX={set=function (i)OrbitMapX=i end,get=function() return OrbitMapX end}, OrbitMapY={set=function (i)OrbitMapY=i end,get=function() return OrbitMapY end}, soundVolume={set=function (i)soundVolume=i end,get=function() return soundVolume end}}

-- Ship flight physics variables - Change with care, can have large effects on ships performance.
    -- NOTE: savableVariablesPhysics below must contain any Ship flight physics variables that needs to be saved/loaded from databank system

    speedChangeLarge = 5.0 -- (Default: 5) The speed change that occurs when you tap speed up/down or mousewheel, default is 5%
    speedChangeSmall = 1.0 -- (Default: 1) the speed change that occurs while you hold speed up/down, default is 1%
    MouseXSensitivity = 0.003 -- (Default: 0.003) For virtual joystick only
    MouseYSensitivity = 0.003 -- (Default: 0.003) For virtual joystick only
    autoRollFactor = 2 -- (Default: 2) [Only in atmosphere] When autoRoll is engaged, this factor will increase to strength of the roll back to 0
    rollSpeedFactor = 1.5 -- (Default: 1.5) This factor will increase/decrease the player input along the roll axis (higher value may be unstable)
    autoRollRollThreshold = 180 -- (Default: 180) The amount of roll below which autoRoll to 0 will occur (if autoRollPreference is true)
    minRollVelocity = 150 -- (Default: 150) Min velocity, in m/s, over which autorolling can occur
    TrajectoryAlignmentStrength = 0.002 -- (Default: 0.002) How strongly AP tries to align your velocity vector to the target when not in orbit, recommend 0.002
    torqueFactor = 2 -- (Default: 2) Force factor applied to reach rotationSpeed (higher value may be unstable)
    pitchSpeedFactor = 0.8 -- (Default: 0.8) For keyboard control, affects rate of pitch change
    yawSpeedFactor = 1 -- (Default: 1) For keyboard control, affects rate of yaw change
    brakeSpeedFactor = 3 -- (Default: 3) When braking, this factor will increase the brake force by brakeSpeedFactor * velocity
    brakeFlatFactor = 1 -- (Default: 1) When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction> (higher value may be unstable)
    DampingMultiplier = 40 -- (Default: 40) How strongly autopilot dampens when nearing the correct orientation
    hudTickRate = 0.0666667 -- (Default: 0.0666667) Set the tick rate for your HUD.
    ExtraEscapeThrust = 0.0 -- (Default: 0.0) Set this to some value (start low till you know your ship) to apply extra thrust between 10% and 0.05% atmosphere while using AtmoSpeedLimit.
    ExtraLongitudeTags = "none" -- (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "forward faster major" These will be added to the engines that are control by longitude.
    ExtraLateralTags = "none" -- (Default: "none") Enter any extra lateral tags you use inside '' seperated by space, i.e. "left right" These will be added to the engines that are control by lateral.
    ExtraVerticalTags = "none" -- (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "up down" These will be added to the engines that are control by vertical.
    savableVariablesPhysics = {speedChangeLarge={set=function (i)speedChangeLarge=i end,get=function() return speedChangeLarge end}, speedChangeSmall={set=function (i)speedChangeSmall=i end,get=function() return speedChangeSmall end}, MouseXSensitivity={set=function (i)MouseXSensitivity=i end,get=function() return MouseXSensitivity end}, MouseYSensitivity={set=function (i)MouseYSensitivity=i end,get=function() return MouseYSensitivity end}, autoRollFactor={set=function (i)autoRollFactor=i end,get=function() return autoRollFactor end},
    rollSpeedFactor={set=function (i)rollSpeedFactor=i end,get=function() return rollSpeedFactor end}, autoRollRollThreshold={set=function (i)autoRollRollThreshold=i end,get=function() return autoRollRollThreshold end}, minRollVelocity={set=function (i)minRollVelocity=i end,get=function() return minRollVelocity end}, TrajectoryAlignmentStrength={set=function (i)TrajectoryAlignmentStrength=i end,get=function() return TrajectoryAlignmentStrength end},
    torqueFactor={set=function (i)torqueFactor=i end,get=function() return torqueFactor end}, pitchSpeedFactor={set=function (i)pitchSpeedFactor=i end,get=function() return pitchSpeedFactor end}, yawSpeedFactor={set=function (i)yawSpeedFactor=i end,get=function() return yawSpeedFactor end}, brakeSpeedFactor={set=function (i)brakeSpeedFactor=i end,get=function() return brakeSpeedFactor end}, brakeFlatFactor={set=function (i)brakeFlatFactor=i end,get=function() return brakeFlatFactor end}, DampingMultiplier={set=function (i)DampingMultiplier=i end,get=function() return DampingMultiplier end}, 
    hudTickRate={set=function (i)hudTickRate=i end,get=function() return hudTickRate end}, ExtraEscapeThrust={set=function (i)ExtraEscapeThrust=i end,get=function() return ExtraEscapeThrust end}, 
    ExtraLongitudeTags={set=function (i)ExtraLongitudeTags=i end,get=function() return ExtraLongitudeTags end}, ExtraLateralTags={set=function (i)ExtraLateralTags=i end,get=function() return ExtraLateralTags end}, ExtraVerticalTags={set=function (i)ExtraVerticalTags=i end,get=function() return ExtraVerticalTags end}}

-- Auto Variable declarations that store status of ship on databank. Do not edit directly here unless you know what you are doing, these change as ship flies.
    -- NOTE: autoVariables below must contain any variable that needs to be saved/loaded from databank system
    BrakeToggleStatus = BrakeToggleDefault
    VertTakeOffEngine = false 
    BrakeIsOn = false
    RetrogradeIsOn = false
    ProgradeIsOn = false
    Autopilot = false
    TurnBurn = false
    AltitudeHold = false
    BrakeLanding = false
    AutoTakeoff = false
    Reentry = false
    VertTakeOff = false
    HoldAltitude = 1000 -- In case something goes wrong, give this a decent start value
    AutopilotAccelerating = false
    AutopilotRealigned = false
    AutopilotBraking = false
    AutopilotCruising = false
    AutopilotEndSpeed = 0
    AutopilotStatus = "Aligning"
    AutopilotPlanetGravity = 0
    PrevViewLock = 1
    AutopilotTargetName = "None"
    AutopilotTargetCoords = nil
    AutopilotTargetIndex = 0
    GearExtended = nil
    TotalDistanceTravelled = 0.0
    TotalFlightTime = 0
    SavedLocations = {}
    VectorToTarget = false    
    LocationIndex = 0
    LastMaxBrake = 0
    LockPitch = nil
    LastMaxBrakeInAtmo = 0
    AntigravTargetAltitude = 1000
    LastStartTime = 0
    SpaceTarget = false
    LeftAmount = 0
    IntoOrbit = false
    iphCondition = "All"
    stablized = true
    UseExtra = "Off"
    LastVersionUpdate = 0.000
    saveRoute = {}
    apRoute = {}
    autoVariables = {VertTakeOff={set=function (i)VertTakeOff=i end,get=function() return VertTakeOff end}, VertTakeOffEngine={set=function (i)VertTakeOffEngine=i end,get=function() return VertTakeOffEngine end},SpaceTarget={set=function (i)SpaceTarget=i end,get=function() return SpaceTarget end},BrakeToggleStatus={set=function (i)BrakeToggleStatus=i end,get=function() return BrakeToggleStatus end}, BrakeIsOn={set=function (i)BrakeIsOn=i end,get=function() return BrakeIsOn end}, RetrogradeIsOn={set=function (i)RetrogradeIsOn=i end,get=function() return RetrogradeIsOn end}, ProgradeIsOn={set=function (i)ProgradeIsOn=i end,get=function() return ProgradeIsOn end},
    Autopilot={set=function (i)Autopilot=i end,get=function() return Autopilot end}, TurnBurn={set=function (i)TurnBurn=i end,get=function() return TurnBurn end}, AltitudeHold={set=function (i)AltitudeHold=i end,get=function() return AltitudeHold end}, BrakeLanding={set=function (i)BrakeLanding=i end,get=function() return BrakeLanding end},
    Reentry={set=function (i)Reentry=i end,get=function() return Reentry end}, AutoTakeoff={set=function (i)AutoTakeoff=i end,get=function() return AutoTakeoff end}, HoldAltitude={set=function (i)HoldAltitude=i end,get=function() return HoldAltitude end}, AutopilotAccelerating={set=function (i)AutopilotAccelerating=i end,get=function() return AutopilotAccelerating end}, AutopilotBraking={set=function (i)AutopilotBraking=i end,get=function() return AutopilotBraking end},
    AutopilotCruising={set=function (i)AutopilotCruising=i end,get=function() return AutopilotCruising end}, AutopilotRealigned={set=function (i)AutopilotRealigned=i end,get=function() return AutopilotRealigned end}, AutopilotEndSpeed={set=function (i)AutopilotEndSpeed=i end,get=function() return AutopilotEndSpeed end}, AutopilotStatus={set=function (i)AutopilotStatus=i end,get=function() return AutopilotStatus end},
    AutopilotPlanetGravity={set=function (i)AutopilotPlanetGravity=i end,get=function() return AutopilotPlanetGravity end}, PrevViewLock={set=function (i)PrevViewLock=i end,get=function() return PrevViewLock end}, AutopilotTargetName={set=function (i)AutopilotTargetName=i end,get=function() return AutopilotTargetName end}, AutopilotTargetCoords={set=function (i)AutopilotTargetCoords=i end,get=function() return AutopilotTargetCoords end},
    AutopilotTargetIndex={set=function (i)AutopilotTargetIndex=i end,get=function() return AutopilotTargetIndex end}, TotalDistanceTravelled={set=function (i)TotalDistanceTravelled=i end,get=function() return TotalDistanceTravelled end},
    TotalFlightTime={set=function (i)TotalFlightTime=i end,get=function() return TotalFlightTime end}, SavedLocations={set=function (i)SavedLocations=i end,get=function() return SavedLocations end}, VectorToTarget={set=function (i)VectorToTarget=i end,get=function() return VectorToTarget end}, LocationIndex={set=function (i)LocationIndex=i end,get=function() return LocationIndex end}, LastMaxBrake={set=function (i)LastMaxBrake=i end,get=function() return LastMaxBrake end}, 
    LockPitch={set=function (i)LockPitch=i end,get=function() return LockPitch end}, LastMaxBrakeInAtmo={set=function (i)LastMaxBrakeInAtmo=i end,get=function() return LastMaxBrakeInAtmo end}, AntigravTargetAltitude={set=function (i)AntigravTargetAltitude=i end,get=function() return AntigravTargetAltitude end}, LastStartTime={set=function (i)LastStartTime=i end,get=function() return LastStartTime end}, iphCondition={set=function (i)iphCondition=i end,get=function() return iphCondition end}, stablized={set=function (i)stablized=i end,get=function() return stablized end}, UseExtra={set=function (i)UseExtra=i end,get=function() return UseExtra end}, SelectedTab={set=function (i)SelectedTab=i end,get=function() return SelectedTab end}, saveRoute={set=function (i)saveRoute=i end,get=function() return saveRoute end},
    apRoute={set=function (i)apRoute=i end,get=function() return apRoute end}}

    local function globalDeclare(c, u, systime, mfloor, atmosphere) -- # is how many classes variable is in
        local s = DUSystem
        local C = DUConstruct
        time = systime() -- 6
        PlayerThrottle = 0 -- 4
        brakeInput2 = 0 -- 2
        ThrottleLimited = false -- 2
        calculatedThrottle = 0 -- 2
        WasInCruise = false -- 3
        hasGear = false -- 4
        pitchInput = 0 -- 2
        rollInput = 0 -- 2
        yawInput = 0 -- 2
        upAmount = 0 -- 2
        followMode = false -- 2
        holdingShift = false -- 3
        leftmouseclick = false -- 2
        msgText = "empty" -- 6
        msgTimer = 3 -- 4
        isBoosting = false -- 3 Dodgin's Don't Die Rocket Govenor
        brakeDistance = 0 -- 2
        brakeTime = 0 -- 2
        autopilotTargetPlanet = nil -- 4
        simulatedX = 0 -- 3
        simulatedY = 0 -- 3       
        distance = 0 -- 4 but needs investigation
        spaceLand = false -- 2
        spaceLaunch = false -- 3
        finalLand = false -- 3
        abvGndDet = -1 -- 4
        inAtmo = (atmosphere() > 0) -- 5
        atmosDensity = atmosphere() -- 4
        coreAltitude = c.getAltitude() -- 3
        coreMass = DUConstruct.getMass() -- 2
        gyroIsOn = nil -- 4
        resolutionWidth = ResolutionX -- 3
        resolutionHeight = ResolutionY -- 3
        atmoTanks = {} -- 2
        spaceTanks = {} -- 2
        rocketTanks = {} -- 2
        galaxyReference = nil -- 4
        Kinematic = nil -- 4
        Kep = nil -- 3
        HUD = nil -- 5
        ATLAS = nil -- 4
        AP = nil -- 5
        RADAR = nil -- 3
        CONTROL = nil -- 2
        SHIELD = nil -- 2
        Animating = false -- 4
        Animated = false -- 2
        autoRoll = autoRollPreference -- 4
        stalling = false -- 2
        adjustedAtmoSpeedLimit = AtmoSpeedLimit -- 4
        orbitMsg = nil -- 2
        OrbitTargetOrbit = 0 -- 2
        OrbitAchieved = false -- 2
        SpaceEngineVertDn = false -- 2
        SpaceEngines = false -- 2
        constructForward = vec3(C.getWorldOrientationForward()) -- 2
        constructRight = vec3(C.getWorldOrientationRight()) -- 3
        coreVelocity = vec3(C.getVelocity()) -- 3
        constructVelocity = vec3(C.getWorldVelocity()) -- 4
        velMag = vec3(constructVelocity):len() -- 3
        worldVertical = vec3(c.getWorldVertical()) -- 3
        vSpd = -worldVertical:dot(constructVelocity) -- 2
        worldPos = vec3(C.getWorldPosition()) -- 5
        UpVertAtmoEngine = false -- 3
        antigravOn = false -- 4
        throttleMode = true -- 3
        adjustedPitch = 0 -- 2
        adjustedRoll = 0 -- 2
        AtlasOrdered = {} -- 3
        notPvPZone = false -- 3
        pvpDist = 50000 -- 2
        ReversalIsOn = nil -- 3
        nearPlanet = u.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000) -- 3
        collisionAlertStatus = false -- 2
        collisionTarget = nil -- 2
        apButtonsHovered = false -- 2
        apScrollIndex = 0 -- 2
        passengers = nil -- 2
        ships = nil -- 2
        planetAtlas = {} -- 3
        scopeFOV = 90 -- 2
        oldShowHud = showHud -- 2
        ThrottleValue = nil -- 2
        radarPanelID = nil -- 2
        privatelocations = {} -- 3
        customlocations = {} -- 2
        apBrk = false -- 2
        alignHeading = nil -- 2
        mouseDistance = 0 -- 2
        sEFC = false -- 2
        MaxSpeed = C.getMaxSpeed() -- 2
        if shield then shieldPercent = mfloor(0.5 + shield.getShieldHitpoints() * 100 / shield.getMaxShieldHitpoints()) end
    end    
    ---[[ timestamped print function for debugging
        function p(msg)
            s.print(time..": "..msg)
        end
    --]]

-- Class Definitions to organize code
    -- Planet Info - https://gitlab.com/JayleBreak/dualuniverse/-/tree/master/DUflightfiles/autoconf/custom with modifications to support HUD, vanilla JayleBreak will not work anymore
    local function PlanetRef(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq)

        --[[                    START OF LOCAL IMPLEMENTATION DETAILS             ]]--
        -- Type checks

        local function isNumber(n)
            return type(n) == 'number'
        end
        local function isSNumber(n)
            return type(tonum(n)) == 'number'
        end
        local function isTable(t)
            return type(t) == 'table'
        end
        local function isString(s)
            return type(s) == 'string'
        end
        local function isVector(v)
            return isTable(v) and isNumber(v.x and v.y and v.z)
        end
        local function isMapPosition(m)
            return isTable(m) and isNumber(m.latitude and m.longitude and m.altitude and m.id and m.systemId)
        end
        -- Constants
        local deg2rad = math.pi / 180
        local rad2deg = 180 / math.pi
        local epsilon = 1e-10
        local num = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
        local posPattern = '::pos{' .. num .. ',' .. num .. ',' .. num .. ',' .. num .. ',' .. num .. '}'
        -- Utilities
        local utils = utils
        local vec3 = vec3
        local function formatNumber(n)
            local result = string.gsub(string.reverse(stringf('%.4f', n)), '^0*%.?', '')
            return result == '' and '0' or string.reverse(result)
        end
        local function formatValue(obj)
            if isVector(obj) then
                return stringf('{x=%.3f,y=%.3f,z=%.3f}', obj.x, obj.y, obj.z)
            end
            if isTable(obj) and not getmetatable(obj) then
                local list = {}
                local nxt = next(obj)
                if type(nxt) == 'nil' or nxt == 1 then -- assume this is an array
                    list = obj
                else
                    for k, v in pairs(obj) do
                        local value = formatValue(v)
                        if type(k) == 'number' then
                            table.insert(list, stringf('[%s]=%s', k, value))
                        else
                            table.insert(list, stringf('%s=%s', k, value))
                        end
                    end
                end
                return stringf('{%s}', table.concat(list, ','))
            end
            if isString(obj) then
                return stringf("'%s'", obj:gsub("'", [[\']]))
            end
            return tostring(obj)
        end
        -- CLASSES
        -- BodyParameters: Attributes of planetary bodies (planets and moons)
        local BodyParameters = {}
        BodyParameters.__index = BodyParameters
        BodyParameters.__tostring = function(obj, indent)
            local keys = {}
            for k in pairs(obj) do
                table.insert(keys, k)
            end
            table.sort(keys)
            local list = {}
            for _, k in ipairs(keys) do
                local value = formatValue(obj[k])
                if type(k) == 'number' then
                    table.insert(list, stringf('[%s]=%s', k, value))
                else
                    table.insert(list, stringf('%s=%s', k, value))
                end
            end
            if indent then
                return stringf('%s%s', indent, table.concat(list, ',\n' .. indent))
            end
            return stringf('{%s}', table.concat(list, ','))
        end
        BodyParameters.__eq = function(lhs, rhs)
            return lhs.systemId == rhs.systemId and lhs.id == rhs.id and
                    float_eq(lhs.radius, rhs.radius) and float_eq(lhs.center.x, rhs.center.x) and
                    float_eq(lhs.center.y, rhs.center.y) and float_eq(lhs.center.z, rhs.center.z) and
                    float_eq(lhs.GM, rhs.GM)
        end
        local function mkBodyParameters(systemId, id, radius, worldCoordinates, GM)
            -- 'worldCoordinates' can be either table or vec3
            assert(isSNumber(systemId), 'Argument 1 (systemId) must be a number:' .. type(systemId))
            assert(isSNumber(id), 'Argument 2 (id) must be a number:' .. type(id))
            assert(isSNumber(radius), 'Argument 3 (radius) must be a number:' .. type(radius))
            assert(isTable(worldCoordinates),
                'Argument 4 (worldCoordinates) must be a array or vec3.' .. type(worldCoordinates))
            assert(isSNumber(GM), 'Argument 5 (GM) must be a number:' .. type(GM))
            return setmetatable({
                systemId = tonum(systemId),
                id = tonum(id),
                radius = tonum(radius),
                center = vec3(worldCoordinates),
                GM = tonum(GM)
            }, BodyParameters)
        end
        -- MapPosition: Geographical coordinates of a point on a planetary body.
        local MapPosition = {}
        MapPosition.__index = MapPosition
        MapPosition.__tostring = function(p)
            return stringf('::pos{%d,%d,%s,%s,%s}', p.systemId, p.id, formatNumber(p.latitude * rad2deg),
                    formatNumber(p.longitude * rad2deg), formatNumber(p.altitude))
        end
        MapPosition.__eq = function(lhs, rhs)
            return lhs.id == rhs.id and lhs.systemId == rhs.systemId and
                    float_eq(lhs.latitude, rhs.latitude) and float_eq(lhs.altitude, rhs.altitude) and
                    (float_eq(lhs.longitude, rhs.longitude) or float_eq(lhs.latitude, math.pi / 2) or
                        float_eq(lhs.latitude, -math.pi / 2))
        end
        -- latitude and longitude are in degrees while altitude is in meters
        local function mkMapPosition(overload, id, latitude, longitude, altitude)
            local systemId = overload -- Id or '::pos{...}' string
            
            if isString(overload) and not longitude and not altitude and not id and not latitude then
                systemId, id, latitude, longitude, altitude = stringmatch(overload, posPattern)
                assert(systemId, 'Argument 1 (position string) is malformed.')
            else
                assert(isSNumber(systemId), 'Argument 1 (systemId) must be a number:' .. type(systemId))
                assert(isSNumber(id), 'Argument 2 (id) must be a number:' .. type(id))
                assert(isSNumber(latitude), 'Argument 3 (latitude) must be in degrees:' .. type(latitude))
                assert(isSNumber(longitude), 'Argument 4 (longitude) must be in degrees:' .. type(longitude))
                assert(isSNumber(altitude), 'Argument 5 (altitude) must be in meters:' .. type(altitude))
            end
            systemId = tonum(systemId)
            id = tonum(id)
            latitude = tonum(latitude)
            longitude = tonum(longitude)
            altitude = tonum(altitude)
            if id == 0 then -- this is a hack to represent points in space
                return setmetatable({
                    latitude = latitude,
                    longitude = longitude,
                    altitude = altitude,
                    id = id,
                    systemId = systemId
                }, MapPosition)
            end
            return setmetatable({
                latitude = deg2rad * uclamp(latitude, -90, 90),
                longitude = deg2rad * (longitude % 360),
                altitude = altitude,
                id = id,
                systemId = systemId
            }, MapPosition)
        end
        -- PlanetarySystem - map body IDs to BodyParameters
        local PlanetarySystem = {}
        PlanetarySystem.__index = PlanetarySystem
        PlanetarySystem.__tostring = function(obj, indent)
            local sep = indent and (indent .. '  ')
            local bdylist = {}
            local keys = {}
            for k in pairs(obj) do
                table.insert(keys, k)
            end
            table.sort(keys)
            for _, bi in ipairs(keys) do
                bdy = obj[bi]
                local bdys = BodyParameters.__tostring(bdy, sep)
                if indent then
                    table.insert(bdylist, stringf('[%s]={\n%s\n%s}', bi, bdys, indent))
                else
                    table.insert(bdylist, stringf('  [%s]=%s', bi, bdys))
                end
            end
            if indent then
                return stringf('\n%s%s%s', indent, table.concat(bdylist, ',\n' .. indent), indent)
            end
            return stringf('{\n%s\n}', table.concat(bdylist, ',\n'))
        end

        local function mkPlanetarySystem(referenceTable)
            local atlas = {}
            local pid
            for _, v in pairs(referenceTable) do
                local id = v.planetarySystemId
                if type(id) ~= 'number' then
                    error('Invalid planetary s ID: ' .. tostring(id))
                elseif pid and id ~= pid then
                    error('Mistringmatch planetary s IDs: ' .. id .. ' and ' .. pid)
                end
                local bid = v.bodyId
                if type(bid) ~= 'number' then
                    error('Invalid body ID: ' .. tostring(bid))
                elseif atlas[bid] then
                    error('Duplicate body ID: ' .. tostring(bid))
                end
                setmetatable(v.center, getmetatable(vec3.unit_x))
                atlas[bid] = setmetatable(v, BodyParameters)
                pid = id
            end
            return setmetatable(atlas, PlanetarySystem)
        end

        -- PlanetaryReference - map planetary s ID to PlanetarySystem
        PlanetaryReference = {}
        local function mkPlanetaryReference(referenceTable)
            return setmetatable({
                galaxyAtlas = referenceTable or {}
            }, PlanetaryReference)
        end
        PlanetaryReference.__index = function(t, i)
            if type(i) == 'number' then
                local s = t.galaxyAtlas[i]
                return mkPlanetarySystem(s)
            end
            return rawget(PlanetaryReference, i)
        end
        PlanetaryReference.__pairs = function(obj)
            return function(t, k)
                local nk, nv = next(t, k)
                return nk, nv and mkPlanetarySystem(nv)
            end, obj.galaxyAtlas, nil
        end
        PlanetaryReference.__tostring = function(obj)
            local pslist = {}
            for _, ps in pairs(obj or {}) do
                local psi = ps:getPlanetarySystemId()
                local pss = PlanetarySystem.__tostring(ps, '    ')
                table.insert(pslist, stringf('  [%s]={%s\n  }', psi, pss))
            end
            return stringf('{\n%s\n}\n', table.concat(pslist, ',\n'))
        end
        PlanetaryReference.BodyParameters = mkBodyParameters
        PlanetaryReference.MapPosition = mkMapPosition
        PlanetaryReference.PlanetarySystem = mkPlanetarySystem
        function PlanetaryReference.createBodyParameters(systemId, id, surfaceArea, aPosition,
            verticalAtPosition, altitudeAtPosition, gravityAtPosition)
            assert(isSNumber(systemId),
                'Argument 1 (systemId) must be a number:' .. type(systemId))
            assert(isSNumber(id), 'Argument 2 (id) must be a number:' .. type(id))
            assert(isSNumber(surfaceArea), 'Argument 3 (surfaceArea) must be a number:' .. type(surfaceArea))
            assert(isTable(aPosition), 'Argument 4 (aPosition) must be an array or vec3:' .. type(aPosition))
            assert(isTable(verticalAtPosition),
                'Argument 5 (verticalAtPosition) must be an array or vec3:' .. type(verticalAtPosition))
            assert(isSNumber(altitudeAtPosition),
                'Argument 6 (altitude) must be in meters:' .. type(altitudeAtPosition))
            assert(isSNumber(gravityAtPosition),
                'Argument 7 (gravityAtPosition) must be number:' .. type(gravityAtPosition))
            local radius = msqrt(surfaceArea / 4 / math.pi)
            local distance = radius + altitudeAtPosition
            local center = vec3(aPosition) + distance * vec3(verticalAtPosition)
            local GM = gravityAtPosition * distance * distance
            return mkBodyParameters(systemId, id, radius, center, GM)
        end

        PlanetaryReference.isMapPosition = isMapPosition
        function PlanetaryReference:getPlanetarySystem(overload)
            -- if galaxyAtlas then
            if i == nil then i = 0 end
            if nv == nil then nv = 0 end
            local systemId = overload
            if isMapPosition(overload) then
                systemId = overload.systemId
            end
            if type(systemId) == 'number' then
                local s = self.galaxyAtlas[i]
                if s then
                    if getmetatable(nv) ~= PlanetarySystem then
                        s = mkPlanetarySystem(s)
                    end
                    return s
                end
            end
            -- end
            -- return nil
        end

        function PlanetarySystem:sizeCalculator(body)
            return 1.05*body.radius
         end
         
         function PlanetarySystem:castIntersections(origin, direction, sizeCalculator, bodyIds, collection, sorted)
            local candidates = {}
            if collection then
                -- Since we don't use bodyIds anywhere, got rid of them
                -- It was two tables doing basically the same thing

                -- Changed this to insert the body to candidates
                for _, body in pairs(collection) do
                    table.insert(candidates, body)
                end
            else
                candidates = planetAtlas -- Already-built and probably already sorted
            end
            -- Added this because, your knownContacts list is already sorted, can skip an expensive re-sort
            if not sorted then
                table.sort(candidates, function (a1, b2)
                    local a = a1.center
                    local b = b2.center
                    return (a.x-origin.x)^2+(a.y-origin.y)^2+(a.z-origin.z)^2 < (b.x-origin.x)^2+(b.y-origin.y)^2+(b.z-origin.z)^2
                end)
            end
            local dir = direction:normalize()
            -- Use the body directly from the for loop instead of getting it with i
            for _, body in ipairs(candidates) do
                local c_oV3 = body.center - origin
                -- Changed to the new method.  IDK if this is how self works but I think so
                local radius 
                if sizeCalculator then radius = sizeCalculator(body) else radius = self:sizeCalculator(body) end
                local dot = c_oV3:dot(dir)
                local desc = dot ^ 2 - (c_oV3:len2() - radius ^ 2)
                if desc >= 0 then
                    local root = msqrt(desc)
                    local farSide = dot + root
                    local nearSide = dot - root
                    if nearSide > 0 then
                        return body, farSide, nearSide
                    elseif farSide > 0 then
                        return body, farSide, nil
                    end
                end
            end
            return nil, nil, nil
        end

        function PlanetarySystem:closestBody(coordinates)
            assert(type(coordinates) == 'table', 'Invalid coordinates.')
            local minDistance2, body
            local coord = vec3(coordinates)
            for _, params in pairs(self) do
                local distance2 = (params.center - coord):len2()
                if (not body or distance2 < minDistance2) and params.name ~= "Space" then -- Never return space.  
                    body = params
                    minDistance2 = distance2
                end
            end
            return body
        end

        function PlanetarySystem:convertToBodyIdAndWorldCoordinates(overload)
            local mapPosition = overload
            if isString(overload) then
                mapPosition = mkMapPosition(overload)
            end
            if mapPosition.id == 0 then
                return 0, vec3(mapPosition.latitude, mapPosition.longitude, mapPosition.altitude)
            end
            local params = self:getBodyParameters(mapPosition)
            if params then
                return mapPosition.id, params:convertToWorldCoordinates(mapPosition)
            end
        end

        function PlanetarySystem:getBodyParameters(overload)
            local id = overload
            if isMapPosition(overload) then
                id = overload.id
            end
            assert(isSNumber(id), 'Argument 1 (id) must be a number:' .. type(id))
            return self[id]
        end

        function PlanetarySystem:getPlanetarySystemId()
            local _, v = next(self)
            return v and v.systemId
        end

        function BodyParameters:convertToMapPosition(worldCoordinates)
            assert(isTable(worldCoordinates),
                'Argument 1 (worldCoordinates) must be an array or vec3:' .. type(worldCoordinates))
            local worldVec = vec3(worldCoordinates)
            if self.id == 0 then
                return setmetatable({
                    latitude = worldVec.x,
                    longitude = worldVec.y,
                    altitude = worldVec.z,
                    id = 0,
                    systemId = self.systemId
                }, MapPosition)
            end
            local coords = worldVec - self.center
            local distance = coords:len()
            local altitude = distance - self.radius
            local latitude = 0
            local longitude = 0
            if not float_eq(distance, 0) then
                local phi = atan(coords.y, coords.x)
                longitude = phi >= 0 and phi or (2 * math.pi + phi)
                latitude = math.pi / 2 - math.acos(coords.z / distance)
            end
            return setmetatable({
                latitude = latitude,
                longitude = longitude,
                altitude = altitude,
                id = self.id,
                systemId = self.systemId
            }, MapPosition)
        end

        function BodyParameters:convertToWorldCoordinates(overload)
            local mapPosition = isString(overload) and mkMapPosition(overload) or overload
            if mapPosition.id == 0 then -- support deep space map position
                return vec3(mapPosition.latitude, mapPosition.longitude, mapPosition.altitude)
            end
            assert(isMapPosition(mapPosition), 'Argument 1 (mapPosition) is not an instance of "MapPosition".')
            assert(mapPosition.systemId == self.systemId,
                'Argument 1 (mapPosition) has a different planetary s ID.')
            assert(mapPosition.id == self.id, 'Argument 1 (mapPosition) has a different planetary body ID.')
            local xproj = math.cos(mapPosition.latitude)
            return self.center + (self.radius + mapPosition.altitude) *
                    vec3(xproj * math.cos(mapPosition.longitude), xproj * math.sin(mapPosition.longitude),
                        math.sin(mapPosition.latitude))
        end

        function BodyParameters:getAltitude(worldCoordinates)
            return (vec3(worldCoordinates) - self.center):len() - self.radius
        end

        function BodyParameters:getDistance(worldCoordinates)
            return (vec3(worldCoordinates) - self.center):len()
        end

        function BodyParameters:getGravity(worldCoordinates)
            local radial = self.center - vec3(worldCoordinates) -- directed towards body
            local len2 = radial:len2()
            return (self.GM / len2) * radial / msqrt(len2)
        end
        -- end of module
        return setmetatable(PlanetaryReference, {
            __call = function(_, ...)
                return mkPlanetaryReference(...)
            end
        })
    end

    local function Kinematics(Nav, c, u, s, msqrt, mabs) -- Part of Jaylebreak's flight files, modified slightly for hud

        local Kinematic = {} -- just a namespace
        local C = 100000000 / 3600
        local C2 = C * C
        local ITERATIONS = 100 -- iterations over engine "warm-up" period
    
        function Kinematic.computeAccelerationTime(initial, acceleration, final)
            -- The low speed limit of following is: t=(vf-vi)/a (from: vf=vi+at)
            local k1 = C * math.asin(initial / C)
            return (C * math.asin(final / C) - k1) / acceleration
        end
    
        function Kinematic.computeDistanceAndTime(initial, final, restMass, thrust, t50, brakeThrust)
    
            t50 = t50 or 0
            brakeThrust = brakeThrust or 0 -- usually zero when accelerating
            local speedUp = initial <= final
            local a0 = thrust * (speedUp and 1 or -1) / restMass
            local b0 = -brakeThrust / restMass
            local totA = a0 + b0
            if speedUp and totA <= 0 or not speedUp and totA >= 0 then
                return -1, -1 -- no solution
            end
            local distanceToMax, timeToMax = 0, 0
    
            if a0 ~= 0 and t50 > 0 then
    
                local k1 = math.asin(initial / C)
                local c1 = math.pi * (a0 / 2 + b0)
                local c2 = a0 * t50
                local c3 = C * math.pi
                local v = function(t)
                    local w = (c1 * t - c2 * math.sin(math.pi * t / 2 / t50) + c3 * k1) / c3
                    local tan = math.tan(w)
                    return C * tan / msqrt(tan * tan + 1)
                end
                local speedchk = speedUp and function(s)
                    return s >= final
                end or function(s)
                    return s <= final
                end
                timeToMax = 2 * t50
                if speedchk(v(timeToMax)) then
                    local lasttime = 0
                    while mabs(timeToMax - lasttime) > 0.5 do
                        local t = (timeToMax + lasttime) / 2
                        if speedchk(v(t)) then
                            timeToMax = t
                        else
                            lasttime = t
                        end
                    end
                end
                -- There is no closed form solution for distance in this case.
                -- Numerically integrate for time t=0 to t=2*T50 (or less)
                local lastv = initial
                local tinc = timeToMax / ITERATIONS
                for step = 1, ITERATIONS do
                    local speed = v(step * tinc)
                    distanceToMax = distanceToMax + (speed + lastv) * tinc / 2
                    lastv = speed
                end
                if timeToMax < 2 * t50 then
                    return distanceToMax, timeToMax
                end
                initial = lastv
            end
    
            local k1 = C * math.asin(initial / C)
            local time = (C * math.asin(final / C) - k1) / totA
            local k2 = C2 * math.cos(k1 / C) / totA
            local distance = k2 - C2 * math.cos((totA * time + k1) / C) / totA
            return distance + distanceToMax, time + timeToMax
        end
    
        function Kinematic.computeTravelTime(initial, acceleration, distance)
            -- The low speed limit of following is: t=(sqrt(2ad+v^2)-v)/a
            -- (from: d=vt+at^2/2)
            if distance == 0 then
                return 0
            end
            -- So then what's with all the weird ass sines and cosines?
            if acceleration > 0 then
                local k1 = C * math.asin(initial / C)
                local k2 = C2 * math.cos(k1 / C) / acceleration
                return (C * math.acos(acceleration * (k2 - distance) / C2) - k1) / acceleration
            end
            if initial == 0 then
                return -1 -- IDK something like that should make sure we never hit the assert yelling at us
            end
            assert(initial > 0, 'Acceleration and initial speed are both zero.')
            return distance / initial
        end
    
        return Kinematic
    end

    local function Keplers(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq) -- Part of Jaylebreak's flight files, modified slightly for hud
        local vec3 = vec3
        local PlanetRef = PlanetRef(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq)
        local function isString(s)
            return type(s) == 'string'
        end
        local function isTable(t)
            return type(t) == 'table'
        end
        Kepler = {}
        Kepler.__index = Kepler
    
        function Kepler:escapeAndOrbitalSpeed(altitude)
            assert(self.body)
            -- P = -GMm/r and KE = mv^2/2 (no lorentz factor used)
            -- mv^2/2 = GMm/r
            -- v^2 = 2GM/r
            -- v = sqrt(2GM/r1)
            local distance = altitude + self.body.radius
            if not float_eq(distance, 0) then
                local orbit = msqrt(self.body.GM / distance)
                return msqrt(2) * orbit, orbit
            end
            return nil, nil
        end
    
        function Kepler:orbitalParameters(overload, velocity)
            assert(self.body)
            assert(isTable(overload) or isString(overload))
            assert(isTable(velocity))
            local pos = (isString(overload) or PlanetRef.isMapPosition(overload)) and
                            self.body:convertToWorldCoordinates(overload) or vec3(overload)
            local v = vec3(velocity)
            local r = pos - self.body.center
            local v2 = v:len2()
            local d = r:len()
            local mu = self.body.GM
            local e = ((v2 - mu / d) * r - r:dot(v) * v) / mu
            local a = mu / (2 * mu / d - v2)
            local ecc = e:len()
            local dir = e:normalize()
            local pd = a * (1 - ecc)
            local ad = a * (1 + ecc)
            local per = pd * dir + self.body.center
            local apo = ecc <= 1 and -ad * dir + self.body.center or nil
            local trm = msqrt(a * mu * (1 - ecc * ecc))
            local Period = apo and 2 * math.pi * msqrt(a ^ 3 / mu)
            -- These are great and all, but, I need more.
            local trueAnomaly = math.acos((e:dot(r)) / (ecc * d))
            if r:dot(v) < 0 then
                trueAnomaly = -(trueAnomaly - 2 * math.pi)
            end
            -- Apparently... cos(EccentricAnomaly) = (cos(trueAnomaly) + eccentricity)/(1 + eccentricity * cos(trueAnomaly))
            local EccentricAnomaly = math.acos((math.cos(trueAnomaly) + ecc) / (1 + ecc * math.cos(trueAnomaly)))
            -- Then.... apparently if this is below 0, we should add 2pi to it
            -- I think also if it's below 0, we're past the apoapsis?
            local timeTau = EccentricAnomaly
            if timeTau < 0 then
                timeTau = timeTau + 2 * math.pi
            end
            -- So... time since periapsis...
            -- Is apparently easy if you get mean anomly.  t = M/n where n is mean motion, = 2*pi/Period
            local MeanAnomaly = timeTau - ecc * math.sin(timeTau)
            local TimeSincePeriapsis = 0
            local TimeToPeriapsis = 0
            local TimeToApoapsis = 0
            if Period ~= nil then
                TimeSincePeriapsis = MeanAnomaly / (2 * math.pi / Period)
                -- Mean anom is 0 at periapsis, positive before it... and positive after it.
                -- I guess this is why I needed to use timeTau and not EccentricAnomaly here
    
                TimeToPeriapsis = Period - TimeSincePeriapsis
                TimeToApoapsis = TimeToPeriapsis + Period / 2
                if trueAnomaly - math.pi > 0 then -- TBH I think something's wrong in my formulas because I needed this.
                    TimeToPeriapsis = TimeSincePeriapsis
                    TimeToApoapsis = TimeToPeriapsis + Period / 2
                end
                if TimeToApoapsis > Period then
                    TimeToApoapsis = TimeToApoapsis - Period
                end
            end
            return {
                periapsis = {
                    position = per,
                    speed = trm / pd,
                    circularOrbitSpeed = msqrt(mu / pd),
                    altitude = pd - self.body.radius
                },
                apoapsis = apo and {
                    position = apo,
                    speed = trm / ad,
                    circularOrbitSpeed = msqrt(mu / ad),
                    altitude = ad - self.body.radius
                },
                currentVelocity = v,
                currentPosition = pos,
                eccentricity = ecc,
                period = Period,
                eccentricAnomaly = EccentricAnomaly,
                meanAnomaly = MeanAnomaly,
                timeToPeriapsis = TimeToPeriapsis,
                timeToApoapsis = TimeToApoapsis,
                trueAnomaly = trueAnomaly
            }
        end
        local function new(bodyParameters)
            local params = PlanetRef.BodyParameters(bodyParameters.systemId, bodyParameters.id,
                            bodyParameters.radius, bodyParameters.center, bodyParameters.GM)
            return setmetatable({
                body = params
            }, Kepler)
        end
        return setmetatable(Kepler, {
            __call = function(_, ...)
                return new(...)
            end
        })
    end  
    -- ArchHUD AtlasOrdering
    local function AtlasClass(Nav, c, u, s, dbHud_1, atlas, sysUpData, sysAddData, mfloor, tonum, msqrt, play, round) -- Atlas and Interplanetary functions including Update Autopilot Target

        -- Atlas functions
            local function getPlanet(position)
                local p = sys:closestBody(position)
                if (position-p.center):len() > p.radius + p.noAtmosphericDensityAltitude then
                    p = atlas[0][0]
                end
                return p
            end

            local function UpdateAtlasLocationsList()
                local function atlasCmp (left, right)
                    return left.name < right.name
                end        
                AtlasOrdered = {}
                for k, v in pairs(atlas[0]) do
                    AtlasOrdered[#AtlasOrdered + 1] = { name = v.name, index = k}
                end

                table.sort(AtlasOrdered, atlasCmp)
            end
            
            local function findAtlasIndex(atlasList, findme)
                if not findme then findme = CustomTarget.name end
                for k, v in pairs(atlasList) do
                    if v.name and v.name == findme then
                        return k
                    end
                end
                return -1
            end

            local function UpdateAutopilotTarget()
                apScrollIndex = AutopilotTargetIndex
                -- So the indices are weird.  I think we need to do a pairs
                if AutopilotTargetIndex == 0 then
                    AutopilotTargetName = "None"
                    autopilotTargetPlanet = nil
                    CustomTarget = nil
                    return true
                end
                local atlasIndex = AtlasOrdered[AutopilotTargetIndex].index
                local autopilotEntry = atlas[0][atlasIndex]
                if autopilotEntry.center then -- Is a real atlas entry
                    AutopilotTargetName = autopilotEntry.name
                    autopilotTargetPlanet = galaxyReference[0][atlasIndex]
                    if CustomTarget ~= nil then
                        if atmosDensity == 0 then
                            if sysUpData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) ~= 1 then
                                sysAddData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) end
                            if sysUpData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) ~= 1 then
                                sysAddData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) end
                            if sysUpData(widgetCurBrakeTimeText, widgetCurBrakeTime) ~= 1 then
                                sysAddData(widgetCurBrakeTimeText, widgetCurBrakeTime) end
                            if sysUpData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) ~= 1 then
                                sysAddData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) end
                            if sysUpData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) ~= 1 then
                                sysAddData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) end
                        end
                        if sysUpData(widgetMaxMassText, widgetMaxMass) ~= 1 then
                            sysAddData(widgetMaxMassText, widgetMaxMass) end
                        if sysUpData(widgetTravelTimeText, widgetTravelTime) ~= 1 then
                            sysAddData(widgetTravelTimeText, widgetTravelTime) end
                        if sysUpData(widgetTargetOrbitText, widgetTargetOrbit) ~= 1 then
                            sysAddData(widgetTargetOrbitText, widgetTargetOrbit) end
                    end
                    CustomTarget = nil
                else
                    CustomTarget = autopilotEntry
                    for _, v in pairs(galaxyReference[0]) do
                        if v.name == CustomTarget.planetname then
                            autopilotTargetPlanet = v
                            AutopilotTargetName = CustomTarget.name
                            break
                        end
                    end
                    if sysUpData(widgetMaxMassText, widgetMaxMass) ~= 1 then
                        sysAddData(widgetMaxMassText, widgetMaxMass) end
                    if sysUpData(widgetTravelTimeText, widgetTravelTime) ~= 1 then
                        sysAddData(widgetTravelTimeText, widgetTravelTime) end
                end
                if CustomTarget == nil then
                    AutopilotTargetCoords = vec3(autopilotTargetPlanet.center) -- Aim center until we align
                else
                    AutopilotTargetCoords = CustomTarget.position
                end
                -- Determine the end speed
                if autopilotTargetPlanet.planetname ~= "Space" then
                    if autopilotTargetPlanet.hasAtmosphere then 
                        AutopilotTargetOrbit = mfloor(autopilotTargetPlanet.radius*(TargetOrbitRadius-1) + autopilotTargetPlanet.noAtmosphericDensityAltitude)
                    else
                        AutopilotTargetOrbit = mfloor(autopilotTargetPlanet.radius*(TargetOrbitRadius-1) + autopilotTargetPlanet.surfaceMaxAltitude)
                    end
                else
                    AutopilotTargetOrbit = AutopilotSpaceDistance
                end
                if CustomTarget ~= nil and CustomTarget.planetname == "Space" then 
                    AutopilotEndSpeed = 0
                else
                    _, AutopilotEndSpeed = Kep(autopilotTargetPlanet):escapeAndOrbitalSpeed(AutopilotTargetOrbit)
                end
                AutopilotPlanetGravity = 0 -- This is inaccurate unless we integrate and we're not doing that.  
                AutopilotAccelerating = false
                AutopilotBraking = false
                AutopilotCruising = false
                Autopilot = false
                AutopilotRealigned = false
                AutopilotStatus = "Aligning"
                return true

            end

            local function adjustAutopilotTargetIndex(up)
                if not Autopilot and not VectorToTarget and not spaceLaunch and not IntoOrbit and not Reentry and not finalLand then -- added to prevent crash when index == 0
                    if up == nil then 
                        AutopilotTargetIndex = AutopilotTargetIndex + 1
                        if AutopilotTargetIndex > #AtlasOrdered then
                            AutopilotTargetIndex = 0
                        end
                    else
                        AutopilotTargetIndex = AutopilotTargetIndex - 1
                        if AutopilotTargetIndex < 0 then
                            AutopilotTargetIndex = #AtlasOrdered
                        end  
                    end
                    if AutopilotTargetIndex == 0 then
                        UpdateAutopilotTarget()
                    else
                        local atlasIndex = AtlasOrdered[AutopilotTargetIndex].index
                        local autopilotEntry = atlas[0][atlasIndex]
                        if autopilotEntry and 
                          ((autopilotEntry ~= nil and autopilotEntry.name == "Space") or 
                           (iphCondition == "Custom Only" and autopilotEntry.center) or
                           (iphCondition == "No Moons" and string.find(autopilotEntry.name, "Moon") ~= nil))
                        then 
                            if up == nil then 
                                adjustAutopilotTargetIndex()
                            else
                                adjustAutopilotTargetIndex(1)
                            end
                        else
                            UpdateAutopilotTarget()
                        end
                    end        
                else
                    msgText = "Disengage autopilot before changing Interplanetary Helper"
                    play("iph","AP")
                end
            end

            local function ClearCurrentPosition()
                local function clearPosition(private)
                    local positions
                    if private then positions = privatelocations else positions = SavedLocations end
                    local index = -1
                    index = findAtlasIndex(atlas[0])
                    if index > -1 then
                        table.remove(atlas[0], index)
                    end
                    index = -1
                    index = findAtlasIndex(positions)
                    if index ~= -1 then
                        msgText = CustomTarget.name .. " saved location cleared"
                        table.remove(positions, index)
                    end
                    adjustAutopilotTargetIndex()
                    UpdateAtlasLocationsList()
                    return positions
                end
                if string.sub(AutopilotTargetName,1,1)=="*" then privatelocations=clearPosition(true) else SavedLocations=clearPosition(false) end
            end
            
            local function AddNewLocation(name, position, temp, safe)
                local function addPosition(private)
                    if private then positions = privatelocations else positions = SavedLocations end
                    if dbHud_1 or temp or private then
        
                        local p = getPlanet(position)
                        local newLocation = {
                            position = position,
                            name = name,
                            planetname = p.name,
                            gravity = c.getGravityIntensity(),
                            safe = safe, -- This indicates we can extreme land here, if this was a real positional waypoint
                        }
                        if not temp then 
                            positions[#positions + 1] = newLocation
                        else
                            for k, v in pairs(atlas[0]) do
                                if v.name and name == v.name then
                                    table.remove(atlas[0], k)
                                end
                            end
                        end
                        -- Nearest planet, gravity also important - if it's 0, we don't autopilot to the target planet, the target isn't near a planet.                      
                        table.insert(atlas[0], newLocation)
                        UpdateAtlasLocationsList()
                        UpdateAutopilotTarget() -- This is safe and necessary to do right?
                        -- Store atmosphere so we know whether the location is in space or not
                        msgText = "Location saved as " .. name.."("..p.name..")"
                        return positions
                    else
                        msgText = "Databank must be installed to save permanent locations"
                    end
                end
                if string.sub(name,1,1)=="*" then privatelocations=addPosition(true) else SavedLocations=addPosition(false) end
            end

        local Atlas = {}

        function Atlas.UpdateAtlasLocationsList()
            UpdateAtlasLocationsList()
        end
        
        function Atlas.UpdateAutopilotTarget()
            UpdateAutopilotTarget()
        end

        function Atlas.adjustAutopilotTargetIndex(up)
            adjustAutopilotTargetIndex(up)
        end 

        function Atlas.findAtlasIndex(atlasList, findme)
            return findAtlasIndex(atlasList, findme)
        end

        function Atlas.UpdatePosition(newName, saveHeading, saveAgg) -- Update a saved location with new position
            local function updatePosition(private)
                local positions
                if private then positions = privatelocations else positions = SavedLocations end
                local index = findAtlasIndex(positions)
                if index ~= -1 then
                    if newName ~= nil then
                        if private then newName = "*"..newName end
                        positions[index].name = newName
                        AutopilotTargetIndex = AutopilotTargetIndex - 1
                        adjustAutopilotTargetIndex()
                    elseif saveAgg ~= nil then
                        if saveAgg then
                            local alt = coreAltitude
                            if alt < 1000 then alt = 1000 end
                            positions[index].agg = round(alt,0)
                            msgText = positions[index].name .. " AGG Altitude:"..positions[index].agg.." saved ("..positions[index].planetname..")"
                            return
                        elseif saveAgg == false then 
                            positions[index].agg = nil 
                            msgText = positions[index].name .. " AGG Altitude cleared ("..positions[index].planetname..")"
                            return
                        end                        
                    else
                        local location = positions[index]
                        if saveHeading then 
                            location.heading = constructRight:cross(worldVertical)*5000 
                            msgText = positions[index].name .. " heading saved ("..positions[index].planetname..")"
                            return
                        elseif saveHeading == false then 
                            location.heading = nil 
                            msgText = positions[index].name .. " heading cleared ("..positions[index].planetname..")"
                            return
                        end
                        location.gravity = c.getGravityIntensity()
                        location.position = worldPos
                        location.safe = true
                    end
                    --UpdateAtlasLocationsList() -- Do we need these, if we only changed the name?  They are already done in AddNewLocation otherwise
                    msgText = positions[index].name .. " position updated ("..positions[index].planetname..")"
                    --UpdateAutopilotTarget()
                else
                    msgText = "Name Not Found"
                end
            end
            if string.sub(AutopilotTargetName,1,1)=="*" then updatePosition(true) else updatePosition(false) end
        end

        function Atlas.AddNewLocation(name, position, temp, safe)
            AddNewLocation(name, position, temp, safe)
        end

        function Atlas.ClearCurrentPosition()
            ClearCurrentPosition()
        end

        --Initial Setup
        for k, v in pairs(customlocations) do
            table.insert(atlas[0], v)
        end
        
        if userAtlas then 
            for k,v in pairs(userAtlas) do Atlas[k] = v end 
        end 

        UpdateAtlasLocationsList()
        if AutopilotTargetIndex > #AtlasOrdered then AutopilotTargetIndex=0 end
        Atlas.UpdateAutopilotTarget()

        return Atlas
    end
    -- ArchHUD classes  
    local function RadarClass(c, s, u, radar_1, radar_2, warpdrive,
        mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) -- Everything related to radar but draw data passed to HUD Class.
        local Radar = {}
        -- Radar Class locals
    
            local friendlies = {}
            local sizeMap = { XS = 13, S = 27, M = 55, L = 110, XL = 221}
            local cTypeString = {"Universe", "Planet", "Asteroid", "Static", "Dynamic", "Space", "Alien"}
            local knownContacts = {}
            local radarContacts = 0
            local target
            local numKnown
            local static
            local activeRadar
            local radars = {activeRadar}
            local rType = "Atmo"
            local UpdateRadarCoroutine
            local perisPanelID
            local peris = 0
            local contacts = {}
            local radarData
            local lastPlay = 0
            local vec3 = vec3
            local insert = table.insert
            local activeRadarState = -4
            local radarStatus = {
                [1] = "Operational",
                [0] = "broken",
                [-1] = "jammed",
                [-2] = "obstructed",
                [-3] = "in use"
              }
            local radarWidgetId, perisWidgetId
            local radarDataId, perisDataId
        local function toggleRadarPanel()
            if radarPanelId ~= nil and peris == 0 then
                sysDestWid(radarPanelId)
                s.destroyWidget(radarWidgetId)
                s.destroyData(radarDataId)
                radarWidgetId, radarDataId, radarPanelId = nil, nil, nil
                if perisPanelID ~= nil then
                    sysDestWid(perisPanelID)
                    s.destroyWidget(perisWidgetId)
                    s.destroyData(perisDataId)
                    perisPanelID, perisWidgetId, perisDataId = nil, nil, nil
                end
            else
                -- If radar is installed but no weapon, don't show periscope
                if peris == 1 then
                    sysDestWid(radarPanelId)
                    radarPanelId = nil
                    perisPanelID = s.createWidgetPanel("PeriWinkle")
                    perisWidgetId = s.createWidget(perisPanelID, 'periscope')
                    perisDataId = activeRadar.getWidgetDataId()
                    s.addDataToWidget(perisDataId , perisWidgetId)
                end
                if radarPanelId == nil and radarContacts > 0 then
                    radarPanelId = s.createWidgetPanel(rType)
                    radarWidgetId = s.createWidget(radarPanelId, 'radar')
                    radarDataId = activeRadar.getWidgetDataId()
                    s.addDataToWidget(radarDataId , radarWidgetId)
                end
                peris = 0
            end
        end
        local function UpdateRadarRoutine()
            -- UpdateRadarRoutine Locals
                local function trilaterate (r1, p1, r2, p2, r3, p3, r4, p4 )-- Thanks to Wolfe's DU math library and Eastern Gamer advice
                    p1,p2,p3,p4 = vec3(p1),vec3(p2),vec3(p3),vec3(p4)
                    local r1s, r2s, r3s = r1*r1, r2*r2, r3*r3
                    local v2 = p2 - p1
                    local ax = v2:normalize()
                    local U = v2:len()
                    local v3 = p3 - p1
                    local ay = (v3 - v3:project_on(ax)):normalize()
                    local v3x, v3y = v3:dot(ax), v3:dot(ay)
                    local vs = v3x*v3x + v3y*v3y
                    local az = ax:cross(ay)  
                    local x = (r1s - r2s + U*U) / (2*U) 
                    local y = (r1s - r3s + vs - 2*v3x*x)/(2*v3y)
                    local m = r1s - (x^2) - (y^2) 
                    local z = msqrt(m)
                    local t1 = p1 + ax*x + ay*y + az*z
                    local t2 = p1 + ax*x + ay*y - az*z
                
                    if mabs((p4 - t1):len() - r4) < mabs((p4 - t2):len() - r4) then
                    return t1
                    else
                    return t2
                    end
                end
                
                local function updateVariables(construct, d, wp) -- Thanks to EasternGamer and Dimencia
                    local pts = construct.pts
                    local index = #pts
                    local ref = construct.ref
                    if index > 3 then
                        local in1, in2, in3, in4 = pts[index], pts[index-1], pts[index-2], pts[index-3]
                        construct.ref = wp
                        local pos = trilaterate(in1[1], in1[2], in2[1], in2[2], in3[1], in3[2], in4[1], in4[2])
                        local x,y,z = pos.x, pos.y, pos.z
                        if x == x and y == y and z == z then
                            x = x + ref[1]
                            y = y + ref[2]
                            z = z + ref[3]
                            local newPos = vec3(x,y,z)
                            construct.center = newPos
                            if construct.lastPos then
                                if (construct.lastPos - newPos):len() < 2 then
                                    local dtt = (newPos - vec3(wp)):len()
                                    if mabs(dtt - d) < 10 then
                                        construct.skipCalc = true
                                    end
                                end
                            end
                            construct.lastPos = newPos
                        end
                        construct.pts = {}
                    else
                        local offset = {wp[1]-ref[1],wp[2]-ref[2],wp[3]-ref[3]}
                        pts[index+1] = {d,offset}
                    end
                end
    
            if radar_1 or radar_2 then RADAR.assignRadar() end
            if (activeRadar) then
                radarContacts = #activeRadar.getConstructIds()
                if radarContacts > 0 then
                    local contactData = radarData:gmatch('{"constructId[^}]*}[^}]*}') 
                    local hasMatchingTransponder = activeRadar.hasMatchingTransponder
                    local getConstructKind = activeRadar.getConstructKind
                    local isConstructAbandoned = activeRadar.isConstructAbandoned
                    local getConstructName = activeRadar.getConstructName
                    local wp = {worldPos["x"],worldPos["y"],worldPos["z"]}  --getTrueWorldPos()
                    local count, count2 = 0, 0
                    local radarDist = velMag * 10
                    local nearPlanet = nearPlanet
                    static, numKnown = 0, 0
                    friendlies = {}
                    for v in contactData do
                        local id,distance,size = v:match([[{"constructId":"([%d%.]*)","distance":([%d%.]*).-"size":"(%a+)"]])
                        local sz = sizeMap[size]
                        distance = tonum(distance)
                        if hasMatchingTransponder(id) == 1 then
                            insert(friendlies,id)
                        end
                        if not notPvPZone and warpdrive and distance < EmergencyWarp and  warpdrive.getStatus() == 15 then 
                            msgText = "INITIATING WARP"
                            msgTimer = 7
                            warpdrive.initiate()
                        end
                        if CollisionSystem then
                            local cType = getConstructKind(id)
                            local abandoned = AbandonedRadar and isConstructAbandoned(id) == 1
                            if abandoned or (distance < radarDist and (sz > 27 or cType == 4 or cType == 6)) then
                                static = static + 1
                                local name = getConstructName(id)
                                local construct = contacts[id]
                                if construct == nil then
                                    sz = sz+coreHalfDiag
                                    contacts[id] = {pts = {}, ref = wp, name = name, i = 0, radius = sz, skipCalc = false}
                                    construct = contacts[id]
                                end
                                if not construct.skipCalc then 
                                    updateVariables(construct, distance, wp)
                                    if abandoned and not construct.abandoned and construct.center then
                                        local time = s.getArkTime()
                                        if lastPlay+5 < time then 
                                            lastPlay = time
                                            play("abRdr", "RD")
                                        end
                                        s.print("Abandoned Construct: "..name.." ("..size.." ".. cTypeString[cType]..") at estimated ::pos{0,0,"..construct.center.x..","..construct.center.y..","..construct.center.z.."}")
                                        msgText = "Abandoned Radar Contact ("..size.." ".. cTypeString[cType]..") detected"
                                        construct.abandoned = true
                                    end
                                    count2 = count2 + 1
                                else
                                    insert(knownContacts, construct) 
                                end
                            end
                            count = count + 1
                            if (nearPlanet and count > 700 or count2 > 70) or (not nearPlanet and count > 300 or count2 > 30) then
                                coroutine.yield()
                                count, count2 = 0, 0
                            end
                        end
                    end
                    numKnown = #knownContacts
                    if numKnown > 0 and (velMag > 20 or BrakeLanding) then 
                        local body, far, near, vect
                        local innerCount = 0
                        local galxRef = galaxyReference:getPlanetarySystem(0)
                        vect = constructVelocity:normalize()
                        while innerCount < numKnown do
                            coroutine.yield()
                            local innerList = { table.unpack(knownContacts, innerCount, math.min(innerCount + 75, numKnown)) }
                            body, far, near = galxRef:castIntersections(worldPos, vect, nil, nil, innerList, true)
                            if body and near then 
                                collisionTarget = {body, far, near} 
                                break 
                            end
                            innerCount = innerCount + 75
                        end
                        if not body then collisionTarget = nil end
                    else
                        collisionTarget = nil
                    end
                    knownContacts = {}
                    target = radarData:find('identifiedConstructs":%[%]')
                end
            end
        end
        local function pickType()
            if activeRadar then
                rType = "Atmo"
                if radarData:find('worksInAtmosphere":false') then 
                    rType = "Space" 
                end
            end
        end
        function Radar.pickType()
            pickType()
        end
    
        function Radar.assignRadar()
            if radar_2 and activeRadarState ~= 1 then
                if activeRadarState == -1 then
                    if activeRadar == radar_2 then 
                        activeRadar = radar_1
                    else  
                        activeRadar = radar_2 
                    end
                end
                radars = {activeRadar}
                radarData = activeRadar.getWidgetData()
                pickType()
            else
                radarData = activeRadar.getWidgetData()
            end
            activeRadarState = activeRadar.getOperationalState()
        end
    
        function Radar.UpdateRadar()
            local cont = coroutine.status (UpdateRadarCoroutine)
            if cont == "suspended" then 
                local value, done = coroutine.resume(UpdateRadarCoroutine)
                if done then s.print("ERROR UPDATE RADAR: "..done) end
            elseif cont == "dead" then
                UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
                local value, done = coroutine.resume(UpdateRadarCoroutine)
            end
        end
    
        function Radar.GetRadarHud(friendx, friendy, radarX, radarY)
            local radarMessage, msg
            local num = numKnown or 0 
            if radarContacts > 0 then 
                if CollisionSystem then 
                    msg = num.."/"..static.." Plotted : "..(radarContacts-static).." Ignored" 
                else
                    msg = "Radar Contacts: "..radarContacts
                end
                radarMessage = svgText(radarX, radarY, msg, "pbright txtbig txtmid")
                if #friendlies > 0 then
                    radarMessage = radarMessage..svgText( friendx, friendy, "Friendlies In Range", "pbright txtbig txtmid")
                    for k, v in pairs(friendlies) do
                        friendy = friendy + 20
                        radarMessage = radarMessage..svgText(friendx, friendy, activeRadar.getConstructName(v), "pdim txtmid")
                    end
                end
    
                if target == nil and perisPanelID == nil then
                    peris = 1
                    RADAR.ToggleRadarPanel()
                end
                if target ~= nil and perisPanelID ~= nil then
                    RADAR.ToggleRadarPanel()
                end
                if radarPanelId == nil then
                    RADAR.ToggleRadarPanel()
                end
            else
                if activeRadarState ~= 1 then
                        radarMessage = svgText(radarX, radarY, rType.." Radar: "..radarStatus[activeRadarState] , "pbright txtbig txtmid")
                else
                    radarMessage = svgText(radarX, radarY, "Radar: No "..rType.." Contacts", "pbright txtbig txtmid")
                end
                if radarPanelId ~= nil then
                    peris = 0
                    RADAR.ToggleRadarPanel()
                end
            end
            return radarMessage
        end
    
        function Radar.GetClosestName(name)
            if activeRadar then -- Just match the first one
                local id,_ = activeRadar.getWidgetData():match('"constructId":"([0-9]*)","distance":([%d%.]*)')
                if id ~= nil and id ~= "" then
                    name = name .. " " .. activeRadar.getConstructName(id)
                end
            end
            return name
        end
        function Radar.ToggleRadarPanel()
            toggleRadarPanel()
        end
    
        function Radar.ContactTick()
            if not contactTimer then contactTimer = 0 end
            if time > contactTimer+10 then
                msgText = "Radar Contact" 
                play("rdrCon","RC")
                contactTimer = time
            end
            u.stopTimer("contact")
        end
    
        function Radar.onEnter(id)
            if activeRadar and not inAtmo and not notPvPZone then 
                u.setTimer("contact",0.1) 
            end
        end
    
        function Radar.onLeave(id)
            if activeRadar and CollisionSystem then 
                if #contacts > 650 then 
                    id = tostring(id)
                    contacts[id] = nil 
                end
            end
        end
    
        local function setup()
            activeRadar=nil
            if radar_2 and radar_2.getOperationalState()==1 then
                activeRadar = radar_2
            else
                activeRadar = radar_1
            end
            activeRadarState=activeRadar.getOperationalState()
            radars = {activeRadar}
            radarData = activeRadar.getWidgetData()
            pickType()
            UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
    
            if userRadar then 
                for k,v in pairs(userRadar) do Radar[k] = v end 
            end   
        end
        setup()
    
        return Radar
    end 
    local function ShieldClass(shield, stringmatch, mfloor) -- Everything related to radar but draw data passed to HUD Class.
        local Shield = {}
        local RCD = shield.getResistancesCooldown()
    
        local function checkShield()
            local shieldState = shield.isActive()
            if AutoShieldToggle then
                if not notPvPZone and shieldState == 0 and shield.isVenting() ~= 1 then
                    shield.toggle()
                elseif notPvPZone and shieldState == 1 then
                    shield.toggle()
                end
            end
        end
    
        local function updateResists()
            local sRR = shield.getStressRatioRaw()
            local tot = 0.5999
            if sRR[1] == 0.0 and sRR[2] == 0.0 and sRR[3] == 0.0 and sRR[4] == 0.0 then return end
            local setResist = shield.setResistances((tot*sRR[1]),(tot*sRR[2]),(tot*sRR[3]),(tot*sRR[4]))
            if setResist == 1 then msgText="Shield Resistances updated" else msgText = "Value Exceeded. Failed to update Shield Resistances" end
        end
    
        function Shield.shieldTick()
            shieldPercent = mfloor(0.5 + shield.getShieldHitpoints() * 100 / shield.getMaxShieldHitpoints())
            checkShield()
            RCD = shield.getResistancesCooldown()
            if RCD == 0 and shieldPercent < AutoShieldPercent then updateResists() end
        end
    
        function Shield.setResist(arguement)
            if not shield then
                msgText = "No shield found"
                return
            elseif arguement == nil or RCD>0 then
                msgText = "Usable once per min.  Usage: /resist 0.15, 0.15, 0.15, 0.15"
                return
            end
            local num  = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
            local posPattern = num .. ', ' .. num .. ', ' ..  num .. ', ' .. num    
            local antimatter, electromagnetic, kinetic, thermic = stringmatch(arguement, posPattern)
            if thermic == nil or (antimatter + electromagnetic+ kinetic + thermic) > 0.6 then msgText="Improperly formatted or total exceeds 0.6" return end
            if shield.setResistances(antimatter,electromagnetic,kinetic,thermic)==1 then msgText="Shield Resistances set" else msgText="Resistance setting failed." end
        end
    
        function Shield.ventShield()
            local vcd = shield.getVentingCooldown()
            if vcd > 0 then msgText="Cannot vent again for "..vcd.." seconds" return end
            if shield.getShieldHitpoints()<shield.getMaxShieldHitpoints() then shield.startVenting() msgText="Shields Venting Enabled - NO SHIELDS WHILE VENTING" else msgText="Shields already at max hitpoints" end
        end
    
        if userShield then 
            for k,v in pairs(userShield) do Shield[k] = v end 
        end  
    
        return Shield
    end
    local function HudClass(Nav, c, u, s, atlas, antigrav, hover, shield, warpdrive, weapon,
        mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, 
        navCom, sysAddData, sysUpData, sysDestWid, sysIsVwLock, msqrt, round, svgText, play, addTable, saveableVariables,
        getDistanceDisplayString, FormatTimeString, elementsID, eleTotalMaxHp)
    
        local C = DUConstruct
        local gravConstant = 9.80665
        local Buttons = {}
        local ControlButtons = {}
        local SettingButtons = {}
        local TabButtons = {}
        local MapXRatio = nil
        local MapYRatio = nil
        local YouAreHere = nil
        local showSettings = false
        local settingsVariables = "none"
        local pipeMessage = ""
        local minAutopilotSpeed = 55 -- Minimum speed for autopilot to maneuver in m/s.  Keep above 25m/s to prevent nosedives when boosters kick in. Also used in apclass
        local maxBrakeDistance = 0
        local maxBrakeTime = 0
        local WeaponPanelID = nil
        local PrimaryR = SafeR
        local PrimaryG = SafeG
        local PrimaryB = SafeB
        local rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
        local rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]
        local totalDistanceTrip = 0
        local flightTime = 0
        local lastOdometerOutput = ""
        local lastTravelTime = systime()
        local repairArrows = false
        local showWarpWidget = false
    
        --Local Huds Functions
    
            local function ConvertResolutionX (v)
                if resolutionWidth == 1920 then 
                    return v
                else
                    return round(resolutionWidth * v / 1920, 0)
                end
            end
        
            local function ConvertResolutionY (v)
                if resolutionHeight == 1080 then 
                    return v
                else
                    return round(resolutionHeight * v / 1080, 0)
                end
            end
    
            local function IsInFreeLook()
                return sysIsVwLock() == 0 and userControlScheme ~= "keyboard" and isRemote() == 0
            end
    
            local function GetFlightStyle()
                local flightStyle = "TRAVEL"
                if not throttleMode then
                    flightStyle = "CRUISE"
                end
                if Autopilot then
                    flightStyle = "AUTOPILOT"
                end
                return flightStyle
            end
    
            local radarMessage = ""
            local tankMessage = ""
            local shieldMessage = ""
            -- DrawTank variables
                local tankID = 1
                local tankName = 2
                local tankMaxVol = 3
                local tankMassEmpty = 4
                local tankLastMass = 5
                local tankLastTime = 6
                local tankSlotIndex = 7
                local slottedTankType = ""
                local slottedTanks = 0        
                local fuelUpdateDelay = 120.0*hudTickRate
                local fuelTimeLeftR = {}
                local fuelPercentR = {}
                local fuelTimeLeftS = {}
                local fuelPercentS = {}
                local fuelTimeLeft = {}
                local fuelPercent = {}
                local fuelUsed = {}
                fuelUsed["atmofueltank"],fuelUsed["spacefueltank"],fuelUsed["rocketfueltank"] = 0,0,0
    
                local tankY = 0
            
            local function DrawTank(x, nameSearchPrefix, nameReplacePrefix, tankTable, fuelTimeLeftTable,
                fuelPercentTable)
                
                local y1 = tankY
                local y2 = tankY+5
                if not BarFuelDisplay then y2=y2+5 end
                if isRemote() == 1 and not RemoteHud then
                    y1 = y1 - 50
                    y2 = y2 - 50
                end
            
                if nameReplacePrefix == "ATMO" then
                    slottedTankType = "atmofueltank"
                elseif nameReplacePrefix == "SPACE" then
                    slottedTankType = "spacefueltank"
                else
                    slottedTankType = "rocketfueltank"
                end
                slottedTanks = _G[slottedTankType .. "_size"]
                if (#tankTable > 0) then
                    for i = 1, #tankTable do
                        local name = tankTable[i][tankName]
                        local slottedIndex = tankTable[i][tankSlotIndex]
                        for j = 1, slottedTanks do
                            if tankTable[i][tankName] == jdecode(u[slottedTankType .. "_" .. j].getWidgetData()).name then
                                slottedIndex = j
                                break
                            end
                        end
    
                        local curTime = systime()
    
                        if fuelTimeLeftTable[i] == nil or fuelPercentTable[i] == nil or (curTime - tankTable[i][tankLastTime]) > fuelUpdateDelay then
                            
                            local fuelMassLast
                            local fuelMass = 0
    
                            fuelMass = (eleMass(tankTable[i][tankID]) - tankTable[i][tankMassEmpty])
                            fuelMassLast = tankTable[i][tankLastMass]
                            if fuelMassLast > fuelMass then 
                                fuelUsed[slottedTankType] = fuelUsed[slottedTankType]+(fuelMassLast - fuelMass) 
                            end
    
                            if slottedIndex ~= 0 then
                                local slotData = jdecode(u[slottedTankType .. "_" .. slottedIndex].getWidgetData())
                                fuelPercentTable[i] = slotData.percentage
                                fuelTimeLeftTable[i] = slotData.timeLeft
                                if fuelTimeLeftTable[i] == "n/a" then
                                    fuelTimeLeftTable[i] = 0
                                end
                            else
                                fuelPercentTable[i] = mfloor(0.5 + fuelMass * 100 / tankTable[i][tankMaxVol])
                                if fuelMassLast <= fuelMass then
                                    fuelTimeLeftTable[i] = 0
                                else
                                    fuelTimeLeftTable[i] = mfloor(
                                                            0.5 + fuelMass /
                                                                ((fuelMassLast - fuelMass) / (curTime - tankTable[i][tankLastTime])))
                                end
                            end
                            tankTable[i][tankLastTime] = curTime
                            tankTable[i][tankLastMass] = fuelMass
                        end
                        if name == nameSearchPrefix then
                            name = stringf("%s %d", nameReplacePrefix, i)
                        end
                        if slottedIndex == 0 then
                            name = name .. " *"
                        end
                        local fuelTimeDisplay
                        if fuelTimeLeftTable[i] == 0 then
                            fuelTimeDisplay = ""
                        else
                            fuelTimeDisplay = FormatTimeString(fuelTimeLeftTable[i])
                        end
                        if fuelPercentTable[i] ~= nil then
                            local colorMod = mfloor(fuelPercentTable[i] * 2.55)
                            local color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                            local class = ""
                            if ((fuelTimeDisplay ~= "" and fuelTimeLeftTable[i] < 120) or fuelPercentTable[i] < 5) then
                                class = "red "
                            end
                            local backColor = stringf("rgb(%d,%d,%d)", uclamp(mfloor((255-colorMod)/2.55),50,100), uclamp(mfloor(colorMod/2.55),0,50), 50)
                            local strokeColor = "rgb(196,0,255)"
                            if nameReplacePrefix == "ATMO" then
                                strokeColor = "rgb(0,188,255)"
                            elseif nameReplacePrefix == "SPACE" then
                                strokeColor = "rgb(239,255,0)"
                            end
                            local changed = false
                            if previous ~= strokeColor then
                                changed = true
                            end
                            previous = strokeColor
                            if BarFuelDisplay then
                                if changed then
                                    y1 = y1 - 5
                                    y2 = y2 - 5
                                end
                                tankMessage = tankMessage..stringf([[
                                    <g class="pdim">                        
                                    <rect fill=%s class="bar" stroke=%s x="%d" y="%d" width="170" height="20"></rect></g>
                                    <g class="bar txtstart">
                                    <rect fill=%s width="%d" height="18" x="%d" y="%d"></rect>
                                    <text class="txtstart" fill="white" x="%d" y="%d" style="font-family:Play;font-size:14px">%s %s%%&nbsp;&nbsp;&nbsp;&nbsp;%s</text>
                                    </g>]], backColor, strokeColor, x, y2, color, mfloor(fuelPercentTable[i]*1.7+0.5)-2, x+1, y2+1, x+5, y2+14, name, fuelPercentTable[i], fuelTimeDisplay
                                )
                                --tankMessage = tankMessage..svgText(x, y1, name, class.."txtstart pdim txtfuel") 
                                y1 = y1 - 22
                                y2 = y2 - 22
                            else
                                tankMessage = tankMessage..svgText(x, y1, name, class.."pdim txtfuel") 
                                tankMessage = tankMessage..svgText( x, y2, stringf("%d%% %s", fuelPercentTable[i], fuelTimeDisplay), "pdim txtfuel","fill:"..color)
                                y1 = y1 + 30
                                y2 = y2 + 30
                            end
                        end
                    end
                end
    
                tankY = y1
            end
    
            local function DrawVerticalSpeed(newContent, altitude) -- Draw vertical speed indicator - Code by lisa-lionheart
                if vSpdMeterX == 0 and vSpdMeterY == 0 then return end
                if (altitude < 200000 and not inAtmo) or (altitude and inAtmo) then
    
                    local angle = 0
                    if mabs(vSpd) > 1 then
                        angle = 45 * math.log(mabs(vSpd), 10)
                        if vSpd < 0 then
                            angle = -angle
                        end
                    end
                    newContent[#newContent + 1] = stringf([[
                        <g class="pbright txt txtvspd" transform="translate(%d %d) scale(0.6)">
                                <text x="55" y="-41">1000</text>
                                <text x="10" y="-65">100</text>
                                <text x="-45" y="-45">10</text>
                                <text x="-73" y="3">O</text>
                                <text x="-45" y="52">-10</text>
                                <text x="10" y="72">-100</text>
                                <text x="55" y="50">-1000</text>
                                <text x="85" y="0" class="txtvspdval txtend">%d m/s</text>
                            <g class="linethick">
                                <path d="m-41 75 2.5-4.4m17 12 1.2-4.9m20 7.5v-10m-75-34 4.4-2.5m-12-17 4.9-1.2m17 40 7-7m-32-53h10m34-75 2.5 4.4m17-12 1.2 4.9m20-7.5v10m-75 34 4.4 2.5m-12 17 4.9 1.2m17-40 7 7m-32 53h10m116 75-2.5-4.4m-17 12-1.2-4.9m40-17-7-7m-12-128-2.5 4.4m-17-12-1.2 4.9m40 17-7 7"/>
                                <circle r="90" />
                            </g>
                            <path transform="rotate(%d)" d="m-0.094-7c-22 2.2-45 4.8-67 7 23 1.7 45 5.6 67 7 4.4-0.068 7.8-4.9 6.3-9.1-0.86-2.9-3.7-5-6.8-4.9z" />
                        </g>
                    ]], vSpdMeterX, vSpdMeterY, mfloor(vSpd), mfloor(angle))
                end
                return newContent
            end
    
            local function getHeading(forward) -- code provided by tomisunlucky   
                local up = -worldVertical
                forward = forward - forward:project_on(up)
                local north = vec3(0, 0, 1)
                north = north - north:project_on(up)
                local east = north:cross(up)
                local angle = north:angle_between(forward) * constants.rad2deg
                if forward:dot(east) < 0 then
                    angle = 360-angle
                end
                return angle
            end
    
            local function DrawRollLines (newContent, centerX, centerY, originalRoll, bottomText, nearPlanet)
                if circleRad == 0 then return end
                local horizonRadius = circleRad -- Aliased global
                local OFFSET = 20
                local rollC = mfloor(originalRoll)
                if nearPlanet then 
                    for i = -45, 45, 5 do
                        local rot = i
                        newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,%d,%d)">]], rot, centerX, centerY)
                        len = 5
                        if (i % 15 == 0) then
                            len = 15
                        elseif (i % 10 == 0) then
                            len = 10
                        end
                        newContent[#newContent + 1] = stringf([[<line x1=%d y1=%d x2=%d y2="%d"/></g>]], centerX, centerY + horizonRadius + OFFSET - len, centerX, centerY + horizonRadius + OFFSET)
                    end 
                    newContent[#newContent + 1] = svgText(centerX, centerY+horizonRadius+OFFSET-35, bottomText, "pdim txt txtmid")
                    newContent[#newContent + 1] = svgText(centerX, centerY+horizonRadius+OFFSET-25, rollC.." deg", "pdim txt txtmid")
                    newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,%d,%d)">]], -originalRoll, centerX, centerY)
                    newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/>]],
                        centerX-5, centerY+horizonRadius+OFFSET-20, centerX+5, centerY+horizonRadius+OFFSET-20, centerX, centerY+horizonRadius+OFFSET-15)
                    newContent[#newContent +1] = "</g>"
                end
                newContent[#newContent + 1] = [[<g style="clip-path: url(#headingClip);">]]
                local yaw = rollC
                if nearPlanet then yaw = getHeading(constructForward) end
                local range = 20
                local yawC = mfloor(yaw) 
                local yawlen = 0
                local yawy = (centerY + horizonRadius + OFFSET + 20)
                local yawx = centerX
                if bottomText ~= "YAW" then 
                    yawy = ConvertResolutionY(130)
                    yawx = ConvertResolutionX(960)
                end
                local tickerPath = [[<path class="txttick line" d="]]
                local degRange = mfloor(yawC - (range+10) - yawC % 5 + 0.5)
                for i = degRange+70, degRange, -5 do
                    local x = yawx - (-i * 5 + yaw * 5)
                    if (i % 10 == 0) then
                        yawlen = 10
                        local num = i
                        if num == 360 then 
                            num = 0
                        elseif num  > 360 then  
                            num = num - 360 
                        elseif num < 0 then
                            num = num + 360
                        end
                        newContent[#newContent + 1] = svgText(x,yawy+15, num, "txtmid bright" )
                    elseif (i % 5 == 0) then
                        yawlen = 5
                    end
                    if yawlen == 10 then
                        tickerPath = stringf([[%s M %f %f v %d]], tickerPath, x, yawy-5, yawlen)
                    else
                        tickerPath = stringf([[%s M %f %f v %d]], tickerPath, x, yawy-2.5, yawlen)
                    end
                end
                newContent[#newContent + 1] = tickerPath .. [["/>]]
                newContent[#newContent + 1] = stringf([[<<polygon class="bright" points="%d,%d %d,%d %d,%d"/>]],
                    yawx-5, yawy-20, yawx+5, yawy-20, yawx, yawy-10)
                if DisplayOdometer then 
                    if nearPlanet then bottomText = "HDG" end
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(960) , ConvertResolutionY(100), yawC.."°" , "dim txt txtmid size14", "")
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(85), bottomText, "dim txt txtmid size20","")
                end
                newContent[#newContent + 1] = [[</g>]]
            end
    
            local function DrawArtificialHorizon(newContent, originalPitch, originalRoll, centerX, centerY, nearPlanet, atmoYaw, speed)
                -- ** CIRCLE ALTIMETER  - Base Code from Discord @Rainsome = Youtube CaptainKilmar** 
                if circleRad == 0 then return end
                local horizonRadius = circleRad -- Aliased global
                local pitchX = mfloor(horizonRadius * 3 / 5)
                if horizonRadius > 0 then
                    local pitchC = mfloor(originalPitch)
                    local len = 0
                    local tickerPath = stringf([[<path transform="rotate(%f,%d,%d)" class="dim line" d="]], (-1 * originalRoll), centerX, centerY)
                    if not inAtmo then
                        tickerPath = stringf([[<path transform="rotate(0,%d,%d)" class="dim line" d="]], centerX, centerY)
                    end
                    newContent[#newContent + 1] = stringf([[<clipPath id="cut"><circle r="%f" cx="%d" cy="%d"/></clipPath>]],(horizonRadius - 1), centerX, centerY)
                    newContent[#newContent + 1] = [[<g class="dim txttick" clip-path="url(#cut)">]]
                    for i = mfloor(pitchC - 30 - pitchC % 5 + 0.5), mfloor(pitchC + 30 + pitchC % 5 + 0.5), 5 do
                        if (i % 10 == 0) then
                            len = 30
                        elseif (i % 5 == 0) then
                            len = 20
                        end
                        local y = centerY + (-i * 5 + originalPitch * 5)
                        if len == 30 then
                            tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX-pitchX-len, y, len)
                            if inAtmo then
                                newContent[#newContent + 1] = stringf([[<g path transform="rotate(%f,%d,%d)" class="pdim txt txtmid"><text x="%d" y="%f">%d</text></g>]],(-1 * originalRoll), centerX, centerY, centerX-pitchX+10, y+4, i)
                                newContent[#newContent + 1] = stringf([[<g path transform="rotate(%f,%d,%d)" class="pdim txt txtmid"><text x="%d" y="%f">%d</text></g>]],(-1 * originalRoll), centerX, centerY, centerX+pitchX-10, y+4, i)
                                if i == 0 or i == 180 or i == -180 then 
                                    newContent[#newContent + 1] = stringf([[<path transform="rotate(%f,%d,%d)" d="m %d,%f %d,0" stroke-width="1" style="fill:none;stroke:#F5B800;" />]],
                                        (-1 * originalRoll), centerX, centerY, centerX-pitchX+20, y, pitchX*2-40)
                                end
                            else
                                newContent[#newContent + 1] = svgText(centerX-pitchX+10, y, i, "pdim txt txtmid")
                                newContent[#newContent + 1] = svgText(centerX+pitchX-10, y, i , "pdim txt txtmid")
                            end                            
                            tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX+pitchX, y, len)
                        else
                            tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX-pitchX-len, y, len)
                            tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX+pitchX, y, len)
                        end
                    end
                    newContent[#newContent + 1] = tickerPath .. [["/>]]
                    local pitchstring = "PITCH"                
                    if not nearPlanet then 
                        pitchstring = "REL PITCH"
                    end
                    if originalPitch > 90 and not inAtmo then
                        originalPitch = 90 - (originalPitch - 90)
                    elseif originalPitch < -90 and not inAtmo then
                        originalPitch = -90 - (originalPitch + 90)
                    end
                    if horizonRadius > 200 then
                        if inAtmo then
                            if speed > minAutopilotSpeed then
                                newContent[#newContent + 1] = svgText(centerX, centerY-15, "Yaw", "pdim txt txtmid")
                                newContent[#newContent + 1] = svgText(centerX, centerY+20, atmoYaw, "pdim txt txtmid")
                            end
                            newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,%d,%d)">]], -originalRoll, centerX, centerY)
                        else
                            newContent[#newContent + 1] = stringf([[<g transform="rotate(0,%d,%d)">]], centerX, centerY)
                        end
                        newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/> class="pdim txtend"><text x="%d" y="%f">%d</text>]],
                        centerX-pitchX+25, centerY-5, centerX-pitchX+20, centerY, centerX-pitchX+25, centerY+5, centerX-pitchX+50, centerY+4, pitchC)
                        newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/> class="pdim txtend"><text x="%d" y="%f">%d</text>]],
                        centerX+pitchX-25, centerY-5, centerX+pitchX-20, centerY, centerX+pitchX-25, centerY+5, centerX+pitchX-30, centerY+4, pitchC)
                        newContent[#newContent +1] = "</g>"
                    end
                    local thirdHorizontal = mfloor(horizonRadius/3)
                    newContent[#newContent + 1] = stringf([[<path d="m %d,%d %d,0" stroke-width="2" style="fill:none;stroke:#F5B800;" />]],
                        centerX-thirdHorizontal, centerY, horizonRadius-thirdHorizontal)
                    if not inAtmo and nearPlanet then 
                        newContent[#newContent + 1] = stringf([[<path transform="rotate(%f,%d,%d)" d="m %d,%f %d,0" stroke-width="1" style="fill:none;stroke:#F5B800;" />]],
                            (-1 * originalRoll), centerX, centerY, centerX-pitchX+10, centerY, pitchX*2-20)
                    end
                    newContent[#newContent + 1] = "</g>"
                    if horizonRadius < 200 then
                        if inAtmo and speed > minAutopilotSpeed then 
                            newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius, pitchstring, "pdim txt txtmid")
                            newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius+10, pitchC, "pdim txt txtmid")
                            newContent[#newContent + 1] = svgText(centerX, centerY-15, "Yaw", "pdim txt txtmid")
                            newContent[#newContent + 1] = svgText(centerX, centerY+20, atmoYaw, "pdim txt txtmid")
                        else
                            newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius, pitchstring, "pdim txt txtmid")
                            newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius+15, pitchC, "pdim txt txtmid")
                        end
                    end
                end
            end
    
            local function DrawAltitudeDisplay(newContent, altitude, nearPlanet)
                local rectX = altMeterX
                local rectY = altMeterY
                if rectX == 0 and rectY == 0 then return end
                local rectW = 78
                local rectH = 19
            
                local gndHeight = abvGndDet
    
                if abvGndDet ~= -1 then
                    newContent[#newContent + 1] = svgText(rectX+rectW, rectY+rectH+20, stringf("AGL: %.1fm", abvGndDet), "pdim altsm txtend")
                end
    
                if nearPlanet and ((altitude < 200000 and not inAtmo) or (altitude and inAtmo)) then
                    table.insert(newContent, stringf([[
                        <g class="pdim">                        
                            <rect class="line" x="%d" y="%d" width="%d" height="%d"/> 
                            <clipPath id="alt"><rect class="line" x="%d" y="%d" width="%d" height="%d"/></clipPath>
                            <g clip-path="url(#alt)">]], 
                            rectX - 1, rectY - 4, rectW + 2, rectH + 6,
                            rectX + 1, rectY - 1, rectW - 4, rectH))
                    local index = 0
                    local divisor = 1
                    local forwardFract = 0
                    local isNegative = altitude < 0
    
                    local isLand = altitude < planet.surfaceMaxAltitude
    
                    local rolloverDigit = 9
                    if isNegative then
                        rolloverDigit = 0
                    end
    
                    local altitude = mabs(altitude)
                    while index < 6 do
                        local glyphW = 11
                        local glyphH = 16
                        local glyphXOffset = 9
                        local glyphYOffset = 14
                        local class = "altsm"
            
                        if index > 2 then
                            glyphH = glyphH + 3
                            glyphW = glyphW + 2
                            glyphYOffset = glyphYOffset + 2
                            glyphXOffset = glyphXOffset - 6
                            class = "altbig"
                        end
            
                        if isNegative then  
                            class = class .. " red"
                        elseif isLand then
                            class = class .. " orange"
                        end
            
                        local digit = (altitude / divisor) % 10
                        local intDigit = mfloor(digit)
                        local fracDigit = mfloor((intDigit + 1) % 10)
            
                        local fract = forwardFract
                        if index == 0 then
                            fract = digit - intDigit
                            if isNegative then
                                fract = 1 - fract
                            end
                        end
    
                        if isNegative and (index == 0 or forwardFract ~= 0) then
                            local temp = fracDigit
                            fracDigit = intDigit
                            intDigit = temp
                        end
            
                        local topGlyphOffset = glyphH * (fract - 1) 
                        local botGlyphOffset = topGlyphOffset + glyphH
            
                        local x = rectX + glyphXOffset + (6 - index) * glyphW
                        local y = rectY + glyphYOffset
                        
                        newContent[#newContent + 1] = svgText(x, y + topGlyphOffset,fracDigit, class)
                        newContent[#newContent + 1] = svgText(x, y + botGlyphOffset,intDigit , class)
    
                        index = index + 1
                        divisor = divisor * 10
                        if intDigit == rolloverDigit then
                            forwardFract = fract
                        else
                            forwardFract = 0
                        end
                    end
                    table.insert(newContent, [[</g></g>]])
                end
            end
    
            local function getRelativePitch(velocity)
                local pitch = -math.deg(atan(velocity.y, velocity.z)) + 180
                -- This is 0-360 where 0 is straight up
                pitch = pitch - 90
                -- So now 0 is straight, but we can now get angles up to 420
                if pitch < 0 then
                    pitch = 360 + pitch
                end
                -- Now, if it's greater than 180, say 190, make it go to like -170
                if pitch > 180 then
                    pitch = -180 + (pitch - 180)
                end
                -- And it's backwards.  
                return -pitch
            end
    
            local function getRelativeYaw(velocity)
                local yaw = math.deg(atan(velocity.y, velocity.x)) - 90
                if yaw < -180 then
                    yaw = 360 + yaw
                end
                return yaw
            end    
    
            local function DrawPrograde (newContent, velocity, speed, centerX, centerY)
                if (speed > 5 and not inAtmo) or (speed > minAutopilotSpeed) then
                    local horizonRadius = circleRad -- Aliased global
                    local pitchRange = 20
                    local yawRange = 20
                    local relativePitch = getRelativePitch(velocity)
                    local relativeYaw = getRelativeYaw(velocity)
            
                    local dotSize = 14
                    local dotRadius = dotSize/2
                    
                    local dx = (-relativeYaw/yawRange)*horizonRadius -- Values from -1 to 1 indicating offset from the center
                    local dy = (relativePitch/pitchRange)*horizonRadius
                    local x = centerX + dx
                    local y = centerY + dy
            
                    local distance = msqrt((dx)^2 + (dy)^2)
            
                    local progradeDot = [[<circle
                    cx="]] .. x .. [["
                    cy="]] .. y .. [["
                    r="]] .. dotRadius/dotSize .. [["
                    style="fill:#d7fe00;stroke:none;fill-opacity:1"/>
                <circle
                    cx="]] .. x .. [["
                    cy="]] .. y .. [["
                    r="]] .. dotRadius .. [["
                    style="stroke:#d7fe00;stroke-opacity:1;fill:none" />
                <path
                    d="M ]] .. x-dotSize .. [[,]] .. y .. [[ h ]] .. dotRadius .. [["
                    style="stroke:#d7fe00;stroke-opacity:1" />
                <path
                    d="M ]] .. x+dotRadius .. [[,]] .. y .. [[ h ]] .. dotRadius .. [["
                    style="stroke:#d7fe00;stroke-opacity:1" />
                <path
                    d="M ]] .. x .. [[,]] .. y-dotSize .. [[ v ]] .. dotRadius .. [["
                    style="stroke:#d7fe00;stroke-opacity:1" />]]
                        
                    if distance < horizonRadius then
                        newContent[#newContent + 1] = progradeDot
                        -- Draw a dot or whatever at x,y, it's inside the AH
                    else
                        -- x,y is outside the AH.  Figure out how to draw an arrow on the edge of the circle pointing to it.
                        -- First get the angle
                        -- tan(ang) = o/a, tan(ang) = x/y
                        -- atan(x/y) = ang (in radians)
                        -- This is a special overload for doing this on a circle and setting up the signs correctly for the quadrants
                        local angle = atan(dy,dx)
                        -- Project this onto the circle
                        -- These are backwards from what they're supposed to be.  Don't know why, that's just what makes it work apparently
                        local arrowSize = 4
                        local projectedX = centerX + (horizonRadius)*math.cos(angle) -- Needs to be converted to deg?  Probably not
                        local projectedY = centerY + (horizonRadius)*math.sin(angle)
                        -- Draw an arrow that we will rotate by angle
                        -- Convert angle to degrees
                        newContent[#newContent + 1] = stringf('<g transform="rotate(%f %f %f)"><rect x="%f" y="%f" width="%f" height="%f" stroke="#d7fe00" fill="#d7fe00" /><path d="M %f %f l %f %f l %f %f z" fill="#d7fe00" stroke="#d7fe00"></g>', angle*(180/math.pi), projectedX, projectedY, projectedX-arrowSize, projectedY-arrowSize/2, arrowSize*2, arrowSize,
                                                                                                                                                            projectedX+arrowSize, projectedY - arrowSize, arrowSize, arrowSize, -arrowSize, arrowSize)
            
                        --newContent[#newContent + 1] = stringf('<circle cx="%f" cy="%f" r="2" stroke="white" stroke-width="2" fill="white" />', projectedX, projectedY)
                    end
            
                    if(not inAtmo) then
                        local velo = vec3(velocity)
                        relativePitch = getRelativePitch(-velo)
                        relativeYaw = getRelativeYaw(-velo)
                        
                        dx = (-relativeYaw/yawRange)*horizonRadius -- Values from -1 to 1 indicating offset from the center
                        dy = (relativePitch/pitchRange)*horizonRadius
                        x = centerX + dx
                        y = centerY + dy
            
                        distance = msqrt((dx)^2 + (dy)^2)
                        -- Retrograde Dot
                        
                        if distance < horizonRadius then
                            local retrogradeDot = [[<circle
                            cx="]] .. x .. [["
                            cy="]] .. y .. [["
                            r="]] .. dotRadius .. [["
                            style="stroke:#d7fe00;stroke-opacity:1;fill:none" />
                        <path
                            d="M ]] .. x .. [[,]] .. y-dotSize .. [[ v ]] .. dotRadius .. [["
                            style="stroke:#d7fe00;stroke-opacity:1" id="l"/>
                        <use
                            xlink:href="#l"
                            transform="rotate(120,]] .. x .. [[,]] .. y .. [[)" />
                        <use
                            xlink:href="#l"
                            transform="rotate(-120,]] .. x .. [[,]] .. y .. [[)" />
                        <path
                            d="M ]] .. x-dotRadius .. [[,]] .. y .. [[ h ]] .. dotSize .. [["
                            style="stroke-width:0.5;stroke:#d7fe00;stroke-opacity:1"
                            transform="rotate(-45,]] .. x .. [[,]] .. y .. [[)" id="c"/>
                        <use
                            xlink:href="#c"
                            transform="rotate(-90,]] .. x .. [[,]] .. y .. [[)"/>]]
                            newContent[#newContent + 1] = retrogradeDot
                            -- Draw a dot or whatever at x,y, it's inside the AH
                        end -- Don't draw an arrow for this one, only prograde is that important
            
                    end
                end
            end
    
            local function DrawThrottle(newContent, flightStyle, throt, flightValue)
                if throtPosX == 0 and throtPosY == 0 then return end
                throt = mfloor(throt+0.5) -- Hard-round it to an int
                local y1 = throtPosY+10
                local y2 = throtPosY+20
                if isRemote() == 1 and not RemoteHud then
                    y1 = 55
                    y2 = 65
                end            
                local label = "CRUISE"
                local u = "km/h"
                local value = flightValue
                if (flightStyle == "TRAVEL" or flightStyle == "AUTOPILOT") then
                    label = "THROT"
                    u = "%"
                    value = throt
                    local throtclass = "dim"
                    if throt < 0 then
                        throtclass = "red"
                    end
                    newContent[#newContent + 1] = stringf([[<g class="%s">
                        <path class="linethick" d="M %d %d L %d %d L %d %d L %d %d"/>
                        <g transform="translate(0 %.0f)">
                            <polygon points="%d,%d %d,%d %d,%d"/>
                        </g>]], throtclass, throtPosX-7, throtPosY-50, throtPosX, throtPosY-50, throtPosX, throtPosY+50, throtPosX-7, throtPosY+50, (1 - mabs(throt)), 
                        throtPosX-10, throtPosY+50, throtPosX-15, throtPosY+53, throtPosX-15, throtPosY+47)
                end
                newContent[#newContent + 1] = svgText(throtPosX+10, y1, label , "pbright txtstart")
                newContent[#newContent + 1] = svgText(throtPosX+10, y2, stringf("%.0f %s", value, u), "pbright txtstart")
                if inAtmo and AtmoSpeedAssist and throttleMode and ThrottleLimited then
                    -- Display a marker for where the AP throttle is putting it, calculatedThrottle
            
                    throt = mfloor(calculatedThrottle*100+0.5)
                    local throtclass = "red"
                    if throt < 0 then
                        throtclass = "red" -- TODO
                    end
                    newContent[#newContent + 1] = stringf([[<g class="%s">
                        <g transform="translate(0 %d)">
                            <polygon points="%d,%d %d,%d %d,%d"/>
                        </g></g>]], throtclass, (1 - mabs(throt)), 
                        throtPosX-10, throtPosY+50, throtPosX-15, throtPosY+53, throtPosX-15, throtPosY+47)
                    newContent[#newContent + 1] = svgText( throtPosX+10, y1+40, "LIMIT", "pbright txtstart")
                    newContent[#newContent + 1] = svgText(throtPosX+10, y2+40, throt.."%", "pbright txtstart")
                end
                if (inAtmo and AtmoSpeedAssist) or Reentry then
                    -- Display AtmoSpeedLimit above the throttle
                    newContent[#newContent + 1] = svgText(throtPosX+10, y1-40, "LIMIT: ".. adjustedAtmoSpeedLimit .. " km/h", "dim txtstart")
                elseif not inAtmo and Autopilot then
                    -- Display MaxGameVelocity above the throttle
                    newContent[#newContent + 1] = svgText(throtPosX+10, y1-40, "LIMIT: ".. mfloor(MaxGameVelocity*3.6+0.5) .. " km/h", "dim txtstart")
                end
            end
    
            local function DrawSpeed(newContent, spd)
                if throtPosX == 0 and throtPosY == 0 then return end
                local ys = throtPosY-10 
                local x1 = throtPosX + 10
                newContent[#newContent + 1] = svgText(0,0,"", "pdim txt txtend")
                if isRemote() == 1 and not RemoteHud then
                    ys = 75
                end
                newContent[#newContent + 1] = svgText( x1, ys, mfloor(spd).." km/h" , "pbright txtbig txtstart")
            end
    
            local function DrawWarnings(newContent)
    
                newContent[#newContent + 1] = svgText(ConvertResolutionX(150), ConvertResolutionY(1070), stringf("ARCH Hud Version: %.3f", VERSION_NUMBER), "hudver")
                newContent[#newContent + 1] = [[<g class="warnings">]]
                if u.isMouseControlActivated() == 1 then
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(550), "Warning: Invalid Control Scheme Detected", "warnings")
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(600), "Keyboard Scheme must be selected", "warnings")
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(650), "Set your preferred scheme in Lua Parameters instead", "warnings")
                end
                local warningX = ConvertResolutionX(960)
                local brakeY = ConvertResolutionY(860)
                local gearY = ConvertResolutionY(880)
                local hoverY = ConvertResolutionY(900)
                local ewarpY = ConvertResolutionY(960)
                local apY = ConvertResolutionY(200)
                local turnBurnY = ConvertResolutionY(250)
                local gyroY = ConvertResolutionY(960)
                if isRemote() == 1 and not RemoteHud then
                    brakeY = ConvertResolutionY(135)
                    gearY = ConvertResolutionY(155)
                    hoverY = ConvertResolutionY(175)
                    apY = ConvertResolutionY(115)
                    turnBurnY = ConvertResolutionY(95)
                end
                local defaultStroke = "#222222"
                local onFill = "white"
                local defaultClass = "dimmer"
                local fillClass = "pbright"
    
                local brakeFill = "#110000"
                local brakeStroke = defaultStroke
                local brakeClass = defaultClass
                if BrakeIsOn then
                    local bkStr = ""
                    if type(BrakeIsOn) == "string" then bkStr="-"..BrakeIsOn end
                    newContent[#newContent + 1] = svgText(warningX, brakeY, "Brake Engaged"..bkStr, "warnings")
                    brakeFill = "#440000"
                    brakeStroke = onFill
                    brakeClass = fillClass
                elseif brakeInput2 > 0 then
                    newContent[#newContent + 1] = svgText(warningX, brakeY, "Auto-Brake Engaged", "warnings", "opacity:"..brakeInput2)
                end
                local stallFill = "#110000"
                local stallStroke = defaultStroke
                local stallClass = defaultClass
                if inAtmo and stalling and abvGndDet == -1 then
                    if not Autopilot and not VectorToTarget and not BrakeLanding and not antigravOn and not VertTakeOff and not AutoTakeoff then
                        newContent[#newContent + 1] = svgText(warningX, apY+50, "** STALL WARNING **", "warnings")
                        stallFill = "#ff0000"
                        stallStroke = onFill
                        stallClass = fillClass
                        play("stall","SW",2)
                    end
                end
                if ReversalIsOn then
                    newContent[#newContent + 1] = svgText(warningX, apY+90, "Flight Assist in Progress", "warnings")
                end
    
                if gyroIsOn then
                    newContent[#newContent + 1] = svgText(warningX, gyroY, "Gyro Enabled", "warnings")
                end
                local gearFill = "#111100"
                local gearStroke = defaultStroke
                local gearClass = defaultClass
                if GearExtended then
                    gearFill = "#775500"
                    gearStroke = onFill
                    gearClass = fillClass
                    if hasGear then
                        newContent[#newContent + 1] = svgText(warningX, gearY, "Gear Extended", "warn")
                    else
                        newContent[#newContent + 1] = svgText(warningX, gearY, "Landed (G: Takeoff)", "warnings")
                    end
                end
                if abvGndDet > -1 and (not antigravOn or coreAltitude < 100) then 
                    local displayText = getDistanceDisplayString(Nav:getTargetGroundAltitude())
                    newContent[#newContent + 1] = svgText(warningX, hoverY,"Hover Height: ".. displayText,"warn") 
                end
                local rocketFill = "#000011"
                local rocketStroke = defaultStroke
                local rocketClass = defaultClass
                if isBoosting then
                    rocketFill = "#0000DD"
                    rocketStroke = onFill
                    rocketClass = fillClass
                    newContent[#newContent + 1] = svgText(warningX, ewarpY+20, "ROCKET BOOST ENABLED", "warn")
                end           
                local aggFill = "#001100"
                local aggStroke = defaultStroke      
                local aggClass = defaultClass
                if antigrav and not ExternalAGG and antigravOn and AntigravTargetAltitude ~= nil then
                    aggFill = "#00DD00"
                    aggStroke = onFill
                    aggClass = fillClass
                    local aggWarn = "warnings"
                    if mabs(coreAltitude - antigrav.getBaseAltitude()) < 501 then aggWarn = "warn" end
                        newContent[#newContent + 1] = svgText(warningX, apY+40, stringf("Target Altitude: %d Singularity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), aggWarn)
                end
                if Autopilot and AutopilotTargetName ~= "None" then
                    newContent[#newContent + 1] = svgText(warningX, apY,  "Autopilot "..AutopilotStatus, "warn")
                elseif LockPitch ~= nil then
                    newContent[#newContent + 1] = svgText(warningX, apY+20, stringf("LockedPitch: %d", mfloor(LockPitch)), "warn")
                elseif followMode then
                    newContent[#newContent + 1] = svgText(warningX, apY+20, "Follow Mode Engaged", "warn")
                elseif Reentry or finalLand then
                    newContent[#newContent + 1] = svgText(warningX, apY+20, "Re-entry in Progress", "warn")
                end
                if AltitudeHold or VertTakeOff then
                    local displayText = getDistanceDisplayString(HoldAltitude, 2)
                    if VertTakeOff then
                        if antigravOn then
                            displayText = getDistanceDisplayString(antigrav.getBaseAltitude(),2).." AGG singularity height"
                        end
                        newContent[#newContent + 1] = svgText(warningX, apY, "VTO to "..displayText , "warn")
                    elseif AutoTakeoff and not IntoOrbit then
                        if spaceLaunch then
                            newContent[#newContent + 1] = svgText(warningX, apY, "Takeoff to "..AutopilotTargetName, "warn")
                        else
                            newContent[#newContent + 1] = svgText(warningX, apY, "Takeoff to "..displayText, "warn")
                        end
                        if BrakeIsOn and not VertTakeOff then
                            newContent[#newContent + 1] = svgText( warningX, apY + 80,"Throttle Up and Disengage Brake For Takeoff", "crit")
                        end
                    else
                        newContent[#newContent + 1] = svgText(warningX, apY, "Altitude Hold: ".. stringf("%.1fm", HoldAltitude), "warn")
                    end
                end
                if VertTakeOff and (antigrav ~= nil and antigrav) then
                    if atmosDensity > 0.1 then
                        newContent[#newContent + 1] = svgText(warningX, apY+20, "Beginning ascent", "warn")
                    elseif atmosDensity < 0.09 and atmosDensity > 0.05 then
                        newContent[#newContent + 1] = svgText(warningX, apY+20,  "Aligning trajectory", "warn")
                    elseif atmosDensity < 0.05 then
                        newContent[#newContent + 1] = svgText(warningX, apY+20,  "Leaving atmosphere", "warn")
                    end
                end
                if IntoOrbit then
                    if orbitMsg ~= nil then
                        newContent[#newContent + 1] = svgText(warningX, apY, orbitMsg, "warn")
                    end
                end
                if BrakeLanding then
                    if StrongBrakes then
                        local str = "Brake Landing"
                        if alignHeading then str = str.."-Aligning" end
                        if apBrk then str = str.."-Drift Limited" end
                        newContent[#newContent + 1] = svgText(warningX, apY, str, "warnings")
                    else
                        newContent[#newContent + 1] = svgText(warningX, apY, "Coast-Landing", "warnings")
                    end
                end
                if ProgradeIsOn then
                    newContent[#newContent + 1] = svgText(warningX, apY, "Prograde Alignment", "crit")
                end
                if RetrogradeIsOn then
                    newContent[#newContent + 1] = svgText(warningX, apY, "Retrograde Alignment", "crit")
                end
                local collisionFill = "#110000"
                local collisionStroke = defaultStroke
                local collisionClass = defaultClass
                if collisionAlertStatus then
                    collisionFill = "#FF0000"
                    collisionStroke = onFill
                    collisionClass = fillClass
                    local type
                    if string.find(collisionAlertStatus, "COLLISION") then type = "warnings" else type = "crit" end
                    newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, collisionAlertStatus, type)
                elseif atmosDensity == 0 then
                    local intersectBody, atmoDistance = AP.checkLOS((constructVelocity):normalize())
                    if atmoDistance ~= nil then
                        collisionClass = fillClass
                        collisionFill = "#FF0000"
                        collisionStroke = onFill
                        local displayText = getDistanceDisplayString(atmoDistance)
                        local travelTime = Kinematic.computeTravelTime(velMag, 0, atmoDistance)
                        local displayCollisionType = "Collision"
                        if intersectBody.noAtmosphericDensityAltitude > 0 then displayCollisionType = "Atmosphere" end
                        newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, intersectBody.name.." "..displayCollisionType.." "..FormatTimeString(travelTime).." In "..displayText, "crit")
                    end
                end
                if VectorToTarget and not IntoOrbit then
                    newContent[#newContent + 1] = svgText(warningX, apY+60, VectorStatus, "warn")
                end
                local boardersFill = "#111100"
                local boardersStroke = defaultStroke
                local boardersClass = defaultClass
                if passengers and #passengers > 1 then
                    boardersFill = "#DDDD00"
                    boardersStroke = onFill
                    boardersClass = fillClass
                end
    
                local crx = ConvertResolutionX
                local cry = ConvertResolutionY
    
                local defaultClass = "topButton"
                local activeClass = "topButtonActive"
                local apClass = defaultClass
                if Autopilot or VectorToTarget or spaceLaunch or IntoOrbit then
                    apClass = activeClass
                end
                local progradeClass = defaultClass
                if ProgradeIsOn then
                    progradeClass = activeClass
                end
                local landClass = defaultClass
                if BrakeLanding or GearExtended then
                    landClass = activeClass
                end
                local altHoldClass = defaultClass
                if AltitudeHold or VectorToTarget then
                    altHoldClass = activeClass
                end
                local retroClass = defaultClass
                if RetrogradeIsOn then
                    retroClass = activeClass
                end
                local orbitClass = defaultClass
                if IntoOrbit or (OrbitAchieved and Autopilot) then
                    orbitClass = activeClass
                end
                if showHud and DisplayOdometer then 
                    local texty = cry(30)
                    newContent[#newContent + 1] = stringf([[ 
                        <g class="pdim txt txtmid">
                            <g class="%s">
                            <path d="M %f %f l 0 %f l %f 0 l %f %f Z"/>
                            ]], apClass, crx(960), cry(54), cry(-53), crx(-120), crx(25), cry(50))
                    newContent[#newContent + 1] = svgText(crx(910),texty, "AUTOPILOT")
                    newContent[#newContent + 1] = stringf([[
                            </g>
        
                            <g class="%s">
                            <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                            ]], progradeClass, crx(865), cry(51), crx(-25), cry(-50), crx(-110), crx(25), cry(46))
                    newContent[#newContent + 1] = svgText(crx(800), texty, "PROGRADE")
                    newContent[#newContent + 1] = stringf([[
                            </g>
        
                            <g class="%s">
                            <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                            ]], landClass, crx(755), cry(47), crx(-25), cry(-46), crx(-98), crx(44), cry(44))
                    newContent[#newContent + 1] = svgText(crx(700), texty, "LAND")
                    newContent[#newContent + 1] = stringf([[
                            </g>
        
                            <g class="%s">
                            <path d="M %f %f l 0 %f l %f 0 l %f %f Z"/>
                            ]], altHoldClass, crx(960), cry(54), cry(-53), crx(120), crx(-25), cry(50))
                    newContent[#newContent + 1] = svgText(crx(1010), texty, "ALT HOLD")
                    newContent[#newContent + 1] = stringf([[
                            </g>
        
                            <g class="%s">
                            <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                            ]], retroClass, crx(1055), cry(51), crx(25), cry(-50), crx(110), crx(-25), cry(46))
                    newContent[#newContent + 1] = svgText(crx(1122), texty, "RETROGRADE")
                    newContent[#newContent + 1] = stringf([[
                            </g>
        
                            <g class="%s">
                            <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                            ]], orbitClass, crx(1165), cry(47), crx(25), cry(-46), crx(98), crx(-44), cry(44))
                    newContent[#newContent + 1] = svgText(crx(1220), texty, "ORBIT")
                    newContent[#newContent + 1] = [[
                            </g>
                        </g>]]
                
                    newContent[#newContent + 1] = "</g>"
                end
                return newContent
            end
    
            local function getSpeedDisplayString(speed) -- TODO: Allow options, for now just do kph
                return mfloor(round(speed * 3.6, 0) + 0.5) .. " km/h" -- And generally it's not accurate enough to not twitch unless we round 0
            end
    
            local function getAPName(index)
                local name = AutopilotTargetName
                if index ~= nil and type(index) == "number" then 
                    if index == 0 then return "None" end
                    name = AtlasOrdered[index].name
                end
                if name == nil then
                    name = CustomTarget.name
                end
                if name == nil then
                    name = "None"
                end
                return name
            end
    
            local function DisplayRoute(newContent)
                local checkRoute = AP.routeWP(true)
                if not checkRoute or #checkRoute==0 then return end
                local x = ConvertResolutionX(750)
                local y = ConvertResolutionY(360)
                if Autopilot or VectorToTarget then
                    newContent[#newContent + 1] = svgText(x, y, "REMAINING ROUTE","pdim txtstart size20" )
                else
                    newContent[#newContent + 1] = svgText(x, y, "LOADED ROUTE","pdim txtstart size20" )
                end
                for k,i in pairs(checkRoute) do
                    y=y+20
                    newContent[#newContent + 1] = svgText( x, y, k..". "..checkRoute[k], "pdim txtstart size20")
                end
            end
    
            local function DisplayHelp(newContent)
                local x = OrbitMapX+10
                local y = OrbitMapY+20
                local help = {}
                local helpAtmoGround = {"Alt-4: AutoTakeoff to Target"}
                local helpAtmoAir = { "Alt-6: Altitude hold at current altitude", "Alt-6-6: Altitude Hold at 11% atmosphere", 
                                    "Alt-Q/E: Hard Bankroll left/right till released", "Alt-S: 180 deg bank turn"}
                local helpSpace = {"Alt-6: Orbit at current altitude", "Alt-6-6: Orbit at LowOrbitHeight over atmosphere","G: Raise or lower landing gear", "Alt-W: Toggle prograde align", "Alt-S: Toggle retrograde align / Turn&Burn (AP)"}
                local helpGeneral = {"", "------------------ALWAYS--------------------", "Alt-1: Increment Interplanetary Helper", "Alt-2: Decrement Interplanetary Helper", "Alt-Shift 1: Show passengers on board","Alt-Shift-2: Deboard passengers",
                                    "Alt-3: Toggle Vanilla Widget view", "Alt-4: Autopilot to IPH target", "Alt-Shift-3: Show docked ships","Alt-Shift-4: Undock all ships",
                                    "Alt-5: Lock Pitch at current pitch","Alt-Shift-5: Lock pitch at preset pitch","Alt-7: Toggle Collision System on and off", "Alt-8: Toggle ground stabilization (underwater flight)",
                                    "B: Toggle rocket boost on/off","CTRL: Toggle Brakes on and off. Cancels active AP", "LAlt: Tap to shift freelook on and off", 
                                    "Shift: Hold while not in freelook to see Buttons", "L: Toggle lights on and off", "Type /commands or /help in lua chat to see text commands"}
                table.insert(help, "--------------DYNAMIC-----------------")
                if inAtmo then 
                    if abvGndDet ~= -1 then
                        addTable(help, helpAtmoGround)
                        if autopilotTargetPlanet and planet and autopilotTargetPlanet.name == planet.name then
                            table.insert(help,"Alt-4-4: Low Orbit Autopilot to Target")
                        end
                        if antigrav or VertTakeOffEngine then 
                            if antigrav then
                                if antigravOn then
                                    table.insert(help, "Alt-6: AGG is on, will takeoff to AGG Height")
                                else
                                    table.insert(help,  "Turn on AGG to takeoff to AGG Height")
                                end
                            end
                            if VertTakeOffEngine then 
                                table.insert(help, "Alt-6: Begins Vertical AutoTakeoff.")
                            end
                        else
                            table.insert(help, "Alt-6: Autotakeoff to AutoTakeoffAltitude")
                            table.insert(help, "Alt-6-6: Autotakeoff to 11% atmosphere")
                        end
                        if GearExtended then
                            table.insert(help,"G: Takeoff to hover height, raise gear")
                        else
                            table.insert(help,"G: Lowergear and Land")
                        end
                    else
                        addTable(help,helpAtmoAir)
                        table.insert(help,"G: Begin BrakeLanding or Land")
                    end
                    if VertTakeOff then
                        table.insert(help,"Hit Alt-6 before exiting Atmosphere during VTO to hold in level flight")
                    end
                else
                    addTable(help, helpSpace)
                    if shield then
                        table.insert(help,"Alt-Shift-6: Vent shields")
                        if not AutoShieldToggle then table.insert(help,"Alt-Shift-7: Toggle shield off/on") end
                    end
                end
                if CustomTarget ~= nil then
                    table.insert(help, "Alt-Shift-8: Add current IPH target to Route")
                end
                if gyro then
                    table.insert(help,"Alt-9: Activate Gyroscope")
                end
                if ExtraLateralTags ~= "none" or ExtraLongitudeTags ~= "none" or ExtraVerticalTags ~= "none" then
                    table.insert(help, "Alt-Shift-9: Cycles engines with Extra tags")
                end
                if AltitudeHold then 
                    table.insert(help, "Alt-Spacebar/C will raise/lower target height")
                    table.insert(help, "Alt+Shift+Spacebar/C will raise/lower target to preset values")
                end
                if AtmoSpeedAssist or not inAtmo then
                    table.insert(help,"LALT+Mousewheel will lower/raise speed limit")
                end
                addTable(help, helpGeneral)
                for i = 1, #help do
                    y=y+12
                    newContent[#newContent + 1] = svgText( x, y, help[i], "pdim txtbig txtstart")
                end
            end
            
            local function DisplayOrbitScreen(newContent)
                local orbitMapX = OrbitMapX
                local orbitMapY = OrbitMapY
                local orbitMapSize = OrbitMapSize -- Always square
                local pad = 4
    
                local orbitInfoYOffset = 15
                local x = 0
                local y = 0
                local rx, ry, scale, xOffset
    
                local tempOrbit
    
                local function orbitInfo(type)
                    local alt, time, speed, line, class, textX
                    if type == "Periapsis" then
                        alt = tempOrbit.periapsis.altitude
                        time = tempOrbit.timeToPeriapsis
                        speed = tempOrbit.periapsis.speed
                        class = "txtend"
                        line = 12
                        textX = math.min(x,orbitMapX + orbitMapSize - (planet.radius/scale) - pad*2)
                    else
                        alt = tempOrbit.apoapsis.altitude
                        time = tempOrbit.timeToApoapsis
                        speed = tempOrbit.apoapsis.speed
                        line = -12
                        class = "txtstart"
                        textX = x
                    end
                    if velMag < 1 then time = 0 end
                    newContent[#newContent + 1] = stringf(
                        [[<line class="pdim linethin" style="stroke:white" x1="%f" y1="%f" x2="%f" y2="%f"/>]],
                        textX + line, y - 5, x, y - 5)
                    newContent[#newContent + 1] = stringf(
                        [[<line class="pdim linethin" x1="%f" y1="%f" x2="%f" y2="%f"/>]],
                        textX - line*4, y+2, x, y+2)
                    newContent[#newContent + 1] = svgText(textX, y, type, class)
                    x = textX - line*2
                    y = y + orbitInfoYOffset
                    local displayText = getDistanceDisplayString(alt)
                    newContent[#newContent + 1] = svgText(x, y, displayText, class)
                    y = y + orbitInfoYOffset
                    newContent[#newContent + 1] = svgText(x, y, FormatTimeString(time), class)
                    y = y + orbitInfoYOffset
                    newContent[#newContent + 1] = svgText(x, y, getSpeedDisplayString(speed), class)
                end
    
                local targetHeight = orbitMapSize*1.5
                if SelectedTab == "INFO" then
                    targetHeight = 25*10
                end
    
                if SelectedTab ~= "HIDE" then
                newContent[#newContent + 1] = [[<g class="pbright txtorb txtmid">]]
                -- Draw a darkened box around it to keep it visible
                newContent[#newContent + 1] = stringf(
                                                '<rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" class="dimfill brightstroke" style="stroke-width:3;fill-opacity:0.3;" />',
                                                orbitMapSize*2, targetHeight, orbitMapX, orbitMapY)
                -- And another inner box for clipping
                newContent[#newContent + 1] = stringf(
                                                [[<clippath id="orbitRect">
                                                <rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" class="dimfill brightstroke" style="stroke-width:3;fill-opacity:0.3;" />
                                                </clippath>]],
                                                orbitMapSize*2, targetHeight, orbitMapX, orbitMapY)
                end
    
                local orbitMapHeight = orbitMapSize*1.5
                local orbitMapWidth = orbitMapSize*2
                local orbitHalfHeight = orbitMapHeight/2
                local orbitHalfWidth = orbitMapSize -- Just to keep things consistent
                local orbitMidX = orbitMapX + orbitHalfWidth
                local orbitMidY = orbitMapY + orbitHalfHeight
                local orbitMaxX = orbitMapX + orbitMapWidth
                local orbitMaxY = orbitMapY + orbitMapHeight
                if SelectedTab == "ORBIT" then
                    -- If orbits are up, let's try drawing a mockup
                    
                    orbitMapY = orbitMapY + pad
                    rx = orbitMapSize / 2
                    xOffset = 0
            
                    tempOrbit = {}
                    tempOrbit.periapsis = {}
                    tempOrbit.apoapsis = {}
                    if orbit ~= nil then -- Clone it so we don't edit it as we replace extreme values
                        if orbit.periapsis ~= nil then
                            tempOrbit.periapsis.altitude = orbit.periapsis.altitude
                            tempOrbit.periapsis.speed = orbit.periapsis.speed
                        end
                        if orbit.apoapsis ~= nil then
                            tempOrbit.apoapsis.altitude = orbit.apoapsis.altitude
                            tempOrbit.apoapsis.speed = orbit.apoapsis.speed
                        end
                        tempOrbit.period = orbit.period
                        tempOrbit.eccentricity = orbit.eccentricity
                        tempOrbit.timeToApoapsis = orbit.timeToApoapsis
                        tempOrbit.timeToPeriapsis = orbit.timeToPeriapsis
                        tempOrbit.eccentricAnomaly = orbit.eccentricAnomaly
                        tempOrbit.trueAnomaly = orbit.trueAnomaly
                    end
                    if tempOrbit.periapsis == nil then 
                        tempOrbit.periapsis = {}
                        tempOrbit.periapsis.altitude = -planet.radius
                        tempOrbit.periapsis.speed = MaxGameVelocity -- Don't show it
                    end
                    if tempOrbit.eccentricity == nil then
                        tempOrbit.eccentricity = 1
                    end
                    if tempOrbit.apoapsis == nil then
                        tempOrbit.apoapsis = {}
                        tempOrbit.apoapsis.altitude = coreAltitude
                        tempOrbit.apoapsis.speed = 0
                    end
                    if velMag < 1 then
                        tempOrbit.apoapsis.altitude = coreAltitude -- Prevent flicker when stopped
                        tempOrbit.apoapsis.speed = 0
                    end
    
                    
                    if tempOrbit.apoapsis.altitude then
                    
                        scale = (tempOrbit.apoapsis.altitude + tempOrbit.periapsis.altitude + (planet.radius) * 2) / (rx * 2)
                        ry = ((planet.radius) + tempOrbit.apoapsis.altitude) / scale *(1 - tempOrbit.eccentricity)
                        -- ry is a straight up distance from center multiplied by scale, then eccentricity
                        xOffset = rx - tempOrbit.periapsis.altitude / scale - (planet.radius) / scale
    
                        local apsisRatio = math.pi
                        if tempOrbit.period ~= nil and tempOrbit.period > 0 and tempOrbit.timeToApoapsis ~= nil then
                            --apsisRatio = (tempOrbit.timeToApoapsis / tempOrbit.period) * 2 * math.pi
                            -- So, this is kinda wrong.  Sorta.  It's a ratio representing where we are in the orbit
                            -- So that 0% and 100% are both at apoapsis, 50% is at periapsis
                            -- The problem is, when we're 25% through the orbit by time, we do not want to be 25% through the circle
                            -- Because speeds are slower near apoapsis and we spend more time near there if eccentric
    
                            -- I'm p sure one of the orbit params is an angle representing where we are on the circle
                            -- The true anomaly is the angle between the direction of periapsis and the current position
                            -- eccentricAnomaly already exists and is... the same thing... ?
                            apsisRatio = tempOrbit.eccentricAnomaly -- But it seems to be based on periapsis?
                            -- Ahhh weird.  It goes up to pi and back down to negative pi... 
                            -- Nope, it's 0 to pi... interesting... 
                            -- So we need to ... conditionally do something depending on which one it's going to
                            -- If periapsis is next, do 2pi-eccentric
                            if tempOrbit.timeToPeriapsis < tempOrbit.timeToApoapsis then
                                apsisRatio = (2*math.pi)-apsisRatio
                            end
                            
                            -- So, this describes a position on a non-eccentric orbit
                            -- The X value on that outer orbit is correct
                            -- But the angle itself is not correct for determining that on an ellipse... 
                        end
                        -- Handle nans and flickering at low speeds
                        if velMag < 1 or apsisRatio ~= apsisRatio then apsisRatio = math.pi end
                        -- x = xr * cos(t)
                        -- y = yr * sin(t)
                        local shipX = -rx * math.cos(apsisRatio) + orbitMapX + orbitHalfWidth + pad
                        local shipY = ry * math.sin(apsisRatio) + orbitMapY + orbitHalfHeight + pad
            
                        local ellipseColor = ""
                        --if orbit.periapsis.altitude <= 0 then
                        --    ellipseColor = 'redout'
                        --end
                        newContent[#newContent + 1] = '<g clip-path="url(#orbitRect)">'
                        newContent[#newContent + 1] = stringf(
                                                        [[<ellipse class="%s line" cx="%f" cy="%f" rx="%f" ry="%f"/>]],
                                                        ellipseColor, orbitMapX + orbitMapSize + pad,
                                                        orbitMapY + orbitMapSize*1.5 / 2 + pad, rx, ry)
                        if ry < 1 then
                            -- Draw a line instead, since the ellipse won't render
                            newContent[#newContent + 1] = stringf(
                                                        [[<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="red"/>]],
                                                        orbitMapX + orbitMapSize + pad - xOffset,
                                                        orbitMapY + orbitMapSize*1.5 / 2 + pad,
                                                        shipX, shipY)
                        end
                        newContent[#newContent + 1] = stringf(
                                                        '<circle cx="%f" cy="%f" r="%f" stroke="white" stroke-width="1" fill="rgb(0,150,200)" opacity="0.5" />',
                                                        orbitMapX + orbitMapSize + pad - xOffset,
                                                        orbitMapY + orbitMapSize*1.5 / 2 + pad, (planet.radius+planet.noAtmosphericDensityAltitude) / scale)
                        newContent[#newContent + 1] = stringf(
                                                        '<clipPath id="planetClip"><circle cx="%f" cy="%f" r="%f" /></clipPath>',
                                                        orbitMapX + orbitMapSize + pad - xOffset,
                                                        orbitMapY + orbitMapSize*1.5 / 2 + pad, (planet.radius+planet.noAtmosphericDensityAltitude) / scale)
                        newContent[#newContent + 1] = stringf(
                                                        [[<ellipse class="%s line" cx="%f" cy="%f" rx="%f" ry="%f" clip-path="url(#planetClip)"/>]],
                                                        "redout", orbitMapX + orbitMapSize + pad,
                                                        orbitMapY + orbitMapSize*1.5 / 2 + pad, rx, ry)
                        newContent[#newContent + 1] = stringf(
                                                        '<circle cx="%f" cy="%f" r="%f" stroke="black" stroke-width="1" fill="rgb(0,100,150)" />',
                                                        orbitMapX + orbitMapSize + pad - xOffset,
                                                        orbitMapY + orbitMapSize*1.5 / 2 + pad, planet.radius / scale)
                        newContent[#newContent + 1] = '</g>' -- The rest doesn't really need clipping hopefully
                        local planetsize = math.floor(planet.radius / scale + 0.5)
    
                        x = orbitMapX + orbitMapSize + pad*4 + rx -- Aligning left makes us need more padding... for some reason... 
                        y = orbitMapY + orbitMapSize*1.5 / 2 + 5 + pad
    
                        if tempOrbit.apoapsis ~= nil and tempOrbit.apoapsis.speed < MaxGameVelocity then
                            orbitInfo("Apoapsis")
                        end
                
                        y = orbitMapY + orbitMapSize*1.5 / 2 + 5 + pad
                        x = orbitMapX + orbitMapSize - pad*2 - rx
                
                        if tempOrbit.periapsis ~= nil and tempOrbit.periapsis.speed < MaxGameVelocity and tempOrbit.periapsis.altitude > 0 then
                            orbitInfo("Periapsis")
                        end
                
                        -- Add a label for the planet
                        newContent[#newContent + 1] = svgText(orbitMapX + orbitMapSize + pad, orbitMapY+20 + pad,planet.name, "txtorbbig")
                
                        
                        newContent[#newContent + 1] = stringf(
                                                        '<circle cx="%f" cy="%f" r="2" stroke="black" stroke-width="1" fill="white" />',
                                                        shipX,
                                                        shipY)
                        
                
                        newContent[#newContent + 1] = [[</g>]]
                        -- Once we have all that, we should probably rotate the entire thing so that the ship is always at the bottom so you can see AP and PE move?
                        return newContent
                    else
                        newContent[#newContent + 1] = '<g clip-path="url(#orbitRect)">'
                        -- There is no apoapsis, which means we're escaping (or approaching)
                        -- The planet should end up on the far left and we show a line indicating how close they will pass/are to the planet
                        -- Or, render the Galaxymap very small
                        local GalaxyMapHTML = "" -- No starting SVG tag so we can add it where we want it
                        -- Figure out our scale here... 
                        local xRatio = 1.2 * (maxAtlasX - minAtlasX) / (orbitMapSize*2) -- Add 10% for padding
                        local yRatio = 1.4 * (maxAtlasY - minAtlasY) / (orbitMapSize*1.5) -- Extra so we can get ion back in
                        for k, v in pairs(atlas[0]) do
                            if v.center then -- Only planets and stuff
                                -- Draw a circle at the scaled coordinates
                                local x = orbitMapX + orbitMapSize + (v.center.x / xRatio)
                                local y = orbitMapY + orbitMapSize*1.5/2 + (v.center.y / yRatio)
                                GalaxyMapHTML =
                                    GalaxyMapHTML .. '<circle cx="' .. x .. '" cy="' .. y .. '" r="' .. (v.radius / xRatio) * 30 ..
                                        '" stroke="white" stroke-width="1" fill="blue" />'
                                if not string.match(v.name, "Moon") and not string.match(v.name, "Sanctuary") and not string.match (v.name, "Space") then
                                    GalaxyMapHTML = GalaxyMapHTML .. "<text x='" .. x .. "' y='" .. y + (v.radius / xRatio) * 30 + 20 ..
                                                        "' font-size='12' fill=" .. rgb .. " text-anchor='middle' font-family='Montserrat'>" ..
                                                        v.name .. "</text>"
                                end
                            end
                        end
                        -- Draw a 'You Are Here' - face edition
                        local pos = vec3(C.getWorldPosition())
                        local x = orbitMapX + orbitMapSize + pos.x / xRatio
                        local y = orbitMapY + orbitMapSize*1.5/2 + pos.y / yRatio
                        GalaxyMapHTML = GalaxyMapHTML .. '<circle cx="' .. x .. '" cy="' .. y ..
                                            '" r="2" stroke="white" stroke-width="1" fill="red"/>'
                        GalaxyMapHTML = GalaxyMapHTML .. "<text x='" .. x .. "' y='" .. y - 10 ..
                                            "' font-size='14' fill='darkred' text-anchor='middle' font-family='Bank' font-weight='bold'>You Are Here</text>"
                        
                        MapXRatio = xRatio
                        MapYRatio = yRatio
                        -- And, if we can, draw a velocity line
                        -- We would need to project velocity on the plane of 0,0,1
                        -- Or the simplest, laziest way.  Project the point they'd be at after a while
                        local futurePoint = pos + constructVelocity*1000000
                        local x2 = orbitMapX + orbitMapSize + futurePoint.x / xRatio
                        local y2 = orbitMapY + orbitMapSize*1.5/2 + futurePoint.y / yRatio
                        GalaxyMapHTML = GalaxyMapHTML .. '<line x1="' .. x .. '" y1="' .. y ..
                                            '" x2="' .. x2 .. '" y2="' .. y2 .. '" stroke="purple" stroke-width="1"/>'
                        newContent[#newContent + 1] = GalaxyMapHTML
                        newContent[#newContent + 1] = '</g>'
                    end
                elseif SelectedTab == "INFO" then
                    newContent = HUD.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
                elseif SelectedTab == "HELP" then
                    newContent = DisplayHelp(newContent)
                elseif SelectedTab == "SCOPE" then
                    newContent[#newContent + 1] = '<g clip-path="url(#orbitRect)">'
                    local fov = scopeFOV
                    -- Sort the atlas by distance so closer planets draw on top
                    
                    -- If atmoDensity == 0, this already gets sorted in a hudTick
                    if atmosDensity > 0 then
                        table.sort(planetAtlas, function(a1,b2) local a,b = a1.center,b2.center return (a.x-worldPos.x)^2+(a.y-worldPos.y)^2+(a.z-worldPos.z)^2 < (b.x-worldPos.x)^2+(b.y-worldPos.y)^2+(b.z-worldPos.z)^2  end)
                    end
    
                    local data = {} -- structure for text data which gets built first
                    local ySorted = {} -- structure to sort by Y value to help prevent line overlaps
                    local planetTextWidth = 120 -- Just an estimate, we calc later, but need this before we calc
                    
                    -- For finding the planet closest to the cursor
                    local minCursorDistance = nil
                    local minCursorData = nil
    
                    -- Iterate backwards to build text, so nearest planets get priority on positioning
                    -- It's already sorted backwards (nearest things are first)
                    for i,v in ipairs(planetAtlas) do
                        
    
                        local target =  (v.center)-worldPos -- +v.radius*constructForward
                        local targetDistance = target:len()
                        local targetN = target:normalize()
                       
                        local horizontalRight = target:cross(constructForward):normalize()
                        local rollRad = math.acos(horizontalRight:dot(constructRight))
                        if rollRad ~= rollRad then rollRad = 0 end -- I don't know why this would fail but it does... so this fixes it... 
                        if horizontalRight:cross(constructRight):dot(constructForward) < 0 then rollRad = -rollRad end
    
                        local flatlen = target:project_on_plane(constructForward):len()
                        -- Triangle math is a bit more efficient than vector math, we just have a triangle with hypotenuse targetDistance
                        -- and the opposite leg is flatlen, so asin gets us the angle
                        -- We then sin it with rollRad to prevent janky square movement when rolling
                        local xAngle = math.sin(rollRad)*math.asin(flatlen/targetDistance)*constants.rad2deg
                        local yAngle = math.cos(rollRad)*math.asin(flatlen/targetDistance)*constants.rad2deg
                        -- These only output from 0 to 90 so we need to handle quadrants
                        if targetN:dot(constructForward) < 0 then
                            -- If it's in top or bottom quadrant, ie yAngle is 90 or -90ish, do this...
                            
                            yAngle = 90*math.cos(rollRad) + (90*math.cos(rollRad) - yAngle)
                            xAngle = 90*math.sin(rollRad) + (90*math.sin(rollRad) - xAngle)
                        end
    
                        local x = orbitMidX + (xAngle/fov)*orbitMapHeight
                        local y = orbitMidY + (yAngle/fov)*orbitMapHeight
    
                        local cursorDistance = ((x-orbitMidX)*(x-orbitMidX))+((y-orbitMidY)*(y-orbitMidY))
                        
                        -- Get the view angle from the center to the edge of a planet using trig
                        local topAngle = math.asin((v.radius+v.surfaceMaxAltitude)/targetDistance)*constants.rad2deg
                        if topAngle ~= topAngle then topAngle = fov end
                        local size = topAngle/fov*orbitMapHeight
    
                        local atmoAngle = math.asin((v.atmosphereRadius)/targetDistance)*constants.rad2deg
                        if atmoAngle ~= atmoAngle then atmoAngle = topAngle end -- hide atmo if inside it
                        local atmoSize = atmoAngle/fov*orbitMapHeight
                        --local nearestDistance = targetDistance - v.radius - math.max(v.surfaceMaxAltitude,v.noAtmosphericDensityAltitude)
                        --if nearestDistance < 0 then nearestDistance = targetDistance - v.radius - v.surfaceMaxAltitude end
                        --if nearestDistance < 0 then nearestDistance = targetDistance - v.radius end
                        --if v.name == "Teoma" then p(x .. "," .. y .. " - " .. xAngle .. ", " .. yAngle) end
    
                        -- Seems useful to give the distance to the atmo, land, etc instead of to the c
                        -- But it looks weird and I can't really label what it is, it'd take up too much space
                        local distance = getDistanceDisplayString(targetDistance,1)
                        local displayString = v.name
                        
                        -- Calculate whether or not we even display this planet.  In a really convoluted way.
                        local displayY = false
                        -- TODO: Simplify this somehow... 
                        if y > orbitMapY then
                            if y > orbitMaxY then
                                if y - atmoSize <= orbitMaxY then
                                    displayY = true
                                end
                            else
                                displayY = true
                            end
                        else
                            if y+atmoSize >= orbitMapY then
                                displayY = true
                            end
                        end
                        local displayX = false
                        local tx = x
                        if v.systemId == 0 then
                            tx = x + planetTextWidth -- Don't stop showing til the text is offscreen
                        else
                            tx = x - planetTextWidth -- Still just an estimated max textWidth... we don't know yet how long it is
                        end
                        if tx+planetTextWidth > orbitMapX then
                            if tx+planetTextWidth > orbitMaxX then
                                if tx-atmoSize-planetTextWidth <= orbitMaxX then
                                    displayX = true
                                end
                            else
                                displayX = true
                            end
                        else
                            if tx+atmoSize+planetTextWidth >= orbitMapX then
                                displayX = true
                            end
                        end
    
                        -- setup what we need for the distance line, because it draws even if the planet doesn't
                        local sortData = {}
                        sortData.x = x
                        sortData.y = y
                        sortData.planet = v
                        sortData.atmoSize = atmoSize
    
                        if not minCursorDistance or cursorDistance < minCursorDistance then
                            minCursorDistance = cursorDistance
                            minCursorData = sortData
                        end
    
                        if displayX and displayY then
                            local hoverSize = math.max(atmoSize,5) -- This 5px hoversize for small planets could probably go up a bit
                            if (cursorDistance) < hoverSize*hoverSize then
                            --if x-hoverSize <= orbitMidX and x+hoverSize >= orbitMidX and y-hoverSize <= orbitMidY and y+hoverSize >= orbitMidY then
                                displayString = displayString .. " - " .. distance
                            end
                            sortData.size = size
                            sortData.i = i
                            sortData.displayString = displayString
                            sortData.distance = distance
                            sortData.visible = true
                            ySorted[#ySorted+1] = sortData
                        else
                            sortData.visible = false
                        end
                    end
    
                    local anyHovered = false
                    -- Setup text in y sort order
                    table.sort(ySorted,function(a,b) return a.y<b.y end)
                    -- Again, we draw the lowest Y first because it prevents the lines from crossing somehow
                    -- And drawing them in this order makes sure that the upper-most planets get the upper-most labels
                    for k,d in ipairs(ySorted) do
                        local v,size,i,atmoSize,x,y,displayString,distance = d.planet,d.size,d.i,d.atmoSize,d.x,d.y,d.displayString,d.distance
    
                        local textX, textY, textWidth, textHeight
                        local xMod = 15 -- Planet names are 15px right or left, for moons or planets respectively
                        local class = "pdim" -- Planet class is pdim
                        if v.systemId ~= 0 then -- This is moons
                            textWidth = ConvertResolutionX(string.len(displayString)*5) -- Smaller text
                            xMod = -(15+textWidth) -- Drawn left
                            textHeight = ConvertResolutionY(10) -- Smaller text
                            class = "pdimfill" -- Darker text
                        else
                            textWidth = ConvertResolutionX(string.len(displayString)*9)
                            textHeight = ConvertResolutionY(15)
                        end
                        -- Only clamp things that are large enough to matter (larger than the text)
                        if size*2 > textWidth then -- Size is a radius, so *2 for fitting text in it
                            -- and center text, if it's that big
                            -- Try to clamp it within the planet itself after clamping to screen
                            textX = uclamp(x,orbitMapX+textWidth/2,orbitMaxX-textWidth/2)
                            textY = uclamp(y,orbitMapY+textHeight,orbitMaxY-5)
                            textX = uclamp(textX, x-size+textWidth/2, x+size-textWidth/2)
                            textY = uclamp(textY, y-size+textHeight, y+size)
                        else
                            textX = x+xMod
                            textY = y
                        end
                        for tpi,d in pairs(data) do
                            local textPos = d.textPositions
                            local yDiff = textPos.y-textY
                            if tpi ~= i and mabs(yDiff) < textPos.height and textPos.x+textPos.width > textX and textPos.x < textX+textWidth then
                                if size > textWidth then
                                    textY = uclamp(textY+textHeight,orbitMapY+15,orbitMaxY-5) -- These clamped values are meant to be on top
                                else
                                    textY = textPos.y+textPos.height+1
                                end
                            end
                        end
                        local hovered = displayString ~= v.name or (textX <= orbitMidX and textX+textWidth >= orbitMidX and textY-textHeight <= orbitMidY and textY >= orbitMidY)
                        d.hovered = hovered
                        local opacityMult = 1
                        if hovered then
                            opacityMult=2
                            if size*2 < textWidth then opacityMult = 10 end -- If v small, make it v bright so you can see it
                            if displayString == v.name then -- If it's hovered and we don't have a distance in it yet, add one
                                displayString = displayString .. " - " .. distance
                            end
                            class = "pbright"
                            -- Sadly we need to redo the size here, I don't like that
                            -- But we need textX to be right to know if it's hovered
                            -- Then if it's hovered can change where textX is displayed
                            if v.systemId ~= 0 then
                                textWidth = ConvertResolutionX(string.len(displayString)*5)
                                xMod = -(15+textWidth)
                            else
                                textWidth = ConvertResolutionX(string.len(displayString)*7) -- When there are spaces, it's less long per char ... vs the *9 for just names
                            end
                            if size*2 > textWidth then -- Only clamp things that are large enough to matter (larger than the text)
                                textX = uclamp(x,orbitMapX+textWidth/2,orbitMaxX-textWidth/2)
                                textX = uclamp(textX, x-size+textWidth/2, x+size-textWidth/2) -- Center text if it can fit, no xMod
                            else
                                textX = x+xMod
                            end
                        end
    
                        data[i] = {}
                        data[i].textPositions = {} -- lua is very slow at inline declare so we do it outline
                        data[i].textPositions.y = textY
                        data[i].textPositions.x = textX
                        data[i].textPositions.width = textWidth
                        data[i].textPositions.height = textHeight
                        data[i].output = ""
    
                        if size*2 > textWidth then class = class .. " txtmid" else class = class .. " txtstart" end
                        
                        
                        if atmoSize-size > 2 then -- Only draw atmo if it's big enough to even show up
                            data[i].output = stringf('<circle cx="%f" cy="%f" r="%f" stroke-width="1" stroke="%s" stroke-opacity="%f" fill="url(#RadialAtmo)" />', -- fill-opacity="0.5"
                                                            x, y, atmoSize, rgbdim, 0.1*opacityMult)
                        end
    
                        data[i].output = data[i].output .. stringf('<circle cx="%f" cy="%f" r="%f" stroke="%s" stroke-width="1" stroke-opacity="%f" fill="url(#RadialPlanetCenter)" />',
                                                            x, y, size, rgbdim, 0.2*opacityMult)
                        
                         -- If it's centered text, don't bother with a line
                        if v.systemId == 0 then
                            data[i].output = data[i].output .. stringf([[<text x='%f' y='%f'
                                    font-size='12' fill='%s' class='%s' font-family='Montserrat'>%s</text>]]
                                    , textX, textY, rgb, class, displayString)
                            if size*2 <= textWidth then
                                data[i].output = data[i].output .. stringf("<path class='linethin dimstroke' d='M %f %f L %f %f L %f %f' />", 
                                                                        textX+textWidth, textY+2, textX, textY+2, x, y)
                            end
                        else
                            data[i].output = data[i].output .. stringf([[<text x='%f' y='%f'
                                    font-size='8' fill='%s' class='%s' font-family='Montserrat'>%s</text>]]
                                    , textX, textY, rgbdim, class, displayString)
                            if size*2 <= textWidth then
                                data[i].output = data[i].output .. stringf("<path class='linethin dimstroke' d='M %f %f L %f %f L %f %f' />", 
                                textX, textY+2, textX+textWidth, textY+2, x, y)
                            end
                        end
                        
                    end
    
                    -- draw everything.  Reverse order so furthest planets draw first
                    for k=#planetAtlas,1,-1 do
                        if data[k] then
                            newContent[#newContent+1] = data[k].output
                        end
                    end
    
                    if minCursorData ~= nil and scopeFOV < 90 and not minCursorData.hovered then
                        -- If zoomed in, draw a line and distance label between the center and the nearest thing on screen
                        -- The distance is the orbital height if they were to go to that point
                        -- which is really minCursorDistance with some math to extrapolate it back out to a dist
    
                        -- But I'm a bit lazy.  How about we extrapolate out a scale for pixels to real distance
                        -- size should make that really easy
                        local scalar = minCursorData.planet.atmosphereRadius/minCursorData.atmoSize
    
                        local projAlt = msqrt(minCursorDistance)*scalar
                        local display = getDistanceDisplayString(projAlt,1)
                        local textWidth = ConvertResolutionX(math.max(string.len(display)*7,string.len(minCursorData.planet.name)*7))
                        local textHeight = ConvertResolutionY(12)
    
                        local textX = uclamp(minCursorData.x + (orbitMidX - minCursorData.x)/2,orbitMapX+textWidth/2,orbitMaxX-textWidth/2)
                        local textY = uclamp(minCursorData.y + (orbitMidY - minCursorData.y)/2,orbitMapY+textHeight*2,orbitMaxY-5)
    
                        newContent[#newContent + 1] = stringf("<path class='linethin dimstroke' stroke='white' d='M %f %f L %f %f' />", 
                                minCursorData.x, minCursorData.y, orbitMidX, orbitMidY)
                        --newContent[#newContent + 1] = stringf("<path class='linethin dimstroke' stroke='white' d='M %f %f L %f %f' />", 
                        --        textX+textWidth/2+1, textY-textHeight/2, orbitMidX, orbitMidY)
                        newContent[#newContent + 1] = stringf([[<text x='%f' y='%f'
                                font-size='12' fill='%s' class='txtmid' font-family='Montserrat'>%s</text>]]
                                , textX, textY, "white", display)
                        if not minCursorData.visible then
                            newContent[#newContent + 1] = stringf([[<text x='%f' y='%f'
                                    font-size='12' fill='%s' class='txtmid' font-family='Montserrat'>%s</text>]]
                                    , textX, textY-textHeight, "white", minCursorData.planet.name)
                        end
                    end
                    
                    if velMag > 1 then
                        -- This does sorta work but, also draws retrograde and the arrow and also isn't scaled correctly 
                        --DrawPrograde(newContent, coreVelocity, velMag, orbitMidX, orbitMidY)
                        -- TODO: Rework DrawPrograde to be able to accept x,y values for the marker
                        local target = constructVelocity
                        local targetN = target:normalize()
                        local flatlen = target:project_on_plane(constructForward):len()
                        local horizontalRight = target:cross(constructForward):normalize()
                        local rollRad = math.acos(horizontalRight:dot(constructRight))
                        if rollRad ~= rollRad then rollRad = 0 end -- Again, idk how this could happen but it does
                        if horizontalRight:cross(constructRight):dot(constructForward) < 0 then rollRad = -rollRad end
                        local xAngle = math.sin(rollRad)*math.asin(flatlen/target:len())*constants.rad2deg
                        local yAngle = math.cos(rollRad)*math.asin(flatlen/target:len())*constants.rad2deg
                        
                        -- Fix quadrants
                        if targetN:dot(constructForward) < 0 then
                            -- If it's in top or bottom quadrant, ie yAngle is 90 or -90ish, do this...
                            
                            yAngle = 90*math.cos(rollRad) + (90*math.cos(rollRad) - yAngle)
                            xAngle = 90*math.sin(rollRad) + (90*math.sin(rollRad) - xAngle)
                        end
    
                        local x = orbitMidX + (xAngle/fov)*orbitMapHeight
                        local y = orbitMidY + (yAngle/fov)*orbitMapHeight
                        local dotSize = 14
                        local dotRadius = dotSize/2
                        -- TODO: stringf
                        local progradeDot = [[<circle
                            cx="]] .. x .. [["
                            cy="]] .. y .. [["
                            r="]] .. dotRadius/dotSize .. [["
                            style="fill:#d7fe00;stroke:none;fill-opacity:1"/>
                        <circle
                            cx="]] .. x .. [["
                            cy="]] .. y .. [["
                            r="]] .. dotRadius .. [["
                            style="stroke:#d7fe00;stroke-opacity:1;fill:none" />
                        <path
                            d="M ]] .. x-dotSize .. [[,]] .. y .. [[ h ]] .. dotRadius .. [["
                            style="stroke:#d7fe00;stroke-opacity:1" />
                        <path
                            d="M ]] .. x+dotRadius .. [[,]] .. y .. [[ h ]] .. dotRadius .. [["
                            style="stroke:#d7fe00;stroke-opacity:1" />
                        <path
                            d="M ]] .. x .. [[,]] .. y-dotSize .. [[ v ]] .. dotRadius .. [["
                            style="stroke:#d7fe00;stroke-opacity:1" />]]
                        newContent[#newContent + 1] = progradeDot
                    end
                    --Add a + to mark the center
                    newContent[#newContent+1] = stringf("<line class='linethin dimstroke' x1='%f' y1='%f' x2='%f' y2='%f' />", 
                                                                                orbitMidX, orbitMidY-10, orbitMidX, orbitMidY+10)
                    newContent[#newContent+1] = stringf("<line class='linethin dimstroke' x1='%f' y1='%f' x2='%f' y2='%f' />", 
                    orbitMidX-10, orbitMidY, orbitMidX+10, orbitMidY)
                    
                    newContent[#newContent + 1] = '</g>'
                else
                    return newContent
                end
            end
    
            local function getPipeDistance(origCenter, destCenter)  -- Many thanks to Tiramon for the idea and functionality.
                local pipeDistance
                local pipe = (destCenter - origCenter):normalize()
                local r = (worldPos -origCenter):dot(pipe) / pipe:dot(pipe)
                if r <= 0. then
                return (worldPos-origCenter):len()
                elseif r >= (destCenter - origCenter):len() then
                return (worldPos-destCenter):len()
                end
                local L = origCenter + (r * pipe)
                pipeDistance =  (L - worldPos):len()
                return pipeDistance
            end
    
            local function getClosestPipe() -- Many thanks to Tiramon for the idea and functionality, thanks to Dimencia for the assist
                local pipeDistance
                local nearestDistance = nil
                local nearestPipePlanet = nil
                local pipeOriginPlanet = nil
                for k,nextPlanet in pairs(atlas[0]) do
                    if nextPlanet.hasAtmosphere then -- Skip moons
                        local distance = getPipeDistance(planet.center, nextPlanet.center)
                        if nearestDistance == nil or distance < nearestDistance then
                            nearestPipePlanet = nextPlanet
                            nearestDistance = distance
                            pipeOriginPlanet = planet
                        end
                        if autopilotTargetPlanet and autopilotTargetPlanet.hasAtmosphere and autopilotTargetPlanet.name ~= planet.name then 
                            local distance2 = getPipeDistance(autopilotTargetPlanet.center, nextPlanet.center)
                            if distance2 < nearestDistance then
                                nearestPipePlanet = nextPlanet
                                nearestDistance = distance2
                                pipeOriginPlanet = autopilotTargetPlanet
                            end
                        end
                    end
                end 
                local pipeX = ConvertResolutionX(1770)
                local pipeY = ConvertResolutionY(330)
                if nearestDistance then
                    local txtadd = "txttick "
                    local fudge = 500000
                    if nearestDistance < nearestPipePlanet.radius+fudge or nearestDistance < pipeOriginPlanet.radius+fudge then 
                        if notPvPZone then txtadd = "txttick red " else txtadd = "txttick orange " end
                    end
                    pipeDistance = getDistanceDisplayString(nearestDistance,2)
                    pipeMessage = svgText(pipeX, pipeY, "Pipe ("..pipeOriginPlanet.name.."--"..nearestPipePlanet.name.."): "..pipeDistance, txtadd.."pbright txtmid") 
                end
            end
    
            local function MakeTabButton(x, y, width, height, label)
                local newButton = {
                    x = x, 
                    y = y,
                    width = width,
                    height = height,
                    label = label
                }
                TabButtons[label] = newButton
                return newButton
            end
    
            local function MakeButton(enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition, buttonList, class)
                local newButton = {
                    enableName = enableName,
                    disableName = disableName,
                    width = width,
                    height = height,
                    x = x,
                    y = y,
                    toggleVar = toggleVar,
                    toggleFunction = toggleFunction,
                    drawCondition = drawCondition,
                    hovered = false,
                    class = class
                }
                if buttonList then 
                    table.insert(SettingButtons, newButton)
                else
                    table.insert(ControlButtons, newButton)
                end
                return newButton -- readonly, I don't think it will be saved if we change these?  Maybe.
                
            end
    
            local function ToggleShownSettings(whichVar)
                if not showSettings then
                    showHandlingVariables = false
                    showHudVariables = false
                    showPhysicsVariables = false
                    showHud = true
                    return
                elseif whichVar == "handling" then
                    showHandlingVariables = not showHandlingVariables
                    showHudVariables = false
                    showPhysicsVariables = false
                elseif whichVar == "hud" then 
                    showHudVariables = not showHudVariables
                    showHandlingVariables = false
                    showPhysicsVariables = false
                elseif whichVar == "physics" then
                    showPhysicsVariables = not showPhysicsVariables
                    showHandlingVariables = false
                    showHudVariables = false
                end
                if showPhysicsVariables or showHudVariables or showHandlingVariables then 
                    settingsVariables = saveableVariables(whichVar)
                    showHud = false 
                else
                    settingsVariables = "none"
                    showHud = true
                end
            end
    
            local function ToggleButtons()
                showSettings = not showSettings 
                if showSettings then 
                    Buttons = SettingButtons
                    msgText = "Tap SHIFT to see Settings" 
                    oldShowHud = showHud
                else
                    Buttons = ControlButtons
                    msgText = "Tap SHIFT to see Control Buttons"
                    ToggleShownSettings()
                    showHud = oldShowHud
                end
            end
    
            local function SettingsButtons()
                local function ToggleBoolean(v,k)
    
                    v.set(not v.get())
                    if v.get() then 
                        msgText = k.." set to true"
                    else
                        msgText = k.." set to false"
                    end
                    if k == "showHud" then
                        oldShowHud = v.get()
                    elseif k == "BrakeToggleDefault" then 
                        BrakeToggleStatus = BrakeToggleDefault
                    end
                end
                local buttonHeight = 50
                local buttonWidth = 340 -- Defaults
                local x = 500
                local y = resolutionHeight / 2 - 400
                local cnt = 0
                for k, v in pairs(saveableVariables("boolean")) do
                    if type(v.get()) == "boolean" then
                        MakeButton(k, k, buttonWidth, buttonHeight, x, y,
                            function() return v.get() end, 
                            function() ToggleBoolean(v,k) end,
                            function() return true end, true) 
                        y = y + buttonHeight + 20
                        if cnt == 9 then 
                            x = x + buttonWidth + 20 
                            y = resolutionHeight / 2 - 400
                            cnt = 0
                        else
                            cnt = cnt + 1
                        end
                    end
                end
                MakeButton("Control View", "Control View", buttonWidth, buttonHeight, 10, resolutionHeight / 2 - 500, function() return true end, 
                    ToggleButtons, function() return true end, true)
                MakeButton("View Handling Settings", 'Hide Handling Settings', buttonWidth, buttonHeight, 10, resolutionHeight / 2 - (500 - buttonHeight), 
                    function() return showHandlingVariables end, function() ToggleShownSettings("handling") end, 
                    function() return true end, true)
                MakeButton("View Hud Settings", 'Hide Hud Settings', buttonWidth, buttonHeight, 10, resolutionHeight / 2 - (500 - buttonHeight*2), 
                    function() return showHudVariables end, function() ToggleShownSettings("hud") end, 
                    function() return true end, true)
                MakeButton("View Physics Settings", 'Hide Physics Settings', buttonWidth, buttonHeight, 10, resolutionHeight / 2 - (500 - buttonHeight*3), 
                    function() return showPhysicsVariables end, function() ToggleShownSettings("physics") end, 
                    function() return true end, true)
            end
            
            local function ControlsButtons()
                local function AddNewLocation()
                    -- Add a new location to SavedLocations
                    local position = worldPos
                    local name = planet.name .. ". " .. #SavedLocations
                    if RADAR then name = RADAR.GetClosestName(name) end
                    return ATLAS.AddNewLocation(name, position, false, true)
                end
                
                local function ToggleTurnBurn()
                    TurnBurn = not TurnBurn
                end
    
                local function gradeToggle(pro)
                    if pro == 1 then 
                        ProgradeIsOn = not ProgradeIsOn
                        RetrogradeIsOn = false
                    else
                        RetrogradeIsOn = not RetrogradeIsOn
                        ProgradeIsOn = false
                    end        
                    Autopilot = false
                    AltitudeHold = false
                    followMode = false
                    BrakeLanding = false
                    LockPitch = nil
                    Reentry = false
                    AutoTakeoff = false
                end
    
                local function UpdatePosition(heading, saveAGG)
                    ATLAS.UpdatePosition(nil, heading, saveAGG)
                end
                local function ClearCurrentPosition()
                    -- So AutopilotTargetIndex is special and not a real index.  We have to do this by hand.
                        ATLAS.ClearCurrentPosition()
                end
    
               
                local function getAPEnableName(index)
                    local checkRoute = AP.routeWP(true)
                    if checkRoute and #checkRoute > 0 then return "Engage Route: "..checkRoute[1] end
                    return "Engage Autopilot: " .. getAPName(index)
                end
    
                local function getAPDisableName(index)
                    local checkRoute = AP.routeWP(true)
                    if checkRoute and #checkRoute > 0 then return "Next Route Point: "..checkRoute[1] end
                    return "Disable Autopilot: " .. getAPName(index)
                end   
    
                local function ToggleFollowMode() -- Toggle Follow Mode on and off
                    if isRemote() == 1 then
                        followMode = not followMode
                        if followMode then
                            Autopilot = false
                            RetrogradeIsOn = false
                            ProgradeIsOn = false
                            AltitudeHold = false
                            Reentry = false
                            BrakeLanding = false
                            AutoTakeoff = false
                            OldGearExtended = GearExtended
                            GearExtended = false
                            Nav.control.retractLandingGears()
                            navCom:setTargetGroundAltitude(TargetHoverHeight)
                            play("folOn","F")
                        else
                            play("folOff","F")
                            BrakeIsOn = "Follow Off"
                            autoRoll = autoRollPreference
                            GearExtended = OldGearExtended
                            if GearExtended then
                                Nav.control.deployLandingGears()
                                navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                            end
                        end
                    else
                        msgText = "Follow Mode only works with Remote controller"
                        followMode = false
                    end
                end
            
                -- BEGIN BUTTON DEFINITIONS
            
                -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                
                local buttonHeight = 50
                local buttonWidth = 260 -- Defaults
                -- TODO: This should use defined orbitMapHeight and Width vars but to move them out they'd have to be unlocal cuz we're out of locals
                -- But we know that height is orbitMapSize*1.5, width is orbitMapSize*2
                local orbitButtonSize = ConvertResolutionX(30)
                local orbitButtonX = OrbitMapX+OrbitMapSize*2+2
                local orbitButtonY = OrbitMapY+1
                MakeButton("+", "+", orbitButtonSize, orbitButtonSize, orbitButtonX, orbitButtonY+orbitButtonSize+1,
                                    function() return false end, function() scopeFOV = scopeFOV/8 end, function() return SelectedTab == "SCOPE" end, nil, "ZoomButton")
                MakeButton("-", "-", orbitButtonSize, orbitButtonSize, orbitButtonX, orbitButtonY,
                                    function() return false end, function() scopeFOV = math.min(scopeFOV*8,90) end, function() return SelectedTab == "SCOPE" end, nil, "ZoomButton")
                MakeButton("0", "0", orbitButtonSize, orbitButtonSize, orbitButtonX, orbitButtonY+orbitButtonSize*2+2,
                                    function() return false end, function() scopeFOV = 90 end, function() return SelectedTab == "SCOPE" and scopeFOV ~= 90 end, nil, "ZoomButton")
                local brake = MakeButton("Enable Brake Toggle", "Disable Brake Toggle", buttonWidth, buttonHeight,
                                    resolutionWidth / 2 - buttonWidth / 2, resolutionHeight / 2 + 350, function()
                        return BrakeToggleStatus
                    end, function()
                        BrakeToggleStatus = not BrakeToggleStatus
                        if (BrakeToggleStatus) then
                            msgText = "Brakes in Toggle Mode"
                        else
                            msgText = "Brakes in Default Mode"
                        end
                    end)
                MakeButton("Align Prograde", "Disable Prograde", buttonWidth, buttonHeight,
                    resolutionWidth / 2 - buttonWidth / 2 - 50 - brake.width, resolutionHeight / 2 - buttonHeight + 380,
                    function()
                        return ProgradeIsOn
                    end, function() gradeToggle(1) end)
                MakeButton("Align Retrograde", "Disable Retrograde", buttonWidth, buttonHeight,
                    resolutionWidth / 2 - buttonWidth / 2 + brake.width + 50, resolutionHeight / 2 - buttonHeight + 380,
                    function()
                        return RetrogradeIsOn
                    end, gradeToggle, function()
                        return atmosDensity == 0
                    end) -- Hope this works
                apbutton = MakeButton(getAPEnableName, getAPDisableName, 600, 60, resolutionWidth / 2 - 600 / 2,
                                        resolutionHeight / 2 - 60 / 2 - 330, function()
                        return Autopilot or VectorToTarget or spaceLaunch or IntoOrbit
                    end, function() end) -- No toggle function because we draw over this with things that do toggle
                -- Make 9 more buttons that only show when moused over the AP button
                local i
                local function getAtlasIndexFromAddition(add)
                    local index = apScrollIndex + add
                    if index > #AtlasOrdered then
                        index = index-#AtlasOrdered-1
                    end
                    if index < 0 then
                        index = #AtlasOrdered+index
                    end
                    
                    return index
                end
                apExtraButtons = {}
                for i=0,10 do
                    local button = MakeButton(function(b)
                        local index = getAtlasIndexFromAddition(b.apExtraIndex)
                        if Autopilot or VectorToTarget or spaceLaunch or IntoOrbit then
                            return "Redirect: " .. getAPName(index)
                        end
                        return getAPEnableName(index)
                    end, function(b)
                        local index = getAtlasIndexFromAddition(b.apExtraIndex)
                        return getAPDisableName(index)
                    end, 600, 60, resolutionWidth/2 - 600/2, 
                    resolutionHeight/2 - 60/2 - 330 + 60*i, function(b)
                        local index = getAtlasIndexFromAddition(b.apExtraIndex)
                        return index == AutopilotTargetIndex and (Autopilot or VectorToTarget or spaceLaunch or IntoOrbit)
                    end, function(b)
                        local index = getAtlasIndexFromAddition(b.apExtraIndex)
                        local disable = AutopilotTargetIndex == index
                        AutopilotTargetIndex = index
                        ATLAS.UpdateAutopilotTarget()
                        AP.ToggleAutopilot()
                        -- Let buttons redirect AP, they're hard to do by accident
                        if not disable and not (Autopilot or VectorToTarget or spaceLaunch or IntoOrbit) then
                            AP.ToggleAutopilot()
                        end
                    end, function()
                        return apButtonsHovered and (#AP.routeWP(true) == 0 or i==0)
                    end)
                    button.apExtraIndex = i
                    apExtraButtons[i] = button
                end
    
    
                MakeButton("Save Position", "Save Position", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y,
                    function()
                        return false
                    end, AddNewLocation, function()
                        return AutopilotTargetIndex == 0 or CustomTarget == nil
                    end)
                MakeButton("Update Position", "Update Position", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y,
                    function() return false end, 
                    function() UpdatePosition(nil) end, 
                    function() return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                    end)
                MakeButton("Save Heading", "Clear Heading", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y + apbutton.height + 20,
                    function() return CustomTarget.heading ~= nil end, 
                    function() if CustomTarget.heading ~= nil then UpdatePosition(false) else UpdatePosition(true) end end, 
                    function() return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                    end)
                MakeButton("Save AGG Alt", "Clear AGG Alt", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y + apbutton.height*2 + 40,
                    function() return CustomTarget.agg ~= nil end, 
                    function() if CustomTarget.agg ~= nil then UpdatePosition(nil, false) else UpdatePosition(nil, true) end end, 
                    function() return AutopilotTargetIndex > 0 and CustomTarget ~= nil and antigrav
                    end)
                MakeButton("Clear Position", "Clear Position", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y,
                    function()
                        return true
                    end, ClearCurrentPosition, function()
                        return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                    end)
                MakeButton("Save Route", "Save Route", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y + apbutton.height*2 + 40, 
                    function() return false end, function() AP.routeWP(false, false, 2) end, function() return #AP.routeWP(true) > 0 end)
                MakeButton("Load Route","Clear Route", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y + apbutton.height + 20,
                    function()
                        return #AP.routeWP(true) > 0
                    end, function() if #AP.routeWP(true) > 0 then AP.routeWP(false, true) elseif  Autopilot or VectorToTarget then 
                        msgText = "Disable Autopilot before loading route" return else AP.routeWP(false, false, 1) end end, function() return true end)   
                -- The rest are sort of standardized
                buttonHeight = 60
                buttonWidth = 300
                local x = 0
                local y = resolutionHeight / 2 - 150
                MakeButton("Enable Check Damage", "Disable Check Damage", buttonWidth, buttonHeight, x, y - buttonHeight - 20, function()
                    return ShouldCheckDamage
                end, function() ShouldCheckDamage = not ShouldCheckDamage end)
                MakeButton("View Settings", "View Settings", buttonWidth, buttonHeight, x, y, function() return true end, ToggleButtons)
                y = y + buttonHeight + 20
                MakeButton("Enable Turn and Burn", "Disable Turn and Burn", buttonWidth, buttonHeight, x, y, function()
                    return TurnBurn
                end, ToggleTurnBurn)
                x = 10
                y = resolutionHeight / 2 - 300
                MakeButton("Horizontal Takeoff Mode", "Vertical Takeoff Mode", buttonWidth, buttonHeight, resolutionWidth/2-buttonWidth/2, y+20,
                    function() return VertTakeOffEngine end, 
                    function () 
                        VertTakeOffEngine = not VertTakeOffEngine 
                        if VertTakeOffEngine then 
                            msgText = "Vertical Takeoff Mode"
                        else
                            msgText = "Horizontal Takeoff Mode"
                        end
                    end, function() return UpVertAtmoEngine end)
                y = y + buttonHeight + 20    
                -- prevent this button from being an option until you're in atmosphere
                MakeButton("Engage Orbiting", "Cancel Orbiting", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                        function()
                            return IntoOrbit
                        end, AP.ToggleIntoOrbit, function()
                            return (atmosDensity == 0 and nearPlanet)
                        end)
                y = resolutionHeight / 2 - 150
                MakeButton("Glide Re-Entry", "Cancel Glide Re-Entry", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                    function() return Reentry end, function() spaceLand = 1 gradeToggle(1) end, function() return (planet.hasAtmosphere and not inAtmo) end )
                y = y + buttonHeight + 20
                MakeButton("Parachute Re-Entry", "Cancel Parachute Re-Entry", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                    function() return Reentry end, function() spaceLand = 2 gradeToggle(1) end, function() return (planet.hasAtmosphere and not inAtmo) end )
                y = y + buttonHeight + 20
                MakeButton("Engage Follow Mode", "Disable Follow Mode", buttonWidth, buttonHeight, x, y, function()
                    return followMode
                    end, ToggleFollowMode, function()
                        return isRemote() == 1
                    end)
                    MakeButton("Enable Repair Arrows", "Disable Repair Arrows", buttonWidth, buttonHeight, x + buttonWidth + 20, y, function()
                        return repairArrows
                    end, function()
                        repairArrows = not repairArrows
                        if (repairArrows) then
                            msgText = "Repair Arrows Enabled"
                        else
                            msgText = "Repair Arrows Diabled"
                        end
                    end, function()
                        return isRemote() == 1
                    end)
                y = y + buttonHeight + 20
                if not ExternalAGG then
                    MakeButton("Enable AGG", "Disable AGG", buttonWidth, buttonHeight, x, y, function()
                    return antigravOn end, AP.ToggleAntigrav, function()
                    return antigrav ~= nil end)
                end
                MakeButton(function() return stringf("Switch IPH Mode - Current: %s", iphCondition)
                end, function()
                    return stringf("IPH Mode: %s", iphCondition)
                end, buttonWidth * 2, buttonHeight, x, y, function()
                    return false
                end, function()
                    if iphCondition == "All" then
                        iphCondition = "Custom Only"
                    elseif iphCondition == "Custom Only" then
                        iphCondition = "No Moons"
                    else
                        iphCondition = "All"
                    end
                    msgText = "IPH Mode: "..iphCondition
                end)
                y = y + buttonHeight + 20
                MakeButton(function() return stringf("Toggle Control Scheme - Current: %s", userControlScheme)
                    end, function()
                        return stringf("Control Scheme: %s", userControlScheme)
                    end, buttonWidth * 2, buttonHeight, x, y, function()
                        return false
                    end, function()
                        if userControlScheme == "keyboard" then
                            userControlScheme = "mouse"
                        elseif userControlScheme == "mouse" then
                            userControlScheme = "virtual joystick"
                        else
                            userControlScheme = "keyboard"
                        end
                        msgText = "New Control Scheme: "..userControlScheme
                    end)
    
    
                -- Make tab buttons
                local tabHeight = ConvertResolutionY(20)
                local button = MakeTabButton(0, 0, ConvertResolutionX(70), tabHeight, "HELP")
                button = MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(80),tabHeight, "INFO")
                button = MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(70),tabHeight,"ORBIT")
                button = MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(70),tabHeight,"SCOPE")
                MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(70),tabHeight,"HIDE")
            end
    
    
        local Hud = {}
        local StaticPaths = nil
    
    
        function Hud.HUDPrologue(newContent)
            if not notPvPZone then -- misnamed variable, fix later
                PrimaryR = PvPR
                PrimaryG = PvPG
                PrimaryB = PvPB
            else
                PrimaryR = SafeR
                PrimaryG = SafeG
                PrimaryB = SafeB
            end
            rgb = [[rgb(]] .. mfloor(PrimaryR + 0.6) .. "," .. mfloor(PrimaryG + 0.6) .. "," .. mfloor(PrimaryB + 0.6) .. [[)]]
            rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.8 + 0.5) .. "," .. mfloor(PrimaryG * 0.8 + 0.5) .. "," ..   mfloor(PrimaryB * 0.8 + 0.5) .. [[)]]    
            local bright = rgb
            local dim = rgbdim
            local dimmer = [[rgb(]] .. mfloor(PrimaryR * 0.4 + 0.5) .. "," .. mfloor(PrimaryG * 0.4 + 0.5) .. "," ..   mfloor(PrimaryB * 0.4 + 0.5) .. [[)]]   
            local brightOrig = rgb
            local dimOrig = rgbdim
            local dimmerOrig = dimmer
            if IsInFreeLook() and not brightHud then
                bright = [[rgb(]] .. mfloor(PrimaryR * 0.5 + 0.5) .. "," .. mfloor(PrimaryG * 0.5 + 0.5) .. "," ..
                            mfloor(PrimaryB * 0.5 + 0.5) .. [[)]]
                dim = [[rgb(]] .. mfloor(PrimaryR * 0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," ..
                        mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]
                dimmer = [[rgb(]] .. mfloor(PrimaryR * 0.2 + 0.5) .. "," .. mfloor(PrimaryG * 0.2 + 0.5) .. "," ..   mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]                        
            end
    
            -- When applying styles, apply color first, then type (e.g. "bright line")
            -- so that "fill:none" gets applied
            local crx = ConvertResolutionX
            local cry = ConvertResolutionY
                newContent[#newContent + 1] = stringf([[ <head> <style>body{margin: 0}svg{position:absolute;top:0;left:0;font-family:Montserrat;}.txt{font-size:10px;font-weight:bold;}.txttick{font-size:12px;font-weight:bold;}.txtbig{font-size:14px;font-weight:bold;}.altsm{font-size:16px;font-weight:normal;}.altbig{font-size:21px;font-weight:normal;}.line{stroke-width:2px;fill:none;stroke:%s}.linethick{stroke-width:3px;fill:none}.linethin{stroke-width:1px;fill:none}.warnings{font-size:26px;fill:red;text-anchor:middle;font-family:Bank;}.warn{fill:orange; font-size:24px}.crit{fill:darkred;font-size:28px}.bright{fill:%s;stroke:%s}text.bright{stroke:black; stroke-width:10px;paint-order:stroke;}.pbright{fill:%s;stroke:%s}text.pbright{stroke:black; stroke-width:10px;paint-order:stroke;}.dim{fill:%s;stroke:%s}text.dim{stroke:black; stroke-width:10px;paint-order:stroke;}.pdim{fill:%s;stroke:%s}text.pdim{stroke:black; stroke-width:10px;paint-order:stroke;}.red{fill:red;stroke:red}text.red{stroke:black; stroke-width:10px;paint-order:stroke;}.orange{fill:orange;stroke:orange}text.orange{stroke:black; stroke-width:10px;paint-order:stroke;}.redout{fill:none;stroke:red}.op30{opacity:0.3}.op10{opacity:0.1}.txtstart{text-anchor:start}.txtend{text-anchor:end}.txtmid{text-anchor:middle}.txtvspd{font-family:sans-serif;font-weight:normal}.txtvspdval{font-size:20px}.txtfuel{font-size:11px;font-weight:bold}.txtorb{font-size:12px}.txtorbbig{font-size:18px}.hudver{font-size:10px;font-weight:bold;fill:red;text-anchor:end;font-family:Bank}.msg{font-size:40px;fill:red;text-anchor:middle;font-weight:normal}.cursor{stroke:white}text{stroke:black; stroke-width:10px;paint-order:stroke;}.dimstroke{stroke:%s}.brightstroke{stroke:%s}.indicatorText{font-size:20px;fill:white}.size14{font-size:14px}.size20{font-size:20px}.topButton{fill:%s;opacity:0.5;stroke-width:2;stroke:%s}.topButtonActive{fill:url(#RadialGradientCenter);opacity:0.8;stroke-width:2;stroke:%s}.topButton text{font-size:13px; fill: %s; opacity:1; stroke-width:20px}.topButtonActive text{font-size:13px;fill:%s; stroke-width:0px; opacity:1}.indicatorFont{font-size:20px;font-family:Bank}.dimmer{stroke: %s;}.pdimfill{fill: %s;}.dimfill{fill: %s;}</style> </head> <body> <svg height="100%%" width="100%%" viewBox="0 0 %d %d"> <defs> <radialGradient id="RadialGradientCenterTop" cx="0.5" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/> <stop offset="100%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="RadialGradientRightTop" cx="1" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="ThinRightTopGradient" cx="1" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.2"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="RadialGradientLeftTop" cx="0" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="ThinLeftTopGradient" cx="0" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.2"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="RadialGradientCenter" cx="0.5" cy="0.5" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.8"/> <stop offset="100%%" stop-color="%s" stop-opacity="0.5"/> </radialGradient> <radialGradient id="RadialPlanetCenter" cx="0.5" cy="0.5" r="0.5"> <stop offset="0%%" stop-color="%s" stop-opacity="1"/> <stop offset="100%%" stop-color="%s" stop-opacity="1"/> </radialGradient> <radialGradient id="RadialAtmo" cx="0.5" cy="0.5" r="0.5"> <stop offset="0%%" stop-color="%s" stop-opacity="1"/> <stop offset="66%%" stop-color="%s" stop-opacity="1"/> <stop offset="100%%" stop-color="%s" stop-opacity="0.1"/> </radialGradient> </defs> <g class="pdim txt txtend">]], bright, bright, bright, brightOrig, brightOrig, dim, dim, dimOrig, dimOrig,dim,bright,dimmer,dimOrig,bright,bright,dimmer,dimmer, dimmerOrig,dimmer, resolutionWidth, resolutionHeight, dim,dim,dim,dim,dim,brightOrig,dim,dimOrig, dimmerOrig, dimOrig, dimOrig, dimmerOrig)
    
            
            -- These never change, set and store it on startup because that's a lot of calculations that we don't want to do every frame
            if not StaticPaths then
                StaticPaths = stringf([[<path class="linethick brightstroke" style="fill:url(#RadialGradientCenterTop);" d="M %f %f L %f %f L %f %f %f %f L %f %f"/>
                <path class="linethick brightstroke" style="fill:url(#RadialGradientRightTop);" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>
                
                <path class="linethick brightstroke" style="fill:url(#RadialGradientLeftTop);" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>
                
                <clipPath id="headingClip">
                    <path class="linethick dimstroke" style="fill:black;fill-opacity:0.4;" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>
                </clipPath>
                <path class="linethick dimstroke" style="fill:black;fill-opacity:0.4;" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>]],
                crx(630), cry(0), crx(675), cry(45), crx(960), cry(55), crx(1245), cry(45), crx(1290), cry(0),
                crx(1000), cry(105), crx(1040), cry(59), crx(1250), cry(51), crx(1300), cry(0), crx(1920), cry(0), crx(1920), cry(20), crx(1400), cry(20), crx(1300), cry(105),
                crx(920), cry(105), crx(880), cry(59), crx(670), cry(51), crx(620), cry(0), crx(0), cry(0), crx(0), cry(20), crx(520), cry(20), crx(620), cry(105),
                crx(890), cry(59), crx(960), cry(62), crx(1030), cry(59), crx(985), cry (112), crx(1150), cry(112), crx(1100), cry(152), crx(820), cry(152), crx(780), cry(112), crx(935), cry(112),
                crx(890), cry(59), crx(960), cry(62), crx(1030), cry(59), crx(985), cry (112), crx(1150), cry(112), crx(1100), cry(152), crx(820), cry(152), crx(780), cry(112), crx(935), cry(112)
                )
            end
            if showHud and DisplayOdometer then 
                newContent[#newContent+1] = StaticPaths
            end
            return newContent
        end
    
        function Hud.DrawVerticalSpeed(newContent, altitude)
            DrawVerticalSpeed(newContent, altitude)
        end
    
        function Hud.UpdateHud(newContent)
            local pitch = adjustedPitch
            local roll = adjustedRoll
            local originalRoll = roll
            local originalPitch = pitch
            local throt = mfloor(u.getThrottle())
            local spd = velMag * 3.6
            local flightValue = u.getAxisCommandValue(0)
            local pvpBoundaryX = ConvertResolutionX(1770)
            local pvpBoundaryY = ConvertResolutionY(310)
            if AtmoSpeedAssist and throttleMode then
                flightValue = PlayerThrottle
                throt = PlayerThrottle*100
            end
    
            local flightStyle = GetFlightStyle()
            local bottomText = "ROLL"
            
            if throt == nil then throt = 0 end
    
            if (not nearPlanet) then
                if (velMag > 5) then
                    pitch = getRelativePitch(coreVelocity)
                    roll = getRelativeYaw(coreVelocity)
                else
                    pitch = 0
                    roll = 0
                end
                bottomText = "YAW"
            end
            
            if pvpDist > 50000 and not inAtmo then
                local dist
                dist = getDistanceDisplayString(pvpDist)
                newContent[#newContent + 1] = svgText(pvpBoundaryX, pvpBoundaryY, "PvP Boundary: "..dist, "pbright txtbig txtmid")
            end
    
            -- CRUISE/ODOMETER
    
            newContent[#newContent + 1] = lastOdometerOutput
    
            -- RADAR
    
            newContent[#newContent + 1] = radarMessage
    
            -- Pipe distance
    
            if pipeMessage ~= "" then newContent[#newContent +1] = pipeMessage end
    
    
            if tankMessage ~= "" then newContent[#newContent + 1] = tankMessage end
            if shieldMessage ~= "" then newContent[#newContent +1] = shieldMessage end
            -- PRIMARY FLIGHT INSTRUMENTS
    
            DrawVerticalSpeed(newContent, coreAltitude) -- Weird this is draw during remote control...?
    
    
            if isRemote() == 0 or RemoteHud then
                if not IsInFreeLook() or brightHud then
                    if nearPlanet then -- use real pitch, roll, and heading
                        DrawRollLines (newContent, centerX, centerY, originalRoll, bottomText, nearPlanet)
                        DrawArtificialHorizon(newContent, originalPitch, originalRoll, centerX, centerY, nearPlanet, mfloor(getRelativeYaw(coreVelocity)), velMag)
                    else -- use Relative Pitch and Relative Yaw
                        DrawRollLines (newContent, centerX, centerY, roll, bottomText, nearPlanet)
                        DrawArtificialHorizon(newContent, pitch, roll, centerX, centerY, nearPlanet, mfloor(roll), velMag)
                    end
                    DrawAltitudeDisplay(newContent, coreAltitude, nearPlanet)
                    DrawPrograde(newContent, coreVelocity, velMag, centerX, centerY)
                end
            end
    
            DrawThrottle(newContent, flightStyle, throt, flightValue)
    
            -- PRIMARY DATA DISPLAYS
    
            DrawSpeed(newContent, spd)
    
            DrawWarnings(newContent)
            DisplayOrbitScreen(newContent)
            if not showSettings and holdingShift then DisplayRoute(newContent) end
    
            return newContent
        end
    
        function Hud.HUDEpilogue(newContent)
            newContent[#newContent + 1] = "</svg>"
            return newContent
        end
    
        function Hud.ExtraData(newContent)
            local xg = ConvertResolutionX(1240)
            local yg1 = ConvertResolutionY(55)
            local yg2 = yg1+10
            local gravity 
            local crx = ConvertResolutionX
            local cry = ConvertResolutionY
    
            local brakeValue = 0
            local flightStyle = GetFlightStyle()
            if VertTakeOffEngine then flightStyle = flightStyle.."-VERTICAL" end
            if CollisionSystem and not AutoTakeoff and not BrakeLanding and velMag > 20 then flightStyle = flightStyle.."-COLLISION ON" end
            if UseExtra ~= "Off" then flightStyle = "("..UseExtra..")-"..flightStyle end
            if TurnBurn then flightStyle = "TB-"..flightStyle end
            if not stablized then flightStyle = flightStyle.."-DeCoupled" end
    
            local labelY1 = cry(99)
            local labelY2 = cry(80)
            local lineY = cry(85)
            local lineY2 = cry(31)
            local maxMass = 0
            local reqThrust = 0
    
            local mass = coreMass > 1000000 and round(coreMass / 1000000,2).."kT" or round(coreMass / 1000, 2).."T"
            if inAtmo then brakeValue = LastMaxBrakeInAtmo else brakeValue = LastMaxBrake end
            local brkDist, brkTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, brakeValue)
            if brkDist < 0 then brkDist = 0 end
            brakeValue = round((brakeValue / (coreMass * gravConstant)),2).."g"
            local maxThrust = Nav:maxForceForward()
            gravity = c.getGravityIntensity()
            if gravity > 0.1 then
                reqThrust = coreMass * gravity
                reqThrust = round((reqThrust / (coreMass * gravConstant)),2).."g"
                maxMass = 0.5 * maxThrust / gravity
                maxMass = maxMass > 1000000 and round(maxMass / 1000000,2).."kT" or round(maxMass / 1000, 2).."T"
            end
            maxThrust = round((maxThrust / (coreMass * gravConstant)),2).."g"
    
            local accel = (vec3(C.getWorldAcceleration()):len() / 9.80665)
            gravity =  c.getGravityIntensity()
            newContent[#newContent + 1] = [[<g class="dim txt txtend size14">]]
            if isRemote() == 1 and not RemoteHud then
                xg = ConvertResolutionX(1120)
                yg1 = ConvertResolutionY(55)
                yg2 = yg1+10
            elseif inAtmo and DisplayOdometer then -- We only show atmo when not remote
                local atX = ConvertResolutionX(770)
                newContent[#newContent + 1] = svgText(crx(895), labelY1, "ATMO", "")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke"  d="M %f %f l %f 0"/>]],crx(895),lineY,crx(-80))
                newContent[#newContent + 1] = svgText(crx(815), labelY2, stringf("%.1f%%", atmosDensity*100), "txtstart size20")
            end
            if DisplayOdometer then 
                newContent[#newContent + 1] = svgText(crx(1025), labelY1, "GRAVITY", "txtstart")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(1025), lineY, crx(80))
                newContent[#newContent + 1] = svgText(crx(1105), labelY2, stringf("%.2fg", (gravity / 9.80665)), "size20")
        
                newContent[#newContent + 1] = svgText(crx(1125), labelY1, "ACCEL", "txtstart")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(1125), lineY, crx(80))
                newContent[#newContent + 1] = svgText(crx(1205), labelY2, stringf("%.2fg", accel), "size20") 
        
                newContent[#newContent + 1] = svgText(crx(695), labelY1, "BRK TIME", "")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(695),lineY, crx(-80))
                newContent[#newContent + 1] = svgText(crx(615), labelY2, stringf("%s", FormatTimeString(brkTime)), "txtstart size20") 
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(10), stringf("BrkTime: %s", FormatTimeString(brkTime)), "txtstart")
                newContent[#newContent + 1] = svgText(crx(635), cry(45), "TRIP", "")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(635),cry(31),crx(-90))
                if travelTime then
                    newContent[#newContent + 1] = svgText(crx(545), cry(26), stringf("%s", FormatTimeString(travelTime)), "txtstart size20")  
                end
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(20), stringf("Trip: %.2f km", totalDistanceTrip), "txtstart") 
                --TODO: newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(30), stringf("Lifetime: %.2f kSU", (TotalDistanceTravelled / 200000)), "txtstart") 
                newContent[#newContent + 1] = svgText(crx(795), labelY1, "BRK DIST", "")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(795),lineY, crx(-80))
                newContent[#newContent + 1] = svgText(crx(715), labelY2, stringf("%s", getDistanceDisplayString(brkDist)), "txtstart size20") 
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(10), stringf("BrkDist: %s", getDistanceDisplayString(brkDist)) , "txtstart")
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(20), "Trip Time: "..FormatTimeString(flightTime), "txtstart") 
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(30), "Total Time: "..FormatTimeString(TotalFlightTime), "txtstart") 
                newContent[#newContent + 1] = svgText(crx(1285), cry(45), "MASS", "txtstart")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(1285), cry(31), crx(90))
                newContent[#newContent + 1] = svgText(crx(1375), cry(26), stringf("%s", mass), "size20") 
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(20), stringf("Mass: %s", mass), "txtstart") 
                --newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(10), stringf("Max Brake: %s",  brakeValue), "txtend") 
                newContent[#newContent + 1] = svgText(crx(1220), labelY1, "THRUST", "txtstart")
                newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]], crx(1220), lineY, crx(80))
                newContent[#newContent + 1] = svgText(crx(1300), labelY2, stringf("%s", maxThrust), "size20") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(175), flightStyle, "pbright txtbig txtmid size20")
            end
            newContent[#newContent + 1] = "</g>"
        end
        
        local mod = 1 - (ContainerOptimization*0.05+FuelTankOptimization*0.05)
        function Hud.FuelUsed(fuelType)
            local used
            if fuelType == "atmofueltank" then 
                used = stringf("Atmo Fuel Used: %.1f L", fuelUsed[fuelType]/(4*mod))
            elseif fuelType == "spacefueltank" then
                used = stringf("Space Fuel Used: %.1f L", fuelUsed[fuelType]/(6*mod))
            else
                used = stringf("Rocket Fuel Used: %.1f L", fuelUsed[fuelType]/(0.8*mod))
            end
            return used
        end
        local fps, fpsAvg, fpsCount, fpsAvgTotal, fpsTotal = 0,0,0,{},0
        function Hud.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
            if SelectedTab ~= "INFO" then return newContent end
            local gravity 
            local maxMass = 0
            local reqThrust = 0
            local brakeValue = 0
            local mass = coreMass > 1000000 and round(coreMass / 1000000,2).." kTons" or round(coreMass / 1000, 2).." Tons"
            if inAtmo then brakeValue = LastMaxBrakeInAtmo else brakeValue = LastMaxBrake end
            local brkDist, brkTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, brakeValue)
            brakeValue = round((brakeValue / (coreMass * gravConstant)),2).." g"
            local maxThrust = Nav:maxForceForward()
            gravity = c.getGravityIntensity()
            if gravity > 0.1 then
                reqThrust = coreMass * gravity
                reqThrust = round((reqThrust / (coreMass * gravConstant)),2).." g"
                maxMass = 0.5 * maxThrust / gravity
                maxMass = maxMass > 1000000 and round(maxMass / 1000000,2).." kTons" or round(maxMass / 1000, 2).." Tons"
            end
            maxThrust = round((maxThrust / (coreMass * gravConstant)),2).." g"
            if isRemote() == 0 or RemoteHud then 
                local startX = ConvertResolutionX(OrbitMapX+10)
                local startY = ConvertResolutionY(OrbitMapY+20)
                local midX = ConvertResolutionX(OrbitMapX+10+OrbitMapSize/1.25)
                local height = 25
                local hudrate = mfloor(1/hudTickRate)
                if fpsCount < hudrate then
                    fpsTotal = fpsTotal + s.getActionUpdateDeltaTime()
                    fpsCount = fpsCount + 1
                else
                    fps = 1/(fpsTotal / hudrate)
                    table.insert(fpsAvgTotal, fps)
                    fpsCount, fpsTotal = 0, 0
                end
                fpsAvg = 0
                for k,v in pairs(fpsAvgTotal) do
                    fpsAvg = fpsAvg + v
                end
                if #fpsAvgTotal> 0 then fpsAvg = mfloor(fpsAvg/#fpsAvgTotal) end
                if #fpsAvgTotal > 29 then
                    table.remove(fpsAvgTotal,1)
                end
                newContent[#newContent + 1] = "<g class='txtstart size14 bright'>"
                newContent[#newContent + 1] = svgText(startX, startY, stringf("BrkTime: %s", FormatTimeString(brkTime)))
                newContent[#newContent + 1] = svgText(midX, startY, stringf("Trip: %.2f km", totalDistanceTrip)) 
                newContent[#newContent + 1] = svgText(startX, startY+height, stringf("Lifetime: %.2f kSU", (TotalDistanceTravelled / 200000))) 
                newContent[#newContent + 1] = svgText(midX, startY+ height, stringf("BrkDist: %s", getDistanceDisplayString(brkDist)))
                newContent[#newContent + 1] = svgText(startX, startY+height*2, "Trip Time: "..FormatTimeString(flightTime)) 
                newContent[#newContent + 1] = svgText(midX, startY+height*2, "Total Time: "..FormatTimeString(TotalFlightTime)) 
                newContent[#newContent + 1] = svgText(startX, startY+height*3, stringf("Mass: %s", mass)) 
                newContent[#newContent + 1] = svgText(midX, startY+height*3, stringf("Max Brake: %s",  brakeValue)) 
                newContent[#newContent + 1] = svgText(startX, startY+height*4, stringf("Max Thrust: %s", maxThrust)) 
                if gravity > 0.1 then
                    newContent[#newContent + 1] = svgText(midX, startY+height*4, stringf("Max Thrust Mass: %s", (maxMass)))
                    newContent[#newContent + 1] = svgText(startX, startY+height*5, stringf("Req Thrust: %s", reqThrust )) 
                else
                    newContent[#newContent + 1] = svgText(midX, startY+height*4, "Max Mass: n/a") 
                    newContent[#newContent + 1] = svgText(startX, startY+height*5, "Req Thrust: n/a") 
                end
    
                newContent[#newContent + 1] = svgText(midX, startY+height*5, HUD.FuelUsed("atmofueltank"))
                newContent[#newContent + 1] = svgText(startX, startY+height*6, HUD.FuelUsed("spacefueltank"))
                newContent[#newContent + 1] = svgText(midX, startY+height*6, HUD.FuelUsed("rocketfueltank"))
                newContent[#newContent +1] = svgText(startX, startY+height*7, stringf("Set Max Speed: %s", mfloor(MaxGameVelocity*3.6+0.5)))
                newContent[#newContent +1] = svgText(midX, startY+height*7, stringf("Actual Max Speed: %s", mfloor(MaxSpeed*3.6+0.5)))
                newContent[#newContent +1] = svgText(startX, startY+height*8, stringf("Friction Burn Speed: %s", mfloor(C.getFrictionBurnSpeed()*3.6)))
                newContent[#newContent +1] = svgText(midX, startY+height*8, stringf("FPS (Avg): %s (%s)", mfloor(fps),fpsAvg))
            end
            newContent[#newContent + 1] = "</g></g>"
            return newContent
        end
    
        function Hud.DrawWarnings(newContent)
            return DrawWarnings(newContent)
        end
    
        function Hud.DisplayOrbitScreen(newContent)
            return DisplayOrbitScreen(newContent)
        end
    
        function Hud.DisplayMessage(newContent, displayText)
            if displayText ~= "empty" then
                local y = 310
                for str in string.gmatch(displayText, "([^\n]+)") do
                    y = y + 35
                    newContent[#newContent + 1] = svgText("50%", y, str, "msg")
                end
            end
            if msgTimer ~= 0 then
                u.setTimer("msgTick", msgTimer)
                msgTimer = 0
            end
        end
    
        function Hud.DrawDeadZone(newContent)
            newContent[#newContent + 1] = stringf(
                                            [[<circle class="dim line" style="fill:none" cx="50%%" cy="50%%" r="%d"/>]],
                                            DeadZone)
        end
    
        function Hud.UpdatePipe() -- Many thanks to Tiramon for the idea and math part of the code.
            if inAtmo then 
                pipeMessage = "" 
                return 
            end
            getClosestPipe()           
        end
    
        function Hud.DrawSettings(newContent)
            local x = ConvertResolutionX(640)
            local y = ConvertResolutionY(200)
            newContent[#newContent + 1] = [[<g class="pbright txtvspd txtstart">]]
            local count=0
            for k, v in pairs(settingsVariables) do
                count=count+1
                newContent[#newContent + 1] = svgText(x, y, k..": "..v.get())
                y = y + 20
                if count%12 == 0 then
                    x = x + ConvertResolutionX(350)
                    y = ConvertResolutionY(200)
                end
            end
            newContent[#newContent + 1] = svgText(ConvertResolutionX(640), ConvertResolutionY(200)+260, "To Change: In Lua Chat, enter /G VariableName Value")
            newContent[#newContent + 1] = "</g>"
            return newContent
        end
    
            -- DrawRadarInfo() variables
    
            local friendy = ConvertResolutionY(125)
            local friendx = ConvertResolutionX(1225)
    
        function Hud.DrawRadarInfo()
            radarMessage = RADAR.GetRadarHud(friendx, friendy, radarX, radarY) 
        end
    
        function Hud.DrawTanks()
            -- FUEL TANKS
            if (fuelX ~= 0 and fuelY ~= 0) then
                tankMessage = svgText(fuelX, fuelY, "", "txtstart pdim txtfuel")
                tankY = fuelY
                DrawTank( fuelX, "Atmospheric ", "ATMO", atmoTanks, fuelTimeLeft, fuelPercent)
                DrawTank( fuelX, "Space Fuel T", "SPACE", spaceTanks, fuelTimeLeftS, fuelPercentS)
                DrawTank( fuelX, "Rocket Fuel ", "ROCKET", rocketTanks, fuelTimeLeftR, fuelPercentR)
            end
    
        end
    
        function Hud.DrawShield()
            local shieldState = (shield.isActive() == 1) and "Shield Active" or "Shield Disabled"
            local pvpTime = C.getPvPTimer()
            local resistances = shield.getResistances()
            local resistString = "A: "..(10+resistances[1]*100).."% / E: "..(10+resistances[2]*100).."% / K:"..(10+resistances[3]*100).."% / T: "..(10+resistances[4]*100).."%"
            local x, y = shieldX -60, shieldY+30
            local colorMod = mfloor(shieldPercent * 2.55)
            local color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
            local class = ""
            shieldMessage = svgText(x, y, "", "txtmid pdim txtfuel")
            if shieldPercent < 10 and shieldState ~= "Shield Disabled" then
                class = "red "
            end
            pvpTime = pvpTime > 0 and "   PvPTime: "..FormatTimeString(pvpTime) or ""
            shieldMessage = shieldMessage..stringf([[
                <g class="pdim">                        
                <rect fill=grey class="bar" x="%d" y="%d" width="200" height="13"></rect></g>
                <g class="bar txtstart">
                <rect fill=%s width="%d" height="13" x="%d" y="%d"></rect>
                <text fill=black x="%d" y="%d">%s%%%s</text>
                </g>]], x, y, color, shieldPercent*2, x, y, x+2, y+10, shieldPercent, pvpTime)
            shieldMessage = shieldMessage..svgText(x, y-5, shieldState, class.."txtstart pbright txtbig") 
            shieldMessage = shieldMessage..svgText(x,y+30, resistString, class.."txtstart pbright txtsmall")
        end
    
        function Hud.hudtick()
            if not planet then return end -- Avoid errors if APTick hasn't initialized before this is called
    
            -- Local Functions for hudTick
                local function DrawCursorLine(newContent)
                    local strokeColor = mfloor(uclamp((mouseDistance / (resolutionWidth / 4)) * 255, 0, 255))
                    newContent[#newContent + 1] = stringf(
                                                    "<line x1='0' y1='0' x2='%fpx' y2='%fpx' style='stroke:rgb(%d,%d,%d);stroke-width:2;transform:translate(50%%, 50%%)' />",
                                                    simulatedX, simulatedY, mfloor(PrimaryR + 0.5) + strokeColor,
                                                    mfloor(PrimaryG + 0.5) - strokeColor, mfloor(PrimaryB + 0.5) - strokeColor)
                end
                local function CheckButtons()
                    if leftmouseclick then
                        for _, v in pairs(Buttons) do
                            if v.hovered then
                                if not v.drawCondition or v.drawCondition(v) then
                                    v.toggleFunction(v)
                                end
                                v.hovered = false
                            end
                        end
                        for _, v in pairs(TabButtons) do
                            if v.hovered then
                                SelectedTab = v.label
                                v.hovered = false
                            end
                        end
                        leftmouseclick = false
                    end
                end    
                local function SetButtonContains()
    
                    local function Contains(mousex, mousey, x, y, width, height)
                        if mousex >= x and mousex <= (x + width) and mousey >= y and mousey <= (y + height) then
                            return true
                        else
                            return false
                        end
                    end
                    local x = simulatedX + resolutionWidth / 2
                    local y = simulatedY + resolutionHeight / 2
                    for _, v in pairs(Buttons) do
                        -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                        v.hovered = Contains(x, y, v.x, v.y, v.width, v.height)
                    end
                    for _, v in pairs(TabButtons) do
                        -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                        v.hovered = Contains(x, y, v.x, v.y, v.width, v.height)
                    end
                    if apButtonsHovered then -- Keep it hovered if any buttons are hovered
                        local hovered = false
                        for _,b in ipairs(apExtraButtons) do
                            if b.hovered then hovered = true break end
                        end
                        if apbutton.hovered then hovered = true end
                        apButtonsHovered = hovered
                    else
                        apButtonsHovered = apbutton.hovered
                        if not apButtonsHovered then
                            apScrollIndex = AutopilotTargetIndex -- Reset when no longer hovering
                        end
                    end
                    
                end
                local function DrawTabButtons(newContent)
                    if not SelectedTab or SelectedTab == "" then
                        SelectedTab = "HELP"
                    end
                    if showHud then 
                        for k,v in pairs(TabButtons) do
                            local class = "dim brightstroke"
                            local opacity = 0.2
                            if SelectedTab == k then
                                class = "pbright dimstroke"
                                opacity = 0.6
                            end
                            local extraStyle = ""
                            if v.hovered then
                                opacity = 0.8
                                extraStyle = ";stroke:white"
                            end
                            newContent[#newContent + 1] = stringf(
                                                                [[<rect width="%f" height="%d" x="%d" y="%d" clip-path="url(#round-corner)" class="%s" style="stroke-width:1;fill-opacity:%f;%s" />]],
                                                                v.width, v.height, v.x,v.y, class, opacity, extraStyle)
                            newContent[#newContent + 1] = svgText(v.x+v.width/2, v.y + v.height/2 + 5, v.label, "txt txtmid pdim")
                        end
                    end
                end
                local function DrawButtons(newContent)
    
                    local function DrawButton(newContent, toggle, hover, x, y, w, h, activeColor, inactiveColor, activeText, inactiveText, button)
                        if type(activeText) == "function" then
                            activeText = activeText(button)
                        end
                        if type(inactiveText) == "function" then
                            inactiveText = inactiveText(button)
                        end
                        newContent[#newContent + 1] = stringf("<rect x='%f' y='%f' width='%f' height='%f' fill='", x, y, w, h)
                        if toggle then
                            newContent[#newContent + 1] = stringf("%s'", activeColor)
                        else
                            newContent[#newContent + 1] = inactiveColor
                        end
                        if hover then
                            newContent[#newContent + 1] = stringf(" style='stroke:rgb(%d,%d,%d); stroke-width:2'",SafeR, SafeG, SafeB)
                        else
                            newContent[#newContent + 1] = stringf(" style='stroke:rgb(%d,%d,%d); stroke-width:1'",round(SafeR*0.5,0),round(SafeG*0.5,0),round(SafeB*0.5,0))
                        end
                        newContent[#newContent + 1] = " rx='5'></rect>"
                        newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='24' fill='", x + w / 2,
                                                        y + (h / 2) + 5)
                        if toggle then
                            newContent[#newContent + 1] = "black"
                        else
                            newContent[#newContent + 1] = "white"
                        end
                        newContent[#newContent + 1] = "' text-anchor='middle' font-family='Play' style='stroke-width:0px;'>"
                        if toggle then
                            newContent[#newContent + 1] = stringf("%s</text>", activeText)
                        else
                            newContent[#newContent + 1] = stringf("%s</text>", inactiveText)
                        end
                    end    
                    local defaultColor = stringf("rgb(%d,%d,%d)'",round(SafeR*0.1,0),round(SafeG*0.1,0),round(SafeB*0.1,0))
                    local onColor = stringf("rgb(%d,%d,%d)",round(SafeR*0.8,0),round(SafeG*0.8,0),round(SafeB*0.8,0))
                    local draw = DrawButton
                    for _, v in pairs(Buttons) do
                        -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                        local disableName = v.disableName
                        local enableName = v.enableName
                        if type(disableName) == "function" then
                            disableName = disableName(v)
                        end
                        if type(enableName) == "function" then
                            enableName = enableName(v)
                        end
                        if not v.drawCondition or v.drawCondition(v) then -- If they gave us a nil condition
                            draw(newContent, v.toggleVar(v), v.hovered, v.x, v.y, v.width, v.height, onColor, defaultColor,
                                disableName, enableName, v)
                        end
                    end
                end
                local halfResolutionX = round(resolutionWidth / 2,0)
                local halfResolutionY = round(resolutionHeight / 2,0)
            local newContent = {}
            if userScreen then newContent[#newContent + 1] = userScreen end
            --local t0 = s.getArkTime()
            HUD.HUDPrologue(newContent)
            if showHud then
                --local t0 = s.getArkTime()
                HUD.UpdateHud(newContent) -- sets up Content for us
                --_logCompute.addValue(s.getArkTime() - t0)
            else
                if AlwaysVSpd then HUD.DrawVerticalSpeed(newContent, coreAltitude) end
                HUD.DrawWarnings(newContent)
            end
            if showSettings and settingsVariables ~= "none" then  
                HUD.DrawSettings(newContent) 
            end
    
            if RADAR then HUD.DrawRadarInfo() else radarMessage = "" end
            HUD.HUDEpilogue(newContent)
            newContent[#newContent + 1] = stringf(
                [[<svg width="100%%" height="100%%" style="position:absolute;top:0;left:0"  viewBox="0 0 %d %d">]],
                resolutionWidth, resolutionHeight)   
            if msgText ~= "empty" then
                HUD.DisplayMessage(newContent, msgText)
            end
            if isRemote() == 0 and userControlScheme == "virtual joystick" then
                if DisplayDeadZone then HUD.DrawDeadZone(newContent) end
            end
    
            DrawTabButtons(newContent)
            if sysIsVwLock() == 0 then
                if isRemote() == 1 and holdingShift then
                    if not AltIsOn then
                        SetButtonContains()
                        DrawButtons(newContent)
                    end
                    -- If they're remote, it's kinda weird to be 'looking' everywhere while you use the mouse
                    -- We need to add a body with a background color
                    if not Animating and not Animated then
                        local collapsedContent = table.concat(newContent, "")
                        newContent = {}
                        newContent[#newContent + 1] = stringf("<style>@keyframes test { from { opacity: 0; } to { opacity: 1; } }  body { animation-name: test; animation-duration: 0.5s; }</style><body><svg width='100%%' height='100%%' position='absolute' top='0' left='0'><rect width='100%%' height='100%%' x='0' y='0' position='absolute' style='fill:rgb(6,5,26);'/></svg><svg width='50%%' height='50%%' style='position:absolute;top:30%%;left:25%%' viewbox='0 0 %d %d'>", resolutionWidth, resolutionHeight)
                        newContent[#newContent + 1] = collapsedContent
                        newContent[#newContent + 1] = "</body>"
                        Animating = true
                        newContent[#newContent + 1] = [[</svg></body>]] -- Uh what.. okay...
                        u.setTimer("animateTick", 0.5)
                    elseif Animated then
                        local collapsedContent = table.concat(newContent, "")
                        newContent = {}
                        newContent[#newContent + 1] = stringf("<body style='background-color:rgb(6,5,26)'><svg width='50%%' height='50%%' style='position:absolute;top:30%%;left:25%%' viewbox='0 0 %d %d'>", resolutionWidth, resolutionHeight)
                        newContent[#newContent + 1] = collapsedContent
                        newContent[#newContent + 1] = "</body>"
                    end
    
                    if not Animating then
                        newContent[#newContent + 1] = stringf(
                                                        [[<g transform="translate(%d %d)"><circle class="cursor" cx="%fpx" cy="%fpx" r="5"/></g>]],
                                                        halfResolutionX, halfResolutionY, simulatedX, simulatedY)
                    end
                else
                    CheckButtons()
                end
            else
                if not holdingShift and isRemote() == 0 then -- Draw deadzone circle if it's navigating
                    CheckButtons()
                    if mouseDistance > DeadZone then -- Draw a line to the cursor from the screen center
                        -- Note that because SVG lines fucking suck, we have to do a translate and they can't use calc in their params
                        if DisplayDeadZone then DrawCursorLine(newContent) end
                    end
                elseif holdingShift and (not AltIsOn or not freeLookToggle) then
                    SetButtonContains()
                    DrawButtons(newContent)
                end
                -- Cursor always on top, draw it last
                newContent[#newContent + 1] = stringf(
                                                [[<g transform="translate(%d %d)"><circle class="cursor" cx="%fpx" cy="%fpx" r="5"/></g>]],
                                                halfResolutionX, halfResolutionY, simulatedX, simulatedY)
            end
            newContent[#newContent + 1] = [[</svg></body>]]
            content = table.concat(newContent, "")
        end
    
        function Hud.TenthTick()
            -- Local Functions for tenthSecond
                local function SetupInterplanetaryPanel() -- Interplanetary helper
                    local sysCrData = s.createData
                    local sysCrWid = s.createWidget
                    panelInterplanetary = s.createWidgetPanel("Interplanetary Helper")
                
                    interplanetaryHeader = sysCrWid(panelInterplanetary, "value")
                    interplanetaryHeaderText = sysCrData('{"label": "Target Planet", "value": "N/A", "unit":""}')
                    sysAddData(interplanetaryHeaderText, interplanetaryHeader)
                
                    widgetDistance = sysCrWid(panelInterplanetary, "value")
                    widgetDistanceText = sysCrData('{"label": "distance", "value": "N/A", "unit":""}')
                    sysAddData(widgetDistanceText, widgetDistance)
                
                    widgetTravelTime = sysCrWid(panelInterplanetary, "value")
                    widgetTravelTimeText = sysCrData('{"label": "Travel Time", "value": "N/A", "unit":""}')
                    sysAddData(widgetTravelTimeText, widgetTravelTime)
                
                    widgetMaxMass = sysCrWid(panelInterplanetary, "value")
                    widgetMaxMassText = sysCrData('{"label": "Maximum Mass", "value": "N/A", "unit":""}')
                    sysAddData(widgetMaxMassText, widgetMaxMass)
                
                    widgetTargetOrbit = sysCrWid(panelInterplanetary, "value")
                    widgetTargetOrbitText = sysCrData('{"label": "Target Altitude", "value": "N/A", "unit":""}')
                    sysAddData(widgetTargetOrbitText, widgetTargetOrbit)
                
                    widgetCurBrakeDistance = sysCrWid(panelInterplanetary, "value")
                    widgetCurBrakeDistanceText = sysCrData('{"label": "Cur Brake distance", "value": "N/A", "unit":""}')
                    widgetCurBrakeTime = sysCrWid(panelInterplanetary, "value")
                    widgetCurBrakeTimeText = sysCrData('{"label": "Cur Brake Time", "value": "N/A", "unit":""}')
                    widgetMaxBrakeDistance = sysCrWid(panelInterplanetary, "value")
                    widgetMaxBrakeDistanceText = sysCrData('{"label": "Max Brake distance", "value": "N/A", "unit":""}')
                    widgetMaxBrakeTime = sysCrWid(panelInterplanetary, "value")
                    widgetMaxBrakeTimeText = sysCrData('{"label": "Max Brake Time", "value": "N/A", "unit":""}')
                    widgetTrajectoryAltitude = sysCrWid(panelInterplanetary, "value")
                    widgetTrajectoryAltitudeText = sysCrData('{"label": "Projected Altitude", "value": "N/A", "unit":""}')
                    if not inAtmo then
                        sysAddData(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
                        sysAddData(widgetCurBrakeTimeText, widgetCurBrakeTime)
                        sysAddData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
                        sysAddData(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
                        sysAddData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
                    end
                end                    
                local function HideInterplanetaryPanel()
                    sysDestWid(panelInterplanetary)
                    panelInterplanetary = nil
                end 
    
            HUD.DrawTanks()
            if shield then HUD.DrawShield() end
            if AutopilotTargetName ~= "None" then
                if panelInterplanetary == nil then
                    SetupInterplanetaryPanel()
                end
                if AutopilotTargetName ~= nil then
                    local targetDistance
                    local customLocation = CustomTarget ~= nil
                    local planetMaxMass = 0.5 * LastMaxBrakeInAtmo /
                        (autopilotTargetPlanet:getGravity(
                        autopilotTargetPlanet.center + (vec3(0, 0, 1) * autopilotTargetPlanet.radius))
                        :len())
                    planetMaxMass = planetMaxMass > 1000000 and round(planetMaxMass / 1000000,2).." kTons" or round(planetMaxMass / 1000, 2).." Tons"
                    sysUpData(interplanetaryHeaderText,
                        '{"label": "Target", "value": "' .. AutopilotTargetName .. '", "unit":""}')
                    if customLocation and not Autopilot then -- If in autopilot, keep this displaying properly
                        targetDistance = (worldPos - CustomTarget.position):len()
                    else
                        targetDistance = (AutopilotTargetCoords - worldPos):len() -- Don't show our weird variations
                    end
                    if not TurnBurn then
                        brakeDistance, brakeTime = AP.GetAutopilotBrakeDistanceAndTime(velMag)
                        maxBrakeDistance, maxBrakeTime = AP.GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
                    else
                        brakeDistance, brakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(velMag)
                        maxBrakeDistance, maxBrakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
                    end
                    local displayText = getDistanceDisplayString(targetDistance)
                    sysUpData(widgetDistanceText, '{"label": "distance", "value": "' .. displayText
                        .. '"}')
                    sysUpData(widgetTravelTimeText, '{"label": "Travel Time", "value": "' ..
                        FormatTimeString(travelTime) .. '", "unit":""}')
                    displayText = getDistanceDisplayString(brakeDistance)
                    sysUpData(widgetCurBrakeDistanceText, '{"label": "Cur Brake distance", "value": "' ..
                        displayText.. '"}')
                    sysUpData(widgetCurBrakeTimeText, '{"label": "Cur Brake Time", "value": "' ..
                        FormatTimeString(brakeTime) .. '", "unit":""}')
                    displayText = getDistanceDisplayString(maxBrakeDistance)
                    sysUpData(widgetMaxBrakeDistanceText, '{"label": "Max Brake distance", "value": "' ..
                        displayText.. '"}')
                    sysUpData(widgetMaxBrakeTimeText, '{"label": "Max Brake Time", "value": "' ..
                        FormatTimeString(maxBrakeTime) .. '", "unit":""}')
                    sysUpData(widgetMaxMassText, '{"label": "Max Brake Mass", "value": "' ..
                        stringf("%s", planetMaxMass ) .. '", "unit":""}')
                    displayText = getDistanceDisplayString(AutopilotTargetOrbit)
                    sysUpData(widgetTargetOrbitText, '{"label": "Target Orbit", "value": "' ..
                    displayText .. '"}')
                    if inAtmo and not WasInAtmo then
                        s.removeDataFromWidget(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
                        s.removeDataFromWidget(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
                        s.removeDataFromWidget(widgetCurBrakeTimeText, widgetCurBrakeTime)
                        s.removeDataFromWidget(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
                        s.removeDataFromWidget(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
                        WasInAtmo = true
                        if not throttleMode and AtmoSpeedAssist and (AltitudeHold or Reentry or finalLand) then
                            -- If they're reentering atmo from cruise, and have atmo speed Assist
                            -- Put them in throttle mode at 100%
                            AP.cmdThrottle(1)
                            BrakeIsOn = false
                            WasInCruise = false -- And override the thing that would reset it, in this case
                        end
                    end
                    if not inAtmo and WasInAtmo then
                        if sysUpData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) == 1 then
                            sysAddData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) end
                        if sysUpData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) == 1 then
                            sysAddData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) end
                        if sysUpData(widgetCurBrakeTimeText, widgetCurBrakeTime) == 1 then
                            sysAddData(widgetCurBrakeTimeText, widgetCurBrakeTime) end
                        if sysUpData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) == 1 then
                            sysAddData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) end
                        if sysUpData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) == 1 then
                            sysAddData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) end
                        WasInAtmo = false
                    end
                end
            else
                HideInterplanetaryPanel()
            end
            if warpdrive ~= nil then
                local warpDriveData = jdecode(warpdrive.getWidgetData())
                if warpDriveData.destination ~= "Unknown" and warpDriveData.distance > 400000 then
                    if not showWarpWidget then
                        warpdrive.showWidget()
                        showWarpWidget = true
                    end
                elseif showWarpWidget then
                    warpdrive.hideWidget()
                    showWarpWidget = false
                end
            end
        end
    
        function Hud.OneSecondTick()
            local function updateDistance()
                local curTime = systime()
                local spd = velMag
                local elapsedTime = curTime - lastTravelTime
                if (spd > 1.38889) then
                    spd = spd / 1000
                    local newDistance = spd * (curTime - lastTravelTime)
                    TotalDistanceTravelled = TotalDistanceTravelled + newDistance
                    totalDistanceTrip = totalDistanceTrip + newDistance
                end
                flightTime = flightTime + elapsedTime
                TotalFlightTime = TotalFlightTime + elapsedTime
                lastTravelTime = curTime
            end
            local function CheckDamage(newContent)
    
                local percentDam = 0
                local maxShipHP = eleTotalMaxHp
                local curShipHP = 0
                local damagedElements = 0
                local disabledElements = 0
                local colorMod = 0
                local color = ""
                local eleHp = c.getElementHitPointsById
                local eleMaxHp = c.getElementMaxHitPointsById
                local markers = {}
    
                for k in pairs(elementsID) do
                    local hp = 0
                    local mhp = 0
                    mhp = eleMaxHp(elementsID[k])
                    hp = eleHp(elementsID[k])
                    curShipHP = curShipHP + hp
                    if (hp+1 < mhp) then
                        if (hp == 0) then
                            disabledElements = disabledElements + 1
                        else
                            damagedElements = damagedElements + 1
                        end
                        -- Thanks to Jerico for the help and code starter for arrow markers!
                        if repairArrows and #markers == 0 then
                            position = vec3(c.getElementPositionById(elementsID[k]))
                            local x = position.x 
                            local y = position.y 
                            local z = position.z 
                            table.insert(markers, c.spawnArrowSticker(x, y, z + 1, "down"))
                            table.insert(markers, c.spawnArrowSticker(x, y, z + 1, "down"))
                            c.rotateSticker(markers[2], 0, 0, 90)
                            table.insert(markers, c.spawnArrowSticker(x + 1, y, z, "north"))
                            table.insert(markers, c.spawnArrowSticker(x + 1, y, z, "north"))
                            c.rotateSticker(markers[4], 90, 90, 0)
                            table.insert(markers, c.spawnArrowSticker(x - 1, y, z, "south"))
                            table.insert(markers, c.spawnArrowSticker(x - 1, y, z, "south"))
                            c.rotateSticker(markers[6], 90, -90, 0)
                            table.insert(markers, c.spawnArrowSticker(x, y - 1, z, "east"))
                            table.insert(markers, c.spawnArrowSticker(x, y - 1, z, "east"))
                            c.rotateSticker(markers[8], 90, 0, 90)
                            table.insert(markers, c.spawnArrowSticker(x, y + 1, z, "west"))
                            table.insert(markers, c.spawnArrowSticker(x, y + 1, z, "west"))
                            c.rotateSticker(markers[10], -90, 0, 90)
                            table.insert(markers, elementsID[k])
                        end
                    elseif repairArrows and #markers > 0 and markers[11] == elementsID[k] then
                        for j in pairs(markers) do
                            c.deleteSticker(markers[j])
                        end
                        markers = {}
                    end
                end
                percentDam = round((curShipHP / maxShipHP)*100,2)
                if disabledElements > 0 or damagedElements > 0 then
                    newContent[#newContent + 1] = svgText(0,0,"", "pbright txt")
                    colorMod = mfloor(percentDam * 2.55)
                    color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                    newContent[#newContent + 1] = svgText("50%", 1035, "Elemental Integrity: "..percentDam.."%", "txtbig txtmid","fill:"..color )
                    if (disabledElements > 0) then
                        newContent[#newContent + 1] = svgText("50%",1055, "Disabled Modules: "..disabledElements.." Damaged Modules: "..damagedElements, "txtbig txtmid","fill:"..color)
                    elseif damagedElements > 0 then
                        newContent[#newContent + 1] = svgText("50%", 1055, "Damaged Modules: "..damagedElements, "txtbig txtmid", "fill:" .. color)
                    end
                end
            end
            local function updateWeapons()
                if weapon then
                    if  WeaponPanelID==nil and (radarPanelId ~= nil or GearExtended)  then
                        _autoconf.displayCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true)
                        WeaponPanelID = _autoconf.panels[_autoconf.panels_size]
                    elseif WeaponPanelID ~= nil and radarPanelId == nil and not GearExtended then
                        sysDestWid(WeaponPanelID)
                        WeaponPanelID = nil
                    end
                end
            end
            passengers = C.getPlayersOnBoard()
            ships = C.getDockedConstructs()  
            local newContent = {}
            updateDistance()
            if ShouldCheckDamage then
                CheckDamage(newContent)
            end
            updateWeapons()
            HUD.UpdatePipe()
            HUD.ExtraData(newContent)
            lastOdometerOutput = table.concat(newContent, "")
        end
    
        function Hud.AnimateTick()
            Animated = true
            Animating = false
            simulatedX = 0
            simulatedY = 0
            u.stopTimer("animateTick")
        end
    
        function Hud.MsgTick()
            -- This is used to clear a message on screen after a short period of time and then stop itself
            local newContent = {}
            HUD.DisplayMessage(newContent, "empty")
            msgText = "empty"
            u.stopTimer("msgTick")
            msgTimer = 3
        end
        function Hud.ButtonSetup()
            SettingsButtons()
            ControlsButtons() -- Set up all the pushable buttons.
            Buttons = ControlButtons
        end
    
        if userHud then 
            for k,v in pairs(userHud) do Hud[k] = v end 
        end  
    
        return Hud
    end
    local function APClass(Nav, c, u, atlas, vBooster, hover, telemeter_1, antigrav, warpdrive, dbHud_1,
        mabs, mfloor, atmosphere, isRemote, atan, systime, uclamp, 
        navCom, sysUpData, sysIsVwLock, msqrt, round, play, addTable, float_eq,
        getDistanceDisplayString, FormatTimeString, SaveDataBank, jdecode, stringf, sysAddData)  
        local s = DUSystem
        local C = DUConstruct
    
        local ap = {}
        -- Local Functions and Variables for whole class
            local speedLimitBreaking = false
            local lastPvPDist = 0
            local previousYawAmount = 0
            local previousPitchAmount = 0
            local lastApTickTime = systime()
            local ahDoubleClick = 0
            local apDoubleClick = 0
            local orbitPitch = 0
            local orbitRoll = 0
            local orbitAligned = false
            local orbitalRecover = false
            local OrbitTargetSet = false
            local OrbitTargetPlanet = nil
            local OrbitTicks = 0
            local minAutopilotSpeed = 55 -- Minimum speed for autopilot to maneuver in m/s.  Keep above 25m/s to prevent nosedives when boosters kick in. Also used in hudclass
            local lastMaxBrakeAtG = nil
            local mousePause = false
            local apThrottleSet = false
            local reentryMode = false
            local pitchInput2 = 0
            local yawInput2 = 0
            local rollInput2 = 0
            local targetRoll = 0
            local VtPitch = 0
            local orbitalParams = { VectorToTarget = false }
            local constructUp = vec3(C.getWorldOrientationUp())
            local setCruiseSpeed = nil
            local hSpd = 0
            local cmdT = -1
            local cmdC = -1
            local cmdDS = false
            local eLL = false
            local sivl = 0
            local AutopilotPaused = false
            local initBL = false
            local swp = false
            local sudi = false
            local sudv = ""
            local sba = false
            local aptoggle = false
            local myAutopilotTarget=""
            local parseRadar = false
            local lastMouseTime = 0
    
            local function safeZone() -- Thanks to @SeM for the base code, modified to work with existing Atlas
                return (C.isInPvPZone()~=1), mabs(C.getDistanceToSafeZone())
            end
            local function GetAutopilotBrakeDistanceAndTime(speed)
                -- If we're in atmo, just return some 0's or LastMaxBrake, whatever's bigger
                -- So we don't do unnecessary API calls when atmo brakes don't tell us what we want
                local finalSpeed = AutopilotEndSpeed
                if not Autopilot then finalSpeed = 0 end
                local whichBrake = LastMaxBrake
                if inAtmo then
                    if LastMaxBrakeInAtmo and LastMaxBrakeInAtmo > 0 then
                        whichBrake = LastMaxBrakeInAtmo
                    else
                        return 0, 0
                    end
                end
                return Kinematic.computeDistanceAndTime(speed, finalSpeed, coreMass, 0, 0,
                        whichBrake - (AutopilotPlanetGravity * coreMass))
            end
            local function GetAutopilotTBBrakeDistanceAndTime(speed)
                local finalSpeed = AutopilotEndSpeed
                if not Autopilot then finalSpeed = 0 end
    
                return Kinematic.computeDistanceAndTime(speed, finalSpeed, coreMass, Nav:maxForceForward(),
                        warmup, LastMaxBrake - (AutopilotPlanetGravity * coreMass))
            end
            local function signedRotationAngle(normal, vecA, vecB)
                vecA = vecA:project_on_plane(normal)
                vecB = vecB:project_on_plane(normal)
                return atan(vecA:cross(vecB):dot(normal), vecA:dot(vecB))
            end
            local function AboveGroundLevel()
                local function hoverDetectGround()
                    local vgroundDistance = -1
                    local hgroundDistance = -1
                    if vBooster then
                        vgroundDistance = vBooster.getDistance()
                    end
                    if hover then
                        hgroundDistance = hover.getDistance()
                    end
                    if vgroundDistance ~= -1 and hgroundDistance ~= -1 then
                        if vgroundDistance < hgroundDistance then
                            return vgroundDistance
                        else
                            return hgroundDistance
                        end
                    elseif vgroundDistance ~= -1 then
                        return vgroundDistance
                    elseif hgroundDistance ~= -1 then
                        return hgroundDistance
                    else
                        return -1
                    end
                end
                local hovGndDet = hoverDetectGround()  
                local groundDistance = -1
                if antigrav and antigrav.isActive() == 1 and not ExternalAGG and velMag < minAutopilotSpeed then
                    local diffAgg = mabs(coreAltitude - antigrav.getBaseAltitude())
                    if diffAgg < 50 then return diffAgg end
                end
                if telemeter_1 then 
                    groundDistance = telemeter_1.raycast().distance
                end
                if hovGndDet ~= -1 and groundDistance ~= -1 then
                    if hovGndDet < groundDistance then 
                        return hovGndDet 
                    else
                        return groundDistance
                    end
                elseif hovGndDet ~= -1 then
                    return hovGndDet
                else
                    return groundDistance
                end
            end
            local function showWaypoint(planet, coordinates, dontSet)
                local function zeroConvertToMapPosition(targetplanet, worldCoordinates)
                    local worldVec = vec3(worldCoordinates)
                    if targetplanet.id == 0 then
                        return setmetatable({
                            latitude = worldVec.x,
                            longitude = worldVec.y,
                            altitude = worldVec.z,
                            id = 0,
                            systemId = targetplanet.systemId
                        }, MapPosition)
                    end
                    local coords = worldVec - targetplanet.center
                    local distance = coords:len()
                    local altitude = distance - targetplanet.radius
                    local latitude = 0
                    local longitude = 0
                    if not float_eq(distance, 0) then
                        local phi = atan(coords.y, coords.x)
                        longitude = phi >= 0 and phi or (2 * math.pi + phi)
                        latitude = math.pi / 2 - math.acos(coords.z / distance)
                    end
                    return setmetatable({
                        latitude = math.deg(latitude),
                        longitude = math.deg(longitude),
                        altitude = altitude,
                        id = targetplanet.id,
                        systemId = targetplanet.systemId
                    }, MapPosition)
                end
                local waypoint = zeroConvertToMapPosition(planet, coordinates)
                waypoint = "::pos{"..waypoint.systemId..","..waypoint.id..","..waypoint.latitude..","..waypoint.longitude..","..waypoint.altitude.."}"
                if dontSet then 
                    return waypoint
                else
                    swp = waypoint
                    return true
                end
            end
            local function AlignToWorldVector(vector, tolerance, damping) -- Aligns ship to vector with a tolerance and a damping override of user damping if needed.
                local function getMagnitudeInDirection(vector, direction)
                    -- return vec3(vector):project_on(vec3(direction)):len()
                    vector = vec3(vector)
                    direction = vec3(direction):normalize()
                    local result = vector * direction -- To preserve sign, just add them I guess
                    
                    return result.x + result.y + result.z
                end
                -- Sets inputs to attempt to point at the autopilot target
                -- Meant to be called from Update or Tick repeatedly
                local alignmentTolerance = 0.001 -- How closely it must align to a planet before accelerating to it
                local autopilotStrength = 1 -- How strongly autopilot tries to point at a target
                if not inAtmo or not stalling or abvGndDet ~= -1 or velMag < minAutopilotSpeed then
                    if damping == nil then
                        damping = DampingMultiplier
                    end
        
                    if tolerance == nil then
                        tolerance = alignmentTolerance
                    end
                    vector = vec3(vector):normalize()
                    local targetVec = (vec3() - vector)
                    local yawAmount = -getMagnitudeInDirection(targetVec, C.getWorldOrientationRight()) * autopilotStrength
                    local pitchAmount = -getMagnitudeInDirection(targetVec, C.getWorldOrientationUp()) * autopilotStrength
                    if previousYawAmount == 0 then previousYawAmount = yawAmount / 2 end
                    if previousPitchAmount == 0 then previousPitchAmount = pitchAmount / 2 end
                    -- Skip dampening at very low values, and force it to effectively overshoot so it can more accurately align back
                    -- Instead of taking literal forever to converge
                    if mabs(yawAmount) < 0.1 then
                        yawInput2 = yawInput2 - yawAmount*2
                    else
                        yawInput2 = yawInput2 - (yawAmount + (yawAmount - previousYawAmount) * damping)
                    end
                    if mabs(pitchAmount) < 0.1 then
                        pitchInput2 = pitchInput2 + pitchAmount*2
                    else
                        pitchInput2 = pitchInput2 + (pitchAmount + (pitchAmount - previousPitchAmount) * damping)
                    end
        
        
                    previousYawAmount = yawAmount
                    previousPitchAmount = pitchAmount
                    -- Return true or false depending on whether or not we're aligned
                    if mabs(yawAmount) < tolerance and (mabs(pitchAmount) < tolerance) then
                        return true
                    end
                    return false
                elseif stalling and abvGndDet == -1 then
                    -- If stalling, align to velocity to fix the stall
                    -- IDK I'm just copy pasting all this
                    vector = constructVelocity
                    if damping == nil then
                        damping = DampingMultiplier
                    end
        
                    if tolerance == nil then
                        tolerance = alignmentTolerance
                    end
                    vector = vec3(vector):normalize()
                    local targetVec = (constructForward - vector)
                    local yawAmount = -getMagnitudeInDirection(targetVec, C.getWorldOrientationRight()) * autopilotStrength
                    local pitchAmount = -getMagnitudeInDirection(targetVec, C.getWorldOrientationUp()) * autopilotStrength
                    if previousYawAmount == 0 then previousYawAmount = yawAmount / 2 end
                    if previousPitchAmount == 0 then previousPitchAmount = pitchAmount / 2 end
                    -- Skip dampening at very low values, and force it to effectively overshoot so it can more accurately align back
                    -- Instead of taking literal forever to converge
                    if mabs(yawAmount) < 0.1 then
                        yawInput2 = yawInput2 - yawAmount*5
                    else
                        yawInput2 = yawInput2 - (yawAmount + (yawAmount - previousYawAmount) * damping)
                    end
        
                    if mabs(pitchAmount) < 0.1 then
                        pitchInput2 = pitchInput2 + pitchAmount*5
                    else
                        pitchInput2 = pitchInput2 + (pitchAmount + (pitchAmount - previousPitchAmount) * damping)
                    end
        
                    previousYawAmount = yawAmount
                    previousPitchAmount = pitchAmount
                    -- Return true or false depending on whether or not we're aligned
                    if mabs(yawAmount) < tolerance and (mabs(pitchAmount) < tolerance) then
                        return true
                    end
                    return false
                end
            end
    
        function ap.clearAll()
            AutopilotAccelerating = false
            AutopilotBraking = false
            AutopilotCruising = false
            Autopilot = false
            AutopilotRealigned = false
            AutopilotStatus = "Aligning"                
            RetrogradeIsOn = false
            ProgradeIsOn = false
            ReversalIsOn = nil
            AltitudeHold = false
            Reentry = false
            BrakeLanding = false
            AutoTakeoff = false
            VertTakeOff = false
            followMode = false
            apThrottleSet = false
            spaceLand = false
            spaceLaunch = false
            reentryMode = false
            autoRoll = autoRollPreference
            VectorToTarget = false
            TurnBurn = false
            gyroIsOn = false
            LockPitch = nil
            IntoOrbit = false
            apBrk = false
            alignHeading = nil
        end
    
        function ap.GetAutopilotBrakeDistanceAndTime(speed)
            return GetAutopilotBrakeDistanceAndTime(speed)
        end
    
        function ap.GetAutopilotTBBrakeDistanceAndTime(speed)
            return GetAutopilotTBBrakeDistanceAndTime(speed)
        end
    
        function ap.showWayPoint(planet, coordinates, dontSet)
            return showWaypoint(planet, coordinates, dontSet)
        end
    
        function ap.APTick()
            local wheel = s.getMouseWheel()
    
            if wheel > 0 then
                AP.changeSpd()
            elseif wheel < 0 then
                AP.changeSpd(true)
            else
                mousePause = true
            end
            sivl = sysIsVwLock()
            if swp then 
                s.setWaypoint(swp) 
                swp = false
            end
            if sba then
                antigrav.setTargetAltitude(sba) 
                sba = false
            end
            if sudi then
                sysUpData(sudi, sudv)
                sudi = false
                sudv = ""
            end
            if cmdC ~= -1 then 
                AP.cmdCruise(cmdC, cmdDS) 
                cmdDS = false 
                cmdC = -1 
            end
            if setCruiseSpeed ~= nil then
                if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed or navCom:getTargetSpeed(axisCommandId.longitudinal) ~= setCruiseSpeed then
                    navCom:setTargetSpeedCommand(axisCommandId.longitudinal, setCruiseSpeed)
                else
                    setCruiseSpeed = nil
                end
            end
            if cmdT ~= -1 then
                AP.cmdThrottle(cmdT, cmdDS) 
                cmdDS = false
                cmdT = -1 
            end
            if eLL then
                CONTROL.landingGear()
                eLL = false
            end 
            if aptoggle then
                AP.ToggleAutopilot()
            end
        end
    
        function ap.ToggleIntoOrbit() -- Toggle IntoOrbit mode on and off
            OrbitAchieved = false
            orbitPitch = nil
            orbitRoll = nil
            OrbitTicks = 0
            if not inAtmo then
                if IntoOrbit then
                    play("orOff", "AP")
                    IntoOrbit = false
                    orbitAligned = false
                    OrbitTargetPlanet = nil
                    autoRoll = autoRollPreference
                    if AltitudeHold then AltitudeHold = false AutoTakeoff = false end
                    orbitalParams.VectorToTarget = false
                    orbitalParams.AutopilotAlign = false
                    OrbitTargetSet = false
                elseif nearPlanet then
                    play("orOn", "AP")
                    IntoOrbit = true
                    autoRoll = true
                    if OrbitTargetPlanet == nil then
                        OrbitTargetPlanet = planet
                    end
                    if AltitudeHold then AltitudeHold = false AutoTakeoff = false end
                else
                    msgText = "Unable to engage auto-orbit, not near a planet"
                end
            else
                -- If this got called while in atmo, make sure it's all false
                IntoOrbit = false
                orbitAligned = false
                OrbitTargetPlanet = nil
                autoRoll = autoRollPreference
                if AltitudeHold then AltitudeHold = false end
                orbitalParams.VectorToTarget = false
                orbitalParams.AutopilotAlign = false
                OrbitTargetSet = false
            end
        end
    
        function ap.ToggleVerticalTakeoff() -- Toggle vertical takeoff mode on and off
            AltitudeHold = false
            if VertTakeOff then
                StrongBrakes = true -- We don't care about this anymore
                Reentry = false
                AutoTakeoff = false
                BrakeLanding = true
                autoRoll = true
                upAmount = 0
                if inAtmo and abvGndDet == -1 then
                    BrakeLanding = false
                    AltitudeHold = true
                    upAmount = 0
                    Nav:setEngineForceCommand('thrust analog vertical fueled ', vec3(), 1)
                    cmdC = mfloor(adjustedAtmoSpeedLimit)
                end
            else
                OrbitAchieved = false
                GearExtended = false
                Nav.control.retractLandingGears()
                navCom:setTargetGroundAltitude(TargetHoverHeight) 
                BrakeIsOn = "VTO Takeoff"
            end
            VertTakeOff = not VertTakeOff
        end
    
        function ap.checkLOS(vector)
            local intersectBody, farSide, nearSide = galaxyReference:getPlanetarySystem(0):castIntersections(worldPos, vector,
                function(body) if body.noAtmosphericDensityAltitude > 0 then return (body.radius+body.noAtmosphericDensityAltitude) else return (body.radius+body.surfaceMaxAltitude*1.5) end end)
            local atmoDistance = farSide
            if nearSide ~= nil and farSide ~= nil then
                atmoDistance = math.min(nearSide,farSide)
            end
            if atmoDistance ~= nil then return intersectBody, atmoDistance else return nil, nil end
        end
    
        function ap.ToggleAutopilot() -- Toggle autopilot mode on and off
    
            local function ToggleVectorToTarget(SpaceTarget)
                -- This is a feature to vector toward the target destination in atmo or otherwise on-planet
                -- Uses altitude hold.  
                collisionAlertStatus = false
                VectorToTarget = not VectorToTarget
                if VectorToTarget then
                    TurnBurn = false
                    if not AltitudeHold and not SpaceTarget then
                        AP.ToggleAltitudeHold()
                    end
                end
                VectorStatus = "Proceeding to Waypoint"
            end
    
            local function getIndex(name)
                if name then
                    for i,k in pairs(AtlasOrdered) do
                        if k.name and k.name == name then return i end
                    end
                else
                    return 0
                end
            end
            local routeOrbit = false
            if (time - apDoubleClick) < 1.5 and inAtmo then
                if not SpaceEngines then
                    if inAtmo then
                        HoldAltitude = planet.spaceEngineMinAltitude - 0.01*planet.noAtmosphericDensityAltitude
                        play("11","EP")
                        apDoubleClick = -1
                        if Autopilot or VectorToTarget or IntoOrbit then 
                            return 
                        end
                    else
                        msgText = "No space engines detected, Orbital Hop not supported"
                        return
                    end
                elseif planet.hasAtmosphere then
                    if inAtmo then
                        HoldAltitude = planet.noAtmosphericDensityAltitude + LowOrbitHeight
                        play("orH","OH")
                    end
                    apDoubleClick = -1
                    if Autopilot or VectorToTarget or IntoOrbit then 
                        return 
                    end
                end
            else
                apDoubleClick = time
            end
            TargetSet = false -- No matter what
            -- Toggle Autopilot, as long as the target isn't None
            if (AutopilotTargetIndex > 0 or #apRoute>0) and not Autopilot and not VectorToTarget and not spaceLaunch and not IntoOrbit then
                if 0.5 * Nav:maxForceForward() / c.getGravityIntensity() < coreMass then  msgText = "WARNING: Heavy Loads may affect autopilot performance." msgTimer=5 end
                if #apRoute>0 and not finalLand then 
                    AutopilotTargetIndex = getIndex(apRoute[1])
                    ATLAS.UpdateAutopilotTarget()
                    msgText = "Route Autopilot in Progress"
                    local targetVec = CustomTarget.position - worldPos
                    local distanceToTarget = targetVec:project_on_plane(worldVertical):len()
                    if distanceToTarget > 50000 and CustomTarget.planetname == planet.name then 
                        routeOrbit=true
                    end
                end
                ATLAS.UpdateAutopilotTarget()
                AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords)
                if CustomTarget ~= nil then
                    if CustomTarget.agg and not ExternalAGG and antigrav then
                        if not antigravOn then AP.ToggleAntigrav() end
                        AntigravTargetAltitude = CustomTarget.agg
                    end
                    LockPitch = nil
                    SpaceTarget = (CustomTarget.planetname == "Space")
                    if SpaceTarget then
                        play("apSpc", "AP")
                        if inAtmo then 
                            spaceLaunch = true
                            AP.ToggleAltitudeHold()
                        else
                            Autopilot = true
                        end
                    elseif planet.name  == CustomTarget.planetname then
                        StrongBrakes = true
                        if inAtmo then
                            if not VectorToTarget then
                                play("vtt", "AP")
                                ToggleVectorToTarget(SpaceTarget)
                                if routeOrbit then
                                    HoldAltitude = planet.noAtmosphericDensityAltitude + LowOrbitHeight
                                end
                            end
                        else
                            play("apOn", "AP")
                            if not (autopilotTargetPlanet.name == planet.name and coreAltitude < (AutopilotTargetOrbit*1.5) ) then
                                OrbitAchieved = false
                                Autopilot = true
                            elseif not inAtmo then
                                if IntoOrbit then AP.ToggleIntoOrbit() end -- Reset all appropriate vars
                                OrbitTargetOrbit = planet.noAtmosphericDensityAltitude + LowOrbitHeight
                                OrbitTargetSet = true
                                orbitalParams.AutopilotAlign = true
                                orbitalParams.VectorToTarget = true
                                orbitAligned = false
                                if not IntoOrbit then AP.ToggleIntoOrbit() end
                            end
                        end
                    else
                        play("apP", "AP")
                        RetrogradeIsOn = false
                        ProgradeIsOn = false
                        if inAtmo then 
                            spaceLaunch = true
                            AP.ToggleAltitudeHold() 
                        else
                            Autopilot = true
                        end
                    end
                elseif not inAtmo then -- Planetary autopilot
                    if CustomTarget == nil and (autopilotTargetPlanet.name == planet.name and nearPlanet) and not IntoOrbit then
                        WaypointSet = false
                        OrbitAchieved = false
                        orbitAligned = false
                        AP.ToggleIntoOrbit() -- this works much better here
                    else
                        play("apP","AP")
                        Autopilot = true
                        RetrogradeIsOn = false
                        ProgradeIsOn = false
                        AutopilotRealigned = false
                        followMode = false
                        AltitudeHold = false
                        BrakeLanding = false
                        Reentry = false
                        AutoTakeoff = false
                        apThrottleSet = false
                        LockPitch = nil
                        WaypointSet = false
                    end
                else
                    play("apP", "AP")
                    spaceLaunch = true
                    AP.ToggleAltitudeHold()
                end
                aptoggle = false
            else
                play("apOff", "AP")
                AP.ResetAutopilots(1)
                if aptoggle == 2 then aptoggle = true end
            end
        end
    
        function ap.routeWP(getRoute, clear, loadit)
            if loadit then 
                if loadit == 1 then 
                    apRoute = {}
                    apRoute = addTable(apRoute,saveRoute)
                    if #apRoute>0 then 
                        msgText = "Route Loaded" 
                    else
                        msgText = "No Saved Route found on Databank"
                    end
                return apRoute 
                else
                    saveRoute = {} 
                    saveRoute = addTable(saveRoute, apRoute) msgText = "Route Saved" SaveDataBank() return 
                end
            end
            if getRoute then return apRoute end
            if clear then 
                apRoute = {}
                msgText = "Current Route Cleared"
            else
                apRoute[#apRoute+1]=CustomTarget.name
                msgText = "Added "..CustomTarget.name.." to route. "
            end
            return apRoute
        end
    
        function ap.cmdThrottle(value, dontSwitch) -- sets the throttle value to value, also switches to throttle mode (vice cruise) unless dontSwitch passed
            if navCom:getAxisCommandType(0) ~= axisCommandType.byThrottle and not dontSwitch then
                Nav.control.cancelCurrentControlMasterMode()
            end
            navCom:setThrottleCommand(axisCommandId.longitudinal, value)
            PlayerThrottle = uclamp(round(value*100,0)/100, -1, 1)
            setCruiseSpeed = nil
        end
    
        function ap.cmdCruise(value, dontSwitch) -- sets the cruise target speed to value, also switches to cruise mode (vice throttle) unless dontSwitch passed
            if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed and not dontSwitch then
                Nav.control.cancelCurrentControlMasterMode()
            end
            navCom:setTargetSpeedCommand(axisCommandId.longitudinal, value)
            setCruiseSpeed = value
        end
    
        function ap.ToggleLockPitch()
            if LockPitch == nil then
                play("lkPOn","LP")
                if not holdingShift then LockPitch = adjustedPitch
                else LockPitch = LockPitchTarget end
                AutoTakeoff = false
                AltitudeHold = false
                BrakeLanding = false
            else
                play("lkPOff","LP")
                LockPitch = nil
            end
        end
        
        function ap.ToggleAltitudeHold()  -- Toggle Altitude Hold mode on and off
            if (time - ahDoubleClick) < 1.5 then
                if planet.hasAtmosphere  then
                    if inAtmo then
    
                        HoldAltitude = planet.spaceEngineMinAltitude - 0.01*planet.noAtmosphericDensityAltitude
                        play("11","EP")
                    else
                        if nearPlanet then
                            HoldAltitude = planet.noAtmosphericDensityAltitude + LowOrbitHeight
                            OrbitTargetOrbit = HoldAltitude
                            OrbitTargetSet = true
                            if not IntoOrbit then AP.ToggleIntoOrbit() end
                            orbitAligned = true
                        end
                    end
                    ahDoubleClick = -1
                    if AltitudeHold or IntoOrbit or VertTakeOff then 
                        return 
                    end
                end
            else
                ahDoubleClick = time
            end
            if nearPlanet and not inAtmo then
                OrbitTargetOrbit = coreAltitude
                OrbitTargetSet = true
                orbitAligned = true
                AP.ToggleIntoOrbit()
                if IntoOrbit then
                    ahDoubleClick = time
                else
                    ahDoubleClick = 0
                end
                return 
            end        
            AltitudeHold = not AltitudeHold
            BrakeLanding = false
            Reentry = false
            if AltitudeHold then
                Autopilot = false
                ProgradeIsOn = false
                RetrogradeIsOn = false
                followMode = false
                autoRoll = true
                LockPitch = nil
                OrbitAchieved = false
                if abvGndDet ~= -1 and velMag < 20 then
                    if GearExtended then CONTROL.landingGear() end
                    play("lfs", "LS")
                    AutoTakeoff = true
                    if ahDoubleClick > -1 then HoldAltitude = coreAltitude + AutoTakeoffAltitude end
                    BrakeIsOn = "ATO Hold"
                    navCom:setTargetGroundAltitude(TargetHoverHeight)
                    if VertTakeOffEngine and UpVertAtmoEngine then 
                        AP.ToggleVerticalTakeoff()
                    end
                else
                    play("altOn","AH")
                    AutoTakeoff = false
                    if ahDoubleClick > -1 then
                        if nearPlanet then
                            HoldAltitude = coreAltitude
                        end
                    end
                    if VertTakeOff then AP.ToggleVerticalTakeoff() end
                end
                if antigravOn and not ExternalAGG then 
                    local gBA = antigrav.getBaseAltitude()
                    if VectorToTarget and CustomTarget.agg and CustomTarget.agg > coreAltitude then 
                        HoldAltitude = CustomTarget.agg
                    elseif AutoTakeoff then
                        HoldAltitude = gBA
                    end
                    if mabs(coreAltitude-gBA) < 100 and velMag < 20 then 
                        HoldAltitude = gBA
                        BrakeIsOn = "AGG Hold"
                        cmdT = 0 
                    end
                end
                if spaceLaunch then HoldAltitude = 200000 end
            else
                play("altOff","AH")
                if IntoOrbit then AP.ToggleIntoOrbit() end
                if VertTakeOff then 
                    AP.ToggleVerticalTakeoff() 
                end
                autoRoll = autoRollPreference
                AutoTakeoff = false
                VectorToTarget = false
                ahDoubleClick = 0
            end
        end
    
        function ap.ResetAutopilots(ap)
            if ap then 
                spaceLaunch = false
                Autopilot = false
                AutopilotRealigned = false
                apThrottleSet = false
                HoldAltitude = coreAltitude
                TargetSet = false
                apBrk = false
                AutopilotStatus = "Aligning"
            end
            VectorToTarget = false
            AutoTakeoff = false
            Reentry = false
            -- We won't abort interplanetary because that would fuck everyone.
            ProgradeIsOn = false -- No reason to brake while facing prograde, but retrograde yes.
            BrakeLanding = false
            alignHeading = nil
            AutoLanding = false
            ReversalIsOn = nil
            apBrk = false
            if not antigravOn then
                AltitudeHold = false -- And stop alt hold
                LockPitch = nil
            end
            if VertTakeOff then
                AP.ToggleVerticalTakeoff()
            end
            if IntoOrbit then
                AP.ToggleIntoOrbit()
            end
            autoRoll = autoRollPreference
            spaceLand = false
            finalLand = false
            upAmount = 0
        end
    
        function ap.BrakeToggle(strBk) -- Toggle brakes on and off
            -- Toggle brakes
            if not BrakeIsOn then
                if strBk then BrakeIsOn = strBk else BrakeIsOn = true end
            else
                BrakeIsOn = false
            end
            if BrakeLanding then
                BrakeLanding = false
                autoRoll = autoRollPreference
                apBrk = false
            end
            if BrakeIsOn then
                play("bkOn","B",1)
                -- If they turn on brakes, disable a few things
                AP.ResetAutopilots()
            else
                play("bkOff","B",1)
            end
        end
    
        function ap.BeginReentry() -- Begins re-entry process
            if Reentry then
                msgText = "Re-Entry cancelled"
                play("reOff", "RE")
                Reentry = false
                autoRoll = autoRollPreference
                AltitudeHold = false
            elseif not planet.hasAtmosphere then
                msgText = "Re-Entry requirements not met: you must start out of atmosphere\n and within a planets gravity well over a planet with atmosphere"
                msgTimer = 5
            elseif not reentryMode then-- Parachute ReEntry
                Reentry = true
                if navCom:getAxisCommandType(0) ~= controlMasterModeId.cruise then
                    Nav.control.cancelCurrentControlMasterMode()
                end                
                autoRoll = true
                BrakeIsOn = false
                msgText = "Beginning Parachute Re-Entry - Strap In.  Target speed: " .. adjustedAtmoSpeedLimit
                play("par", "RE")
            else --Glide Reentry
                Reentry = true
                AltitudeHold = true
                autoRoll = true
                BrakeIsOn = false
                HoldAltitude = planet.surfaceMaxAltitude + ReEntryHeight
                if HoldAltitude > planet.spaceEngineMinAltitude then 
                    HoldAltitude = planet.spaceEngineMinAltitude - 0.01*planet.noAtmosphericDensityAltitude 
                end
                local text = getDistanceDisplayString(HoldAltitude)
                msgText = "Beginning Re-entry.  Target speed: " .. adjustedAtmoSpeedLimit .. " Target Altitude: " .. text 
                play("glide","RE")
                cmdC = mfloor(adjustedAtmoSpeedLimit)
            end
            AutoTakeoff = false -- This got left on somewhere.. 
        end
    
        function ap.ToggleAntigrav() -- Toggles antigrav on and off
            if antigrav and not ExternalAGG then
                if antigravOn then
                    play("aggOff","AG")
                    antigrav.deactivate()
                    antigrav.hideWidget()
                else
                    if AntigravTargetAltitude == nil then AntigravTargetAltitude = coreAltitude end
                    if AntigravTargetAltitude < 1000 then
                        AntigravTargetAltitude = 1000
                    end
                    play("aggOn","AG")
                    antigrav.activate()
                    antigrav.showWidget()
                end
            end
        end
    
        function ap.changeSpd(down)
            local mult=1
            if down then mult = -1 end
            if not holdingShift then
                if AtmoSpeedAssist and not AltIsOn and mousePause then
                    local currentPlayerThrot = PlayerThrottle
                    PlayerThrottle = round(uclamp(PlayerThrottle + mult*speedChangeLarge/100, -1, 1),2)
                    if PlayerThrottle >= 0 and currentPlayerThrot < 0 then 
                        PlayerThrottle = 0 
                        mousePause = false
                    end
                elseif AltIsOn then
                    if inAtmo or Reentry then
                        adjustedAtmoSpeedLimit = uclamp(adjustedAtmoSpeedLimit + mult*speedChangeLarge,0,AtmoSpeedLimit)
                    elseif Autopilot then
                        MaxGameVelocity = uclamp(MaxGameVelocity + mult*speedChangeLarge/3.6*100,0, MaxSpeed-0.2)
                    end
                else
                    navCom:updateCommandFromActionStart(axisCommandId.longitudinal, mult*speedChangeLarge/10)
                end
            else
                if Autopilot or VectorToTarget or spaceLaunch or IntoOrbit then
                    apScrollIndex = apScrollIndex+1*mult*-1
                    if apScrollIndex > #AtlasOrdered then apScrollIndex = 1 end
                    if apScrollIndex < 1 then apScrollIndex = #AtlasOrdered end
                else
                    if not down then mult = 1 else mult = nil end
                    ATLAS.adjustAutopilotTargetIndex(mult)
                end
            end
        end
    
        function ap.TenthTick()
            local function GetAutopilotTravelTime()
                if not Autopilot then
                    if CustomTarget == nil or CustomTarget.planetname ~= planet.name then
                        AutopilotDistance = (autopilotTargetPlanet.center - worldPos):len() -- This updates elsewhere if we're already piloting
                    else
                        AutopilotDistance = (CustomTarget.position - worldPos):len()
                    end
                end
                local speed = velMag
                local throttle = u.getThrottle()/100
                if AtmoSpeedAssist then throttle = PlayerThrottle end
                local accelDistance, accelTime =
                    Kinematic.computeDistanceAndTime(velMag, MaxGameVelocity, -- From currently velocity to max
                        coreMass, Nav:maxForceForward()*throttle, warmup, -- T50?  Assume none, negligible for this
                        0) -- Brake thrust, none for this
                -- accelDistance now has the amount of distance for which we will be accelerating
                -- Then we need the distance we'd brake from full speed
                -- Note that for some nearby moons etc, it may never reach full speed though.
                local brakeDistance, brakeTime
                if not TurnBurn then
                    brakeDistance, brakeTime = AP.GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
                else
                    brakeDistance, brakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
                end
                local _, curBrakeTime
                if not TurnBurn and speed > 0 then -- Will this cause problems?  Was spamming something in here was giving 0 speed and 0 accel
                    _, curBrakeTime = AP.GetAutopilotBrakeDistanceAndTime(speed)
                else
                    _, curBrakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(speed)
                end
                local cruiseDistance = 0
                local cruiseTime = 0
                -- So, time is in seconds
                -- If cruising or braking, use real cruise/brake values
                if AutopilotCruising or (not Autopilot and speed > 5) then -- If already cruising, use current speed
                    cruiseTime = Kinematic.computeTravelTime(speed, 0, AutopilotDistance)
                elseif brakeDistance + accelDistance < AutopilotDistance then
                    -- Add any remaining distance
                    cruiseDistance = AutopilotDistance - (brakeDistance + accelDistance)
                    cruiseTime = Kinematic.computeTravelTime(8333.0556, 0, cruiseDistance)
                else
                    local accelRatio = (AutopilotDistance - brakeDistance) / accelDistance
                    accelDistance = AutopilotDistance - brakeDistance -- Accel until we brake
                    
                    accelTime = accelTime * accelRatio
                end
                if CustomTarget ~= nil and CustomTarget.planetname == planet.name and not Autopilot then
                    return cruiseTime
                elseif AutopilotBraking then
                    return curBrakeTime
                elseif AutopilotCruising then
                    return cruiseTime + curBrakeTime
                else -- If not cruising or braking, assume we'll get to max speed
                    return accelTime + brakeTime + cruiseTime
                end
            end
            local function RefreshLastMaxBrake(gravity, force)
                if gravity == nil then
                    gravity = c.getGravityIntensity()
                end
                gravity = round(gravity, 5) -- round to avoid insignificant updates
                if (force ~= nil and force) or (lastMaxBrakeAtG == nil or lastMaxBrakeAtG ~= gravity) then
                    local speed = coreVelocity:len()
                    local maxBrake = jdecode(u.getWidgetData()).maxBrake 
                    if maxBrake ~= nil and maxBrake > 0 and inAtmo then 
                        maxBrake = maxBrake / uclamp(speed/100, 0.1, 1)
                        maxBrake = maxBrake / atmosDensity
                        if atmosDensity > 0.10 then 
                            if LastMaxBrakeInAtmo then
                                LastMaxBrakeInAtmo = (LastMaxBrakeInAtmo + maxBrake) / 2
                            else
                                LastMaxBrakeInAtmo = maxBrake 
                            end
                        end -- Now that we're calculating actual brake values, we want this updated
                    end
                    if maxBrake ~= nil and maxBrake > 0 then
                        LastMaxBrake = maxBrake
                    end
                    lastMaxBrakeAtG = gravity
                end
            end
            notPvPZone, pvpDist = safeZone()
            MaxSpeed = C.getMaxSpeed()  
            if AutopilotTargetName ~= "None" and (autopilotTargetPlanet or CustomTarget) then
                travelTime = GetAutopilotTravelTime() -- This also sets AutopilotDistance so we don't have to calc it again
            end
            RefreshLastMaxBrake(nil, true) -- force refresh, in case we took damage
        end
    
        function ap.SatNavTick()
            if not UseSatNav then return end
            -- Support for SatNav by Trog
            myAutopilotTarget = dbHud_1.getStringValue("SPBAutopilotTargetName")
            if myAutopilotTarget ~= nil and myAutopilotTarget ~= "" and myAutopilotTarget ~= "SatNavNotChanged" then
                local result = jdecode(dbHud_1.getStringValue("SavedLocations"))
                if result ~= nil then
                    SavedLocations = result        
                    local index = -1        
                    local newLocation        
                    for k, v in pairs(SavedLocations) do        
                        if v.name and v.name == "SatNav Location" then                   
                            index = k                
                            break                
                        end            
                    end        
                    if index ~= -1 then       
                        newLocation = SavedLocations[index]            
                        index = -1            
                        for k, v in pairs(atlas[0]) do           
                            if v.name and v.name == "SatNav Location" then               
                                index = k                    
                                break                  
                            end                
                        end            
                        if index > -1 then           
                            atlas[0][index] = newLocation                
                        end            
                        ATLAS.UpdateAtlasLocationsList()           
                        msgText = newLocation.name .. " position updated"            
                    end       
                end
    
                for i=1,#AtlasOrdered do    
                    if AtlasOrdered[i].name == myAutopilotTarget then
                        AutopilotTargetIndex = i
                        s.print("Index = "..AutopilotTargetIndex.." "..AtlasOrdered[i].name)          
                        ATLAS.UpdateAutopilotTarget()
                        dbHud_1.setStringValue("SPBAutopilotTargetName", "SatNavNotChanged")
                        break            
                    end     
                end
            end
        end
        
        function ap.onFlush()
            -- Local functions for onFlush
                local function composeAxisAccelerationFromTargetSpeedV(commandAxis, targetSpeed)
    
                    local axisCRefDirection = vec3()
                    local axisWorldDirection = vec3()
                
                    if (commandAxis == axisCommandId.longitudinal) then
                        axisCRefDirection = vec3(C.getOrientationForward())
                        axisWorldDirection = constructForward
                    elseif (commandAxis == axisCommandId.vertical) then
                        axisCRefDirection = vec3(C.getOrientationUp())
                        axisWorldDirection = constructUp
                    elseif (commandAxis == axisCommandId.lateral) then
                        axisCRefDirection = vec3(C.getOrientationRight())
                        axisWorldDirection = constructRight
                    else
                        return vec3()
                    end
                
                    local gravityAcceleration = vec3(c.getWorldGravity())
                    local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
                
                    local airResistanceAcceleration = vec3(C.getWorldAirFrictionAcceleration())
                    local airResistanceAccelerationCommand = airResistanceAcceleration:dot(axisWorldDirection)
                
    
                    local currentAxisSpeedMS = coreVelocity:dot(axisCRefDirection)
                
                    local targetAxisSpeedMS = targetSpeed * constants.kph2m
                
                    if targetSpeedPID2 == nil then -- CHanged first param from 1 to 10...
                        targetSpeedPID2 = pid.new(10, 0, 10.0) -- The PID used to compute acceleration to reach target speed
                    end
                
                    targetSpeedPID2:inject(targetAxisSpeedMS - currentAxisSpeedMS) -- update PID
                
                    local accelerationCommand = targetSpeedPID2:get()
                
                    local finalAcceleration = (accelerationCommand - airResistanceAccelerationCommand - gravityAccelerationCommand) * axisWorldDirection  -- Try to compensate air friction
                
                    -- The hell are these? Uncommented recently just in case they were important
                    --s.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
                    --s.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())
                
                    return finalAcceleration
                end
    
                local function composeAxisAccelerationFromTargetSpeed(commandAxis, targetSpeed)
    
                    local axisCRefDirection = vec3()
                    local axisWorldDirection = vec3()
                
                    if (commandAxis == axisCommandId.longitudinal) then
                        axisCRefDirection = vec3(C.getOrientationForward())
                        axisWorldDirection = constructForward
                    elseif (commandAxis == axisCommandId.vertical) then
                        axisCRefDirection = vec3(C.getOrientationUp())
                        axisWorldDirection = constructUp
                    elseif (commandAxis == axisCommandId.lateral) then
                        axisCRefDirection = vec3(C.getOrientationRight())
                        axisWorldDirection = constructRight
                    else
                        return vec3()
                    end
                
                    local gravityAcceleration = vec3(c.getWorldGravity())
                    local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
                
                    local airResistanceAcceleration = vec3(C.getWorldAirFrictionAcceleration())
                    local airResistanceAccelerationCommand = airResistanceAcceleration:dot(axisWorldDirection)
                
                    local currentAxisSpeedMS = coreVelocity:dot(axisCRefDirection)
                
                    local targetAxisSpeedMS = targetSpeed * constants.kph2m
                
                    if targetSpeedPID == nil then -- CHanged first param from 1 to 10...
                        targetSpeedPID = pid.new(10, 0, 10.0) -- The PID used to compute acceleration to reach target speed
                    end
                
                    targetSpeedPID:inject(targetAxisSpeedMS - currentAxisSpeedMS) -- update PID
                
                    local accelerationCommand = targetSpeedPID:get()
                
                    local finalAcceleration = (accelerationCommand - airResistanceAccelerationCommand - gravityAccelerationCommand) * axisWorldDirection  -- Try to compensate air friction
                
                    -- The hell are these? Uncommented recently just in case they were important
                    --s.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
                    --s.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())
                
                    return finalAcceleration
                end
    
                local function getPitch(gravityDirection, forward, right)
                
                    local horizontalForward = gravityDirection:cross(right):normalize_inplace() -- Cross forward?
                    local pitch = math.acos(uclamp(horizontalForward:dot(-forward), -1, 1)) * constants.rad2deg -- acos?
                    
                    if horizontalForward:cross(-forward):dot(right) < 0 then
                        pitch = -pitch
                    end -- Cross right dot forward?
                    return pitch
                end
    
                local function checkCollision()
                    if collisionTarget and not BrakeLanding then
                        local body = collisionTarget[1]
                        local far, near = collisionTarget[2],collisionTarget[3] 
                        local collisionDistance = math.min(far, near or far)
                        local collisionTime = collisionDistance/velMag
                        local ignoreCollision = AutoTakeoff and (velMag < 42 or abvGndDet ~= -1)
                        local apAction = (AltitudeHold or VectorToTarget or LockPitch or Autopilot)
                        if apAction and not ignoreCollision and (brakeDistance*1.5 > collisionDistance or collisionTime < 1) then
                            BrakeIsOn = "Collision"
                            apRoute = {}
                            cmdT = 0
                            if AltitudeHold then AP.ToggleAltitudeHold() end
                            if LockPitch then AP.ToggleLockPitch() end
                            msgText = "Autopilot Cancelled due to possible collision"
                            s.print(body.name.." COLLISION "..FormatTimeString(collisionTime).." / "..getDistanceDisplayString(collisionDistance,2))
                            AP.ResetAutopilots(1)
                            StrongBrakes = true
                            if inAtmo then BrakeLanding = true end
                            autoRoll = true
                        end
                        if collisionTime < 11 then 
                            collisionAlertStatus = body.name.." COLLISION "..FormatTimeString(collisionTime).." / "..getDistanceDisplayString(collisionDistance,2)
                        else
                            collisionAlertStatus = body.name.." collision "..FormatTimeString(collisionTime)
                        end
                        if collisionTime < 6 then play("alarm","AL",2) end
                    else
                        collisionAlertStatus = false
                    end
                end
    
            if antigrav and not ExternalAGG then
                if not antigravOn and antigrav.getBaseAltitude() ~= AntigravTargetAltitude then 
                    sba = AntigravTargetAltitude
                end
            end
            if sEFC then
                Nav:setEngineForceCommand('hover', vec3(), 1)
                sEFC = false
            end
            throttleMode = (navCom:getAxisCommandType(0) == axisCommandType.byThrottle)
    
            -- validate params
            pitchSpeedFactor = math.max(pitchSpeedFactor, 0.01)
            yawSpeedFactor = math.max(yawSpeedFactor, 0.01)
            rollSpeedFactor = math.max(rollSpeedFactor, 0.01)
            torqueFactor = math.max(torqueFactor, 0.01)
            brakeSpeedFactor = math.max(brakeSpeedFactor, 0.01)
            brakeFlatFactor = math.max(brakeFlatFactor, 0.01)
            autoRollFactor = math.max(autoRollFactor, 0.01)
            -- final inputs
            local finalPitchInput = uclamp(pitchInput + pitchInput2 + s.getControlDeviceForwardInput(),-1,1)
            local finalRollInput = uclamp(rollInput + rollInput2 + s.getControlDeviceYawInput(),-1,1)
            local finalYawInput = uclamp((yawInput + yawInput2) - s.getControlDeviceLeftRightInput(),-1,1)
            
            local finalBrakeInput = (BrakeIsOn and 1) or 0
    
            -- Axis
            worldVertical = vec3(c.getWorldVertical()) -- along gravity
            if worldVertical == nil or worldVertical:len() == 0 then
                worldVertical = (planet.center - worldPos):normalize() -- I think also along gravity hopefully?
            end
    
            constructUp = vec3(C.getWorldOrientationUp())
            constructForward = vec3(C.getWorldOrientationForward())
            constructRight = vec3(C.getWorldOrientationRight())
            constructVelocity = vec3(C.getWorldVelocity())
            coreVelocity = vec3(C.getVelocity())
            worldPos = vec3(C.getWorldPosition())
            coreMass =  C.getMass()
            velMag = vec3(constructVelocity):len()
            vSpd = -worldVertical:dot(constructVelocity)
            adjustedRoll = getRoll(worldVertical, constructForward, constructRight) 
            local radianRoll = (adjustedRoll / 180) * math.pi
            local corrX = math.cos(radianRoll)
            local corrY = math.sin(radianRoll)
            adjustedPitch = getPitch(worldVertical, constructForward, (constructRight * corrX) + (constructUp * corrY)) 
    
            local constructVelocityDir = constructVelocity:normalize()
            local currentRollDegAbs = mabs(adjustedRoll)
            local currentRollDegSign = utils.sign(adjustedRoll)
    
            -- Rotation
            local constructAngularVelocity = vec3(C.getWorldAngularVelocity())
            local targetAngularVelocity =
                finalPitchInput * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward +
                    finalYawInput * yawSpeedFactor * constructUp
    
    
            if autoRoll == true and worldVertical:len() > 0.01 then
                -- autoRoll on AND adjustedRoll is big enough AND player is not rolling
                local currentRollDelta = mabs(targetRoll-adjustedRoll)
                if ((( ProgradeIsOn or Reentry or BrakeLanding or spaceLand or AltitudeHold or IntoOrbit) and currentRollDelta > 0) or
                    (inAtmo and currentRollDelta < autoRollRollThreshold and autoRollPreference))  
                    and finalRollInput == 0 and mabs(adjustedPitch) < 85 then
                    local targetRollDeg = targetRoll
                    local rollFactor = autoRollFactor
                    if not inAtmo then
                        rollFactor = rollFactor/4 -- Better or worse, you think?
                        targetRoll = 0 -- Always roll to 0 out of atmo
                        targetRollDeg = 0
                    end
                    if (rollPID == nil) then
                        rollPID = pid.new(rollFactor * 0.01, 0, rollFactor * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                    end
                    rollPID:inject(targetRollDeg - adjustedRoll)
                    local autoRollInput = rollPID:get()
                    targetAngularVelocity = targetAngularVelocity + autoRollInput * constructForward
                end
            end
    
    
            -- Engine commands
            local keepCollinearity = 1 -- for easier reading
            local dontKeepCollinearity = 0 -- for easier reading
            local tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities
    
            brakeInput2 = 0
    
        -- Start old APTick Code 
            atmosDensity = atmosphere()
            inAtmo = false or (coreAltitude < planet.noAtmosphericDensityAltitude and atmosDensity > 0.00001 )
    
            coreAltitude = c.getAltitude()
            abvGndDet = AboveGroundLevel()
            time = systime()
            lastApTickTime = time
    
            if GearExtended and abvGndDet > -1 and (abvGndDet - 3) < LandingGearGroundHeight then
                if navCom.targetGroundAltitudeActivated then 
                    navCom:deactivateGroundEngineAltitudeStabilization()
                end
            end        
    
            if RADAR then
                parseRadar = not parseRadar
                if parseRadar then 
                    RADAR.UpdateRadar()
                end
                if CollisionSystem then checkCollision() end
            end
    
            if antigrav then
                antigravOn = (antigrav.isActive() == 1)
            end
    
    
            local MousePitchFactor = 1 -- Mouse control only
            local MouseYawFactor = 1 -- Mouse control only
            local deltaTick = time - lastApTickTime
            local currentYaw = -math.deg(signedRotationAngle(constructUp, constructVelocity, constructForward))
            local currentPitch = math.deg(signedRotationAngle(constructRight, constructVelocity, constructForward)) -- Let's use a consistent func that uses global velocity
            local up = worldVertical * -1
    
            stalling = inAtmo and currentYaw < -YawStallAngle or currentYaw > YawStallAngle or currentPitch < -PitchStallAngle or currentPitch > PitchStallAngle
            local deltaX = s.getMouseDeltaX()
            local deltaY = s.getMouseDeltaY()
            
            if lastMouseTime then
                local elapsed = systime()-lastMouseTime
                -- Aim for 60fps?
                deltaX = deltaX * (elapsed/0.016)
                deltaY = deltaY * (elapsed/0.016)
            end
            lastMouseTime = systime()
            if InvertMouse and not holdingShift then deltaY = -deltaY end
            yawInput2 = 0
            rollInput2 = 0
            pitchInput2 = 0
            sys = galaxyReference[0]
            local cWorldPos = C.getWorldPosition()
            planet = sys:closestBody(cWorldPos)
            kepPlanet = Kep(planet)
            orbit = kepPlanet:orbitalParameters(cWorldPos, constructVelocity)
            if coreAltitude == 0 then
                coreAltitude = (worldPos - planet.center):len() - planet.radius
            end
            nearPlanet = u.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000)
    
            local gravity = planet:getGravity(cWorldPos):len() * coreMass
            targetRoll = 0
            local maxKinematicUp = C.getMaxThrustAlongAxis("ground", C.getOrientationUp())[1]
    
            if sivl == 0 then
                if isRemote() == 1 and holdingShift then
                    if not Animating then
                        simulatedX = uclamp(simulatedX + deltaX/2,-resolutionWidth/2,resolutionWidth/2)
                        simulatedY = uclamp(simulatedY + deltaY/2,-resolutionHeight/2,resolutionHeight/2)
                    end
                else
                    simulatedX = 0
                    simulatedY = 0 -- Reset after they do view things, and don't keep sending inputs while unlocked view
                    -- Except of course autopilot, which is later.
                end
            else
                simulatedX = uclamp(simulatedX + deltaX/2,-resolutionWidth/2,resolutionWidth/2)
                simulatedY = uclamp(simulatedY + deltaY/2,-resolutionHeight/2,resolutionHeight/2)
                mouseDistance = msqrt(simulatedX * simulatedX + simulatedY * simulatedY)
                if not holdingShift and isRemote() == 0 then -- Draw deadzone circle if it's navigating
                    local dx,dy = 1,1
                    if SelectedTab == "SCOPE" then
                        dx,dy = (scopeFOV/90),(scopeFOV/90)
                    end
                    if userControlScheme == "virtual joystick" then -- Virtual Joystick
                        -- Do navigation things
    
                        if mouseDistance > DeadZone then
                            yawInput2 = yawInput2 - (uclamp(mabs(simulatedX)-DeadZone,0,resolutionWidth/2)*utils.sign(simulatedX)) * MouseXSensitivity * dx
                            pitchInput2 = pitchInput2 - (uclamp(mabs(simulatedY)-DeadZone,0,resolutionHeight/2)*utils.sign(simulatedY)) * MouseYSensitivity * dy
                        end
                    else
                        simulatedX = 0
                        simulatedY = 0
                        if userControlScheme == "mouse" then -- Mouse Direct
                            pitchInput2 = (-utils.smoothstep(deltaY, -100, 100) + 0.5) * 2 * MousePitchFactor
                            yawInput2 = (-utils.smoothstep(deltaX, -100, 100) + 0.5) * 2 * MouseYawFactor
                        end
                    end
                end
            end
    
            local isWarping = (velMag > 27777)
    
            if velMag > SpaceSpeedLimit/3.6 and not inAtmo and not Autopilot and not isWarping then
                msgText = "Space Speed Engine Shutoff reached"
                cmdT = 0
            end
    
            if not isWarping and LastIsWarping then
                if not BrakeIsOn then
                    AP.BrakeToggle()
                end
                if Autopilot then
                    AP.ResetAutopilots(1)
                end
                cmdT = 0
            end
            LastIsWarping = isWarping
    
            if atmosDensity > 0.09 then
                if velMag > (adjustedAtmoSpeedLimit / 3.6) and not AtmoSpeedAssist and not speedLimitBreaking then
                        BrakeIsOn = "SpdLmt"
                        speedLimitBreaking  = true
                elseif not AtmoSpeedAssist and speedLimitBreaking then
                    if velMag < (adjustedAtmoSpeedLimit / 3.6) then
                        BrakeIsOn = false
                        speedLimitBreaking = false
                    end
                end    
            end
    
            if ProgradeIsOn then
                if spaceLand then 
                    BrakeIsOn = false -- wtf how does this keep turning on, and why does it matter if we're in cruise?
                    local aligned = false
                    if CustomTarget and spaceLand == true then
                        aligned = AlignToWorldVector(CustomTarget.position-worldPos,0.1) 
                    else
                        aligned = AlignToWorldVector(vec3(constructVelocity),0.01) 
                    end
                    autoRoll = true
                    if aligned then
                        cmdC = mfloor(adjustedAtmoSpeedLimit)
                        if (mabs(adjustedRoll) < 2 or mabs(adjustedPitch) > 85) and velMag >= adjustedAtmoSpeedLimit/3.6-1 then
                            -- Try to force it to get full speed toward target, so it goes straight to throttle and all is well
                            BrakeIsOn = false
                            ProgradeIsOn = false
                            if spaceLand ~= 2 then reentryMode = true end
                            if spaceLand == true then finalLand = true end
                            spaceLand = false
                            Autopilot = false
                            --autoRoll = autoRollPreference   
                            AP.BeginReentry()
                        end
                    elseif inAtmo and AtmoSpeedAssist then 
                        cmdT = 1
                    end
                elseif velMag > minAutopilotSpeed then
                    AlignToWorldVector(vec3(constructVelocity),0.01) 
                end
            end
    
            if RetrogradeIsOn then
                if inAtmo then 
                    RetrogradeIsOn = false
                elseif velMag > minAutopilotSpeed then -- Help with div by 0 errors and careening into terrain at low speed
                    AlignToWorldVector(-(vec3(constructVelocity)))
                end
            end
    
            if not ProgradeIsOn and spaceLand and not IntoOrbit then 
                if not inAtmo then 
                    if spaceLand ~= 2 then reentryMode = true end
                    AP.BeginReentry()
                    spaceLand = false
                    finalLand = true
                else
                    spaceLand = false
                    if not aptoggle then aptoggle = true end
                end
            end
    
            if finalLand and CustomTarget and (coreAltitude < (HoldAltitude + 250) and coreAltitude > (HoldAltitude - 250)) and ((velMag*3.6) > (adjustedAtmoSpeedLimit-250)) and mabs(vSpd) < 25 and atmosDensity >= 0.1
                and (CustomTarget.position-worldPos):len() > 2000 + coreAltitude then -- Only engage if far enough away to be able to turn back for it
                    if not aptoggle then aptoggle = true end
                finalLand = false
            end
    
            if VertTakeOff then
                autoRoll = true
                local targetAltitude = HoldAltitude
                if vSpd < -30 then -- saftey net
                    msgText = "Unable to achieve lift. Safety Landing."
                    upAmount = 0
                    autoRoll = autoRollPreference
                    VertTakeOff = false
                    BrakeLanding = true
                elseif (not ExternalAGG and antigravOn) or HoldAltitude < planet.spaceEngineMinAltitude then
                    if antigravOn then targetAltitude = antigrav.getBaseAltitude() end
                    if coreAltitude < (targetAltitude - 100) then
                        VtPitch = 0
                        upAmount = 15
                        BrakeIsOn = false
                    elseif vSpd > 0 then
                        BrakeIsOn = "VTO Limit"
                        upAmount = 0
                    elseif vSpd < -30 then
                        BrakeIsOn = "VTO Fall"
                        upAmount = 15
                    elseif coreAltitude >= targetAltitude then
                        if antigravOn then 
                            if Autopilot or VectorToTarget then
                                AP.ToggleVerticalTakeoff()
    
                            else
                                BrakeIsOn = "VTO Complete"
                                VertTakeOff = false
                            end
                            msgText = "Takeoff complete. Singularity engaged"
                            play("aggLk","AG")
                        else
                            BrakeIsOn = false
                            msgText = "VTO complete. Engaging Horizontal Flight"
                            play("vtoc", "VT")
                            AP.ToggleVerticalTakeoff()
                        end
                        upAmount = 0
                    end
                else
                    if atmosDensity > 0.08 then
                        VtPitch = 0
                        BrakeIsOn = false
                        upAmount = 20
                    elseif atmosDensity < 0.08 and inAtmo then
                        BrakeIsOn = false
                        if SpaceEngineVertDn then
                            VtPitch = 0
                            upAmount = 20
                        else
                            upAmount = 0
                            VtPitch = 36
                            cmdC = 3500
                        end
                    else
                        autoRoll = autoRollPreference
                        IntoOrbit = true
                        OrbitAchieved = false
                        CancelIntoOrbit = false
                        orbitAligned = false
                        orbitPitch = nil
                        orbitRoll = nil
                        if OrbitTargetPlanet == nil then
                            OrbitTargetPlanet = planet
                        end
                        OrbitTargetOrbit = targetAltitude
                        OrbitTargetSet = true
                        VertTakeOff = false
                    end
                end
                if VtPitch ~= nil then
                    if (vTpitchPID == nil) then
                        vTpitchPID = pid.new(2 * 0.01, 0, 2 * 0.1)
                    end
                    local vTpitchDiff = uclamp(VtPitch-adjustedPitch, -PitchStallAngle*0.80, PitchStallAngle*0.80)
                    vTpitchPID:inject(vTpitchDiff)
                    local vTPitchInput = uclamp(vTpitchPID:get(),-1,1)
                    pitchInput2 = vTPitchInput
                end
            end
    
            if IntoOrbit then
                local function orbitCheck()
                    if (orbit.periapsis.altitude >= OrbitTargetOrbit*0.99 and orbit.apoapsis.altitude >= OrbitTargetOrbit*0.99 and 
                                orbit.periapsis.altitude < orbit.apoapsis.altitude and orbit.periapsis.altitude*1.05 >= orbit.apoapsis.altitude) and 
                                mabs(OrbitTargetOrbit - coreAltitude) < 1000 then
                        return true
                    else
                        return false
                    end
                end
                local targetVec
                local yawAligned = false
                local orbitHeightString = getDistanceDisplayString(OrbitTargetOrbit)
    
                if OrbitTargetPlanet == nil then
                    OrbitTargetPlanet = planet
                    if VectorToTarget then
                        OrbitTargetPlanet = autopilotTargetPlanet
                    end
                end
                if not OrbitTargetSet then
                    OrbitTargetOrbit = mfloor(OrbitTargetPlanet.radius + OrbitTargetPlanet.surfaceMaxAltitude + LowOrbitHeight)
                    if OrbitTargetPlanet.hasAtmosphere then
                        OrbitTargetOrbit = mfloor(OrbitTargetPlanet.radius + OrbitTargetPlanet.noAtmosphericDensityAltitude + LowOrbitHeight)
                    end
                    OrbitTargetSet = true
                end     
    
                if orbitalParams.VectorToTarget and CustomTarget then
                    targetVec = CustomTarget.position - worldPos
                end
                local escapeVel, endSpeed = Kep(OrbitTargetPlanet):escapeAndOrbitalSpeed((worldPos -OrbitTargetPlanet.center):len()-OrbitTargetPlanet.radius)
                local orbitalRoll = adjustedRoll
                -- Getting as close to orbit distance as comfortably possible
                if not orbitAligned then
                    local pitchAligned = false
                    local rollAligned = false
                    cmdT = 0
                    orbitRoll = 0
                    orbitMsg = "Aligning to orbital path - OrbitHeight: "..orbitHeightString
    
                    if orbitalParams.VectorToTarget then
                        AlignToWorldVector(targetVec:normalize():project_on_plane(worldVertical)) -- Returns a value that wants both pitch and yaw to align, which we don't do
                        yawAligned = constructForward:dot(targetVec:project_on_plane(constructUp):normalize()) > 0.95
                    else
                        AlignToWorldVector(constructVelocity)
                        yawAligned = currentYaw < 0.5
                        if velMag < 150 then yawAligned = true end-- Low velocities can never truly align yaw
                    end
                    pitchInput2 = 0
                    orbitPitch = 0
                    if adjustedPitch <= orbitPitch+2 and adjustedPitch >= orbitPitch-2 then
                        pitchAligned = true
                    else
                        pitchAligned = false
                    end
                    if orbitalRoll <= orbitRoll+2 and orbitalRoll >= orbitRoll-2 then
                        rollAligned = true
                    else
                        rollAligned = false
                    end
                    if pitchAligned and rollAligned and yawAligned then
                        orbitPitch = nil
                        orbitRoll = nil
                        orbitAligned = true
                    end
                else
                    if orbitalParams.VectorToTarget then
                        AlignToWorldVector(targetVec:normalize():project_on_plane(worldVertical))
                    elseif velMag > 150 then
                        AlignToWorldVector(constructVelocity)
                    end
                    pitchInput2 = 0
                    if orbitalParams.VectorToTarget and CustomTarget then
                        -- Orbit to target...
    
                        local brakeDistance, _ =  Kinematic.computeDistanceAndTime(velMag, adjustedAtmoSpeedLimit/3.6, coreMass, 0, 0, LastMaxBrake)
                        if OrbitAchieved and targetVec:len() > 15000+brakeDistance+coreAltitude then -- Triggers when we get close to passing it or within 15km+height I guess
                            orbitMsg = "Orbiting to Target"
                            if (coreAltitude - 100) <= OrbitTargetPlanet.noAtmosphericDensityAltitude or  (travelTime> orbit.timeToPeriapsis and  orbit.periapsis.altitude  < OrbitTargetPlanet.noAtmosphericDensityAltitude) or 
                                (not orbitCheck() and orbit.eccentricity > 0.1) then 
                                msgText = "Re-Aligning Orbit"
                                OrbitAchieved = false 
                            end
                        elseif OrbitAchieved or targetVec:len() < 15000+brakeDistance+coreAltitude then
                            msgText = "Orbit complete, proceeding with reentry"
                            play("orCom", "OB")
                            -- We can skip prograde completely if we're approaching from an orbit?
                            --BrakeIsOn = false -- Leave brakes on to be safe while we align prograde
                            AutopilotTargetCoords = CustomTarget.position -- For setting the waypoint
                            reentryMode = true
                            finalLand = true
                            orbitalParams.VectorToTarget, orbitalParams.AutopilotAlign = false, false -- Let it disable orbit
                            AP.ToggleIntoOrbit()
                            AP.BeginReentry()
                            return
                        end
                    end
                    if orbit.periapsis ~= nil and orbit.apoapsis ~= nil and orbit.eccentricity < 1 and coreAltitude > OrbitTargetOrbit*0.9 and coreAltitude < OrbitTargetOrbit*1.4 then
                        if orbit.apoapsis ~= nil then
                            if orbitCheck() or OrbitAchieved then -- This should get us a stable orbit within 10% with the way we do it
                                if OrbitAchieved then
                                    BrakeIsOn = false
                                    cmdT = 0
                                    orbitPitch = 0
                                    
                                    if not orbitalParams.VectorToTarget then
                                        msgText = "Orbit complete"
                                        play("orCom", "OB")
                                        AP.ToggleIntoOrbit()
                                    end
                                else
                                    OrbitTicks = OrbitTicks + 1 -- We want to see a good orbit for 2 consecutive ticks plz
                                    if OrbitTicks >= 2 then
                                        OrbitAchieved = true
                                    end
                                end
                                
                            else
                                orbitMsg = "Adjusting Orbit - OrbitHeight: "..orbitHeightString
                                orbitalRecover = true
                                -- Just set cruise to endspeed...
                                cmdC = endSpeed*3.6+1
                                -- And set pitch to something that scales with vSpd
                                -- Well, a pid is made for this stuff
                                local altDiff = OrbitTargetOrbit - coreAltitude
    
                                if (VSpdPID == nil) then
                                    VSpdPID = pid.new(0.1, 0, 1 * 0.1)
                                end
                                -- Scale vspd up to cubed as altDiff approaches 0, starting at 2km
                                -- 20's are kinda arbitrary but I've tested lots of others and these are consistent
                                -- The 2000's also.  
                                -- Also the smoothstep might not be entirely necessary alongside the cubing but, I'm sure it helps...
                                -- Well many of the numbers changed, including the cubing but.  This looks amazing.  
                                VSpdPID:inject(altDiff-vSpd*uclamp((utils.smoothstep(2000-altDiff,-2000,2000))^6*10,1,10)) 
                                
    
                                orbitPitch = uclamp(VSpdPID:get(),-60,60) -- Prevent it from pitching so much that cruise starts braking
                                
                            end
                        end
                    else
                        local orbitalMultiplier = 2.75
                        local pcs = mabs(round(escapeVel*orbitalMultiplier))
                        local mod = pcs%50
                        if mod > 0 then pcs = (pcs - mod) + 50 end
                        BrakeIsOn = false
                        if coreAltitude < OrbitTargetOrbit*0.8 then
                            orbitMsg = "Escaping planet gravity - OrbitHeight: "..orbitHeightString
                            orbitPitch = utils.map(vSpd, 200, 0, -15, 80)
                        elseif coreAltitude >= OrbitTargetOrbit*0.8 and coreAltitude < OrbitTargetOrbit*1.15 then
                            orbitMsg = "Approaching orbital corridor - OrbitHeight: "..orbitHeightString
                            pcs = pcs*0.75
                            orbitPitch = utils.map(vSpd, 100, -100, -15, 65)
                        elseif coreAltitude >= OrbitTargetOrbit*1.15 and coreAltitude < OrbitTargetOrbit*1.5 then
                            orbitMsg = "Approaching orbital corridor - OrbitHeight: "..orbitHeightString
                            pcs = pcs*0.75
                            if vSpd < 0 or orbitalRecover then
                                orbitPitch = utils.map(coreAltitude, OrbitTargetOrbit*1.5, OrbitTargetOrbit*1.01, -30, 0) -- Going down? pitch up.
                                --orbitPitch = utils.map(vSpd, 100, -100, -15, 65)
                            else
                                orbitPitch = utils.map(coreAltitude, OrbitTargetOrbit*0.99, OrbitTargetOrbit*1.5, 0, 30) -- Going up? pitch down.
                            end
                        elseif coreAltitude > OrbitTargetOrbit*1.5 then
                            orbitMsg = "Reentering orbital corridor - OrbitHeight: "..orbitHeightString
                            orbitPitch = -65 --utils.map(vSpd, 25, -200, -65, -30)
                            local pcsAdjust = utils.map(vSpd, -150, -400, 1, 0.55)
                            pcs = pcs*pcsAdjust
                        end
                        cmdC = mfloor(pcs)
                    end
                end
                if orbitPitch ~= nil then
                    if (OrbitPitchPID == nil) then
                        OrbitPitchPID = pid.new(1 * 0.01, 0, 5 * 0.1)
                    end
                    local orbitPitchDiff = orbitPitch - adjustedPitch
                    OrbitPitchPID:inject(orbitPitchDiff)
                    local orbitPitchInput = uclamp(OrbitPitchPID:get(),-0.5,0.5)
                    pitchInput2 = orbitPitchInput
                end
            end
    
            if Autopilot and not inAtmo and not spaceLand then
                local function finishAutopilot(msg, orbit)
                    s.print(msg)
                    BrakeIsOn = false
                    AutopilotBraking = false
                    Autopilot = false
                    TargetSet = false
                    AutopilotStatus = "Aligning" -- Disable autopilot and reset
                    cmdT = 0
                    apThrottleSet = false
                    msgText = msg
                    play("apCom","AP")
                    if orbit or spaceLand then
                        if orbit and AutopilotTargetOrbit ~= nil and not spaceLand then 
                            if not coreAltitude or coreAltitude == 0 then return end
                            OrbitTargetOrbit = coreAltitude
                            OrbitTargetSet = true
                        end
                        AP.ToggleIntoOrbit()
                    end
                end
                -- Planetary autopilot engaged, we are out of atmo, and it has a target
                -- Do it.  
                -- And tbh we should calc the brakeDistance live too, and of course it's also in meters
                
                -- Maybe instead of pointing at our vector, we point at our vector + how far off our velocity vector is
                -- This is gonna be hard to get the negatives right.
                -- If we're still in orbit, don't do anything, that velocity will suck
                local targetCoords, skipAlign = AutopilotTargetCoords, false
                -- This isn't right.  Maybe, just take the smallest distance vector between the normal one, and the wrongSide calculated one
                --local wrongSide = (CustomTarget.position-worldPos):len() > (autopilotTargetPlanet.center-worldPos):len()
                if CustomTarget and CustomTarget.planetname ~= "Space" then
                    AutopilotRealigned = true -- Don't realign, point straight at the target.  Or rather, at AutopilotTargetOrbit above it
                    if not TargetSet then
                        -- It's on the wrong side of the planet. 
                        -- So, get the 3d direction between our target and planet center.  Note that, this is basically a vector defining gravity at our target, too...
                        local initialDirection = (CustomTarget.position - autopilotTargetPlanet.center):normalize() -- Should be pointing up
                        local finalDirection = initialDirection:project_on_plane((autopilotTargetPlanet.center-worldPos):normalize()):normalize()
                        -- And... actually that's all that I need.  If forward is really gone, this should give us a point on the edge of the planet
                        local wrongSideCoords = autopilotTargetPlanet.center + finalDirection*(autopilotTargetPlanet.radius + AutopilotTargetOrbit)
                        -- This used to be calculated based on our direction instead of gravity, which helped us approach not directly overtop it
                        -- But that caused bad things to happen for nearside/farside detection sometimes
                        local rightSideCoords = CustomTarget.position + (CustomTarget.position - autopilotTargetPlanet.center):normalize() * (AutopilotTargetOrbit - autopilotTargetPlanet:getAltitude(CustomTarget.position))
                        if (worldPos-wrongSideCoords):len() < (worldPos-rightSideCoords):len() then
                            targetCoords = wrongSideCoords
                        else
                            targetCoords = rightSideCoords
                            AutopilotEndSpeed = 0
                        end
                        AutopilotTargetCoords = targetCoords
                        AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords)
    
                        skipAlign = true
                        TargetSet = true -- Only set the targetCoords once.  Don't let them change as we fly.
                    end
                    --AutopilotPlanetGravity = autopilotTargetPlanet.gravity*9.8 -- Since we're aiming straight at it, we have to assume gravity?
                    AutopilotPlanetGravity = 0
                elseif CustomTarget and CustomTarget.planetname == "Space" then
                    if not TargetSet then
                        AutopilotPlanetGravity = 0
                        skipAlign = true
                        AutopilotRealigned = true
                        TargetSet = true
                        -- We forgot to normalize this... though that should have really fucked everything up... 
                        -- Ah also we were using AutopilotTargetOrbit which gets set to 0 for space.  
    
                        -- So we should ... do what, if they're inside that range?  I guess just let it pilot them to outside. 
                        -- TODO: Later have some settable intervals like 10k, 5k, 1k, 500m and have it approach the nearest one that's below it
                        -- With warnings about what it's doing 
    
                        targetCoords = CustomTarget.position + (worldPos - CustomTarget.position):normalize()*AutopilotSpaceDistance
                        AutopilotTargetCoords = targetCoords
                        -- Unsure if we should update the waypoint to the new target or not.  
                        --AP.showWayPoint(autopilotTargetPlanet, targetCoords)
                    end
                elseif CustomTarget == nil then -- and not autopilotTargetPlanet.name == planet.name then
                    AutopilotPlanetGravity = 0
    
                    if not TargetSet then
                        -- Set the target to something on the radius in the direction closest to velocity
                        -- We have to fudge a high velocity because at standstill this can give us bad results
                        local initialDirection = ((worldPos+(constructVelocity*100000)) - autopilotTargetPlanet.center):normalize() -- Should be pointing up
                        local finalDirection = initialDirection:project_on_plane((autopilotTargetPlanet.center-worldPos):normalize()):normalize()
                        if finalDirection:len() < 1 then
                            initialDirection = ((worldPos+(constructForward*100000)) - autopilotTargetPlanet.center):normalize()
                            finalDirection = initialDirection:project_on_plane((autopilotTargetPlanet.center-worldPos):normalize()):normalize() -- Align to nearest to ship forward then
                        end
                        -- And... actually that's all that I need.  If forward is really gone, this should give us a point on the edge of the planet
                        targetCoords = autopilotTargetPlanet.center + finalDirection*(autopilotTargetPlanet.radius + AutopilotTargetOrbit)
                        AutopilotTargetCoords = targetCoords
                        TargetSet = true
                        skipAlign = true
                        AutopilotRealigned = true
                        --AutopilotAccelerating = true
                        AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords)
                    end
                end
                
                AutopilotDistance = (vec3(targetCoords) - worldPos):len()
                local intersectBody, farSide, nearSide = galaxyReference:getPlanetarySystem(0):castIntersections(worldPos, (constructVelocity):normalize(), 
                    function(body) if body.noAtmosphericDensityAltitude > 0 then return (body.radius+body.noAtmosphericDensityAltitude) else return (body.radius+body.surfaceMaxAltitude*1.5) end end)
                local atmoDistance = farSide
                if nearSide ~= nil and farSide ~= nil then
                    atmoDistance = math.min(nearSide,farSide)
                end
                if atmoDistance ~= nil and atmoDistance < AutopilotDistance and intersectBody.name == autopilotTargetPlanet.name then
                    AutopilotDistance = atmoDistance -- If we're going to hit atmo before our target, use that distance instead.
                    -- Can we put this on the HUD easily?
                    --local value, units = getDistanceDisplayString(atmoDistance)
                    --msgText = "Adjusting Brake Distance, will hit atmo in: " .. value .. units
                end
    
                
                -- We do this in tenthSecond already.
                --sysUpData(widgetDistanceText, '{"label": "distance", "value": "' ..
                --    displayText.. '", "u":"' .. displayUnit .. '"}')
                local aligned = true -- It shouldn't be used if the following condition isn't met, but just in case
    
                local projectedAltitude = (autopilotTargetPlanet.center -
                                            (worldPos +
                                                (vec3(constructVelocity):normalize() * AutopilotDistance))):len() -
                                            autopilotTargetPlanet.radius
                local displayText = getDistanceDisplayString(projectedAltitude)
                sudi = widgetTrajectoryAltitudeText 
                sudv = '{"label": "Projected Altitude", "value": "' ..displayText.. '"}'
    
                
    
    
    
                --orbit.apoapsis == nil and 
    
                -- Brought this min velocity way down from 300 because the logic when velocity is low doesn't even point at the target or anything
                -- I'll prob make it do that, too, though.  There was just no reason for this to wait for such high speeds
                if velMag > 50 and AutopilotAccelerating then
                    -- Use signedRotationAngle to get the yaw and pitch angles with shipUp and shipRight as the normals, respectively
                    -- Then use a PID
                    local targetVec = (vec3(targetCoords) - worldPos)
                    local targetYaw = uclamp(math.deg(signedRotationAngle(constructUp, constructVelocity:normalize(), targetVec:normalize()))*(velMag/500),-90,90)
                    local targetPitch = uclamp(math.deg(signedRotationAngle(constructRight, constructVelocity:normalize(), targetVec:normalize()))*(velMag/500),-90,90)
    
                
                    -- If they're both very small, scale them both up a lot to converge that last bit
                    if mabs(targetYaw) < 20 and mabs(targetPitch) < 20 then
                        targetYaw = targetYaw * 2
                        targetPitch = targetPitch * 2
                    end
                    -- If they're both very very small even after scaling them the first time, do it again
                    if mabs(targetYaw) < 2 and mabs(targetPitch) < 2 then
                        targetYaw = targetYaw * 2
                        targetPitch = targetPitch * 2
                    end
    
                    -- We'll do our own currentYaw and Pitch
                    local currentYaw = -math.deg(signedRotationAngle(constructUp, constructForward, constructVelocity:normalize()))
                    local currentPitch = -math.deg(signedRotationAngle(constructRight, constructForward, constructVelocity:normalize()))
    
                    if (apPitchPID == nil) then
                        apPitchPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                    end
                    apPitchPID:inject(targetPitch - currentPitch)
                    local autoPitchInput = uclamp(apPitchPID:get(),-1,1)
    
                    pitchInput2 = pitchInput2 + autoPitchInput
    
                    if (apYawPID == nil) then -- Changed from 2 to 8 to tighten it up around the target
                        apYawPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                    end
                    --yawPID:inject(yawDiff) -- Aim for 85% stall angle, not full
                    apYawPID:inject(targetYaw - currentYaw)
                    local autoYawInput = uclamp(apYawPID:get(),-1,1) -- Keep it reasonable so player can override
                    yawInput2 = yawInput2 + autoYawInput
                    
    
                    skipAlign = true
    
                    if mabs(targetYaw) > 2 or mabs(targetPitch) > 2 then
                        if AutopilotStatus ~= "Adjusting Trajectory" then
                            AutopilotStatus = "Adjusting Trajectory"
                            play("apAdj","AP")
                        end
                    else
                        if AutopilotStatus ~= "Accelerating" then
                            AutopilotStatus = "Accelerating"
                            play("apAcc","AP")
                        end
                    end
                
                elseif AutopilotAccelerating and velMag <= 50 then
                    -- Point at target... 
                    AlignToWorldVector((targetCoords - worldPos):normalize())
                end
    
                if projectedAltitude < AutopilotTargetOrbit*1.5 then
                    AutopilotEndSpeed = adjustedAtmoSpeedLimit/3.6
                    -- Recalc end speeds for the projectedAltitude since it's reasonable... 
                    if CustomTarget == nil then
                        _, AutopilotEndSpeed = Kep(autopilotTargetPlanet):escapeAndOrbitalSpeed(projectedAltitude)
                    end
                end
                local brakeDistance, brakeTime
                
                if not TurnBurn then
                    brakeDistance, brakeTime = GetAutopilotBrakeDistanceAndTime(velMag)
                else
                    brakeDistance, brakeTime = GetAutopilotTBBrakeDistanceAndTime(velMag)
                end
                if Autopilot and not AutopilotAccelerating and not AutopilotCruising and not AutopilotBraking then
                    local intersectBody, atmoDistance = AP.checkLOS( (AutopilotTargetCoords-worldPos):normalize())
                    if autopilotTargetPlanet.name ~= planet.name then 
                        if intersectBody ~= nil and autopilotTargetPlanet.name ~= intersectBody.name and atmoDistance < AutopilotDistance then 
                            msgText = "Collision with "..intersectBody.name.." in ".. getDistanceDisplayString(atmoDistance).."\nClear LOS to continue."
                            msgTimer = 5
                            AutopilotPaused = true
                        else
                            AutopilotPaused = false
                            msgText = ""
                        end
                    end
                end
                if not AutopilotPaused then
                    if not AutopilotCruising and not AutopilotBraking and not skipAlign then
                        aligned = AlignToWorldVector((targetCoords - worldPos):normalize())
                    elseif TurnBurn and (AutopilotBraking or AutopilotCruising) then
                        aligned = AlignToWorldVector(-vec3(constructVelocity):normalize())
                    end
                end
                if AutopilotAccelerating then
                    if not apThrottleSet then
                        BrakeIsOn = false
                        cmdT = AutopilotInterplanetaryThrottle
                        PlayerThrottle = round(AutopilotInterplanetaryThrottle,2)
                        apThrottleSet = true
                    end
                    local throttle = u.getThrottle()
                    if AtmoSpeedAssist then throttle = PlayerThrottle end
                    -- If we're within warmup/8 seconds of needing to brake, cut throttle to handle warmdowns
                    -- Note that warmup/8 is kindof an arbitrary guess.  But it shouldn't matter that much.  
    
                    -- We need the travel time, the one we compute elsewhere includes estimates on acceleration
                    -- Also it doesn't account for velocity not being in the correct direction, this should
                    local timeUntilBrake = 99999 -- Default in case accel and velocity are both 0 
                    local accel = -(vec3(C.getWorldAcceleration()):dot(constructVelocity:normalize()))
                    local velAlongTarget = uclamp(constructVelocity:dot((targetCoords - worldPos):normalize()),0,velMag)
                    if velAlongTarget > 0 or accel > 0 then -- (otherwise divide by 0 errors)
                        timeUntilBrake = Kinematic.computeTravelTime(velAlongTarget, accel, AutopilotDistance-brakeDistance)
                    end
                    if MaxGameVelocity > MaxSpeed then MaxGameVelocity = MaxSpeed - 0.2 end
                    if (coreVelocity:len() >= MaxGameVelocity or (throttle == 0 and apThrottleSet) or warmup/4 > timeUntilBrake) then
                        AutopilotAccelerating = false
                        if AutopilotStatus ~= "Cruising" then
                            play("apCru","AP")
                            AutopilotStatus = "Cruising"
                        end
                        AutopilotCruising = true
                        cmdT = 0
                        --apThrottleSet = false -- We already did it, if they cancelled let them throttle up again
                    end
                    -- Check if accel needs to stop for braking
                    --if brakeForceRequired >= LastMaxBrake then
                    local apDist = AutopilotDistance
                    --if autopilotTargetPlanet.name == "Space" then
                    --    apDist = apDist - AutopilotSpaceDistance
                    --end
    
                    if apDist <= brakeDistance or (PreventPvP and pvpDist <= brakeDistance+10000 and notPvPZone) then
                        if (PreventPvP and pvpDist <= brakeDistance+10000 and notPvPZone) then
                                if pvpDist < lastPvPDist and pvpDist > 2000 then
                                    AP.ResetAutopilots(1)
                                    msgText = "Autopilot cancelled to prevent crossing PvP Line" 
                                    BrakeIsOn = "PvP Prevent"
                                    lastPvPDist = pvpDist
                                else
                                    lastPvPDist = pvpDist
                                    return
                                end
                        end
                        AutopilotAccelerating = false
                        if AutopilotStatus ~= "Braking" then
                            play("apBrk","AP")
                            AutopilotStatus = "Braking"
                        end
                        AutopilotBraking = true
                        cmdT = 0
                        apThrottleSet = false
                    end
                elseif AutopilotBraking then
                    if AutopilotStatus ~= "Orbiting to Target" then
                        BrakeIsOn = "AP Brk"
                    end
                    if TurnBurn then
                        cmdT = 1
                        cmdDS = true
                    end
                    -- Check if an orbit has been established and cut brakes and disable autopilot if so
                    -- We'll try <0.9 instead of <1 so that we don't end up in a barely-orbit where touching the controls will make it an escape orbit
                    -- Though we could probably keep going until it starts getting more eccentric, so we'd maybe have a circular orbit
                    local _, endSpeed = Kep(autopilotTargetPlanet):escapeAndOrbitalSpeed((worldPos-planet.center):len()-planet.radius)
                    
    
                    local targetVec--, targetAltitude, --horizontalDistance
                    if CustomTarget then
                        targetVec = CustomTarget.position - worldPos
                        --targetAltitude = planet:getAltitude(CustomTarget.position)
                        --horizontalDistance = msqrt(targetVec:len()^2-(coreAltitude-targetAltitude)^2)
                    end
                    if (CustomTarget and CustomTarget.planetname == "Space" and velMag < 50) then
                        if #apRoute>0 then
                            if not aptoggle then table.remove(apRoute,1) end
                            if #apRoute>0 then
                                BrakeIsOn = false
                                if not aptoggle then aptoggle = 2 end
                                return
                            end
                        end
                        finishAutopilot("Autopilot complete, arrived at space location")
                        BrakeIsOn = "Space Arrival"
                        -- We only aim for endSpeed even if going straight in, because it gives us a smoother transition to alignment
                    elseif (CustomTarget and CustomTarget.planetname ~= "Space") and velMag <= endSpeed and (orbit.apoapsis == nil or orbit.periapsis == nil or orbit.apoapsis.altitude <= 0 or orbit.periapsis.altitude <= 0) then
                        -- They aren't in orbit, that's a problem if we wanted to do anything other than reenter.  Reenter regardless.                  
                        finishAutopilot("Autopilot complete, commencing reentry")
                        --BrakeIsOn = true
                        --BrakeIsOn = false -- Leave brakes on to be safe while we align prograde
                        AutopilotTargetCoords = CustomTarget.position -- For setting the waypoint
                        --ProgradeIsOn = true  
                        spaceLand = true
                        AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords)
                    elseif ((CustomTarget and CustomTarget.planetname ~= "Space") or CustomTarget == nil) and orbit.periapsis ~= nil and orbit.periapsis.altitude > 0 and orbit.eccentricity < 1 or AutopilotStatus == "Circularizing" then
                        if AutopilotStatus ~= "Circularizing" then
                            play("apCir", "AP")
                            AutopilotStatus = "Circularizing"
                        end
                        if velMag <= endSpeed then 
                            if CustomTarget then
                                if constructVelocity:normalize():dot(targetVec:normalize()) > 0.4 then -- Triggers when we get close to passing it
                                    if AutopilotStatus ~= "Orbiting to Target" then
                                        play("apOrb","OB")
                                        AutopilotStatus = "Orbiting to Target"
                                    end
                                    if not WaypointSet then
                                        BrakeIsOn = false -- We have to set this at least once
                                        AP.showWayPoint(autopilotTargetPlanet, CustomTarget.position)
                                        WaypointSet = true
                                    end
                                else 
                                    finishAutopilot("Autopilot complete, proceeding with reentry")
                                    AutopilotTargetCoords = CustomTarget.position -- For setting the waypoint
                                    --ProgradeIsOn = true
                                    spaceLand = true
                                    AP.showWayPoint(autopilotTargetPlanet, CustomTarget.position)
                                    WaypointSet = false -- Don't need it anymore
                                end
                            else
                                finishAutopilot("Autopilot completed, setting orbit", true)
                                BrakeIsOn = false
                            end
                        end
                    elseif AutopilotStatus == "Circularizing" then
                        finishAutopilot("Autopilot complete, fixing Orbit", true)
                    end
                elseif AutopilotCruising then
                    --if brakeForceRequired >= LastMaxBrake then
                    --if brakeForceRequired >= LastMaxBrake then
                    local apDist = AutopilotDistance
                    --if autopilotTargetPlanet.name == "Space" then
                    --    apDist = apDist - AutopilotSpaceDistance
                    --end
    
                    if apDist <= brakeDistance or (PreventPvP and pvpDist <= brakeDistance+10000 and notPvPZone) then
                        if (PreventPvP and pvpDist <= brakeDistance+10000 and notPvPZone) then
                            if pvpDist < lastPvPDist and pvpDist > 2000 then 
                                if not aptoggle then aptoggle = true end
                                msgText = "Autopilot cancelled to prevent crossing PvP Line" 
                                BrakeIsOn = "Prevent PvP"
                                lastPvPDist = pvpDist
                            else
                                lastPvPDist = pvpDist
                                return
                            end
                        end
                        AutopilotAccelerating = false
                        if AutopilotStatus ~= "Braking" then
                            play("apBrk","AP")
                            AutopilotStatus = "Braking"
                        end
                        AutopilotBraking = true
                    end
                    local throttle = u.getThrottle()
                    if AtmoSpeedAssist then throttle = PlayerThrottle end
                    if throttle > 0 then
                        AutopilotAccelerating = true
                        if AutopilotStatus ~= "Accelerating" then
                            AutopilotStatus = "Accelerating"
                            play("apAcc","AP")
                        end
                        AutopilotCruising = false
                    end
                else
                    -- It's engaged but hasn't started accelerating yet.
                    if aligned then
                        -- Re-align to 200km from our aligned right                    
                        if not AutopilotRealigned and CustomTarget == nil or (not AutopilotRealigned and CustomTarget and CustomTarget.planetname ~= "Space") then
                            if not spaceLand then
                                AutopilotTargetCoords = vec3(autopilotTargetPlanet.center) +
                                                            ((AutopilotTargetOrbit + autopilotTargetPlanet.radius) *
                                                                constructRight)
                                AutopilotShipUp = constructUp
                                AutopilotShipRight = constructRight
                            end
                            AutopilotRealigned = true
                        elseif aligned and not AutopilotPaused then
                                AutopilotAccelerating = true
                                if AutopilotStatus ~= "Accelerating" then
                                    AutopilotStatus = "Accelerating"
                                    play("apAcc","AP")
                                end
                                -- Set throttle to max
                                if not apThrottleSet then
                                    cmdT = AutopilotInterplanetaryThrottle
                                    cmdDS = true
                                    PlayerThrottle = round(AutopilotInterplanetaryThrottle,2)
                                    apThrottleSet = true
                                    BrakeIsOn = false
                                end
                        end
                    end
                    -- If it's not aligned yet, don't try to burn yet.
                end
                -- If we accidentally hit atmo while autopiloting to a custom target, cancel it and go straight to pulling up
            elseif Autopilot and (CustomTarget ~= nil and CustomTarget.planetname ~= "Space" and inAtmo) then
                msgText = "Autopilot complete, starting reentry"
                play("apCom", "AP")
                AutopilotTargetCoords = CustomTarget.position -- For setting the waypoint
                BrakeIsOn = false -- Leaving these on makes it screw up alignment...?
                AutopilotBraking = false
                Autopilot = false
                TargetSet = false
                AutopilotStatus = "Aligning" -- Disable autopilot and reset
                cmdT = 0
                apThrottleSet = false
                ProgradeIsOn = true
                spaceLand = true
                AP.showWayPoint(autopilotTargetPlanet, CustomTarget.position)
            end
    
            if followMode then
                -- User is assumed to be outside the construct
                autoRoll = true -- Let Nav handle that while we're here
                local targetPitch = 0
                -- Keep brake engaged at all times unless: 
                -- Ship is aligned with the target on yaw (roll and pitch are locked to 0)
                -- and ship's speed is below like 5-10m/s
                local pos = worldPos + vec3(u.getMasterPlayerRelativePosition()) -- Is this related to c forward or nah?
                local distancePos = (pos - worldPos)
                -- local distance = distancePos:len()
                -- distance needs to be calculated using only construct forward and right
                local distanceForward = vec3(distancePos):project_on(constructForward):len()
                local distanceRight = vec3(distancePos):project_on(constructRight):len()
                local distance = msqrt(distanceForward * distanceForward + distanceRight * distanceRight)
                AlignToWorldVector(distancePos:normalize())
                local targetDistance = 40
                -- local onShip = false
                -- if distanceDown < 1 then 
                --    onShip = true
                -- end
                local nearby = (distance < targetDistance)
                local maxSpeed = 100 -- Over 300kph max, but, it scales down as it approaches
                local targetSpeed = uclamp((distance - targetDistance) / 2, 10, maxSpeed)
                pitchInput2 = 0
                local aligned = (mabs(yawInput2) < 0.1)
                if (aligned and velMag < targetSpeed and not nearby) then -- or (not BrakeIsOn and onShip) then
                    -- if not onShip then -- Don't mess with brake if they're on ship
                    BrakeIsOn = false
                    -- end
                    targetPitch = -20
                else
                    -- if not onShip then
                    BrakeIsOn = "Follow"
                    -- end
                    targetPitch = 0
                end
                
                local autoPitchThreshold = 0
                -- Copied from autoroll let's hope this is how a PID works... 
                if mabs(targetPitch - adjustedPitch) > autoPitchThreshold then
                    if (pitchPID == nil) then
                        pitchPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                    end
                    pitchPID:inject(targetPitch - adjustedPitch)
                    local autoPitchInput = pitchPID:get()
    
                    pitchInput2 = autoPitchInput
                end
            end
    
            if AltitudeHold or BrakeLanding or Reentry or VectorToTarget or LockPitch ~= nil then 
                -- We want current brake value, not max
                local curBrake = LastMaxBrakeInAtmo
                if curBrake then
                    curBrake = curBrake * uclamp(velMag/100,0.1,1) * atmosDensity
                else
                    curBrake = LastMaxBrake
                end
                if not inAtmo then
                    curBrake = LastMaxBrake -- Assume space brakes
                end
    
                hSpd = constructForward:project_on_plane(worldVertical):normalize():dot(constructVelocity)
    
                if hSpd > 100 then 
                    brakeDistance, brakeTime = Kinematic.computeDistanceAndTime(hSpd, 100, coreMass, 0, 0,
                                                    curBrake)
    
                    local lastDist, brakeTime2 = Kinematic.computeDistanceAndTime(100, 0, coreMass, 0, 0, curBrake*0.55)
                    brakeDistance = brakeDistance + lastDist
                else 
                    brakeDistance, brakeTime = Kinematic.computeDistanceAndTime(hSpd, 0, coreMass, 0, 0, curBrake*0.55)
                end
                -- HoldAltitude is the alt we want to hold at
    
                -- Dampen this.
    
                -- Consider: 100m below target, but 30m/s vspeed.  We should pitch down.  
                -- Or 100m above and -30m/s vspeed.  So (Hold-Core) - vspd
                -- Scenario 1: Hold-c = -100.  Scen2: Hold-c = 100
                -- 1: 100-30 = 70     2: -100--30 = -70
                --if not ExternalAGG and antigravOn and not Reentry and HoldAltitude < antigrav.getBaseAltitude() then p("HERE3") HoldAltitude = antigrav.getBaseAltitude() end
                local altDiff = (HoldAltitude - coreAltitude) - vSpd -- Maybe a multiplier for vSpd here...
                -- This may be better to smooth evenly regardless of HoldAltitude.  Let's say, 2km scaling?  Should be very smooth for atmo
                -- Even better if we smooth based on their velocity
                local minmax = 200+velMag -- Previously 500+
                if Reentry or spaceLand then minMax = 2000+velMag end -- Smoother reentries
                -- Smooth the takeoffs with a velMag multiplier that scales up to 100m/s
                local velMultiplier = 1
                if AutoTakeoff then velMultiplier = uclamp(velMag/100,0.1,1) end
                local targetPitch = (utils.smoothstep(altDiff, -minmax, minmax) - 0.5) * 2 * MaxPitch * velMultiplier
    
                            -- not inAtmo and
                if not Reentry and not spaceLand and not VectorToTarget and constructForward:dot(constructVelocity:normalize()) < 0.99 then
                    -- Widen it up and go much harder based on atmo level if we're exiting atmo and velocity is keeping up with the nose
                    -- I.e. we have a lot of power and need to really get out of atmo with that power instead of feeding it to speed
                    -- Scaled in a way that no change up to 10% atmo, then from 10% to 0% scales to *20 and *2
                    targetPitch = (utils.smoothstep(altDiff, -minmax*uclamp(20 - 19*atmosDensity*10,1,20), minmax*uclamp(20 - 19*atmosDensity*10,1,20)) - 0.5) * 2 * MaxPitch * uclamp(2 - atmosDensity*10,1,2) * velMultiplier
                end
    
                if not AltitudeHold then
                    targetPitch = 0
                end
                if LockPitch ~= nil then 
                    if nearPlanet and not IntoOrbit then 
                        targetPitch = LockPitch 
                    else
                        LockPitch = nil
                    end
                end
                autoRoll = true
    
                local oldInput = pitchInput2 
                if Reentry then
    
                    local ReentrySpeed = mfloor(adjustedAtmoSpeedLimit)
    
                    local brakeDistancer, brakeTimer = Kinematic.computeDistanceAndTime(velMag, ReentrySpeed/3.6, coreMass, 0, 0, LastMaxBrake - planet.gravity*9.8*coreMass)
                    brakeDistancer = brakeDistancer == -1 and 5000 or brakeDistancer
                    local distanceToTarget = coreAltitude - (planet.noAtmosphericDensityAltitude + brakeDistancer)
                    local freeFallHeight = coreAltitude > (planet.noAtmosphericDensityAltitude + brakeDistancer*1.35)
                    if freeFallHeight then
                        targetPitch = ReEntryPitch
                        if velMag <= ReentrySpeed/3.6 and velMag > (ReentrySpeed/3.6)-10 and mabs(constructVelocity:normalize():dot(constructForward)) > 0.9 and not throttleMode then
                            WasInCruise = false
                            cmdT = 1
                        end
                    elseif (throttleMode or navCom:getTargetSpeed(axisCommandId.longitudinal) ~= ReentrySpeed) and not freeFallHeight and not inAtmo then 
                        cmdC = ReentrySpeed
                        cmdDS = true
                    end
                    if throttleMode then
                        if velMag > ReentrySpeed/3.6 and not freeFallHeight then
                            BrakeIsOn = "Reentry Limit"
                            if PlayerThrottle > 0 then cmdT = 0 end
                        else
                            BrakeIsOn = false
                        end
                    else
                        BrakeIsOn = false
                    end
                    if vSpd > 0 then BrakeIsOn = "Reentry vSpd" end
                    if not reentryMode then
                        targetPitch = -80
                        if coreAltitude < (planet.surfaceMaxAltitude+(planet.atmosphereThickness-planet.surfaceMaxAltitude)*0.25) then
                            msgText = "PARACHUTE DEPLOYED at "..round(coreAltitude,0)
                            Reentry = false
                            BrakeLanding = true
                            StrongBrakes = true
                            cmdT = 0
                            targetPitch = 0
                            autoRoll = autoRollPreference
                        end
                    elseif planet.noAtmosphericDensityAltitude > 0 and freeFallHeight then -- 5km is good
    
                        autoRoll = true -- It shouldn't actually do it, except while aligning
                    elseif not freeFallHeight then
                        if not inAtmo and (throttleMode or navCom:getTargetSpeed(axisCommandId.longitudinal) ~= ReentrySpeed) then 
                            cmdC = ReentrySpeed
                        end
                        if velMag < ((ReentrySpeed/3.6)+1) then
                            BrakeIsOn = false
                            reentryMode = false
                            Reentry = false
                            autoRoll = true 
                            cmdT = 1
                        end
                    end
                end
                if velMag > minAutopilotSpeed and not spaceLaunch and not VectorToTarget and not BrakeLanding and ForceAlignment then -- When do we even need this, just alt hold? lol
                    AlignToWorldVector(vec3(constructVelocity))
                end
                if ReversalIsOn or ((VectorToTarget or spaceLaunch) and AutopilotTargetIndex > 0 and inAtmo) then
                    local targetVec
                    if ReversalIsOn then
                        if type(ReversalIsOn) == "table" then
                            targetVec = ReversalIsOn
                        elseif ReversalIsOn < 3 and ReversalIsOn > 0 then
                           targetVec = -worldVertical:cross(constructVelocity)*5000
                        elseif ReversalIsOn >= 3 then
                            targetVec = worldVertical:cross(constructVelocity)*5000
                        elseif ReversalIsOn < 0 then
                            targetVec = constructVelocity*25000
                        end
                    elseif CustomTarget ~= nil then
                        targetVec = CustomTarget.position - worldPos
                    else
                        targetVec = autopilotTargetPlanet.center - worldPos
                    end
    
                    local targetYaw = math.deg(signedRotationAngle(worldVertical:normalize(),constructVelocity,targetVec))*2
                    local rollRad = math.rad(mabs(adjustedRoll))
                    if velMag > minRollVelocity and inAtmo then
                        local rollminmax = 1000+velMag -- Roll should taper off within 1km instead of 100m because it's aggressive
                        -- And should also very aggressively use vspd so it can counteract high rates of ascent/descent
                        -- Otherwise this matches the formula to calculate targetPitch
                        local rollAltitudeLimiter = (utils.smoothstep(altDiff-vSpd*10, -rollminmax, rollminmax) - 0.5) * 2 * MaxPitch
                        local maxRoll = uclamp(90-rollAltitudeLimiter,0,180) -- Reverse roll to fix altitude seems good (max 180 instead of max 90)
                        targetRoll = uclamp(targetYaw*2, -maxRoll, maxRoll)
                        local origTargetYaw = targetYaw
                        -- 4x weight to pitch consideration because yaw is often very weak compared and the pid needs help?
                        targetYaw = uclamp(uclamp(targetYaw,-YawStallAngle*0.80,YawStallAngle*0.80)*math.cos(rollRad) + 4*(adjustedPitch-targetPitch)*math.sin(math.rad(adjustedRoll)),-YawStallAngle*0.80,YawStallAngle*0.80) -- We don't want any yaw if we're rolled
                        -- While this already should only pitch based on current roll, it still pitches early, resulting in altitude increase before the roll kicks in
                        -- I should adjust the first part so that when rollRad is relatively far from targetRoll, it is lower
                        local rollMatchMult = 1
                        if targetRoll ~= 0 then
                            rollMatchMult = mabs(rollRad/targetRoll) -- Should scale from 0 to 1... 
                        -- Such that if target is 90 and roll is 0, we have 0%.  If it's 90 and roll is 80, we have 8/9 
                        end
                        -- But if we're going say from 90 to 0, that's bad.  
                        -- We need to definitely subtract. 
                        -- Then basically on a scale from 0 to 90 is fine enough, a little arbitrary
                        rollMatchMult = (90-uclamp(mabs(targetRoll-adjustedRoll),0,90))/90
                        -- So if we're 90 degrees apart, it does 0%, if we're 10 degrees apart it does 8/9
                        -- We should really probably also apply that to altitude pitching... but I won't, not unless I see something needing it
                        -- Also it could use some scaling otherwise tho, it doesn't pitch enough.  Taking off the min/max 0.8 to see if that helps... 
                        -- Dont think it did.  Let's do a static scale
                        -- Yeah that went pretty crazy in a bad way.  Which is weird.  It started bouncing between high and low pitch while rolled
                        -- Like the rollRad or something is dependent on velocity vector.  It also immediately rolled upside down... 
                        local rollPitch = targetPitch
                        if mabs(adjustedRoll) > 90 then rollPitch = -rollPitch end
                        targetPitch = rollMatchMult*uclamp(uclamp(rollPitch*math.cos(rollRad),-PitchStallAngle*0.8,PitchStallAngle*0.8) + mabs(uclamp(mabs(origTargetYaw)*math.sin(rollRad),-PitchStallAngle*0.80,PitchStallAngle*0.80)),-PitchStallAngle*0.80,PitchStallAngle*0.80) -- Always yaw positive 
                        -- And also it seems pitch might be backwards when we roll upside down...
    
                        -- But things were working great with just the rollMatchMult and vSpd*10
                        
                    else
                        targetRoll = 0
                        targetYaw = uclamp(targetYaw,-YawStallAngle*0.80,YawStallAngle*0.80)
                    end
    
    
                    local yawDiff = currentYaw-targetYaw
    
                    if ReversalIsOn and mabs(yawDiff) <= 0.0001 and
                                        ((type(ReversalIsOn) == "table") or 
                                         (type(ReversalIsOn) ~= "table" and ReversalIsOn < 0 and mabs(adjustedRoll) < 1)) then
                        if ReversalIsOn == -2 then AP.ToggleAltitudeHold() end
                        ReversalIsOn = nil
                        play("180Off", "BR")
                        return
                    end
    
                    if not stalling and velMag > minRollVelocity and inAtmo then
                        if (yawPID == nil) then
                            yawPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                        end
                        yawPID:inject(yawDiff)
                        local autoYawInput = uclamp(yawPID:get(),-1,1) -- Keep it reasonable so player can override
                        yawInput2 = yawInput2 + autoYawInput
                    elseif (inAtmo and abvGndDet > -1 or velMag < minRollVelocity) then
    
                        AlignToWorldVector(targetVec) -- Point to the target if on the ground and 'stalled'
                    elseif stalling and inAtmo then
                        -- Do this if we're yaw stalling
                        if (currentYaw < -YawStallAngle or currentYaw > YawStallAngle) and inAtmo then
                            AlignToWorldVector(constructVelocity) -- Otherwise try to pull out of the stall, and let it pitch into it
                        end
                        -- Only do this if we're stalled for pitch
                        if (currentPitch < -PitchStallAngle or currentPitch > PitchStallAngle) and inAtmo then
                            targetPitch = uclamp(adjustedPitch-currentPitch,adjustedPitch - PitchStallAngle*0.80, adjustedPitch + PitchStallAngle*0.80) -- Just try to get within un-stalling range to not bounce too much
                        end
                    end
                    
                    if CustomTarget ~= nil and not spaceLaunch then
                        --local distanceToTarget = targetVec:project_on(velocity):len() -- Probably not strictly accurate with curvature but it should work
                        -- Well, maybe not.  Really we have a triangle.  Of course.  
                        -- We know C, our distance to target.  We know the height we'll be above the target (should be the same as our current height)
                        -- We just don't know the last leg
                        -- a2 + b2 = c2.  c2 - b2 = a2
                        local targetAltitude = planet:getAltitude(CustomTarget.position)
                        --local olddistanceToTarget = msqrt(targetVec:len()^2-(coreAltitude-targetAltitude)^2)
                        local distanceToTarget = targetVec:project_on_plane(worldVertical):len()
    
                    
                        StrongBrakes = true -- We don't care about this or glide landing anymore and idk where all it gets used
                        
                        -- Fudge it with the distance we'll travel in a tick - or half that and the next tick accounts for the other? idk
    
                        -- Just fudge it arbitrarily by 5% so that we get some feathering for better accuracy
                        -- Make it think it will take longer to brake than it will
                        if (HoldAltitude < planet.noAtmosphericDensityAltitude and not spaceLaunch and not AutoTakeoff and not Reentry and (distanceToTarget <= brakeDistance and targetVec:len() < planet.radius) and 
                                (constructVelocity:project_on_plane(worldVertical):normalize():dot(targetVec:project_on_plane(worldVertical):normalize()) > 0.99  or VectorStatus == "Finalizing Approach")) then 
                            VectorStatus = "Finalizing Approach" 
                            if #apRoute>0 then
                                if not aptoggle then table.remove(apRoute,1) end
                                if #apRoute>0 then
                                    if not aptoggle then aptoggle = 2 end
                                    return
                                end
                            end
                            cmdT = 0 -- Kill throttle in case they weren't in cruise
                            if AltitudeHold then
                                -- if not OrbitAchieved then
                                    AP.ToggleAltitudeHold() -- Don't need this anymore
                                -- end
                                VectorToTarget = true -- But keep this on
                            end
                            BrakeIsOn = "AP Finalizing"
                        elseif not AutoTakeoff then
                            BrakeIsOn = false
                        end
                        if (VectorStatus == "Finalizing Approach" and (hSpd < 0.1 or distanceToTarget < 0.1 or (LastDistanceToTarget ~= nil and LastDistanceToTarget < distanceToTarget))) then
                            play("bklOn","BL")
                            BrakeLanding = true 
                            apBrk = true
                            if CustomTarget.heading then 
                                alignHeading = CustomTarget.heading 
                            else 
                                alignHeading = nil 
                            end
                            VectorToTarget = false
                            VectorStatus = "Proceeding to Waypoint"
                            collisionAlertStatus = false
                        end
                        LastDistanceToTarget = distanceToTarget
                    end
                elseif VectorToTarget and not inAtmo and HoldAltitude > planet.noAtmosphericDensityAltitude and not (spaceLaunch or Reentry) then
                    if CustomTarget ~= nil and autopilotTargetPlanet.name == planet.name then
                        local targetVec = CustomTarget.position - worldPos
                        local targetAltitude = planet:getAltitude(CustomTarget.position)
                        local distanceToTarget = msqrt(targetVec:len()^2-(coreAltitude-targetAltitude)^2)
                        local curBrake = LastMaxBrakeInAtmo
                        if curBrake then
    
                            brakeDistance, brakeTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, curBrake/2)
                            StrongBrakes = true
                            if distanceToTarget <= brakeDistance + (velMag*deltaTick)/2 and constructVelocity:project_on_plane(worldVertical):normalize():dot(targetVec:project_on_plane(worldVertical):normalize()) > 0.99 then 
                                if planet.hasAtmosphere then
                                    BrakeIsOn = false
                                    ProgradeIsOn = false
                                    reentryMode = true
                                    spaceLand = false   
                                    finalLand = true
                                    Autopilot = false
                                    -- VectorToTarget = true
                                    AP.BeginReentry()
                                end
                            end
                            LastDistanceToTarget = distanceToTarget
                        end
                    end
                end
    
                -- Altitude hold and AutoTakeoff orbiting
                if not inAtmo and (AltitudeHold and HoldAltitude > planet.noAtmosphericDensityAltitude) and not (spaceLaunch or IntoOrbit or Reentry ) then
                    if not OrbitAchieved and not IntoOrbit then
                        OrbitTargetOrbit = HoldAltitude -- If AP/VectorToTarget, AP already set this.  
                        OrbitTargetSet = true
                        if VectorToTarget then orbitalParams.VectorToTarget = true end
                        AP.ToggleIntoOrbit() -- Should turn off alt hold
                        VectorToTarget = false -- WTF this gets stuck on? 
                        orbitAligned = true
                    end
                end
    
                if stalling and inAtmo and abvGndDet == -1 and velMag > minRollVelocity and VectorStatus ~= "Finalizing Approach" then
                    AlignToWorldVector(constructVelocity) -- Otherwise try to pull out of the stall, and let it pitch into it
                    targetPitch = uclamp(adjustedPitch-currentPitch,adjustedPitch - PitchStallAngle*0.80, adjustedPitch + PitchStallAngle*0.80) -- Just try to get within un-stalling range to not bounce too much
                end
    
    
                pitchInput2 = oldInput
                local groundDistance = -1
    
                if BrakeLanding then
                    if not initBL then
                        if not throttleMode then
                            cmdT = 0
                        end
                        navCom:setTargetGroundAltitude(500)
                        navCom:activateGroundEngineAltitudeStabilization(500)
                        stablized = true
                        initBL = true
                    end
                    targetPitch = 0
                    local aggBase = false
                    local absHspd = math.abs(hSpd)
                    if not ExternalAGG and antigravOn then 
                        aggBase = antigrav.getBaseAltitude() 
                        if (aggBase < planet.surfaceMaxAltitude and CustomTarget == nil) or
                           (CustomTarget ~= nil and planet:getAltitude(CustomTarget.position) > aggBase) then 
                            aggBase = false 
                        end
                    else
                        aggBase = false
                    end
                    if alignHeading then
                        if absHspd < 0.05 then
                            if vSpd > -brakeLandingRate then BrakeIsOn = false else BrakeIsOn = "BL Align BLR" end
                            if AlignToWorldVector(alignHeading, 0.001) then 
                                alignHeading = nil 
                                autoRoll = autoRollPreference 
                            else
                                pitchInput2 = 0
                                autoRoll = true
                            end
                        else
                            BrakeIsOn = "BL Align Hzn"
                        end
                        if aggBase and mabs(coreAltitude - aggBase) < 250 then
                            BrakeIsOn = "AGG Align"
                        end
                    else
                        local skipLandingRate = false
                        local distanceToStop = 30 
    
                        if absHspd < 10 and maxKinematicUp ~= nil and maxKinematicUp > 0 then
                            -- Funny enough, LastMaxBrakeInAtmo has stuff done to it to convert to a flat value
                            -- But we need the instant one back, to know how good we are at braking at this exact moment
                            local atmos = uclamp(atmosDensity,0.4,2) -- Assume at least 40% atmo when they land, to keep things fast in low atmo
                            local curBrake = LastMaxBrakeInAtmo * uclamp(velMag/100,0.1,1) * atmos
                            local totalNewtons = maxKinematicUp * atmos + curBrake - gravity -- Ignore air friction for leeway, KinematicUp and Brake are already in newtons
                            local weakBreakNewtons = curBrake/2 - gravity
    
                            local speedAfterBraking = velMag - msqrt((mabs(weakBreakNewtons/2)*20)/(0.5*coreMass))*utils.sign(weakBreakNewtons)
                            if speedAfterBraking < 0 then  
                                speedAfterBraking = 0 -- Just in case it gives us negative values
                            end
                            -- So then see if hovers can finish the job in the remaining distance
    
                            local brakeStopDistance
                            if velMag > 100 then
                                local brakeStopDistance1, _ = Kinematic.computeDistanceAndTime(velMag, 100, coreMass, 0, 0, curBrake)
                                local brakeStopDistance2, _ = Kinematic.computeDistanceAndTime(100, 0, coreMass, 0, 0, msqrt(curBrake))
                                brakeStopDistance = brakeStopDistance1+brakeStopDistance2
                            else
                                brakeStopDistance = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, msqrt(curBrake))
                            end
                            if brakeStopDistance < 20 then
                                BrakeIsOn = false -- We can stop in less than 20m from just brakes, we don't need to do anything
                                -- This gets overridden later if we don't know the altitude or don't want to calculate
                            else
                                local stopDistance = 0
                                if speedAfterBraking > 100 then
                                    local stopDistance1, _ = Kinematic.computeDistanceAndTime(speedAfterBraking, 100, coreMass, 0, 0, totalNewtons) 
                                    local stopDistance2, _ = Kinematic.computeDistanceAndTime(100, 0, coreMass, 0, 0, maxKinematicUp * atmos + msqrt(curBrake) - gravity) -- Low brake power for the last 100kph
                                    stopDistance = stopDistance1 + stopDistance2
                                else
                                    stopDistance, _ = Kinematic.computeDistanceAndTime(speedAfterBraking, 0, coreMass, 0, 0, maxKinematicUp * atmos + msqrt(curBrake) - gravity) 
                                end
                                --if LandingGearGroundHeight == 0 then
                                stopDistance = (stopDistance+15+(velMag*deltaTick))*1.1 -- Add leeway for large ships with forcefields or landing gear, and for lag
                                -- And just bad math I guess
                                local knownAltitude = (apBrk and CustomTarget ~= nil and planet:getAltitude(CustomTarget.position) > 0 and CustomTarget.safe)
                                local targetAltitude = nil
                                if aggBase and aggBase < coreAltitude then
                                    targetAltitude = aggBase
                                elseif knownAltitude then
                                    targetAltitude = planet:getAltitude(CustomTarget.position) + 250 -- Try to aim for like 500m above the target, give it lots of time
                                elseif coreAltitude > planet.surfaceMaxAltitude then
                                    targetAltitude = planet.surfaceMaxAltitude
                                end
                                if collisionTarget then
                                    local collAlt = planet:getAltitude(collisionTarget[1].center)
                                    if targetAltitude then 
                                        if collAlt > targetAltitude then 
                                            targetAltitude = collAlt 
                                        end 
                                    else 
                                        targetAltitude = collAlt 
                                    end
                                end
                                if targetAltitude ~= nil then
                                    local distanceToGround = coreAltitude - targetAltitude 
                                    skipLandingRate = true
                                    if distanceToGround <= stopDistance or stopDistance == -1 or (absHspd > 0.05 and apBrk) then
                                        if (absHspd > 0.05 and apBrk) then
                                            BrakeIsOn = "BL AP Hzn"
                                        else
                                            BrakeIsOn = "BL Stop Dist"
                                        end
                                    else
                                        BrakeIsOn = false
                                    end
                                end
                            end
                        end
    
    
                        groundDistance = abvGndDet
                        if groundDistance > -1 then 
                                if (velMag < 1 or constructVelocity:normalize():dot(worldVertical) < 0) and not alignHeading then -- Or if they start going back up
                                    BrakeLanding = false
                                    AltitudeHold = false
                                    if not aggBase then
                                        eLL = true
                                        navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                                    end
                                    upAmount = 0
                                    BrakeIsOn = "BL Complete"
                                    autoRoll = autoRollPreference 
                                    apBrk = false
                                else
                                    BrakeIsOn = "BL Slowing"
                                end
                        elseif not skipLandingRate then
                            if StrongBrakes and (constructVelocity:normalize():dot(-up) < 0.999) then
                                BrakeIsOn = "BL Strong"
                                AlignToWorldVector()
                            elseif absHspd > 10 or (absHspd > 0.05 and apBrk) then
                                BrakeIsOn = "BL hSpd"
                            elseif vSpd < -brakeLandingRate then
                                BrakeIsOn = "BL BLR"
                            else
                                BrakeIsOn = false
                            end
                        end
                    end
                else
                    initBL = false
                end
                if AutoTakeoff or spaceLaunch then
                    local intersectBody, nearSide, farSide
                    if AutopilotTargetCoords ~= nil then
                        intersectBody, nearSide, farSide = galaxyReference:getPlanetarySystem(0):castIntersections(worldPos, (AutopilotTargetCoords-worldPos):normalize(), 
                            function(body) if body.noAtmosphericDensityAltitude > 0 then return (body.radius+body.noAtmosphericDensityAltitude) else return (body.radius+body.surfaceMaxAltitude*1.5) end end)
                    end
                    if antigravOn and not spaceLaunch then
                        if coreAltitude >= (HoldAltitude-50) and velMag > minAutopilotSpeed then
                            AutoTakeoff = false
                            if not Autopilot and not VectorToTarget then
                                BrakeIsOn = "ATO Agg Arrive"
                                cmdT = 0
                            end
                        end
                    elseif mabs(targetPitch) < 15 and (coreAltitude/HoldAltitude) > 0.75 then
                        AutoTakeoff = false -- No longer in ascent
                        if not spaceLaunch then 
                            if throttleMode and not AtmoSpeedAssist then
                                Nav.control.cancelCurrentControlMasterMode()
                            end
                        elseif spaceLaunch and velMag < minAutopilotSpeed then
                            Autopilot = true
                            spaceLaunch = false
                            AltitudeHold = false
                            AutoTakeoff = false
                            cmdT = 0
                        elseif spaceLaunch then
                            cmdT = 0
                            BrakeIsOn = "ATO Space"
                        end --coreAltitude > 75000
                    elseif spaceLaunch and not inAtmo and autopilotTargetPlanet ~= nil and (intersectBody == nil or intersectBody.name == autopilotTargetPlanet.name) then
                        Autopilot = true
                        spaceLaunch = false
                        AltitudeHold = false
                        AutoTakeoff = false
                        if not throttleMode then
                            cmdT = 0
                        end
                        AutopilotAccelerating = true -- Skip alignment and don't warm down the engines
                    end
                end
                -- Copied from autoroll let's hope this is how a PID works... 
                -- Don't pitch if there is significant roll, or if there is stall
                local onGround = abvGndDet > -1
                local pitchToUse = adjustedPitch
    
                if (VectorToTarget or spaceLaunch or ReversalIsOn) and not onGround and velMag > minRollVelocity and inAtmo then
                    local rollRad = math.rad(mabs(adjustedRoll))
                    pitchToUse = adjustedPitch*mabs(math.cos(rollRad))+currentPitch*math.sin(rollRad)
                end
                -- TODO: These clamps need to be related to roll and YawStallAngle, we may be dealing with yaw?
                local pitchDiff = uclamp(targetPitch-pitchToUse, -PitchStallAngle*0.80, PitchStallAngle*0.80)
                if not inAtmo and VectorToTarget then
                    pitchDiff = uclamp(targetPitch-pitchToUse, -85, MaxPitch) -- I guess
                elseif not inAtmo then
                    pitchDiff = uclamp(targetPitch-pitchToUse, -MaxPitch, MaxPitch) -- I guess
                end
                if (((mabs(adjustedRoll) < 5 or VectorToTarget or ReversalIsOn)) or BrakeLanding or onGround or AltitudeHold) then
                    if (pitchPID == nil) then -- Changed from 8 to 5 to help reduce problems?
                        pitchPID = pid.new(5 * 0.01, 0, 5 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                    end
                    pitchPID:inject(pitchDiff)
                    local autoPitchInput = pitchPID:get()
                    pitchInput2 = pitchInput2 + autoPitchInput
                end
            end
            if antigrav ~= nil and (antigrav and not ExternalAGG and coreAltitude < 200000) then
                if AntigravTargetAltitude == nil or AntigravTargetAltitude < 1000 then AntigravTargetAltitude = 1000 end
                if desiredBaseAltitude ~= AntigravTargetAltitude then
                    desiredBaseAltitude = AntigravTargetAltitude
                    sba = desiredBaseAltitude
                end
            end
    
        -- End old APTick Code
    
            if (inAtmo or Reentry or finalLand) and AtmoSpeedAssist and throttleMode then
                -- This is meant to replace cruise
                -- Uses AtmoSpeedLimit as the desired speed in which to 'cruise'
                -- In atmo, if throttle is 100%, it applies a PID to throttle to try to achieve AtmoSpeedLimit
                -- Since throttle is already 100% this means nothing except, it should slow them as it approaches it, throttling down
                    -- Note - Beware reentry.  It will throttle them down due to high fall speeds, but they need that throttle
                    -- We could instead only throttle down when the velMag in the direction of ShipFront exceeds AtmoSpeedLimt.  
                -- We also need to do braking if the speed is high enough above the desired limit.  
                -- Braking should happen immediately if the speed is not mostly forward
    
                -- .. Maybe as a whole we just, also PID brakeForce to keep speed under that limit, so if we barely go over it'll only tap them and throttle down
    
                -- We're going to want a param, PlayerThrottle, which we always keep (not between loads).  We set it in SpeedUp and SpeedDown
                -- So we only control throttle if their last throttle input was 100%
    
                -- Well, no.  Even better, do it all the time.  We would show their throttle on the HUD, then a red line separating it from our adjusted throttle
                -- Along with a message like, "Atmospheric Speed Limit Reached - Press Something to Disable Temporarily"
                -- But of course, don't throttle up for them.  Only down. 
    
    
    
                if (throttlePID == nil) then
                    throttlePID = pid.new(0.1, 0, 1) -- First param, higher means less range in which to PID to a proper value
                    -- IE 1 there means it tries to get within 1m/s of target, 0.5 there means it tries to get within 5m/s of target
                    -- The smaller the value, the further the end-speed is from the target, but also the sooner it starts reducing throttle
                    -- It is also the same as taking the result * (firstParam), it's a direct scalar
    
                    -- Second value makes it change constantly over time.  This doesn't work in this case, it just builds up forever while they're not at max
    
                    -- And third value affects how hard it tries to fix it.  Higher values mean it will very quickly go to negative values as you approach target
                    -- Lower values means it steps down slower
    
                    -- 0.5, 0, 20 works pretty great
                    -- And I think it was, 0.5, 0, 0.001 is smooth, but gets some braking early
                    -- 0.5, 0, 1 is v good.  One early braking bit then stabilizes easily .  10 as the last is way too much, it's bouncy.  Even 2.  1 will do
                end
                -- Add in vertical speed as well as the front speed, to help with ships that have very bad brakes
                local addThrust = 0
                if ExtraEscapeThrust > 0 and not Reentry and  atmosDensity > 0.005 and atmosDensity < 0.1 and vSpd > - 50 then
                    addThrust = (0.1 - atmosDensity)*adjustedAtmoSpeedLimit*ExtraEscapeThrust
                end
                throttlePID:inject(adjustedAtmoSpeedLimit/3.6 + addThrust - constructVelocity:dot(constructForward))
                local pidGet = throttlePID:get()
                calculatedThrottle = uclamp(pidGet,-1,1)
                if not ThrottleValue then 
                    if calculatedThrottle < PlayerThrottle and (atmosDensity > 0.005 or Reentry or finalLand ) then -- We can limit throttle all the way to 0.05% probably
                        ThrottleLimited = true
                        ThrottleValue = uclamp(calculatedThrottle,0.01,1)
                    else
                        ThrottleLimited = false
                        ThrottleValue = PlayerThrottle
                    end
                end
    
                
                -- Then additionally
                if (brakePID == nil) then
                    brakePID = pid.new(1 * 0.01, 0, 1 * 0.1)
                end
                brakePID:inject(constructVelocity:len() - (adjustedAtmoSpeedLimit/3.6) - addThrust) 
                local calculatedBrake = uclamp(brakePID:get(),0,1)
                if (inAtmo and vSpd < -80) or (atmosDensity > 0.005 or Reentry or finalLand) then -- Don't brake-limit them at <5% atmo if going up (or mostly up), it's mostly safe up there and displays 0% so people would be mad
                    brakeInput2 = calculatedBrake
                end
                if brakeInput2 > 0 then
                    if ThrottleLimited and calculatedThrottle == 0.01 and not ThrottleValue then
                        ThrottleValue = 0 -- We clamped it to >0 before but, if braking and it was at that clamp, 0 is good.
                    end
                else -- For display purposes, keep calculatedThrottle positive in this case
                    calculatedThrottle = uclamp(calculatedThrottle,0.01,1)
                end
    
                -- And finally, do what cruise does for angling wings toward the nose
    
                local autoNavigationEngineTags = ''
                local autoNavigationAcceleration = vec3()
                
    
                local verticalStrafeAcceleration = composeAxisAccelerationFromTargetSpeedV(axisCommandId.vertical,upAmount*1000)
                Nav:setEngineForceCommand("vertical airfoil , vertical ground ", verticalStrafeAcceleration, dontKeepCollinearity)
                --autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. "vertical airfoil , vertical ground "
                --autoNavigationAcceleration = autoNavigationAcceleration + verticalStrafeAcceleration
    
                local longitudinalEngineTags = 'thrust analog longitudinal '
                if (UseExtra=="All" or UseExtra=="Longitude") then longitudinalEngineTags = longitudinalEngineTags..ExtraLongitudeTags end
                local longitudinalCommandType = navCom:getAxisCommandType(axisCommandId.longitudinal)
                local longitudinalAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                        longitudinalEngineTags, axisCommandId.longitudinal)
    
                local lateralAcceleration = composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral, LeftAmount*1000)
                autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. "lateral airfoil , lateral ground " -- We handle the rest later
                autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration
    
                -- Auto Navigation (Cruise Control)
                if (autoNavigationAcceleration:len() > constants.epsilon) then
                    Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '',
                        '', tolerancePercentToSkipOtherPriorities)
                end
                -- And let throttle do its thing separately
                Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)
    
                local verticalStrafeEngineTags = 'thrust analog vertical fueled '
                local lateralStrafeEngineTags = 'thrust analog lateral fueled '
    
                if (UseExtra=="All" or UseExtra=="Lateral")then lateralStrafeEngineTags = lateralStrafeEngineTags..ExtraLateralTags end
                if (UseExtra=="All" or UseExtra=="Vertical") then verticalStrafeEngineTags = verticalStrafeEngineTags..ExtraVerticalTags end
    
                -- Vertical also handles the non-airfoils separately
                if upAmount ~= 0 or (BrakeLanding and BrakeIsOn) or (not GearExtended and not stablized) then
                    Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity)
                else
                    Nav:setEngineForceCommand(verticalStrafeEngineTags, vec3(), keepCollinearity) -- Reset vertical engines but not airfoils or ground
                end
    
                if LeftAmount ~= 0 then
                    Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralAcceleration, keepCollinearity)
                else
                    Nav:setEngineForceCommand(lateralStrafeEngineTags, vec3(), keepCollinearity) -- Reset vertical engines but not airfoils or ground
                end
    
                if finalBrakeInput == 0 then -- If player isn't braking, use cruise assist braking
                    finalBrakeInput = brakeInput2
                end
    
                -- Brakes
                local brakeAcceleration = -finalBrakeInput *
                (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
                Nav:setEngineForceCommand('brake', brakeAcceleration)
    
            else
                --PlayerThrottle = 0
                if AtmoSpeedAssist then
                    if not ThrottleValue then
                        ThrottleValue = PlayerThrottle -- Use PlayerThrottle always.
                    end
                end
    
                local targetSpeed = u.getAxisCommandValue(0)
    
                if not throttleMode then -- Use a PID to brake past targetSpeed
                    if (brakePID == nil) then
                        brakePID = pid.new(1 * 0.01, 0, 1 * 0.1)
                    end
                    brakePID:inject(constructVelocity:len() - (targetSpeed/3.6)) 
                    local calculatedBrake = uclamp(brakePID:get(),0,1)
                    finalBrakeInput = uclamp(finalBrakeInput + calculatedBrake,0,1)
                end
    
                -- Brakes - Do these first so Cruise can override it
                local brakeAcceleration = -finalBrakeInput *
                (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
                Nav:setEngineForceCommand('brake', brakeAcceleration)
    
                -- AutoNavigation regroups all the axis command by 'TargetSpeed'
                local autoNavigationEngineTags = ''
                local autoNavigationAcceleration = vec3()
                local autoNavigationUseBrake = false
    
                -- Longitudinal Translation
                local longitudinalEngineTags = 'thrust analog longitudinal '
                if (UseExtra=="All" or UseExtra=="Longitude") then longitudinalEngineTags = longitudinalEngineTags..ExtraLongitudeTags end
                local longitudinalCommandType = navCom:getAxisCommandType(axisCommandId.longitudinal)
                if (longitudinalCommandType == axisCommandType.byThrottle) then
                    local longitudinalAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                        longitudinalEngineTags, axisCommandId.longitudinal)
                    Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)
                elseif (longitudinalCommandType == axisCommandType.byTargetSpeed) then
                    local longitudinalAcceleration = navCom:composeAxisAccelerationFromTargetSpeed(
                                                        axisCommandId.longitudinal)
                    autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. longitudinalEngineTags
                    autoNavigationAcceleration = autoNavigationAcceleration + longitudinalAcceleration
                    if (navCom:getTargetSpeed(axisCommandId.longitudinal) == 0 or -- we want to stop
                        navCom:getCurrentToTargetDeltaSpeed(axisCommandId.longitudinal) <
                        -navCom:getTargetSpeedCurrentStep(axisCommandId.longitudinal) * 0.5) -- if the longitudinal velocity would need some braking
                    then
                        autoNavigationUseBrake = true
                    end
    
                end
    
                -- Lateral Translation
                local lateralStrafeEngineTags = 'thrust analog lateral '
                if (UseExtra=="All" or UseExtra=="Lateral") then lateralStrafeEngineTags = lateralStrafeEngineTags..ExtraLateralTags end
                local lateralCommandType = navCom:getAxisCommandType(axisCommandId.lateral)
                if (lateralCommandType == axisCommandType.byThrottle) then
                    local lateralStrafeAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                        lateralStrafeEngineTags, axisCommandId.lateral)
                    Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralStrafeAcceleration, keepCollinearity)
                elseif (lateralCommandType == axisCommandType.byTargetSpeed) then
                    local lateralAcceleration = navCom:composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral)
                    autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. lateralStrafeEngineTags
                    autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration
                end
    
                -- Vertical Translation
                local verticalStrafeEngineTags = 'thrust analog vertical '
                if (UseExtra=="All" or UseExtra=="Vertical") then verticalStrafeEngineTags = verticalStrafeEngineTags..ExtraVerticalTags end
                local verticalCommandType = navCom:getAxisCommandType(axisCommandId.vertical)
                if (verticalCommandType == axisCommandType.byThrottle)  then
                    local verticalStrafeAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                        verticalStrafeEngineTags, axisCommandId.vertical)
                    if upAmount ~= 0 or (BrakeLanding and BrakeIsOn) then
                        Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity, 'airfoil',
                            'ground', '', tolerancePercentToSkipOtherPriorities)
                    else
                        Nav:setEngineForceCommand(verticalStrafeEngineTags, vec3(), keepCollinearity) -- Reset vertical engines but not airfoils or ground
                        Nav:setEngineForceCommand('airfoil vertical', verticalStrafeAcceleration, keepCollinearity, 'airfoil',
                        '', '', tolerancePercentToSkipOtherPriorities)
                        Nav:setEngineForceCommand('ground vertical', verticalStrafeAcceleration, keepCollinearity, 'ground',
                        '', '', tolerancePercentToSkipOtherPriorities)
                    end
                elseif (verticalCommandType == axisCommandType.byTargetSpeed) then
                    if upAmount < 0 then 
                        Nav:setEngineForceCommand('hover', vec3(), keepCollinearity) 
                    end
                    local verticalAcceleration = navCom:composeAxisAccelerationFromTargetSpeed(
                                                    axisCommandId.vertical)
                    autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. verticalStrafeEngineTags
                    autoNavigationAcceleration = autoNavigationAcceleration + verticalAcceleration
                end
    
                -- Auto Navigation (Cruise Control)
                if (autoNavigationAcceleration:len() > constants.epsilon) then -- This means it's in cruise
                    if (finalBrakeInput ~= 0 or autoNavigationUseBrake or mabs(constructVelocityDir:dot(constructForward)) < 0.5)
                    then
                        autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
                    end
                    Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '',
                        '', tolerancePercentToSkipOtherPriorities)
                end
            end
    
            -- Rotation
            local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
            local airAcceleration = vec3(C.getWorldAirFrictionAngularAcceleration())
            angularAcceleration = angularAcceleration - airAcceleration -- Try to compensate air friction
            
            Nav:setEngineTorqueCommand('torque', angularAcceleration, keepCollinearity, 'airfoil', '', '',
                tolerancePercentToSkipOtherPriorities)
    
            -- Rockets
            Nav:setBoosterCommand('rocket_engine')
            -- Dodgin's Don't Die Rocket Govenor - Cruise Control Edition
            if isBoosting and not VanillaRockets then 
                local speed = coreVelocity:len()
                local maxSpeedLag = 0.15
                if not throttleMode then -- Cruise control rocket boost assist, Dodgin's modified.
                    local cc_speed = navCom:getTargetSpeed(axisCommandId.longitudinal)
                    if speed * 3.6 > (cc_speed * (1 - maxSpeedLag)) and IsRocketOn then
                        IsRocketOn = false
                        Nav:toggleBoosters()
                    elseif speed * 3.6 < (cc_speed * (1 - maxSpeedLag)) and not IsRocketOn then
                        IsRocketOn = true
                        Nav:toggleBoosters()
                    end
                else -- Atmosphere Rocket Boost Assist Not in Cruise Control by Azraeil
                    local throttle = u.getThrottle()
                    if AtmoSpeedAssist then throttle = PlayerThrottle*100 end
                    local targetSpeed = (throttle/100)
                    if not inAtmo then
                        targetSpeed = targetSpeed * MaxGameVelocity
                        if speed >= (targetSpeed * (1- maxSpeedLag)) and IsRocketOn then
                            IsRocketOn = false
                            Nav:toggleBoosters()
                        elseif speed < (targetSpeed * (1- maxSpeedLag)) and not IsRocketOn then
                            IsRocketOn = true
                            Nav:toggleBoosters()
                        end
                    else
                        local ReentrySpeed = mfloor(adjustedAtmoSpeedLimit)
                        targetSpeed = targetSpeed * ReentrySpeed / 3.6 -- 1100km/hr being max safe speed in atmo for most ships
                        if speed >= (targetSpeed * (1- maxSpeedLag)) and IsRocketOn then
                            IsRocketOn = false
                            Nav:toggleBoosters()
                        elseif speed < (targetSpeed * (1- maxSpeedLag)) and not IsRocketOn then 
                            IsRocketOn = true
                            Nav:toggleBoosters()
                        end
                    end
                end
            end
        end
    
        if userAP then 
            for k,v in pairs(userAP) do ap[k] = v end 
        end   
    
        abvGndDet = AboveGroundLevel()
    
        return ap
    end
    local function ControlClass(Nav, c, u, s, atlas, vBooster, hover, antigrav, shield, dbHud_2, gyro, screenHud_1,
        isRemote, navCom, sysIsVwLock, sysLockVw, sysDestWid, round, stringmatch, tonum, uclamp, play, saveableVariables, SaveDataBank)
        local C = DUConstruct
        local Control = {}
        local UnitHidden = true
        local holdAltitudeButtonModifier = 5
        local antiGravButtonModifier = 5
        local currentHoldAltModifier = holdAltitudeButtonModifier
        local currentAggModifier = antiGravButtonModifier
        local clearAllCheck = time
    
        function Control.landingGear()
            GearExtended = not GearExtended
            if GearExtended then
                VectorToTarget = false
                LockPitch = nil
                AP.cmdThrottle(0)
                if vBooster or hover then 
                    if inAtmo and abvGndDet == -1 then
                        play("bklOn", "BL")
                        StrongBrakes = true -- We don't care about this anymore
                        Reentry = false
                        AutoTakeoff = false
                        VertTakeOff = false
                        AltitudeHold = false
                        if BrakeLanding then apBrk = not apBrk end
                        BrakeLanding = true
                        autoRoll = true
                        GearExtended = false -- Don't actually toggle the gear yet though
                    else
                        if hasGear then
                            play("grOut","LG",1)
                            Nav.control.deployLandingGears()                            
                        end
                        apBrk = false
                        navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                        if inAtmo then
                            BrakeIsOn = "Landing"
                        end
                    end
                elseif hasGear and not BrakeLanding  then
                    play("grOut","LG",1)
                    Nav.control.deployLandingGears() -- Actually extend
                end
            else
                if hasGear then
                    play("grIn","LG",1)
                    Nav.control.retractLandingGears()
                end
                navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                if stablized then 
                    if LandingGearGroundHeight < navCom.targetGroundAltitude then 
                        navCom:setTargetGroundAltitude(navCom.targetGroundAltitude) 
                    else
                        navCom:setTargetGroundAltitude(TargetHoverHeight)
                    end
                end
            end
        end
        function Control.startControl(action)
            -- Local function for onActionStart items in more than one
                local function groundAltStart(down)
                    local mult=1
                    local function nextTargetHeight(curTarget, down)
                        local targetHeights = { planet.surfaceMaxAltitude+100, (planet.spaceEngineMinAltitude-0.01*planet.noAtmosphericDensityAltitude), planet.noAtmosphericDensityAltitude + LowOrbitHeight,
                            planet.radius*(TargetOrbitRadius-1) + planet.noAtmosphericDensityAltitude }
                        local origTarget = curTarget
                        for _,v in ipairs(targetHeights) do
                            if down and origTarget > v then
                                curTarget = v -- Change to the first altitude below our current target
                            elseif curTarget < v and not down then
                                curTarget = v -- Change to the first altitude above our current target
                                break
                            end
                        end
                        return curTarget
                    end
    
                    if down then mult = -1 end
                    if not ExternalAGG and antigravOn then
                        if holdingShift and down then
                            AntigravTargetAltitude = 1000
                        elseif AntigravTargetAltitude ~= nil  then
                            AntigravTargetAltitude = AntigravTargetAltitude + mult*antiGravButtonModifier
                            if AntigravTargetAltitude < 1000 then AntigravTargetAltitude = 1000 end
                            if AltitudeHold and AntigravTargetAltitude < HoldAltitude + 10 and AntigravTargetAltitude > HoldAltitude - 10 then 
                                HoldAltitude = AntigravTargetAltitude
                            end
                        else
                            AntigravTargetAltitude = desiredBaseAltitude + mult*100
                        end
                    elseif AltitudeHold or VertTakeOff or IntoOrbit then
                        if IntoOrbit then
                            if holdingShift then
                                OrbitTargetOrbit = nextTargetHeight(OrbitTargetOrbit, down) 
                            else                          
                                OrbitTargetOrbit = OrbitTargetOrbit + mult*holdAltitudeButtonModifier
                            end
                            if OrbitTargetOrbit < planet.noAtmosphericDensityAltitude then OrbitTargetOrbit = planet.noAtmosphericDensityAltitude end
                        else
                            if holdingShift and inAtmo then
                                HoldAltitude = nextTargetHeight(HoldAltitude, down)
                            else
                                HoldAltitude = HoldAltitude + mult*holdAltitudeButtonModifier
                            end
                        end
                    else
                        navCom:updateTargetGroundAltitudeFromActionStart(mult*1.0)
                    end
                end
                local function assistedFlight(vectorType)
                    if not inAtmo then
                        msgText = "Flight Assist in Atmo only"
                        return
                    end
                    local t = type(vectorType)
                    if ReversalIsOn == nil then 
                        if t == "table" then
                            if Autopilot or VectorToTarget then 
                                AP.ToggleAutopilot() 
                            end
                            play("180On", "BR")
                        elseif vectorType==1 then
                            play("bnkLft","BR")
                        else
                            play("bnkRht", "BR")
                        end
                        if not AltitudeHold and not Autopilot and not VectorToTarget then 
                            AP.ToggleAltitudeHold() 
                            if t ~= "table" then 
                                vectorType = vectorType + 1 
                            end
                        end
                        ReversalIsOn = vectorType
                    else 
                        play("180Off", "BR")
                        ReversalIsOn = nil
                    end                
                end
                local function holdingShiftOff()
                    if sysIsVwLock() == 1 then
                        simulatedX = 0
                        simulatedY = 0 -- Reset for steering purposes
                        sysLockVw(PrevViewLock)
                    elseif isRemote() == 1 and ShiftShowsRemoteButtons then
                        Animated = false
                        Animating = false
                    end
                    holdingShift = false
                end
            if action == "gear" then
                CONTROL.landingGear()
            elseif action == "light" then
                if Nav.control.isAnyHeadlightSwitchedOn() == 1 then
                    Nav.control.switchOffHeadlights()
                else
                    Nav.control.switchOnHeadlights()
                end
            elseif action == "forward" then
                if AltIsOn and not inAtmo and not Autopilot then
                    ProgradeIsOn = not ProgradeIsOn
                    RetrogradeIsOn = false
                else
                    pitchInput = pitchInput - 1
                end
            elseif action == "backward" then
                if AltIsOn then
                    if not inAtmo then
                        if not Autopilot then
                            RetrogradeIsOn = not RetrogradeIsOn
                            ProgradeIsOn = false
                        else
                            TurnBurn = not TurnBurn
                        end
                    else
                        assistedFlight(-constructVelocity*5000)
                    end
                else
                    pitchInput = pitchInput + 1
                end
            elseif action == "left" then
                if AltIsOn then
                    assistedFlight(1)
                else            
                    rollInput = rollInput - 1
                end
            elseif action == "right" then
                if AltIsOn then
                    assistedFlight(3)
                else      
                    rollInput = rollInput + 1
                end
            elseif action == "yawright" then
                yawInput = yawInput - 1
                alignHeading = nil
            elseif action == "yawleft" then
                yawInput = yawInput + 1
                alignHeading = nil
            elseif action == "straferight" then
                    navCom:updateCommandFromActionStart(axisCommandId.lateral, 1.0)
                    LeftAmount = 1
            elseif action == "strafeleft" then
                    navCom:updateCommandFromActionStart(axisCommandId.lateral, -1.0)
                    LeftAmount = -1
            elseif action == "up" then
                upAmount = upAmount + 1
                if abvGndDet - 3 < LandingGearGroundHeight and coreAltitude > 0 and GearExtended then CONTROL.landingGear() end
                navCom:deactivateGroundEngineAltitudeStabilization()
                navCom:updateCommandFromActionStart(axisCommandId.vertical, 1.0)
            elseif action == "down" then
                upAmount = upAmount - 1
                navCom:deactivateGroundEngineAltitudeStabilization()
                navCom:updateCommandFromActionStart(axisCommandId.vertical, -1.0)
            elseif action == "groundaltitudeup" then
                groundAltStart()
            elseif action == "groundaltitudedown" then
                groundAltStart(true)
            elseif action == "option1" then
                toggleView = false
                if AltIsOn and holdingShift then 
                    local onboard = ""
                    for i=1, #passengers do
                        onboard = onboard.."| Name: "..s.getPlayerName(passengers[i]).." Mass: "..round(C.getBoardedPlayerMass(passengers[i])/1000,1).."t "
                    end
                    s.print("Onboard: "..onboard)
                    return
                end
                ATLAS.adjustAutopilotTargetIndex()
            elseif action == "option2" then
                toggleView = false
                if AltIsOn and holdingShift then 
                    for i=1, #passengers do
                        C.forceDeboard(passengers[i])
                        C.forceInterruptVRSession(passengers[i])
                    end
                    msgText = "Deboarded All Passengers"
                    return
                end
                ATLAS.adjustAutopilotTargetIndex(1)
            elseif action == "option3" then
                local function ToggleWidgets()
                    UnitHidden = not UnitHidden
                    if not UnitHidden then
                        play("wid","DH")
                        u.showWidget()
                        c.showWidget()
                        if atmofueltank_size > 0 then
                            _autoconf.displayCategoryPanel(atmofueltank, atmofueltank_size,
                                "Atmo Fuel", "fuel_container")
                            fuelPanelID = _autoconf.panels[_autoconf.panels_size]
                        end
                        if spacefueltank_size > 0 then
                            _autoconf.displayCategoryPanel(spacefueltank, spacefueltank_size,
                                "Space Fuel", "fuel_container")
                            spacefuelPanelID = _autoconf.panels[_autoconf.panels_size]
                        end
                        if rocketfueltank_size > 0 then
                            _autoconf.displayCategoryPanel(rocketfueltank, rocketfueltank_size,
                                "Rocket Fuel", "fuel_container")
                            rocketfuelPanelID = _autoconf.panels[_autoconf.panels_size]
                        end
                        parentingPanelId = s.createWidgetPanel("Docking")
                        parentingWidgetId = s.createWidget(parentingPanelId,"parenting")
                        s.addDataToWidget(u.getWidgetDataId(),parentingWidgetId)
                        coreCombatStressPanelId = s.createWidgetPanel("Core combat stress")
                        coreCombatStressgWidgetId = s.createWidget(coreCombatStressPanelId,"core_stress")
                        s.addDataToWidget(c.getWidgetDataId(),coreCombatStressgWidgetId)
                        if shield ~= nil then shield.showWidget() end
                    else
                        play("hud","DH")
                        u.hideWidget()
                        c.hideWidget()
                        if fuelPanelID ~= nil then
                            sysDestWid(fuelPanelID)
                            fuelPanelID = nil
                        end
                        if parentingPanelId ~=nil then
                            sysDestWid(parentingPanelId)
                            parentingPanelId=nil
                        end
                        if coreCombatStressPanelId ~=nil then
                            sysDestWid(coreCombatStressPanelId)
                            coreCombatStressPanelId=nil
                        end
                        if spacefuelPanelID ~= nil then
                            sysDestWid(spacefuelPanelID)
                            spacefuelPanelID = nil
                        end
                        if rocketfuelPanelID ~= nil then
                            sysDestWid(rocketfuelPanelID)
                            rocketfuelPanelID = nil
                        end
                        if shield ~= nil then shield.hideWidget() end
                    end
                end
    
                toggleView = false
                if AltIsOn and holdingShift then 
                    local onboard = ""
                    for i=1, #ships do
                        onboard = onboard.."| ID: "..ships[i].." Mass: "..round(c.getDockedConstructMass(ships[i])/1000,1).."t "
                    end
                    s.print("Docked Ships: "..onboard)
                    return
                end
                if hideHudOnToggleWidgets then
                    if showHud then
                        showHud = false
                    else
                        showHud = true
                    end
                end
                ToggleWidgets()
            elseif action == "option4" then
                toggleView = false      
                if AltIsOn and holdingShift then 
                    for i=1, #ships do
                        c.forceUndock(ships[i])
                    end
                    msgText = "Undocked all ships"
                    return
                end
                ReversalIsOn = nil
                AP.ToggleAutopilot()
            elseif action == "option5" then 
                toggleView = false 
                AP.ToggleLockPitch()
            elseif action == "option6" then
                toggleView = false 
                if AltIsOn and holdingShift then 
                    if shield then 
                        SHIELD.ventShield()
                    else
                        msgText = "No shield found"
                    end
                    return
                end
                AP.ToggleAltitudeHold()
            elseif action == "option7" then
                toggleView = false
                if AltIsOn and holdingShift then 
                    if shield then
                        shield.toggle() 
                        return 
                    else
                        msgText = "No shield found"
                        return
                    end
                end
                CollisionSystem = not CollisionSystem
                if CollisionSystem then 
                    msgText = "Collision System Enabled"
                else 
                    msgText = "Collision System Secured"
                end
            elseif action == "option8" then
                toggleView = false
                if AltIsOn and holdingShift then 
                    if AutopilotTargetIndex > 0 and CustomTarget ~= nil then
                        AP.routeWP()
                    else
                        msgText = "Select a saved wp on IPH to add to or remove from route"
                    end
                    return
                end
                stablized = not stablized
                if not stablized then
                    msgText = "DeCoupled Mode - Ground Stabilization off"
                    navCom:deactivateGroundEngineAltitudeStabilization()
                    play("gsOff", "GS")
                else
                    msgText = "Coupled Mode - Ground Stabilization on"
                    navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                    sEFC = true
                    play("gsOn", "GS") 
                end
            elseif action == "option9" then
                toggleView = false
                if AltIsOn and holdingShift then 
                    navCom:resetCommand(axisCommandId.longitudinal)
                    navCom:resetCommand(axisCommandId.lateral)
                    navCom:resetCommand(axisCommandId.vertical)
                    AP.cmdThrottle(0)
                    u.setTimer("tagTick",0.1)
                elseif gyro ~= nil then
                    gyro.toggle()
                    gyroIsOn = gyro.getState() == 1
                    if gyroIsOn then play("gyOn", "GA") else play("gyOff", "GA") end
                else
                    msgText = "No gyro found"
                end
            elseif action == "lshift" then
                apButtonsHovered = false
                if AltIsOn then holdingShift = true
                elseif holdingShift then
                    holdingShiftOff()
                else
                    if sysIsVwLock() == 1 then
                        holdingShift = true
                        PrevViewLock = sysIsVwLock()
                        sysLockVw(1)
                    elseif isRemote() == 1 and ShiftShowsRemoteButtons then
                        holdingShift = true
                        Animated = false
                        Animating = false
                    end
                end
            elseif action == "brake" then
                if BrakeToggleStatus or AltIsOn then
                    AP.BrakeToggle("Manual")
                elseif not BrakeIsOn then
                    AP.BrakeToggle("Manual") -- Trigger the cancellations
                else
                    BrakeIsOn = "Manual" -- Should never happen
                end
            elseif action == "lalt" then
                toggleView = true
                AltIsOn = true
                if isRemote() == 0 and not freeLookToggle and userControlScheme == "keyboard" then
                    sysLockVw(1)
                end
            elseif action == "booster" then
                -- Dodgin's Don't Die Rocket Govenor - Cruise Control Edition
                if VanillaRockets then 
                    Nav:toggleBoosters()
                elseif not isBoosting then 
                    if not IsRocketOn then 
                        Nav:toggleBoosters()
                        IsRocketOn = true
                    end
                    isBoosting = true
                else
                    if IsRocketOn then
                        Nav:toggleBoosters()
                        IsRocketOn = false
                    end
                    isBoosting = false
                end
            elseif action == "stopengines" then
                local function clearAll()         
                    if (time - clearAllCheck) < 1.5 then
                        play("clear","CA")
                        AP.clearAll()
                    end
                end
                clearAll()
                clearAllCheck = time
                if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed then
                    if PlayerThrottle ~= 0 then
                        navCom:resetCommand(axisCommandId.longitudinal)
                        AP.cmdThrottle(0)
                    else
                        AP.cmdThrottle(100)
                    end
                else
                    if navCom:getTargetSpeed(axisCommandId.longitudinal) ~= 0 then
                        navCom:resetCommand(axisCommandId.longitudinal)
                    else
                        if inAtmo then 
                            AP.cmdCruise(adjustedAtmoSpeedLimit) 
                        else
                            AP.cmdCruise(MaxGameVelocity*3.6)
                        end
                    end
                end
            elseif action == "speedup" then
                if holdingShift and not AltIsOn then p("RADAR OFF") return end
                AP.changeSpd()
            elseif action == "speeddown" then
                AP.changeSpd(true)
            elseif action == "antigravity" and not ExternalAGG then
                if antigrav ~= nil then
                    AP.ToggleAntigrav()
                else
                    msgText = "No antigrav found"
                end
            elseif action == "leftmouse" then
                if AltIsOn and holdingShift then 
                    if RADAR then 
                        RADAR.ToggleRadarPanel()
                        RADAR = nil
                        FullRadar = false
                    else
                        FullRadar = true
                        PROGRAM.radarSetup()
                    end
                    toggleView = false
                elseif holdingShift then 
                    leftmouseclick=true 
                    holdingShiftOff() 
                end
            end
        end
    
        function Control.stopControl(action)
            -- Local function in more than one onActionStop
                local function groundAltStop()
                    if not ExternalAGG and antigravOn then
                        currentAggModifier = antiGravButtonModifier
                    end
                    if AltitudeHold or VertTakeOff or IntoOrbit then
                        currentHoldAltModifier = holdAltitudeButtonModifier
                    end
                end
            if action == "forward" then
                pitchInput = 0
            elseif action == "backward" then
                pitchInput = 0
            elseif action == "left" then
                if ReversalIsOn then
                    if ReversalIsOn == 2 then ReversalIsOn = -2 else ReversalIsOn = -1 end
                end
                rollInput = 0
            elseif action == "right" then
                if ReversalIsOn then
                    if ReversalIsOn == 4 then ReversalIsOn = -2 else ReversalIsOn = -1 end
                end
                rollInput = 0
            elseif action == "yawright" then
                yawInput = 0
            elseif action == "yawleft" then
                yawInput = 0
            elseif action == "straferight" then
                navCom:updateCommandFromActionStop(axisCommandId.lateral, -1.0)
                LeftAmount = 0
            elseif action == "strafeleft" then
                navCom:updateCommandFromActionStop(axisCommandId.lateral, 1.0)
                LeftAmount = 0
            elseif action == "up" then
                upAmount = 0
                navCom:updateCommandFromActionStop(axisCommandId.vertical, -1.0)
                if stablized then 
                    navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                    sEFC = true
                end
            elseif action == "down" then
                upAmount = 0
                navCom:updateCommandFromActionStop(axisCommandId.vertical, 1.0)
                if stablized then 
                    navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                    sEFC = true 
                end
            elseif action == "groundaltitudeup" then
                groundAltStop()
                toggleView = false
            elseif action == "groundaltitudedown" then
                groundAltStop()
                toggleView = false
            elseif action == "brake" then
                if not BrakeToggleStatus and not AltIsOn then
                    if BrakeIsOn then
                        AP.BrakeToggle()
                    else
                        BrakeIsOn = false -- Should never happen
                    end
                end
            elseif action == "lalt" then
                if holdingShift then holdingShift = false end
                if isRemote() == 0 and freeLookToggle then
                    if toggleView then
                        if sysIsVwLock() == 1 then
                            sysLockVw(0)
                        else
                            sysLockVw(1)
                        end
                    else
                        toggleView = true
                    end
                elseif isRemote() == 0 and not freeLookToggle and userControlScheme == "keyboard" then
                    sysLockVw(0)
                end
                AltIsOn = false
            end
    
        end
    
        function Control.loopControl(action)
            -- Local functions onActionLoop
    
                local function groundLoop(down)
                    local mult = 1
                    if down then mult = -1 end
                    if not ExternalAGG and antigravOn then
                        if AntigravTargetAltitude ~= nil then 
                            AntigravTargetAltitude = AntigravTargetAltitude + mult*currentAggModifier
                            if AntigravTargetAltitude < 1000 then AntigravTargetAltitude = 1000 end
                            if AltitudeHold and AntigravTargetAltitude < HoldAltitude + 10 and AntigravTargetAltitude > HoldAltitude - 10 then 
                                HoldAltitude = AntigravTargetAltitude
                            end
                            currentAggModifier = uclamp(currentAggModifier * 1.05, antiGravButtonModifier, 50)
                            --BrakeIsOn = false
                        else
                            AntigravTargetAltitude = desiredBaseAltitude + mult*100
                           --BrakeIsOn = false
                        end
                    elseif AltitudeHold or VertTakeOff or IntoOrbit then
                        if IntoOrbit then
                            OrbitTargetOrbit = OrbitTargetOrbit + mult*currentHoldAltModifier
                            if OrbitTargetOrbit < planet.noAtmosphericDensityAltitude then OrbitTargetOrbit = planet.noAtmosphericDensityAltitude end
                        else
                            HoldAltitude = HoldAltitude + mult*currentHoldAltModifier
                        end
                        currentHoldAltModifier = uclamp(currentHoldAltModifier * 1.05, holdAltitudeButtonModifier, 50)
                    else
                        navCom:updateTargetGroundAltitudeFromActionLoop(mult*1.0)
                    end                
                end
                local function spdLoop(down)
                    local mult = 1
                    if down then mult = -1 end
                    if not holdingShift then
                        if AtmoSpeedAssist and not AltIsOn then
                            PlayerThrottle = uclamp(PlayerThrottle + mult*speedChangeSmall/100, -1, 1)
                        else
                            navCom:updateCommandFromActionLoop(axisCommandId.longitudinal, mult*speedChangeSmall)
                        end
                    end
                end
            if action == "groundaltitudeup" then
                if not holdingShift then groundLoop() end
            elseif action == "groundaltitudedown" then
                if not holdingShift then groundLoop(true) end
            elseif action == "speedup" then
                spdLoop()
            elseif action == "speeddown" then
                spdLoop(true)
            end
        end
    
        function Control.inputTextControl(text)
            -- Local functions for onInputText
                local function AddNewLocationByWaypoint(savename, pos, temp)
    
                    local function zeroConvertToWorldCoordinates(pos) -- Many thanks to SilverZero for this.
                        local num  = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
                        local posPattern = '::pos{' .. num .. ',' .. num .. ',' ..  num .. ',' .. num ..  ',' .. num .. '}'    
                        local systemId, id, latitude, longitude, altitude = stringmatch(pos, posPattern)
                        if (systemId == "0" and id == "0") then
                            return vec3(tonum(latitude),
                                        tonum(longitude),
                                        tonum(altitude))
                        end
                        longitude = math.rad(longitude)
                        latitude = math.rad(latitude)
                        local planet = atlas[tonum(systemId)][tonum(id)]  
                        local xproj = math.cos(latitude);   
                        local planetxyz = vec3(xproj*math.cos(longitude),
                                            xproj*math.sin(longitude),
                                                math.sin(latitude));
                        return planet.center + (planet.radius + altitude) * planetxyz
                    end   
                    local position = zeroConvertToWorldCoordinates(pos)
                    return ATLAS.AddNewLocation(savename, position, temp)
                end
    
            local i
            local command, arguement = nil, nil
            local commandhelp = "Command List:\n/commands \n/setname <newname> - Updates current selected saved position name\n/G VariableName newValue - Updates global variable to new value\n"..
                    "/G dump - shows all variables updatable by /G\n/agg <targetheight> - Manually set agg target height\n"..
                    "/addlocation SafeZoneCenter ::pos{0,0,13771471,7435803,-128971} - adds a saved location by waypoint, not as accurate as making one at location\n"..
                    "/::pos{0,0,13771471,7435803,-128971} - adds a temporary waypoint that is not saved to databank with name 0Temp\n"..
                    "/copydatabank - copies dbHud databank to a blank databank\n"..
                    "/iphWP - displays current IPH target's ::pos waypoint in lua chat\n"..
                    "/resist 0.15, 0.15, 0.15, 0.15 - Sets shield resistance distribution of the floating 60% extra available, usable once per minute\n"..
                    "/deletewp - Deletes current selected custom wp\n"..
                    "/createPrivate (all) - dumps private lcoations to screen if present to cut and paste to privatelocations.lua, all if present will make it include all databank locations."
            i = string.find(text, " ")
            command = text
            if i ~= nil then
                command = string.sub(text, 0, i-1)
                arguement = string.sub(text, i+1)
            end
            if command == "/help" or command == "/commands" then
                for str in string.gmatch(commandhelp, "([^\n]+)") do
                    s.print(str)
                end
                return   
            elseif command == "/setname" then 
                if arguement == nil or arguement == "" then
                    msgText = "Usage: ah-setname Newname"
                    return
                end
                if AutopilotTargetIndex > 0 and CustomTarget ~= nil then
                    ATLAS.UpdatePosition(arguement)
                else
                    msgText = "Select a saved target to rename first"
                end
            elseif shield and command =="/resist" then
                SHIELD.setResist(arguement)
            elseif command == "/addlocation" or string.find(text, "::pos") ~= nil then
                local temp = false
                local savename = "0-Temp"
                if arguement == nil or arguement == "" or command ~= "/addlocation" then
                    arguement = command
                    temp = true
                end
                i = string.find(arguement, "::")
                if not temp then savename = string.sub(arguement, 1, i-2) end
                local pos = string.sub(arguement, i)
                AddNewLocationByWaypoint(savename, pos, temp)
                elseif command == "/agg" then
                if arguement == nil or arguement == "" then
                    msgText = "Usage: /agg targetheight"
                    return
                end
                arguement = tonum(arguement)
                if arguement < 1000 then arguement = 1000 end
                AntigravTargetAltitude = arguement
                msgText = "AGG Target Height set to "..arguement
            elseif command == "/G" then
                if arguement == nil or arguement == "" then
                    msgText = "Usage: /G VariableName variablevalue\n/G dump - shows all variables"
                    return
                end
                if arguement == "dump" then
                    for k, v in pairs(saveableVariables()) do
                        if type(v.get()) == "boolean" then
                            if v.get() == true then
                                s.print(k.." true")
                            else
                                s.print(k.." false")
                            end
                        elseif v.get() == nil then
                            s.print(k.." nil")
                        else
                            s.print(k.." "..v.get())
                        end
                    end
                    return
                end
                i = string.find(arguement, " ")
                local globalVariableName = string.sub(arguement,0, i-1)
                local newGlobalValue = string.sub(arguement,i+1)
                for k, v in pairs(saveableVariables()) do
                    if k == globalVariableName then
                        local varType = type(v.get())
                        if varType == "number" then
                            newGlobalValue = tonum(newGlobalValue)
                            if k=="AtmoSpeedLimit" then adjustedAtmoSpeedLimit = newGlobalValue end
                        end
                        msgText = "Variable "..globalVariableName.." changed to "..newGlobalValue
                        if k=="MaxGameVelocity" then 
                            newGlobalValue = newGlobalValue/3.6
                            if newGlobalValue > MaxSpeed-0.2 then 
                                newGlobalValue = MaxSpeed-0.2 
                                msgText = "Variable "..globalVariableName.." changed to "..round(newGlobalValue*3.6,1)
                            end
                        end
                        if varType == "boolean" then
                            if string.lower(newGlobalValue) == "true" then
                                newGlobalValue = true
                            else
                                newGlobalValue = false
                            end
                        end
                        v.set(newGlobalValue)
                        return
                    end
                end
                msgText = "No such global variable: "..globalVariableName
            
            elseif command == "/deletewp" then
                if AutopilotTargetIndex > 0 and CustomTarget ~= nil then
                    ATLAS.ClearCurrentPosition()
                else
                    msgText = "Select a custom wp to delete first in IPH"
                end
            elseif command == "/copydatabank" then 
                if dbHud_2 then 
                    SaveDataBank(true) 
                else
                    msgText = "Spare Databank required to copy databank"
                end
    
            elseif command == "/iphWP" then
                if AutopilotTargetIndex > 0 then
                    s.print(AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords, true))
                    s.print(json.encode(AutopilotTargetCoords))
                    msgText = "::pos waypoint shown in lua chat in local and world format"
                else
                    msgText = "No target selected in IPH"
                end
            elseif command == "/createPrivate" then
                local saveStr = "privatelocations = {\n"
                local msgStr = ""
                if #privatelocations > 0 then
                    for k,v in pairs(privatelocations) do
                        saveStr = saveStr.. "{position = {x = "..v.position.x..", y = "..v.position.y..", z = "..v.position.z.."},\n "..
                                            "name = '"..v.name.."',\n planetname = '"..v.planetname.."',\n gravity = "..v.gravity..",\n"
                        if v.heading then saveStr = saveStr.."heading = {x = "..v.heading.x..", y = "..v.heading.y..", z = "..v.heading.z.."},\n" end
                        if v.safe then saveStr = saveStr.."safe = true},\n" else saveStr = saveStr.."safe = false},\n" end
                    end
                end
                msgStr = #privatelocations.."-Private "
                if arguement == "all" then
                    for k,v in pairs(SavedLocations) do
                        saveStr = saveStr.. "{position = {x = "..v.position.x..", y = "..v.position.y..", z = "..v.position.z.."},\n "..
                                            "name = '*"..v.name.."',\n planetname = '"..v.planetname.."',\n gravity = "..v.gravity..",\n"
                        if v.heading then saveStr = saveStr.."heading = {x = "..v.heading.x..", y = "..v.heading.y..", z = "..v.heading.z.."},\n" end
                        if v.safe then saveStr = saveStr.." safe = true},\n" else saveStr = saveStr.."safe = false},\n" end
                    end
                    msgStr = msgStr..#SavedLocations.."-Public "
                end
                saveStr = saveStr.."}\n return privatelocations"
                if screenHud_1 then screenHud_1.setHTML(saveStr) end
                msgText = msgStr.."locations dumped to screen if present.\n Cut and paste to privatelocations.lua to use"
                msgTimer = 7
            end
        end
    
        function Control.tagTick()
            if UseExtra == "Off" then UseExtra = "All"
            elseif UseExtra == "All" then UseExtra = "Longitude"
            elseif UseExtra == "Longitude" then UseExtra = "Lateral"
            elseif UseExtra == "Lateral" then UseExtra = "Vertical"
            else UseExtra = "Off"
            end
            msgText = "Extra Engine Tags: "..UseExtra 
            u.stopTimer("tagTick")
        end
    
        if userControl then 
            for k,v in pairs(userControl) do Control[k] = v end 
        end  
    
        return Control
    end
    local function programClass(Nav, c, u, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield, gyro, warpdrive, weapon, screenHud_1)
        local s = DUSystem
        local C = DUConstruct
        local P = DUPlayer
        local library = DULibrary
        -- Local variables and functions
            local program = {}
    
            local stringf = string.format
            local jdecode = json.decode
            local jencode = json.encode
            local eleMaxHp = c.getElementMaxHitPointsById
            local eleMass = c.getElementMassById
            local isRemote = Nav.control.isRemoteControlled
            local stringmatch = string.match
            local sysDestWid = s.destroyWidgetPanel
            local sysUpData = s.updateData
            local sysAddData = s.addDataToWidget
            local sysLockVw = s.lockView
            local sysIsVwLock = s.isViewLocked
            local msqrt = math.sqrt
            local tonum = tonumber
            local mabs = math.abs
            local mfloor = math.floor
            local atmosphere = u.getAtmosphereDensity
            local atan = math.atan
            local systime = s.getArkTime
            local uclamp = utils.clamp
            local navCom = Nav.axisCommandManager
    
            local targetGroundAltitude = LandingGearGroundHeight -- So it can tell if one loaded or not
            local coreHalfDiag = 13
            local elementsID = c.getElementIdList()
    
            local eleTotalMaxHp = 0
    
            local function float_eq(a, b) -- float equation
                if a == 0 then
                    return mabs(b) < 1e-09
                end
                if b == 0 then
                    return mabs(a) < 1e-09
                end
                return mabs(a - b) < math.max(mabs(a), mabs(b)) * epsilon
            end
            local function round(num, numDecimalPlaces) -- rounds variable num to numDecimalPlaces
                local mult = 10 ^ (numDecimalPlaces or 0)
                return mfloor(num * mult + 0.5) / mult
            end
            local function addTable(table1, table2) -- Function to add two tables together
                for k,v in pairs(table2) do
                    if type(k)=="string" then
                        table1[k] = v
                    else
                        table1[#table1 + 1 ] = table2[k]
                    end
                end
                return table1
            end
            local function saveableVariables(subset) -- returns saveable variables by catagory
                local returnSet = {}
                    -- Complete list of user variables above, must be in saveableVariables to be stored on databank
    
                if not subset then
                    addTable(returnSet, saveableVariablesBoolean)
                    addTable(returnSet, savableVariablesHandling)
                    addTable(returnSet, savableVariablesHud)
                    addTable(returnSet, savableVariablesPhysics)
                    return returnSet
                elseif subset == "boolean" then
                    return saveableVariablesBoolean
                elseif subset == "handling" then
                    return savableVariablesHandling
                elseif subset == "hud" then
                    return savableVariablesHud
                elseif subset == "physics" then
                    return savableVariablesPhysics
                end            
            end
            local function SaveDataBank(copy) -- Save values to the databank.
                local function writeData(dataList)
                    for k, v in pairs(dataList) do
                        dbHud_1.setStringValue(k, jencode(v.get()))
                        if copy and dbHud_2 then
                            dbHud_2.setStringValue(k, jencode(v.get()))
                        end
                    end
                end
                if dbHud_1 then
                    writeData(autoVariables) 
                    writeData(saveableVariables())
                    s.print("Saved Variables to Datacore")
                    if copy and dbHud_2 then
                        msgText = "Databank copied.  Remove copy when ready."
                    end
                end
            end
            local function play(sound, ID, type)
                if (type == nil and not voices) or (type ~= nil and not alerts) or soundFolder == "archHUD" then return end
                s.playSound(soundFolder.."/"..sound..".mp3")
            end
            local function svgText(x, y, text, class, style) -- processes a svg text string, saves code lines by doing it this way
                if class == nil then class = "" end
                if style == nil then style = "" end
                return stringf([[<text class="%s" x=%s y=%s style="%s">%s</text>]], class,x, y, style, text)
            end
        
            local function getDistanceDisplayString(distance, places) -- Turn a distance into a string to a number of places
                local su = distance > 100000
                if places == nil then places = 1 end
                if su then
                    -- Convert to SU
                    return round(distance / 1000 / 200, places).."SU"
                elseif distance < 1000 then
                    return round(distance, places).."M"
                else
                    -- Convert to KM
                    return round(distance / 1000, places).."KM"
                end
            end
        
            local function FormatTimeString(seconds) -- Format a time string for display
                local minutes = 0
                local hours = 0
                local days = 0
                if seconds < 60 then
                    seconds = mfloor(seconds)
                elseif seconds < 3600 then
                    minutes = mfloor(seconds / 60)
                    seconds = mfloor(seconds % 60) 
                elseif seconds < 86400 then
                    hours = mfloor(seconds / 3600)
                    minutes = mfloor( (seconds % 3600) / 60)
                else
                    days = mfloor ( seconds / 86400)
                    hours = mfloor ( (seconds % 86400) / 3600)
                end
                if days > 0 then 
                    return days .. "d " .. hours .."h "
                elseif hours > 0 then
                    return hours .. "h " .. minutes .. "m "
                elseif minutes > 0 then
                    return minutes .. "m " .. seconds .. "s"
                elseif seconds > 0 then 
                    return seconds .. "s"
                else
                    return "0s"
                end
            end
        local function radarSetup()
            if radar_1 and FullRadar then 
                RADAR = RadarClass(c, s, u, radar_1, radar_2, warpdrive, mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) 
            end
        end
    
        function program.radarSetup()
            radarSetup()
        end
    
        function program.onStart()
            -- Local functions for onStart
    
                local valuesAreSet = false
                local function LoadVariables()
    
                    local function processVariableList(varList)
                        local hasKey = dbHud_1.hasKey
                        for k, v in pairs(varList) do
                            if hasKey(k) then
                                local result = jdecode(dbHud_1.getStringValue(k))
                                if result ~= nil then
                                    v.set(result)
                                    valuesAreSet = true
                                end
                            end
                        end
                    end
                    pcall(require,"autoconf/custom/archhud/custom/userglobals")
                    if dbHud_1 then
                        if not useTheseSettings then 
                            processVariableList(saveableVariables())
                            coroutine.yield()
                            processVariableList(autoVariables)
                        else
                            processVariableList(autoVariables)
                            msgText = "Updated user preferences used.  Will be saved when you exit seat.\nToggle off useTheseSettings to use saved values"
                            msgTimer = 5
                            valuesAreSet = false
                        end
                        coroutine.yield()
                        if valuesAreSet then
                            msgText = "Loaded Saved Variables"
                        elseif not useTheseSettings then
                            msgText = "No Databank Saved Variables Found\nVariables will save to Databank on standing"
                            msgTimer = 5
                        end
                        if #SavedLocations>0 then customlocations = addTable(customlocations, SavedLocations) end
                    else
                        msgText = "No databank found. Attach one to control u and rerun \nthe autoconfigure to save preferences and locations"
                    end
                    resolutionWidth = ResolutionX
                    resolutionHeight = ResolutionY
                    BrakeToggleStatus = BrakeToggleDefault
                    userControlScheme = string.lower(userControlScheme)
                    autoRoll = autoRollPreference
                    adjustedAtmoSpeedLimit = AtmoSpeedLimit
                    if (LastStartTime + 180) < time then -- Variables to reset if out of seat (and not on hud) for more than 3 min
                        LastMaxBrakeInAtmo = 0
                    end
                    LastStartTime = time
                    userControlScheme = string.lower(userControlScheme)
                    if string.find("keyboard virtual joystick mouse",  userControlScheme) == nil then 
                        msgText = "Invalid User Control Scheme selected.\nChange userControlScheme in Lua Parameters to keyboard, mouse, or virtual joystick\nOr use shift and button in screen"
                        msgTimer = 7
                    end
                
                    if antigrav and not ExternalAGG then
                        if AntigravTargetAltitude == nil then 
                            AntigravTargetAltitude = coreAltitude
                        end
                        antigrav.setTargetAltitude(AntigravTargetAltitude)
                    end
                    if pcall(require, "autoconf/custom/archhud/privatelocations") then
                        if #privatelocations>0 then customlocations = addTable(customlocations, privatelocations) end
                    end
                    VectorStatus = "Proceeding to Waypoint"
                    if not MaxGameVelocity or MaxGameVelocity < 0 then MaxGameVelocity = C.getMaxSpeed()-0.1 end
                end
    
                local function ProcessElements()
                    
                    local function CalculateFuelVolume(curMass, vanillaMaxVolume)
                        if curMass > vanillaMaxVolume then
                            vanillaMaxVolume = curMass
                        end
                        local f1, f2 = 0, 0
                        if ContainerOptimization > 0 then 
                            f1 = ContainerOptimization * 0.05
                        end
                        if FuelTankOptimization > 0 then 
                            f2 = FuelTankOptimization * 0.05
                        end
                        vanillaMaxVolume = vanillaMaxVolume * (1 - (f1 + f2))
                        return vanillaMaxVolume            
                    end
    
                    local eleName = c.getElementNameById
                    local checkTanks = (fuelX ~= 0 and fuelY ~= 0)
                    local slottedTanksAtmo = _G["atmofueltank_size"]
                    local slottedTanksSpace = _G["spacefueltank_size"]
                    local slottedTanksRocket = _G["rocketfueltank_size"]
                    for k in pairs(elementsID) do --Look for space engines, landing gear, fuel tanks if not slotted and c size
                        local type = c.getElementDisplayNameById(elementsID[k])
                        if stringmatch(type, '^.*Atmospheric Engine$') then
                            if stringmatch(tostring(c.getElementTagsById(elementsID[k])), '^.*vertical.*$') and c.getElementForwardById(elementsID[k])[3]>0 then
                                UpVertAtmoEngine = true
                            end
                        end
    
                        if stringmatch(type, '^.*Space Engine$') then
                            SpaceEngines = true
                            if stringmatch(tostring(c.getElementTagsById(elementsID[k])), '^.*vertical.*$') then
                                local enrot = c.getElementForwardById(elementsID[k])
                                if enrot[3] < 0 then
                                    SpaceEngineVertUp = true
                                else
                                    SpaceEngineVertDn = true
                                end
                            end
                        end
                        if (type == "Landing Gear") then
                            hasGear = true
                        end
                        if (type == "Dynamic Core Unit") then
                            local hp = eleMaxHp(elementsID[k])
                            if hp > 10000 then
                                coreHalfDiag = 110
                            elseif hp > 1000 then
                                coreHalfDiag = 55
                            elseif hp > 150 then
                                coreHalfDiag = 27
                            end
                        end
                        eleTotalMaxHp = eleTotalMaxHp + eleMaxHp(elementsID[k])
                        if checkTanks and (type == "Atmospheric Fuel Tank" or type == "Space Fuel Tank" or type == "Rocket Fuel Tank") then
                            local hp = eleMaxHp(elementsID[k])
                            local mass = eleMass(elementsID[k])
                            local curMass = 0
                            local curTime = systime()
                            if (type == "Atmospheric Fuel Tank") then
                                local vanillaMaxVolume = 400
                                local massEmpty = 35.03
                                if hp > 10000 then
                                    vanillaMaxVolume = 51200 -- volume in kg of L tank
                                    massEmpty = 5480
                                elseif hp > 1300 then
                                    vanillaMaxVolume = 6400 -- volume in kg of M
                                    massEmpty = 988.67
                                elseif hp > 150 then
                                    vanillaMaxVolume = 1600 --- volume in kg small
                                    massEmpty = 182.67
                                end
                                curMass = mass - massEmpty
                                if fuelTankHandlingAtmo > 0 then
                                    vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingAtmo * 0.2))
                                end
                                vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                                
                                local name = eleName(elementsID[k])
                                
                                local slottedIndex = 0
                                for j = 1, slottedTanksAtmo do
                                    if name == jdecode(u["atmofueltank_" .. j].getWidgetData()).name then
                                        slottedIndex = j
                                        break
                                    end
                                end
                                
                                local tank = {elementsID[k], string.sub(name, 1, 12),
                                                            vanillaMaxVolume, massEmpty, curMass, curTime, slottedIndex}
                                atmoTanks[#atmoTanks + 1] = tank
                            end
                            if (type == "Rocket Fuel Tank") then
                                local vanillaMaxVolume = 320
                                local massEmpty = 173.42
                                if hp > 65000 then
                                    vanillaMaxVolume = 40000 -- volume in kg of L tank
                                    massEmpty = 25740
                                elseif hp > 6000 then
                                    vanillaMaxVolume = 5120 -- volume in kg of M
                                    massEmpty = 4720
                                elseif hp > 700 then
                                    vanillaMaxVolume = 640 --- volume in kg small
                                    massEmpty = 886.72
                                end
                                curMass = mass - massEmpty
                                if fuelTankHandlingRocket > 0 then
                                    vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingRocket * 0.1))
                                end
                                vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                                
                                local name = eleName(elementsID[k])
                                
                                local slottedIndex = 0
                                for j = 1, slottedTanksRocket do
                                    if name == jdecode(u["rocketfueltank_" .. j].getWidgetData()).name then
                                        slottedIndex = j
                                        break
                                    end
                                end
                                
                                local tank = {elementsID[k], string.sub(name, 1, 12),
                                                            vanillaMaxVolume, massEmpty, curMass, curTime, slottedIndex}
                                rocketTanks[#rocketTanks + 1] = tank
                            end
                            if (type == "Space Fuel Tank") then
                                local vanillaMaxVolume = 600
                                local massEmpty = 35.03
                                if hp > 10000 then
                                    vanillaMaxVolume = 76800 -- volume in kg of L tank
                                    massEmpty = 5480
                                elseif hp > 1300 then
                                    vanillaMaxVolume = 9600 -- volume in kg of M
                                    massEmpty = 988.67
                                elseif hp > 150 then
                                    vanillaMaxVolume = 2400 -- volume in kg of S
                                    massEmpty = 182.67                                
                                end
                                curMass = mass - massEmpty
                                if fuelTankHandlingSpace > 0 then
                                    vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingSpace * 0.2))
                                end
                                vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                                
                                local name = eleName(elementsID[k])
                                
                                local slottedIndex = 0
                                for j = 1, slottedTanksSpace do
                                    if name == jdecode(u["spacefueltank_" .. j].getWidgetData()).name then
                                        slottedIndex = j
                                        break
                                    end
                                end
                                
                                local tank = {elementsID[k], string.sub(name, 1, 12),
                                                            vanillaMaxVolume, massEmpty, curMass, curTime, slottedIndex}
                                spaceTanks[#spaceTanks + 1] = tank
                            end
                        end
                    end
                    if not UpVertAtmoEngine then
                        VertTakeOff, VertTakeOffEngine = false, false
                    end
                end
                
                local function SetupChecks()
                    
                    if gyro ~= nil then
                        gyroIsOn = gyro.isActive() == 1
                    end
                    if not stablized then 
                        navCom:deactivateGroundEngineAltitudeStabilization()
                    end
                    if userControlScheme ~= "keyboard" then
                        sysLockVw(1)
                    else
                        sysLockVw(0)
                    end
                    -- Close door and retract ramp if available
                    if door and (inAtmo or (not inAtmo and coreAltitude < 10000)) then
                        for _, v in pairs(door) do
                            v.toggle()
                        end
                    end
                    if switch then 
                        for _, v in pairs(switch) do
                            v.toggle()
                        end
                    end    
                    if forcefield and (inAtmo or (not inAtmo == 0 and coreAltitude < 10000)) then
                        for _, v in pairs(forcefield) do
                            v.toggle()
                        end
                    end
                    if antigrav then
                        antigravOn = (antigrav.isActive() == 1)
                        if antigravOn and not ExternalAGG then antigrav.showWidget() end
                    end
                    -- unfreeze the player if he is remote controlling the construct
                    if isRemote() == 1 and RemoteFreeze then
                        P.freeze(1)
                    else
                        P.freeze(0)
                    end
                    if hasGear then
                        if abvGndDet ~= -1 and not antigravOn then
                            Nav.control.deployLandingGears()
                        else
                            Nav.control.retractLandingGears()
                        end
                    end
                    GearExtended = (Nav.control.isAnyLandingGearDeployed() == 1) or (abvGndDet ~=-1 and (abvGndDet - 3) < LandingGearGroundHeight)
                    -- Engage brake and extend Gear if either a hover detects something, or they're in space and moving very slowly
                    if abvGndDet ~= -1 or (not inAtmo and coreVelocity:len() < 50) then
                        BrakeIsOn = "Startup"
                    else
                        BrakeIsOn = false
                    end
    
                    navCom:setTargetGroundAltitude(targetGroundAltitude)
    
                    WasInAtmo = inAtmo
    
                end
    
                local function atlasSetup()
                    local atlasCopy = {}
                    
                    local function getSpaceEntry()
                        return {
                                    id = 0,
                                    name = { "Space", "Space", "Space"},
                                    type = {},
                                    biosphere = {},
                                    classification = {},
                                    habitability = {},
                                    description = {},
                                    iconPath = "",
                                    hasAtmosphere = false,
                                    isSanctuary = false,
                                    isInSafeZone = true,
                                    systemId = 0,
                                    positionInSystem = 0,
                                    satellites = {},
                                    center = { 0, 0, 0 },
                                    gravity = 0,
                                    radius = 0,
                                    atmosphereThickness = 0,
                                    atmosphereRadius = 0,
                                    surfaceArea = 0,
                                    surfaceAverageAltitude = 0,
                                    surfaceMaxAltitude = 0,
                                    surfaceMinAltitude = 0,
                                    GM = 0,
                                    ores = {},
                                    territories = 0,
                                    noAtmosphericDensityAltitude = 0,
                                    spaceEngineMinAltitude = 0,
                                }
                    end
    
                    local altTable = { [1]=4480, [6]=4480, [7]=6270, [27]=4150 } -- Alternate min space engine altitudes for madis, sinnen, sicari, haven
                    -- No Atmo Heights for Madis, Alioth, Thades, Talemai, Feli, Sicari, Sinnen, Teoma, Jago, Sanctuary, Haven, Lacobus, Symeon, Ion.
                    local noAtmoAlt = {[1]=8041,[2]=6263,[3]=39281,[4]=10881,[5]=78382,[6]=8761,[7]=11616,[8]=6272,[9]=10891,[26]=7791,[27]=7700,[100]=12511,[110]=7792,[120]=11766} 
                    for galaxyId,galaxy in pairs(atlas) do
                        -- Create a copy of Space with the appropriate SystemId for each galaxy
                        atlas[galaxyId][0] = getSpaceEntry()
                        atlas[galaxyId][0].systemId = galaxyId
                        atlasCopy[galaxyId] = {} -- Prepare a copy galaxy
    
                        for planetId,planet in pairs(atlas[galaxyId]) do
                            planet.gravity = planet.gravity/9.8
                            planet.center = vec3(planet.center)
                            planet.name = planet.name[1]
                    
                            planet.noAtmosphericDensityAltitude = noAtmoAlt[planet.id] or planet.atmosphereThickness or (planet.atmosphereRadius-planet.radius)
                            planet.spaceEngineMinAltitude = altTable[planet.id] or 0.68377*(planet.atmosphereThickness)
                                    
                            planet.planetarySystemId = galaxyId
                            planet.bodyId = planet.id
                            atlasCopy[galaxyId][planetId] = planet
                            if minAtlasX == nil or planet.center.x < minAtlasX then
                                minAtlasX = planet.center.x
                            end
                            if maxAtlasX == nil or planet.center.x > maxAtlasX then
                                maxAtlasX = planet.center.x
                            end
                            if minAtlasY == nil or planet.center.y < minAtlasY then
                                minAtlasY = planet.center.y
                            end
                            if maxAtlasY == nil or planet.center.y > maxAtlasY then
                                maxAtlasY = planet.center.y
                            end
                            if planet.center and planet.name ~= "Space" then
                                planetAtlas[#planetAtlas + 1] = planet
                            end
                        end
                    end
                    PlanetaryReference = PlanetRef(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq)
                    galaxyReference = PlanetaryReference(atlasCopy)
                    -- Setup Modular Classes
                    Kinematic = Kinematics(Nav, c, u, s, msqrt, mabs)
                    Kep = Keplers(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq)
    
                    ATLAS = AtlasClass(Nav, c, u, s, dbHud_1, atlas, sysUpData, sysAddData, mfloor, tonum, msqrt, play, round)
                    planet = galaxyReference[0]:closestBody(C.getWorldPosition())
                end
    
            SetupComplete = false
    
            beginSetup = coroutine.create(function()
                
                --[[ --EliasVilld Log Code setup material.
                Logs = Logger()
                _logCompute = Logs.CreateLog("Computation", "time")
                --]]
    
                navCom:setupCustomTargetSpeedRanges(axisCommandId.longitudinal,
                    {1000, 5000, 10000, 20000, 30000})
    
                -- Load Saved Variables
    
                LoadVariables()
                coroutine.yield() -- Give it some time to breathe before we do the rest
    
                -- Find elements we care about
                ProcessElements()
                coroutine.yield() -- Give it some time to breathe before we do the rest
    
                AP = APClass(Nav, c, u, atlas, vBooster, hover, telemeter_1, antigrav, warpdrive, dbHud_1, 
                    mabs, mfloor, atmosphere, isRemote, atan, systime, uclamp, 
                    navCom, sysUpData, sysIsVwLock, msqrt, round, play, addTable, float_eq, 
                    getDistanceDisplayString, FormatTimeString, SaveDataBank, jdecode, stringf, sysAddData)
    
                SetupChecks() -- All the if-thens to set up for particular ship.  Specifically override these with the saved variables if available
    
                coroutine.yield() -- Just to make sure
    
                atlasSetup()
                radarSetup()
    
                if HudClass then 
                    HUD = HudClass(Nav, c, u, s, atlas, antigrav, hover, shield, warpdrive, weapon, mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, navCom, 
                        sysAddData, sysUpData, sysDestWid, sysIsVwLock, msqrt, round, svgText, play, addTable, saveableVariables, getDistanceDisplayString, FormatTimeString, elementsID, eleTotalMaxHp) 
                end
                if HUD then 
                    HUD.ButtonSetup() 
                end
                CONTROL = ControlClass(Nav, c, u, s, atlas, vBooster, hover, antigrav, shield, dbHud_2, gyro, screenHud_1,
                    isRemote, navCom, sysIsVwLock, sysLockVw, sysDestWid, round, stringmatch, tonum, uclamp, play, saveableVariables, SaveDataBank)
                if shield then SHIELD = ShieldClass(shield, stringmatch, mfloor) end
                coroutine.yield()
                u.hideWidget()
                s.showScreen(1)
                s.showHelper(0)
                if screenHud_1 then screenHud_1.clear() end
                -- That was a lot of work with dirty strings and json.  Clean up
                collectgarbage("collect")
                -- Start timers
                coroutine.yield()
    
                u.setTimer("apTick", 0.0166667)
                u.setTimer("hudTick", hudTickRate)
                u.setTimer("oneSecond", 1)
                u.setTimer("tenthSecond", 1/10)
                u.setTimer("fiveSecond", 5) 
                if shield then u.setTimer("shieldTick", 0.0166667) end
                if userBase then PROGRAM.ExtraOnStart() end
                play("start","SU")
            end)
            coroutine.resume(beginSetup)
        end
        
        function program.onUpdate()
            if not SetupComplete then
                local cont = coroutine.status (beginSetup)
                if cont == "suspended" then 
                    local value, done = coroutine.resume(beginSetup)
                    if done then s.print("ERROR STARTUP: "..done) end
                elseif cont == "dead" then
                    SetupComplete = true
                end
            end
            if SetupComplete then
                Nav:update()
                if inAtmo and AtmoSpeedAssist and throttleMode then
                    if throttleMode and WasInCruise then
                        -- Not in cruise, but was last tick
                        AP.cmdThrottle(0)
                        WasInCruise = false
                    elseif not throttleMode and not WasInCruise then
                        -- Is in cruise, but wasn't last tick
                        PlayerThrottle = 0 -- Reset this here too, because, why not
                        WasInCruise = true
                    end
                end
                if ThrottleValue then
                    navCom:setThrottleCommand(axisCommandId.longitudinal, ThrottleValue)
                    ThrottleValue = nil
                end
                
                if not Animating and content ~= LastContent then
                    s.setScreen(content) 
                end
                LastContent = content
                if userBase then PROGRAM.ExtraOnUpdate() end
            end
        end
    
        function program.onFlush()
            if SetupComplete then
                AP.onFlush()
                if userBase then PROGRAM.ExtraOnFlush() end
            end
        end
    
        function program.onStop()
            _autoconf.hideCategoryPanels()
            if antigrav ~= nil  and not ExternalAGG then
                antigrav.hideWidget()
            end
            if warpdrive ~= nil then
                warpdrive.hideWidget()
            end
            c.hideWidget()
            Nav.control.switchOffHeadlights()
            -- Open door and extend ramp if available
            if door and (atmosDensity > 0 or (atmosDensity == 0 and coreAltitude < 10000)) then
                for _, v in pairs(door) do
                    v.toggle()
                end
            end
            if switch then
                for _, v in pairs(switch) do
                    v.toggle()
                end
            end
            if forcefield and (atmosDensity > 0 or (atmosDensity == 0 and coreAltitude < 10000)) then
                for _, v in pairs(forcefield) do
                    v.toggle()
                end
            end
            showHud = oldShowHud
            SaveDataBank()
            if button then
                button.activate()
            end
            if SetWaypointOnExit then AP.showWayPoint(planet, worldPos) end
            if HUD then s.print(HUD.FuelUsed("atmofueltank")..", "..HUD.FuelUsed("spacefueltank")..", "..HUD.FuelUsed("rocketfueltank")) end
            if userBase then PROGRAM.ExtraOnStop() end
            play("stop","SU")
        end
    
        function program.controlStart(action)
            if SetupComplete then
                CONTROL.startControl(action)
            end
        end
    
        function program.controlStop(action)
            if SetupComplete then
                CONTROL.stopControl(action)
            end
        end
    
        function program.controlLoop(action)
            if SetupComplete then
                CONTROL.loopControl(action)
            end
        end
    
        function program.controlInput(text)
            if SetupComplete then
                CONTROL.inputTextControl(text)
            end
        end
    
        function program.radarEnter(id)
            if RADAR then RADAR.onEnter(id) end
        end
    
        function program.radarLeave(id)
            if RADAR then RADAR.onLeave(id) end
        end
    
        function program.onTick(timerId)
            if timerId == "tenthSecond" then -- Timer executed ever tenth of a second
                AP.TenthTick()
                if HUD then HUD.TenthTick() end
            elseif timerId == "oneSecond" then -- Timer for evaluation every 1 second
                if HUD then HUD.OneSecondTick() end
            elseif timerId == "fiveSecond" then -- Timer executed every 5 seconds (SatNav only stuff for now)
                AP.SatNavTick()
            elseif timerId == "msgTick" then -- Timer executed whenever msgText is applied somwehere
                if HUD then HUD.MsgTick() end
            elseif timerId == "animateTick" then -- Timer for animation
                if HUD then HUD.AnimateTick() end
            elseif timerId == "hudTick" then -- Timer for all hud updates not called elsewhere
                if HUD then HUD.hudtick() end
            elseif timerId == "apTick" then -- Timer for all autopilot functions
                AP.APTick()
            elseif timerId == "shieldTick" then
                SHIELD.shieldTick()
            elseif timerId == "tagTick" then
                CONTROL.tagTick()
            elseif timerId == "contact" then
                RADAR.ContactTick()
            end
        end
    
        if userBase then 
            for k,v in pairs(userBase) do program[k] = v end 
        end  
    
        return program
    end
-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
    function script.onStart()
        PROGRAM.onStart()
    end

    function script.onOnStop()
        PROGRAM.onStop()
    end

    function script.onTick(timerId)  
        PROGRAM.onTick(timerId)       -- Various tick timers
    end

    function script.onOnFlush()
        PROGRAM.onFlush()
    end

    function script.onOnUpdate()
        PROGRAM.onUpdate()
    end

    function script.onActionStart(action)
        PROGRAM.controlStart(action)
    end

    function script.onActionStop(action)
        PROGRAM.controlStop(action)
    end

    function script.onActionLoop(action)
        PROGRAM.controlLoop(action)
    end

    function script.onInputText(text)
        PROGRAM.controlInput(text)
    end

    function script.onEnter(id)
        PROGRAM.radarEnter(id)
    end

    function script.onLeave(id)
        PROGRAM.radarLeave(id)
    end
-- Execute Script
    globalDeclare(core, unit, system.getArkTime, math.floor, unit.getAtmosphereDensity) -- Variables that need to be Global, arent user defined, and are declared in globals.lua due to use across multple modules where there values can change.
    PROGRAM = programClass(Nav, core, unit, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield, gyro, warpdrive, weapon, screenHud_1)
    script.onStart()