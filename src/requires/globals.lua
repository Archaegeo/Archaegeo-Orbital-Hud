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
        CalculateBrakeLandingSpeed = false -- (Default: false) Whether BrakeLanding speed at non-waypoints should be calculated (faster) or use the brakeLandingRate user setting (safer).  Set to true for faster, not as safe, brake landing
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
        AutoShieldToggle = true -- (Default: true) If true, system will toggle Shield off in safe space and on in PvP space automagically.
        PreventPvP = true -- (Default: true) If true, system will stop you before crossing from safe to pvp space while in autopilot.
        DisplayOdometer = true -- (Default: true) If false the top odometer bar of information will be hidden.

        saveableVariablesBoolean = {userControlScheme={set=function (i)userControlScheme=i end,get=function() return userControlScheme end}, soundFolder={set=function (i)soundFolder=i end,get=function() return soundFolder end}, freeLookToggle={set=function (i)freeLookToggle=i end,get=function() return freeLookToggle end}, BrakeToggleDefault={set=function (i)BrakeToggleDefault=i end,get=function() return BrakeToggleDefault end}, RemoteFreeze={set=function (i)RemoteFreeze=i end,get=function() return RemoteFreeze end}, brightHud={set=function (i)brightHud=i end,get=function() return brightHud end}, RemoteHud={set=function (i)RemoteHud=i end,get=function() return RemoteHud end}, VanillaRockets={set=function (i)VanillaRockets=i end,get=function() return VanillaRockets end},
        InvertMouse={set=function (i)InvertMouse=i end,get=function() return InvertMouse end}, autoRollPreference={set=function (i)autoRollPreference=i end,get=function() return autoRollPreference end}, ExternalAGG={set=function (i)ExternalAGG=i end,get=function() return ExternalAGG end}, UseSatNav={set=function (i)UseSatNav=i end,get=function() return UseSatNav end}, ShouldCheckDamage={set=function (i)ShouldCheckDamage=i end,get=function() return ShouldCheckDamage end}, 
        CalculateBrakeLandingSpeed={set=function (i)CalculateBrakeLandingSpeed=i end,get=function() return CalculateBrakeLandingSpeed end}, AtmoSpeedAssist={set=function (i)AtmoSpeedAssist=i end,get=function() return AtmoSpeedAssist end}, ForceAlignment={set=function (i)ForceAlignment=i end,get=function() return ForceAlignment end}, DisplayDeadZone={set=function (i)DisplayDeadZone=i end,get=function() return DisplayDeadZone end}, showHud={set=function (i)showHud=i end,get=function() return showHud end}, hideHudOnToggleWidgets={set=function (i)hideHudOnToggleWidgets=i end,get=function() return hideHudOnToggleWidgets end}, 
        ShiftShowsRemoteButtons={set=function (i)ShiftShowsRemoteButtons=i end,get=function() return ShiftShowsRemoteButtons end}, SetWaypointOnExit={set=function (i)SetWaypointOnExit=i end,get=function() return SetWaypointOnExit end}, AlwaysVSpd={set=function (i)AlwaysVSpd=i end,get=function() return AlwaysVSpd end}, BarFuelDisplay={set=function (i)BarFuelDisplay=i end,get=function() return BarFuelDisplay end}, 
        voices={set=function (i)voices=i end,get=function() return voices end}, alerts={set=function (i)alerts=i end,get=function() return alerts end}, CollisionSystem={set=function (i)CollisionSystem=i end,get=function() return CollisionSystem end}, AutoShieldToggle={set=function (i)AutoShieldToggle=i end,get=function() return AutoShieldToggle end}, PreventPvP={set=function (i)PreventPvP=i end,get=function() return PreventPvP end}, DisplayOdometer={set=function (i)DisplayOdometer=i end,get=function() return DisplayOdometer end}}

    -- Ship Handling variables
        -- NOTE: savableVariablesHandling below must contain any Ship Handling variables that needs to be saved/loaded from databank system

        YawStallAngle = 35 -- (Default: 35) Angle at which the ship stalls when yawing, determine by experimentation. Higher allows faster AP Bank turns.
        PitchStallAngle = 35 -- (Default: 35) Angle at which the ship stalls when pitching, determine by experimentation.
        brakeLandingRate = 30 -- (Default: 30) Max loss of altitude speed in m/s when doing a brake landing. 30 is safe for almost all ships.  Overriden if CalculateBrakeLandingSpeed is true.
        MaxPitch = 30 -- (Default: 30) Maximum allowed pitch during takeoff and altitude changes while in altitude hold. You can set higher or lower depending on your ships capabilities.
        ReEntryPitch = -30 -- (Default: -30) Maximum downward pitch allowed during freefall portion of re-entry.
        LockPitchTarget = 0 -- (Default: 0) Target pitch ship tries to hold when LALT-LSHIFT-5 is pressed.
        AutopilotSpaceDistance = 5000 -- (Default: 5000) Target distance AP will try to stop from a custom waypoint in space.  Good ships can lower this value a lot.
        TargetOrbitRadius = 1.2 -- (Default: 1.2) How tight you want to orbit the planet at end of autopilot.  The smaller the value the tighter the orbit.  Value is multiple of Atmospheric Height
        LowOrbitHeight = 2000 -- (Default: 2000) Height of Orbit above top of atmospehre when using Alt-4-4 same planet autopilot or alt-6-6 in space.
        AtmoSpeedLimit = 1050 -- (Default: 1050) Speed limit in Atmosphere in km/h. AtmoSpeedAssist will cause ship to throttle back when this speed is reached.
        SpaceSpeedLimit = 30000 -- (Default: 30000) Space speed limit in KM/H. If you hit this speed and are NOT in active autopilot, engines will turn off to prevent using all fuel (30000 means they wont turn off)
        AutoTakeoffAltitude = 1000 -- (Default: 1000) How high above your ground height AutoTakeoff tries to put you
        TargetHoverHeight = 50 -- (Default: 50) Hover height above ground when G used to lift off, 50 is above all max hover heights.
        LandingGearGroundHeight = 0 -- (Default: 0) Set to AGL-1 when on ground (or 0). Will help prevent ship landing on ground then bouncing back up to landing gear height. If too high, engines will not turn off
        ReEntryHeight = 100000 -- (Default: 100000) Height above a planets maximum surface altitude used for re-entry, if height exceeds min space engine height, then 11% atmo is used instead. (100000 means 11% is used)
        MaxGameVelocity = 8333.00 -- (Default: 8333.00) Max speed for your autopilot in m/s, do not go above 8333.055 (30000 km/hr), can be reduced to save fuel. Some ships will not turn off engines if 8333.055 is used.
        AutopilotInterplanetaryThrottle = 1.0 -- (Default: 1.0) How much throttle, 0.0 to 1.0, you want it to use when in autopilot to another planet while reaching MaxGameVelocity
        warmup = 32 -- How long it takes your space engines to warmup. Basic Space Engines, from XS to XL: 0.25,1,4,16,32. Only affects turn and burn brake calculations.
        fuelTankHandlingAtmo = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
        fuelTankHandlingSpace = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
        fuelTankHandlingRocket = 0 --  (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
        ContainerOptimization = 0 -- (Default: 0) For accurate estimates on unslotted tanks, set this to the Container Optimization level of the person who placed the tanks. Ignored for slotted tanks.
        FuelTankOptimization = 0 -- (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank optimization skill level of the person who placed the tank. Ignored for slotted tanks.
        AutoShieldPercent = 0 -- (Default: 0) Automatically adjusts shield resists once per minute if shield percent is less than this value.
        savableVariablesHandling = {YawStallAngle={set=function (i)YawStallAngle=i end,get=function() return YawStallAngle end},PitchStallAngle={set=function (i)PitchStallAngle=i end,get=function() return PitchStallAngle end},brakeLandingRate={set=function (i)brakeLandingRate=i end,get=function() return brakeLandingRate end},MaxPitch={set=function (i)MaxPitch=i end,get=function() return MaxPitch end}, ReEntryPitch={set=function (i)ReEntryPitch=i end,get=function() return ReEntryPitch end},LockPitchTarget={set=function (i)LockPitchTarget=i end,get=function() return LockPitchTarget end}, AutopilotSpaceDistance={set=function (i)AutopilotSpaceDistance=i end,get=function() return AutopilotSpaceDistance end}, TargetOrbitRadius={set=function (i)TargetOrbitRadius=i end,get=function() return TargetOrbitRadius end}, LowOrbitHeight={set=function (i)LowOrbitHeight=i end,get=function() return LowOrbitHeight end},
        AtmoSpeedLimit={set=function (i)AtmoSpeedLimit=i end,get=function() return AtmoSpeedLimit end},SpaceSpeedLimit={set=function (i)SpaceSpeedLimit=i end,get=function() return SpaceSpeedLimit end},AutoTakeoffAltitude={set=function (i)AutoTakeoffAltitude=i end,get=function() return AutoTakeoffAltitude end},TargetHoverHeight={set=function (i)TargetHoverHeight=i end,get=function() return TargetHoverHeight end}, LandingGearGroundHeight={set=function (i)LandingGearGroundHeight=i end,get=function() return LandingGearGroundHeight end}, ReEntryHeight={set=function (i)ReEntryHeight=i end,get=function() return ReEntryHeight end},
        MaxGameVelocity={set=function (i)MaxGameVelocity=i end,get=function() return MaxGameVelocity end}, AutopilotInterplanetaryThrottle={set=function (i)AutopilotInterplanetaryThrottle=i end,get=function() return AutopilotInterplanetaryThrottle end},warmup={set=function (i)warmup=i end,get=function() return warmup end},fuelTankHandlingAtmo={set=function (i)fuelTankHandlingAtmo=i end,get=function() return fuelTankHandlingAtmo end},fuelTankHandlingSpace={set=function (i)fuelTankHandlingSpace=i end,get=function() return fuelTankHandlingSpace end},
        fuelTankHandlingRocket={set=function (i)fuelTankHandlingRocket=i end,get=function() return fuelTankHandlingRocket end},ContainerOptimization={set=function (i)ContainerOptimization=i end,get=function() return ContainerOptimization end},FuelTankOptimization={set=function (i)FuelTankOptimization=i end,get=function() return FuelTankOptimization end},AutoShieldPercent={set=function (i)AutoShieldPercent=i end,get=function() return AutoShieldPercent end}}


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
        DeadZone = 50 -- (Default: 50) Number of pixels of deadzone at the center of the screen
        OrbitMapSize = 250 -- (Default: 250) Size of the orbit map, make sure it is divisible by 4
        OrbitMapX = 0 -- (Default: 0) X postion of Orbit Display 
        OrbitMapY = 30 -- (Default: 30) Y position of Orbit Display
        soundVolume = 100 -- (Default: 100) Set to value (0-100 recommended) to control volume of voice and alerts. Alerts will automatically lower other hud sounds 50% if needed.

        savableVariablesHud = {ResolutionX={set=function (i)ResolutionX=i end,get=function() return ResolutionX end},ResolutionY={set=function (i)ResolutionY=i end,get=function() return ResolutionY end},circleRad={set=function (i)circleRad=i end,get=function() return circleRad end},SafeR={set=function (i)SafeR=i end,get=function() return SafeR end}, SafeG={set=function (i)SafeG=i end,get=function() return SafeG end}, SafeB={set=function (i)SafeB=i end,get=function() return SafeB end}, 
        PvPR={set=function (i)PvPR=i end,get=function() return PvPR end}, PvPG={set=function (i)PvPG=i end,get=function() return PvPG end}, PvPB={set=function (i)PvPB=i end,get=function() return PvPB end},centerX={set=function (i)centerX=i end,get=function() return centerX end}, centerY={set=function (i)centerY=i end,get=function() return centerY end}, throtPosX={set=function (i)throtPosX=i end,get=function() return throtPosX end}, throtPosY={set=function (i)throtPosY=i end,get=function() return throtPosY end},
        vSpdMeterX={set=function (i)vSpdMeterX=i end,get=function() return vSpdMeterX end}, vSpdMeterY={set=function (i)vSpdMeterY=i end,get=function() return vSpdMeterY end},altMeterX={set=function (i)altMeterX=i end,get=function() return altMeterX end}, altMeterY={set=function (i)altMeterY=i end,get=function() return altMeterY end},fuelX={set=function (i)fuelX=i end,get=function() return fuelX end}, fuelY={set=function (i)fuelY=i end,get=function() return fuelY end}, shieldX={set=function (i)shieldX=i end,get=function() return shieldX end}, shieldY={set=function (i)shieldY=i end,get=function() return shieldY end}, DeadZone={set=function (i)DeadZone=i end,get=function() return DeadZone end},
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
        apTickRate = 0.0166667 -- (Default: 0.0166667) Set the Tick Rate for your autopilot features. 0.016667 is effectively 60 fps and the default value. 0.03333333 is 30 fps.
        hudTickRate = 0.0666667 -- (Default: 0.0666667) Set the tick rate for your HUD. Default is 4 times slower than apTickRate
        ExtraEscapeThrust = 0.0 -- (Default: 0.0) Set this to some value (start low till you know your ship) to apply extra thrust between 10% and 0.05% atmosphere while using AtmoSpeedLimit.
        ExtraLongitudeTags = "none" -- (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "forward faster major" These will be added to the engines that are control by longitude.
        ExtraLateralTags = "none" -- (Default: "none") Enter any extra lateral tags you use inside '' seperated by space, i.e. "left right" These will be added to the engines that are control by lateral.
        ExtraVerticalTags = "none" -- (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "up down" These will be added to the engines that are control by vertical.
        savableVariablesPhysics = {speedChangeLarge={set=function (i)speedChangeLarge=i end,get=function() return speedChangeLarge end}, speedChangeSmall={set=function (i)speedChangeSmall=i end,get=function() return speedChangeSmall end}, MouseXSensitivity={set=function (i)MouseXSensitivity=i end,get=function() return MouseXSensitivity end}, MouseYSensitivity={set=function (i)MouseYSensitivity=i end,get=function() return MouseYSensitivity end}, autoRollFactor={set=function (i)autoRollFactor=i end,get=function() return autoRollFactor end},
        rollSpeedFactor={set=function (i)rollSpeedFactor=i end,get=function() return rollSpeedFactor end}, autoRollRollThreshold={set=function (i)autoRollRollThreshold=i end,get=function() return autoRollRollThreshold end}, minRollVelocity={set=function (i)minRollVelocity=i end,get=function() return minRollVelocity end}, TrajectoryAlignmentStrength={set=function (i)TrajectoryAlignmentStrength=i end,get=function() return TrajectoryAlignmentStrength end},
        torqueFactor={set=function (i)torqueFactor=i end,get=function() return torqueFactor end}, pitchSpeedFactor={set=function (i)pitchSpeedFactor=i end,get=function() return pitchSpeedFactor end}, yawSpeedFactor={set=function (i)yawSpeedFactor=i end,get=function() return yawSpeedFactor end}, brakeSpeedFactor={set=function (i)brakeSpeedFactor=i end,get=function() return brakeSpeedFactor end}, brakeFlatFactor={set=function (i)brakeFlatFactor=i end,get=function() return brakeFlatFactor end}, DampingMultiplier={set=function (i)DampingMultiplier=i end,get=function() return DampingMultiplier end}, 
        apTickRate={set=function (i)apTickRate=i end,get=function() return apTickRate end},  hudTickRate={set=function (i)hudTickRate=i end,get=function() return hudTickRate end}, ExtraEscapeThrust={set=function (i)ExtraEscapeThrust=i end,get=function() return ExtraEscapeThrust end}, 
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

-- Unsaved Globals
local function globalDeclare(s, c, u, systime, mfloor, atmosphere) -- # is how many classes variable is in
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
    coreMass = c.getConstructMass() -- 2
    gyroIsOn = nil -- 4
    resolutionWidth = ResolutionX -- 3
    resolutionHeight = ResolutionY -- 3
    atmoTanks = {} -- 2
    spaceTanks = {} -- 2
    rocketTanks = {} -- 2
    galaxyReference = nil -- 4
    Kinematic = nil -- 4
    maxKinematicUp = nil -- 2
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
    constructForward = vec3(c.getConstructWorldOrientationForward()) -- 2
    constructRight = vec3(c.getConstructWorldOrientationRight()) -- 3
    coreVelocity = vec3(c.getVelocity()) -- 3
    constructVelocity = vec3(c.getWorldVelocity()) -- 4
    velMag = vec3(constructVelocity):len() -- 3
    worldVertical = vec3(c.getWorldVertical()) -- 3
    vSpd = -worldVertical:dot(constructVelocity) -- 2
    worldPos = vec3(c.getConstructWorldPos()) -- 5
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
    alignHeading=nil -- 2
    if shield_1 then shieldPercent = mfloor(0.5 + shield_1.getShieldHitpoints() * 100 / shield_1.getMaxShieldHitpoints()) end
end

return globalDeclare