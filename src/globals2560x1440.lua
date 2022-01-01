-- These values are a default set for 2560x1440 ResolutionX and Y settings. 

-- User variables, visable via Edit Lua Parameters. Must be global to wor kwith databank system as set up due to using _G assignment
useTheseSettings = false --export:  Change this to true to override databank saved settings
userControlScheme = "virtual joystick" --export: (Default: "virtual joystick") Set to "virtual joystick", "mouse", or "keyboard". This can be set by holding SHIFT and clicking the button in lower left of main Control buttons view.
soundFolder = "archHUD" --export: (Default: "archHUD") Set to the name of the folder with sound files in it. Must be changed from archHUD to prevent other scripts making your PC play sounds.
-- True/False variables
    -- NOTE: saveableVariablesBoolean below must contain any True/False variables that needs to be saved/loaded from databank.
    saveableVariablesBoolean = {"userControlScheme", "soundFolder", "freeLookToggle", "BrakeToggleDefault", "RemoteFreeze", "brightHud", "RemoteHud", "VanillaRockets",
    "InvertMouse", "autoRollPreference", "ExternalAGG", "UseSatNav", "ShouldCheckDamage", 
    "CalculateBrakeLandingSpeed", "AtmoSpeedAssist", "ForceAlignment", "DisplayDeadZone", "showHud", "hideHudOnToggleWidgets", 
    "ShiftShowsRemoteButtons", "SetWaypointOnExit", "AlwaysVSpd", "BarFuelDisplay", 
    "voices", "alerts", "CollisionSystem", "AutoShieldToggle", "PreventPvP"}

    freeLookToggle = true --export: (Default: true) Set to false for vanilla DU free look behavior.
    BrakeToggleDefault = true --export: (Default: true) Whether your brake toggle is on/off by default. Can be adjusted in the button menu. False is vanilla DU brakes.
    RemoteFreeze = false --export: (Default: false) Whether or not to freeze your character in place when using a remote controller.
    RemoteHud = false --export:  (Default: false) Whether you want to see the full normal HUD while in remote mode.
    brightHud = false --export: (Default: false) Enable to prevent hud hiding when in freelook.
    VanillaRockets = false --export: (Default: false) If on, rockets behave like vanilla
    InvertMouse = false --export: (Default: false) If true, then when controlling flight mouse Y axis is inverted (pushing up noses plane down) Does not affect selecting buttons or camera.
    autoRollPreference = false --export: (Default: false) [Only in atmosphere] - When the pilot stops rolling, flight model will try to get back to horizontal (no roll)
    ExternalAGG = false --export: (Default: false) Toggle On if using an external AGG system. If on will prevent this HUD from doing anything with AGG.
    UseSatNav = false --export: (Default: false) Toggle on if using Trog SatNav script. This will provide SatNav support.
    ShouldCheckDamage = true --export: (Default: true) Whether or not damage checks are performed. Disable for performance improvement on very large ships or if using external Damage Report and you do not want the built in info.
    CalculateBrakeLandingSpeed = false --export: (Default: false) Whether BrakeLanding speed at non-waypoints should be calculated (faster) or use the brakeLandingRate user setting (safer).  Set to true for faster, not as safe, brake landing
    AtmoSpeedAssist = true --export: (Default: true) Whether or not atmospheric speeds should be limited to a maximum of AtmoSpeedLimit (Hud built in speed limiter)
    ForceAlignment = false --export: (Default: false) Whether velocity vector alignment should be forced when in Altitude Hold (needed for ships that drift alignment in altitude hold mode due to poor inertial matrix)
    DisplayDeadZone = true --export: (Default: true) Virtual Joystick Mode: Set this to false to not display deadzone circle while in virtual joystick mode.
    showHud = true --export: (Default: true) False to hide the HUD screen and only use HUD Autopilot features (AP via ALT+# keys)
    hideHudOnToggleWidgets = true --export:  (Default: true) Uncheck to keep showing HUD when you toggle on the vanilla widgets via ALT+3. Note, hiding the HUD with Alt+3 gives a lot of FPS back in laggy areas, so leave true normally.
    ShiftShowsRemoteButtons = true --export: (Default: true) Whether or not pressing Shift in remote controller mode shows you the buttons (otherwise no access to them)
    SetWaypointOnExit = false --export: (Default: true) Set to false to not set a waypoint when you exit hud. True helps find your ship in crowded locations when you get out of seat.
    AlwaysVSpd = false --export: (Default: false) Set to true to make vertical speed meter stay on screen when you alt-3 widget mode.
    BarFuelDisplay = true --export: (Default: true) Set to false to use old non-bar fuel display
    voices = true --export: (Default: true) Set to false to disable voice sounds when using sound pack
    alerts = true --export: (Default: true) Set to false to disable alert sounds when using sound pack
    CollisionSystem = true --export: (Default: true) If True, system will provide collision alerts and abort vector to target if conditions met.
    AutoShieldToggle = true --export: (Default: true) If true, system will toggle Shield off in safe space and on in PvP space automagically.
    PreventPvP = true --export: (Default: true) If true, system will stop you before crossing from safe to pvp space while in autopilot.

-- Ship Handling variables
    -- NOTE: savableVariablesHandling below must contain any Ship Handling variables that needs to be saved/loaded from databank.
    savableVariablesHandling = {"YawStallAngle","PitchStallAngle","brakeLandingRate","MaxPitch", "ReEntryPitch","LockPitchTarget", "AutopilotSpaceDistance", "TargetOrbitRadius", "LowOrbitHeight",
    "AtmoSpeedLimit","SpaceSpeedLimit","AutoTakeoffAltitude","TargetHoverHeight", "LandingGearGroundHeight", "ReEntryHeight",
    "MaxGameVelocity", "AutopilotInterplanetaryThrottle","warmup","fuelTankHandlingAtmo","fuelTankHandlingSpace",
    "fuelTankHandlingRocket","ContainerOptimization","FuelTankOptimization", "WipeDamage"}

    YawStallAngle = 35 --export: (Default: 35) Angle at which the ship stalls when yawing, determine by experimentation. Higher allows faster AP Bank turns.
    PitchStallAngle = 35 --export: (Default: 35) Angle at which the ship stalls when pitching, determine by experimentation.
    brakeLandingRate = 30 --export: (Default: 30) Max loss of altitude speed in m/s when doing a brake landing. 30 is safe for almost all ships.  Overriden if CalculateBrakeLandingSpeed is true.
    MaxPitch = 30 --export: (Default: 30) Maximum allowed pitch during takeoff and altitude changes while in altitude hold. You can set higher or lower depending on your ships capabilities.
    ReEntryPitch = -30 --export: (Default: -30) Maximum downward pitch allowed during freefall portion of re-entry.
    LockPitchTarget = 0 --export: (Default: 0) Target pitch ship tries to hold when LALT-LSHIFT-5 is pressed.
    AutopilotSpaceDistance = 5000 --export: (Default: 5000) Target distance AP will try to stop from a custom waypoint in space.  Good ships can lower this value a lot.
    TargetOrbitRadius = 1.2 --export: (Default: 1.2) How tight you want to orbit the planet at end of autopilot.  The smaller the value the tighter the orbit.  Value is multiple of Atmospheric Height
    LowOrbitHeight = 2000 --export: (Default: 2000) Height of Orbit above top of atmospehre when using Alt-4-4 same planet autopilot or alt-6-6 in space.
    AtmoSpeedLimit = 1050 --export: (Default: 1050) Speed limit in Atmosphere in km/h. AtmoSpeedAssist will cause ship to throttle back when this speed is reached.
    SpaceSpeedLimit = 30000 --export: (Default: 30000) Space speed limit in KM/H. If you hit this speed and are NOT in active autopilot, engines will turn off to prevent using all fuel (30000 means they wont turn off)
    AutoTakeoffAltitude = 1000 --export: (Default: 1000) How high above your ground height AutoTakeoff tries to put you
    TargetHoverHeight = 50 --export: (Default: 50) Hover height above ground when G used to lift off, 50 is above all max hover heights.
    LandingGearGroundHeight = 0 --export: (Default: 0) Set to AGL-1 when on ground (or 0). Will help prevent ship landing on ground then bouncing back up to landing gear height. If too high, engines will not turn off
    ReEntryHeight = 100000 -- export: (Default: 100000) Height above a planets maximum surface altitude used for re-entry, if height exceeds min space engine height, then 11% atmo is used instead. (100000 means 11% is used)
    MaxGameVelocity = 8333.00 --export: (Default: 8333.00) Max speed for your autopilot in m/s, do not go above 8333.055 (30000 km/hr), can be reduced to save fuel. Some ships will not turn off engines if 8333.055 is used.
    AutopilotInterplanetaryThrottle = 1.0 --export: (Default: 1.0) How much throttle, 0.0 to 1.0, you want it to use when in autopilot to another planet while reaching MaxGameVelocity
    warmup = 32 --export: How long it takes your space engines to warmup. Basic Space Engines, from XS to XL: 0.25,1,4,16,32. Only affects turn and burn brake calculations.
    fuelTankHandlingAtmo = 0 --export:  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
    fuelTankHandlingSpace = 0 --export:  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
    fuelTankHandlingRocket = 0 --export:  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
    ContainerOptimization = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the Container Optimization level of the person who placed the tanks. Ignored for slotted tanks.
    FuelTankOptimization = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank optimization skill level of the person who placed the tank. Ignored for slotted tanks.
    WipeDamage = 0 --export: (Default: 0) % damage above which hud will wipe saved locations on databank.  Requires ShouldCheckDamage to be true.

-- HUD Postioning variables
    -- NOTE: savableVariablesHud below must contain any HUD Postioning variables that needs to be saved/loaded from databank.
    savableVariablesHud = {"ResolutionX","ResolutionY","circleRad","SafeR", "SafeG", "SafeB", 
    "PvPR", "PvPG", "PvPB","centerX", "centerY", "throtPosX", "throtPosY",
    "vSpdMeterX", "vSpdMeterY","altMeterX", "altMeterY","fuelX", "fuelY", "shieldX", "shieldY", "DeadZone",
    "OrbitMapSize", "OrbitMapX", "OrbitMapY", "soundVolume"}

    ResolutionX = 2560 --export: (Default: 2560) Does not need to be set to same as game resolution. You can set 1920 on a 2560 to get larger resolution
    ResolutionY = 1440 --export: (Default: 1440) Does not need to be set to same as game resolution. You can set 1080 on a 1440 to get larger resolution
    circleRad = 400 --export: (Default: 400) The size of the artifical horizon circle, recommended minimum 100, maximum 400. Looks different > 200. Set to 0 to remove.
    SafeR = 130 --export: (Default: 130) Primary HUD color
    SafeG = 224 --export: (Default: 224) Primary HUD color
    SafeB = 255 --export: (Default: 255) Primary HUD color
    PvPR = 255 --export: (Default: 255) PvP HUD color
    PvPG = 0 --export: (Default: 0) PvP HUD color
    PvPB = 0 --export: (Default: 0) PvP HUD color
    centerX = 1280 --export: (Default: 1280) X postion of Artifical Horizon (KSP Navball), Default 960. Use centerX=700 and centerY=880 for lower left placement.
    centerY = 720 --export: (Default: 720) Y postion of Artifical Horizon (KSP Navball), Default 540. Use centerX=700 and centerY=880 for lower left placement.
    throtPosX = 1400 --export: (Default: 1400) X position of Throttle Indicator, default 1300 to put it to right of default AH centerX parameter.
    throtPosY = 720 --export: (Default: 720) Y position of Throttle indicator, default is 540 to place it centered on default AH centerY parameter
    vSpdMeterX = 2150  --export: (Default: 2150) X postion of Vertical Speed Meter. Default 1525
    vSpdMeterY = 380 --export: (Default: 380) Y postion of Vertical Speed Meter. Default 325
    altMeterX = 1090  --export: (Default: 1090) X postion of Altimeter. Default 550
    altMeterY = 710 --export: (Default: 710) Y postion of Altimeter. Default 500
    fuelX = 40 --export: (Default: 40) X position of fuel tanks, set to 100 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
    fuelY = 940 --export: (Default: 940) Y position of fuel tanks, set to 300 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
    shieldX = 2330 --export: (Default: 2330) X position of shield indicator
    shieldY = 380 --export: (Default: 380) Y position of shield indicator
    DeadZone = 50 --export: (Default: 50) Number of pixels of deadzone at the center of the screen
    OrbitMapSize = 250 --export: (Default: 250) Size of the orbit map, make sure it is divisible by 4
    OrbitMapX = 0 --export: (Default: 0) X postion of Orbit Display 
    OrbitMapY = 25 --export: (Default: 25) Y position of Orbit Display
    soundVolume = 100 --export: (Default: 100) Set to value (0-100 recommended) to control volume of voice and alerts. Alerts will automatically lower other hud sounds 50% if needed.

-- Ship flight physics variables - Change with care, can have large effects on ships performance.
    -- NOTE: savableVariablesPhysics below must contain any Ship flight physics variables that needs to be saved/loaded from databank.
    savableVariablesPhysics = {"speedChangeLarge", "speedChangeSmall", "MouseXSensitivity", "MouseYSensitivity", "autoRollFactor",
    "rollSpeedFactor", "autoRollRollThreshold", "minRollVelocity", "TrajectoryAlignmentStrength",
    "torqueFactor", "pitchSpeedFactor", "yawSpeedFactor", "brakeSpeedFactor", "brakeFlatFactor", "DampingMultiplier", 
    "apTickRate",  "hudTickRate", "ExtraLongitudeTags", "ExtraLateralTags", "ExtraVerticalTags"}

    speedChangeLarge = 5 --export: (Default: 5) The speed change that occurs when you tap speed up/down, default is 5 (25% throttle change).
    speedChangeSmall = 1 --export: (Default: 1) the speed change that occurs while you hold speed up/down, default is 1 (5% throttle change).
    MouseXSensitivity = 0.003 --export: (Default: 0.003) For virtual joystick only
    MouseYSensitivity = 0.003 --export: (Default: 0.003) For virtual joystick only
    autoRollFactor = 2 --export: (Default: 2) [Only in atmosphere] When autoRoll is engaged, this factor will increase to strength of the roll back to 0
    rollSpeedFactor = 1.5 --export: (Default: 1.5) This factor will increase/decrease the player input along the roll axis (higher value may be unstable)
    autoRollRollThreshold = 180 --export: (Default: 180) The amount of roll below which autoRoll to 0 will occur (if autoRollPreference is true)
    minRollVelocity = 150 --export: (Default: 150) Min velocity, in m/s, over which autorolling can occur
    TrajectoryAlignmentStrength = 0.002 --export: (Default: 0.002) How strongly AP tries to align your velocity vector to the target when not in orbit, recommend 0.002
    torqueFactor = 2 --export: (Default: 2) Force factor applied to reach rotationSpeed (higher value may be unstable)
    pitchSpeedFactor = 0.8 --export: (Default: 0.8) For keyboard control, affects rate of pitch change
    yawSpeedFactor = 1 --export: (Default: 1) For keyboard control, affects rate of yaw change
    brakeSpeedFactor = 3 --export: (Default: 3) When braking, this factor will increase the brake force by brakeSpeedFactor * velocity
    brakeFlatFactor = 1 --export: (Default: 1) When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction> (higher value may be unstable)
    DampingMultiplier = 40 --export: (Default: 40) How strongly autopilot dampens when nearing the correct orientation
    apTickRate = 0.0166667 --export: (Default: 0.0166667) Set the Tick Rate for your autopilot features. 0.016667 is effectively 60 fps and the default value. 0.03333333 is 30 fps.
    hudTickRate = 0.0666667 --export: (Default: 0.0666667) Set the tick rate for your HUD. Default is 4 times slower than apTickRate
    ExtraLongitudeTags = "none" --export: (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "forward faster major" These will be added to the engines that are control by longitude.
    ExtraLateralTags = "none" --export: (Default: "none") Enter any extra lateral tags you use inside '' seperated by space, i.e. "left right" These will be added to the engines that are control by lateral.
    ExtraVerticalTags = "none" --export: (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "up down" These will be added to the engines that are control by vertical.

-- Auto Variable declarations that store status of ship on databank. Do not edit directly here unless you know what you are doing, these change as ship flies.
-- NOTE: autoVariables below must contain any variable that needs to be saved/loaded from databank.
    autoVariables = {"VertTakeOff", "VertTakeOffEngine","SpaceTarget","BrakeToggleStatus", "BrakeIsOn", "RetrogradeIsOn", "ProgradeIsOn",
                "Autopilot", "TurnBurn", "AltitudeHold", "BrakeLanding",
                "Reentry", "AutoTakeoff", "HoldAltitude", "AutopilotAccelerating", "AutopilotBraking",
                "AutopilotCruising", "AutopilotRealigned", "AutopilotEndSpeed", "AutopilotStatus",
                "AutopilotPlanetGravity", "PrevViewLock", "AutopilotTargetName", "AutopilotTargetCoords",
                "AutopilotTargetIndex", "TotalDistanceTravelled",
                "TotalFlightTime", "SavedLocations", "VectorToTarget", "LocationIndex", "LastMaxBrake", 
                "LockPitch", "LastMaxBrakeInAtmo", "AntigravTargetAltitude", "LastStartTime", "iphCondition", "stablized", "UseExtra", "SelectedTab"}
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
