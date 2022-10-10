require 'src.slots'

Nav = Navigator.new(system, core, unit)
local atlas = require("atlas")
--
function p(msg)
    system.print(system.getArkTime()..": "..msg)
end
--]]

-- User variables. Must be global to work with databank system
    useTheseSettings = false --export:  Change this to true to override databank saved settings
    userControlScheme = "virtual joystick" --export: (Default: "virtual joystick") Set to "virtual joystick", "mouse", or "keyboard". This can be set by holding SHIFT and clicking the button in lower left of main Control buttons view.
    soundFolder = "archHUD" --export: (Default: "archHUD") Set to the name of the folder with sound files in it. Must be changed from archHUD to prevent other scripts making your PC play sounds.
    privateFile = "name" --export: (Default "name") Set to the name of the file for private locations to prevent others from getting your private locations. Filename should end in .lua
    -- True/False variables
    -- NOTE: saveableVariablesBoolean below must contain any True/False variables that needs to be saved/loaded from databank.
        freeLookToggle = true --export: (Default: true) Set to false for vanilla DU free look behavior.
        BrakeToggleDefault = true --export: (Default: true) Whether your brake toggle is on/off by default. Can be adjusted in the button menu. False is vanilla DU brakes.
        RemoteFreeze = false --export: (Default: false) Whether or not to freeze your character in place when using a remote controller.
        RemoteHud = false --  (Default: false) Whether you want to see the full normal HUD while in remote mode.
        brightHud = false --export: (Default: false) Enable to prevent hud hiding when in freelook.
        VanillaRockets = false --export: (Default: false) If on, rockets behave like vanilla
        InvertMouse = false --export: (Default: false) If true, then when controlling flight mouse Y axis is inverted (pushing up noses plane down) Does not affect selecting buttons or camera.
        autoRollPreference = false --export: (Default: false) [Only in atmosphere] - When the pilot stops rolling, flight model will try to get back to horizontal (no roll)
        ExternalAGG = false --export: (Default: false) Toggle On if using an external AGG system. If on will prevent this HUD from doing anything with AGG.
        ShouldCheckDamage = false --export: (Default: true) Whether or not damage checks are performed. Disable for performance improvement on very large ships or if using external Damage Report and you do not want the built in info.
        AtmoSpeedAssist = true --export: (Default: true) Whether or not atmospheric speeds should be limited to a maximum of AtmoSpeedLimit (Hud built in speed limiter)
        ForceAlignment = false --export: (Default: false) Whether velocity vector alignment should be forced when in Altitude Hold (needed for ships that drift alignment in altitude hold mode due to poor inertial matrix)
        DisplayDeadZone = true --export: (Default: true) Virtual Joystick Mode: Set this to false to not display deadzone circle while in virtual joystick mode.
        showHud = true --export: (Default: true) False to hide the HUD screen and only use HUD Autopilot features (AP via ALT+# keys)
        hideHudOnToggleWidgets = true --export: (Default: true) Uncheck to keep showing HUD when you toggle on the vanilla widgets via ALT+3. Note, hiding the HUD with Alt+3 gives a lot of FPS back in laggy areas, so leave true normally.
        ShiftShowsRemoteButtons = true --export: (Default: true) Whether or not pressing Shift in remote controller mode shows you the buttons (otherwise no access to them)
        SetWaypointOnExit = false --export: (Default: true) Set to false to not set a waypoint when you exit hud. True helps find your ship in crowded locations when you get out of seat.
        AlwaysVSpd = false --export: (Default: false) Set to true to make vertical speed meter stay on screen when you alt-3 widget mode.
        BarFuelDisplay = true --export: (Default: true) Set to false to use old non-bar fuel display
        voices = true --export: (Default: true) Set to false to disable voice sounds when using sound pack
        alerts = true --export: (Default: true) Set to false to disable alert sounds when using sound pack
        CollisionSystem = true --export: (Default: true) If True, system will provide collision alerts and abort vector to target if conditions met.
        AbandonedRadar = false --export: (Default: false) If true, and CollisionSystem is true, all radar contacts will be checked for abandoned status.
        AutoShieldToggle = true --export: (Default: true) If true, system will toggle Shield off in safe space and on in PvP space automagically.
        PreventPvP = true --export: (Default: true) If true, system will stop you before crossing from safe to pvp space while in autopilot.
        DisplayOdometer = true --export: (Default: true) If false the top odometer bar of information will be hidden.
        ECUHud = false --export: (Default: false) If set to true and HUD is installed on an Emergency Control Unit, when ECU activates due to leaving control unit, it will continue normal hud flight.
        MaintainOrbit = true --export: (Default: true) If true, ship will attempt to maintain orbit if it decays (when not autopiloting to a landing point) till fuel runs out.
        saveableVariablesBoolean = {userControlScheme={set=function (i)userControlScheme=i end,get=function() return userControlScheme end}, soundFolder={set=function (i)soundFolder=i end,get=function() return soundFolder end},  privateFile={set=function (i)privateFile=i end,get=function() return privateFile end},freeLookToggle={set=function (i)freeLookToggle=i end,get=function() return freeLookToggle end}, BrakeToggleDefault={set=function (i)BrakeToggleDefault=i end,get=function() return BrakeToggleDefault end}, RemoteFreeze={set=function (i)RemoteFreeze=i end,get=function() return RemoteFreeze end}, brightHud={set=function (i)brightHud=i end,get=function() return brightHud end}, RemoteHud={set=function (i)RemoteHud=i end,get=function() return RemoteHud end}, VanillaRockets={set=function (i)VanillaRockets=i end,get=function() return VanillaRockets end},
        InvertMouse={set=function (i)InvertMouse=i end,get=function() return InvertMouse end}, autoRollPreference={set=function (i)autoRollPreference=i end,get=function() return autoRollPreference end}, ExternalAGG={set=function (i)ExternalAGG=i end,get=function() return ExternalAGG end}, ShouldCheckDamage={set=function (i)ShouldCheckDamage=i end,get=function() return ShouldCheckDamage end}, 
        AtmoSpeedAssist={set=function (i)AtmoSpeedAssist=i end,get=function() return AtmoSpeedAssist end}, ForceAlignment={set=function (i)ForceAlignment=i end,get=function() return ForceAlignment end}, DisplayDeadZone={set=function (i)DisplayDeadZone=i end,get=function() return DisplayDeadZone end}, showHud={set=function (i)showHud=i end,get=function() return showHud end}, hideHudOnToggleWidgets={set=function (i)hideHudOnToggleWidgets=i end,get=function() return hideHudOnToggleWidgets end}, 
        ShiftShowsRemoteButtons={set=function (i)ShiftShowsRemoteButtons=i end,get=function() return ShiftShowsRemoteButtons end}, SetWaypointOnExit={set=function (i)SetWaypointOnExit=i end,get=function() return SetWaypointOnExit end}, AlwaysVSpd={set=function (i)AlwaysVSpd=i end,get=function() return AlwaysVSpd end}, BarFuelDisplay={set=function (i)BarFuelDisplay=i end,get=function() return BarFuelDisplay end}, 
        voices={set=function (i)voices=i end,get=function() return voices end}, alerts={set=function (i)alerts=i end,get=function() return alerts end}, CollisionSystem={set=function (i)CollisionSystem=i end,get=function() return CollisionSystem end}, AbandonedRadar={set=function (i)AbandonedRadar=i end,get=function() return AbandonedRadar end},AutoShieldToggle={set=function (i)AutoShieldToggle=i end,get=function() return AutoShieldToggle end}, PreventPvP={set=function (i)PreventPvP=i end,get=function() return PreventPvP end}, 
        DisplayOdometer={set=function (i)DisplayOdometer=i end,get=function() return DisplayOdometer end},ECUHud={set=function (i)ECUHud=i end,get=function() return ECUHud end},MaintainOrbit={set=function (i)MaintainOrbit=i end,get=function() return MaintainOrbit end}}

    -- Ship Handling variables
    -- NOTE: savableVariablesHandling below must contain any Ship Handling variables that needs to be saved/loaded from databank system
        YawStallAngle = 35 --export: (Default: 35) Angle at which the ship stalls when yawing, determine by experimentation. Higher allows faster AP Bank turns.
        PitchStallAngle = 35 --export: (Default: 35) Angle at which the ship stalls when pitching, determine by experimentation.
        brakeLandingRate = 30 --export: (Default: 30) Max loss of altitude speed in m/s when doing a brake landing. 30 is safe for almost all ships.  
        MaxPitch = 30 --export: (Default: 30) Maximum allowed pitch during takeoff and altitude changes while in altitude hold. You can set higher or lower depending on your ships capabilities.
        ReEntryPitch = -30 --export: (Default: -30) Maximum downward pitch allowed during freefall portion of re-entry.
        LockPitchTarget = 0 --export: (Default: 0) Target pitch ship tries to hold when LALT-LSHIFT-5 is pressed.
        AutopilotSpaceDistance = 5000 --export: (Default: 5000) Target distance AP will try to stop from a custom waypoint in space.  Good ships can lower this value a lot.
        TargetOrbitRadius = 1.2 --export: (Default: 1.2) How tight you want to orbit the planet at end of autopilot.  The smaller the value the tighter the orbit.  Value is multiple of Atmospheric Height
        LowOrbitHeight = 2000 --export: (Default: 2000) Height of Orbit above top of atmospehre when using Alt-4-4 same planet autopilot or alt-6-6 in space.
        AtmoSpeedLimit = 1175 --export: (Default: 1175) Speed limit in Atmosphere in km/h. AtmoSpeedAssist will cause ship to throttle back when this speed is reached.
        SpaceSpeedLimit = 66000 --export: (Default: 66000) Space speed limit in KM/H. If you hit this speed and are NOT in active autopilot, engines will turn off to prevent using all fuel (66000 means they wont turn off)
        AutoTakeoffAltitude = 1000 --export: (Default: 1000) How high above your ground height AutoTakeoff tries to put you
        TargetHoverHeight = 50 --export: (Default: 50) Hover height above ground when G used to lift off, 50 is above all max hover heights.
        LandingGearGroundHeight = 0 --export: (Default: 0) Set to AGL when on ground. Will help prevent ship landing on ground then bouncing back up to landing gear height. 
        ReEntryHeight = 100000 --export: (Default: 100000) Height above a planets maximum surface altitude used for re-entry, if height exceeds min space engine height, then 11% atmo is used instead. (100000 means 11% is used)
        MaxGameVelocity = -1.00 --export: (Default: -1.00) Max speed for your autopilot in m/s.  If -1 then when you sit down it will set to actualy max speed.
        AutopilotInterplanetaryThrottle = 1.0 --export: (Default: 1.0) How much throttle, 0.0 to 1.0, you want it to use when in autopilot to another planet while reaching MaxGameVelocity
        warmup = 32 --export: (Default: 32) How long it takes your space engines to warmup. Basic Space Engines, from XS to XL: 0.25,1,4,16,32. Only affects turn and burn brake calculations.
        fuelTankHandlingAtmo = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
        fuelTankHandlingSpace = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
        fuelTankHandlingRocket = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank handling level of the person who placed the tank. Ignored for slotted tanks.
        ContainerOptimization = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the Container Optimization level of the person who placed the tanks. Ignored for slotted tanks.
        FuelTankOptimization = 0 --export: (Default: 0) For accurate estimates on unslotted tanks, set this to the fuel tank optimization skill level of the person who placed the tank. Ignored for slotted tanks.
        AutoShieldPercent = 0 --export: (Default: 0) Automatically adjusts shield resists once per minute if shield percent is less than this value.
        EmergencyWarp = 0 --export: (Default: 0) If > 0 and a radar contact is detected in pvp space and the contact is closer than EmergencyWarp value, and all other warp conditions met, will initiate warp.
        DockingMode = 2 --export: (Default: 2) Docking mode of ship, default is 2 (Automatic), options are Manual = 1, Automatic = 2, Semi-automatic = 3
        savableVariablesHandling = {YawStallAngle={set=function (i)YawStallAngle=i end,get=function() return YawStallAngle end},PitchStallAngle={set=function (i)PitchStallAngle=i end,get=function() return PitchStallAngle end},brakeLandingRate={set=function (i)brakeLandingRate=i end,get=function() return brakeLandingRate end},MaxPitch={set=function (i)MaxPitch=i end,get=function() return MaxPitch end}, ReEntryPitch={set=function (i)ReEntryPitch=i end,get=function() return ReEntryPitch end},LockPitchTarget={set=function (i)LockPitchTarget=i end,get=function() return LockPitchTarget end}, AutopilotSpaceDistance={set=function (i)AutopilotSpaceDistance=i end,get=function() return AutopilotSpaceDistance end}, TargetOrbitRadius={set=function (i)TargetOrbitRadius=i end,get=function() return TargetOrbitRadius end}, LowOrbitHeight={set=function (i)LowOrbitHeight=i end,get=function() return LowOrbitHeight end},
        AtmoSpeedLimit={set=function (i)AtmoSpeedLimit=i end,get=function() return AtmoSpeedLimit end},SpaceSpeedLimit={set=function (i)SpaceSpeedLimit=i end,get=function() return SpaceSpeedLimit end},AutoTakeoffAltitude={set=function (i)AutoTakeoffAltitude=i end,get=function() return AutoTakeoffAltitude end},TargetHoverHeight={set=function (i)TargetHoverHeight=i end,get=function() return TargetHoverHeight end}, LandingGearGroundHeight={set=function (i)LandingGearGroundHeight=i end,get=function() return LandingGearGroundHeight end}, ReEntryHeight={set=function (i)ReEntryHeight=i end,get=function() return ReEntryHeight end},
        MaxGameVelocity={set=function (i)MaxGameVelocity=i end,get=function() return MaxGameVelocity end}, AutopilotInterplanetaryThrottle={set=function (i)AutopilotInterplanetaryThrottle=i end,get=function() return AutopilotInterplanetaryThrottle end},warmup={set=function (i)warmup=i end,get=function() return warmup end},fuelTankHandlingAtmo={set=function (i)fuelTankHandlingAtmo=i end,get=function() return fuelTankHandlingAtmo end},fuelTankHandlingSpace={set=function (i)fuelTankHandlingSpace=i end,get=function() return fuelTankHandlingSpace end},
        fuelTankHandlingRocket={set=function (i)fuelTankHandlingRocket=i end,get=function() return fuelTankHandlingRocket end},ContainerOptimization={set=function (i)ContainerOptimization=i end,get=function() return ContainerOptimization end},FuelTankOptimization={set=function (i)FuelTankOptimization=i end,get=function() return FuelTankOptimization end},AutoShieldPercent={set=function (i)AutoShieldPercent=i end,get=function() return AutoShieldPercent end},
        EmergencyWarp={set=function (i)EmergencyWarp=i end,get=function() return EmergencyWarp end}, DockingMode={set=function (i)DockingMode=i end,get=function() return DockingMode end}}

    -- HUD Postioning variables
    -- NOTE: savableVariablesHud below must contain any HUD Postioning variables that needs to be saved/loaded from databank system
        ResolutionX = 1920 --export: (Default: 1920) Does not need to be set to same as game resolution. You can set 1920 on a 2560 to get larger resolution
        ResolutionY = 1080 --export: (Default: 1080) Does not need to be set to same as game resolution. You can set 1080 on a 1440 to get larger resolution
        circleRad = 400 --export: (Default: 400) The size of the artifical horizon circle, recommended minimum 100, maximum 400. Looks different > 200. Set to 0 to remove.
        SafeR = 130 --export: (Default: 130) Primary HUD color
        SafeG = 224 --export: (Default: 224) Primary HUD color
        SafeB = 255 --export: (Default: 255) Primary HUD color
        PvPR = 255 --export: (Default: 255) PvP HUD color
        PvPG = 0 --export: (Default: 0) PvP HUD color
        PvPB = 0 --export: (Default: 0) PvP HUD color
        centerX = 960 --export: (Default: 960) X postion of Artifical Horizon (KSP Navball), Default 960. Use centerX=700 and centerY=880 for lower left placement.
        centerY = 540 --export: (Default: 540) Y postion of Artifical Horizon (KSP Navball), Default 540. Use centerX=700 and centerY=880 for lower left placement.
        throtPosX = 1300 --export: (Default: 1300) X position of Throttle Indicator, default 1300 to put it to right of default AH centerX parameter.
        throtPosY = 540 --export: (Default: 540) Y position of Throttle indicator, default is 540 to place it centered on default AH centerY parameter
        vSpdMeterX = 1525  --export: (Default: 1525) X postion of Vertical Speed Meter. Default 1525
        vSpdMeterY = 325 --export: (Default: 325) Y postion of Vertical Speed Meter. Default 325
        altMeterX = 550  --export: (Default: 550) X postion of Altimeter. Default 550
        altMeterY = 540 --export: (Default: 540) Y postion of Altimeter. Default 500
        fuelX = 30 --export: (Default: 30) X position of fuel tanks, set to 100 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
        fuelY = 700 --export: (Default: 700) Y position of fuel tanks, set to 300 for non-bar style fuel display, set both fuelX and fuelY to 0 to hide fuel display
        shieldX = 1750 --export: (Default: 1750) X position of shield indicator
        shieldY = 250 --export: (Default: 250) Y position of shield indicator
        radarX = 1750 --export: (Default 1750) X position of radar info
        radarY = 350 --export: (Default: 350) Y position of radar info
        DeadZone = 50 --export: (Default: 50) Number of pixels of deadzone at the center of the screen
        OrbitMapSize = 250 --export: (Default: 250) Size of the orbit map, make sure it is divisible by 4
        OrbitMapX = 0 --export: (Default: 0) X postion of Orbit Display 
        OrbitMapY = 30 --export: (Default: 30) Y position of Orbit Display

        savableVariablesHud = {ResolutionX={set=function (i)ResolutionX=i end,get=function() return ResolutionX end},ResolutionY={set=function (i)ResolutionY=i end,get=function() return ResolutionY end},circleRad={set=function (i)circleRad=i end,get=function() return circleRad end},SafeR={set=function (i)SafeR=i end,get=function() return SafeR end}, SafeG={set=function (i)SafeG=i end,get=function() return SafeG end}, SafeB={set=function (i)SafeB=i end,get=function() return SafeB end}, 
        PvPR={set=function (i)PvPR=i end,get=function() return PvPR end}, PvPG={set=function (i)PvPG=i end,get=function() return PvPG end}, PvPB={set=function (i)PvPB=i end,get=function() return PvPB end},centerX={set=function (i)centerX=i end,get=function() return centerX end}, centerY={set=function (i)centerY=i end,get=function() return centerY end}, throtPosX={set=function (i)throtPosX=i end,get=function() return throtPosX end}, throtPosY={set=function (i)throtPosY=i end,get=function() return throtPosY end},
        vSpdMeterX={set=function (i)vSpdMeterX=i end,get=function() return vSpdMeterX end}, vSpdMeterY={set=function (i)vSpdMeterY=i end,get=function() return vSpdMeterY end},altMeterX={set=function (i)altMeterX=i end,get=function() return altMeterX end}, altMeterY={set=function (i)altMeterY=i end,get=function() return altMeterY end},fuelX={set=function (i)fuelX=i end,get=function() return fuelX end}, fuelY={set=function (i)fuelY=i end,get=function() return fuelY end},
        shieldX={set=function (i)shieldX=i end,get=function() return shieldX end}, shieldY={set=function (i)shieldY=i end,get=function() return shieldY end}, radarX={set=function (i)radarX=i end,get=function() return radarX end}, radarY={set=function (i)radarY=i end,get=function() return radarY end},DeadZone={set=function (i)DeadZone=i end,get=function() return DeadZone end},
        OrbitMapSize={set=function (i)OrbitMapSize=i end,get=function() return OrbitMapSize end}, OrbitMapX={set=function (i)OrbitMapX=i end,get=function() return OrbitMapX end}, OrbitMapY={set=function (i)OrbitMapY=i end,get=function() return OrbitMapY end}}

    -- Ship flight physics variables - Change with care, can have large effects on ships performance.
        -- NOTE: savableVariablesPhysics below must contain any Ship flight physics variables that needs to be saved/loaded from databank system
            speedChangeLarge = 5.0 --export: (Default: 5) The speed change that occurs when you tap speed up/down or mousewheel, default is 5%
            speedChangeSmall = 1.0 --export: (Default: 1) the speed change that occurs while you hold speed up/down, default is 1%
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
            hudTickRate = 0.0666667 --export: (Default: 0.0666667) Set the tick rate for your HUD. 
            ExtraEscapeThrust = 1.0 --export: (Default: 1.0) Set this to 1 to use friction burn speed as your max speed when escaping atmosphere. Setting other than 1 will be a the value multiplied by your friction burn speed.
            ExtraLongitudeTags = "none" --export: (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "forward faster major" These will be added to the engines that are control by longitude.
            ExtraLateralTags = "none" --export: (Default: "none") Enter any extra lateral tags you use inside '' seperated by space, i.e. "left right" These will be added to the engines that are control by lateral.
            ExtraVerticalTags = "none" --export: (Default: "none") Enter any extra longitudinal tags you use inside '' seperated by space, i.e. "up down" These will be added to the engines that are control by vertical.
            savableVariablesPhysics = {speedChangeLarge={set=function (i)speedChangeLarge=i end,get=function() return speedChangeLarge end}, speedChangeSmall={set=function (i)speedChangeSmall=i end,get=function() return speedChangeSmall end}, MouseXSensitivity={set=function (i)MouseXSensitivity=i end,get=function() return MouseXSensitivity end}, MouseYSensitivity={set=function (i)MouseYSensitivity=i end,get=function() return MouseYSensitivity end}, autoRollFactor={set=function (i)autoRollFactor=i end,get=function() return autoRollFactor end},
            rollSpeedFactor={set=function (i)rollSpeedFactor=i end,get=function() return rollSpeedFactor end}, autoRollRollThreshold={set=function (i)autoRollRollThreshold=i end,get=function() return autoRollRollThreshold end}, minRollVelocity={set=function (i)minRollVelocity=i end,get=function() return minRollVelocity end}, TrajectoryAlignmentStrength={set=function (i)TrajectoryAlignmentStrength=i end,get=function() return TrajectoryAlignmentStrength end},
            torqueFactor={set=function (i)torqueFactor=i end,get=function() return torqueFactor end}, pitchSpeedFactor={set=function (i)pitchSpeedFactor=i end,get=function() return pitchSpeedFactor end}, yawSpeedFactor={set=function (i)yawSpeedFactor=i end,get=function() return yawSpeedFactor end}, brakeSpeedFactor={set=function (i)brakeSpeedFactor=i end,get=function() return brakeSpeedFactor end}, brakeFlatFactor={set=function (i)brakeFlatFactor=i end,get=function() return brakeFlatFactor end}, DampingMultiplier={set=function (i)DampingMultiplier=i end,get=function() return DampingMultiplier end}, 
            hudTickRate={set=function (i)hudTickRate=i end,get=function() return hudTickRate end}, ExtraEscapeThrust={set=function (i)ExtraEscapeThrust=i end,get=function() return ExtraEscapeThrust end}, 
            ExtraLongitudeTags={set=function (i)ExtraLongitudeTags=i end,get=function() return ExtraLongitudeTags end}, ExtraLateralTags={set=function (i)ExtraLateralTags=i end,get=function() return ExtraLateralTags end}, ExtraVerticalTags={set=function (i)ExtraVerticalTags=i end,get=function() return ExtraVerticalTags end}}

local requireTable = {"autoconf/custom/archhud/globals","autoconf/custom/archhud/hudclass", "autoconf/custom/archhud/apclass", "autoconf/custom/archhud/controlclass",
                      "autoconf/custom/archhud/atlasclass", "autoconf/custom/archhud/baseclass", "autoconf/custom/archhud/shieldclass",
                      "autoconf/custom/archhud/radarclass", "autoconf/custom/archhud/axiscommandoverride", "autoconf/custom/archhud/userclass"}

for k,v in ipairs(requireTable) do
    pcall(require,requireTable[k])
end

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 2.005


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