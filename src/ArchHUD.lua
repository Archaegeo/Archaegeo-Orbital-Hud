require 'src.slots'

local Nav = Navigator.new(system, core, unit)

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 1.411

-- User variables, visable via Edit Lua Parameters. Must be global to work with databank system as set up due to using _G assignment
    useTheseSettings = false --export:
    userControlScheme = "virtual joystick" --export:
    soundFolder = "archHUD" --export:
    
    -- True/False variables
    freeLookToggle = true --export:
    BrakeToggleDefault = true --export:
    RemoteFreeze = false --export:
    RemoteHud = true --export:
    brightHud = false --export:
    VanillaRockets = false --export:
    InvertMouse = false --export:
    autoRollPreference = false --export:
    ExternalAGG = false --export:
    UseSatNav = false --export:
    ShouldCheckDamage = true --export:
    CalculateBrakeLandingSpeed = false --export:
    AtmoSpeedAssist = true --export:
    ForceAlignment = false --export:
    DisplayDeadZone = true --export:
    showHud = true --export: 
    ShowOdometer = true --export:
    hideHudOnToggleWidgets = true --export:
    ShiftShowsRemoteButtons = true --export:
    DisplayOrbit = true --export: 
    SetWaypointOnExit = false --export:
    AlwaysVSpd = false --export:
    BarFuelDisplay = true --export:
    showHelp = true --export:
    Cockpit = false --export:
    voices = true --export:
    alerts = true --export:
    CollisionSystem = true --export:
    
    -- Ship Handling variables
    YawStallAngle = 35 --export:
    PitchStallAngle = 35 --export:
    brakeLandingRate = 30 --export:
    MaxPitch = 30 --export:
    ReEntryPitch = -30 --export:
    LockPitchTarget = 0 --export:
    TargetOrbitRadius = 1.4 --export:
    LowOrbitHeight = 1000 --export:
    AtmoSpeedLimit = 1050 --export:
    SpaceSpeedLimit = 30000 --export:
    AutoTakeoffAltitude = 1000 --export:
    TargetHoverHeight = 50 --export:
    LandingGearGroundHeight = 0 --export:
    ReEntryHeight = 100000 -- export:
    MaxGameVelocity = 8333.00 --export:
    AutopilotInterplanetaryThrottle = 1.0 --export:
    warmup = 32 --export:
    fuelTankHandlingAtmo = 0 --export:
    fuelTankHandlingSpace = 0 --export:
    fuelTankHandlingRocket = 0 --export:
    ContainerOptimization = 0 --export:
    FuelTankOptimization = 0 --export:

    -- HUD Postioning variables
    ResolutionX = 1920 --export:
    ResolutionY = 1080 --export:
    circleRad = 400 --export:
    SafeR = 130 --export:
    SafeG = 224 --export:
    SafeB = 255 --export:
    PvPR = 255 --export:
    PvPG = 0 --export:
    PvPB = 0 --export:
    centerX = 960 --export:
    centerY = 540 --export:
    throtPosX = 1300 --export:
    throtPosY = 540 --export:
    vSpdMeterX = 1525  --export:
    vSpdMeterY = 325 --export:
    altMeterX = 550  --export:
    altMeterY = 540 --export:
    fuelX = 30 --export:
    fuelY = 700 --export:
    shieldX = 1750 --export:
    shieldY = 250 --export:
    DeadZone = 50 --export:
    OrbitMapSize = 250 --export:
    OrbitMapX = 75 --export:
    OrbitMapY = 0 --export:
    soundVolume = 100 --export:

    --Ship flight physics variables 
    speedChangeLarge = 5 --export:
    speedChangeSmall = 1 --export:
    MouseXSensitivity = 0.003 --export:
    MouseYSensitivity = 0.003 --export:
    autoRollFactor = 2 --export:
    rollSpeedFactor = 1.5 --export:
    autoRollRollThreshold = 180 --export:
    minRollVelocity = 150 --export:
    TrajectoryAlignmentStrength = 0.002 --export:
    torqueFactor = 2 --export:
    pitchSpeedFactor = 0.8 --export:
    yawSpeedFactor = 1 --export:
    brakeSpeedFactor = 3 --export:
    brakeFlatFactor = 1 --export:
    DampingMultiplier = 40 --export:
    apTickRate = 0.0166667 --export:
    hudTickRate = 0.0666667 --export:
    ExtraLongitudeTags = "none" --export:
    ExtraLateralTags = "none" --export:
    ExtraVerticalTags = "none" --export:

-- Auto Variable declarations that store status of ship. Must be global because they get saved/read to Databank due to using _G assignment
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

    -- autoVariables table of above variables to be stored on databank to save ships status but are not user settable
        local autoVariables = {"VertTakeOff", "VertTakeOffEngine","SpaceTarget","BrakeToggleStatus", "BrakeIsOn", "RetrogradeIsOn", "ProgradeIsOn",
                    "Autopilot", "TurnBurn", "AltitudeHold", "BrakeLanding",
                    "Reentry", "AutoTakeoff", "HoldAltitude", "AutopilotAccelerating", "AutopilotBraking",
                    "AutopilotCruising", "AutopilotRealigned", "AutopilotEndSpeed", "AutopilotStatus",
                    "AutopilotPlanetGravity", "PrevViewLock", "AutopilotTargetName", "AutopilotTargetCoords",
                    "AutopilotTargetIndex", "TotalDistanceTravelled",
                    "TotalFlightTime", "SavedLocations", "VectorToTarget", "LocationIndex", "LastMaxBrake", 
                    "LockPitch", "LastMaxBrakeInAtmo", "AntigravTargetAltitude", "LastStartTime", "iphCondition", "stablized", "UseExtra"}

-- function localizations for improved performance when used frequently or in loops.
    local mabs = math.abs
    local mfloor = math.floor
    local stringf = string.format
    local jdecode = json.decode
    local jencode = json.encode
    local eleMaxHp = core.getElementMaxHitPointsById
    local atmosphere = unit.getAtmosphereDensity
    local eleMass = core.getElementMassById
    local isRemote = Nav.control.isRemoteControlled
    local atan = math.atan
    local stringmatch = string.match
    local systime = system.getTime
    local vec3 = vec3
    local uclamp = utils.clamp
    local navCom = Nav.axisCommandManager
    local sysDestWid = system.destroyWidgetPanel
    local sysUpData = system.updateData
    local sysAddData = system.addDataToWidget
    local sysLockVw = system.lockView
    local sysIsVwLock = system.isViewLocked
    local msqrt = math.sqrt
    local tonum = tonumber
    local core = core

    local function round(num, numDecimalPlaces) -- rounds variable num to numDecimalPlaces
        local mult = 10 ^ (numDecimalPlaces or 0)
        return mfloor(num * mult + 0.5) / mult
    end
-- Variables that we declare local outside script because they will be treated as global but get local effectiveness
    local time = systime()
    local clearAllCheck = systime()
    local coreOffset = 16
    local coreHalfDiag = 13
    local PrimaryR = SafeR
    local PrimaryB = SafeB
    local PrimaryG = SafeG
    local PlayerThrottle = 0
    local brakeInput2 = 0
    local ThrottleLimited = false
    local calculatedThrottle = 0
    local WasInCruise = false
    local apThrottleSet = false -- Do not save this, because when they re-enter, throttle won't be set anymore
    local minAutopilotSpeed = 55 -- Minimum speed for autopilot to maneuver in m/s.  Keep above 25m/s to prevent nosedives when boosters kick in
    local reentryMode = false
    local hasGear = false
    local pitchInput = 0
    local pitchInput2 = 0
    local yawInput2 = 0
    local rollInput = 0
    local yawInput = 0
    local brakeInput = 0
    local rollInput2 = 0
    local followMode = false
    local holdingCtrl = false
    local msgText = "empty"
    local holdAltitudeButtonModifier = 5
    local antiGravButtonModifier = 5
    local currentHoldAltModifier = holdAltitudeButtonModifier
    local currentAggModifier = antiGravButtonModifier
    local isBoosting = false -- Dodgin's Don't Die Rocket Govenor
    local brakeDistance, brakeTime = 0
    local maxBrakeDistance, maxBrakeTime = 0
    local autopilotTargetPlanet = nil
    local totalDistanceTrip = 0
    local flightTime = 0
    local upAmount = 0
    local simulatedX = 0
    local simulatedY = 0        
    local msgTimer = 3
    local distance = 0
    local lastOdometerOutput = ""

    local spaceLand = false
    local spaceLaunch = false
    local finalLand = false
    local abvGndDet = -1
    local myAutopilotTarget=""
    local inAtmo = (atmosphere() > 0)
    local atmosDensity = atmosphere()
    local coreAltitude = core.getAltitude()
    local elementsID = core.getElementIdList()
    local lastTravelTime = systime()
    local coreMass = core.getConstructMass()
    local mousePause = false
    local gyroIsOn = nil
    local rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
    local rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]
    local markers = {}
    local previousYawAmount = 0
    local previousPitchAmount = 0
    local damageMessage = ""
    local UnitHidden = true
    local Buttons = {}
    local resolutionWidth = ResolutionX
    local resolutionHeight = ResolutionY
    local atmoTanks = {}
    local spaceTanks = {}
    local rocketTanks = {}
    local eleTotalMaxHp = 0
    local repairArrows = false

    local atlas = nil
    local MapXRatio = nil
    local MapYRatio = nil
    local YouAreHere = nil
    local PlanetaryReference = nil
    local galaxyReference = nil
    local Kinematic = nil
    local maxKinematicUp = nil
    local Kep = nil
    local HUD = nil
    local ATLAS = nil
    local AP = nil
    local RADAR = nil
    local Animating = false
    local Animated = false
    local autoRoll = autoRollPreference
    local targetGroundAltitude = LandingGearGroundHeight -- So it can tell if one loaded or not
    local stalling = false
    local lastApTickTime = systime()
    local targetRoll = 0
    local ahDoubleClick = 0
    local apDoubleClick = 0
    local adjustedAtmoSpeedLimit = AtmoSpeedLimit
    local VtPitch = 0
    local orbitMsg = nil
    local orbitPitch = 0
    local orbitRoll = 0
    local orbitAligned = false
    local orbitalRecover = false
    local orbitalParams = { VectorToTarget = false } --, AltitudeHold = false }
    local OrbitTargetSet = false
    local OrbitTargetOrbit = 0
    local OrbitTargetPlanet = nil
    local OrbitAchieved = false
    local SpaceEngineVertUp = false
    local SpaceEngineVertDn = false
    local SpaceEngines = false
    local OrbitTicks = 0
    local constructUp = vec3(core.getConstructWorldOrientationUp())
    local constructForward = vec3(core.getConstructWorldOrientationForward())
    local constructRight = vec3(core.getConstructWorldOrientationRight())
    local coreVelocity = vec3(core.getVelocity())
    local constructVelocity = vec3(core.getWorldVelocity())
    local velMag = vec3(constructVelocity):len()
    local worldVertical = vec3(core.getWorldVertical())
    local vSpd = -worldVertical:dot(constructVelocity)
    local worldPos = vec3(core.getConstructWorldPos())
    local soundAlarm = 0
    local UpVertAtmoEngine = false
    local antigravOn = false
    local setCruiseSpeed = nil
    local throttleMode = true
    local adjustedPitch = 0
    local adjustedRoll = 0
    local showSettings = false
    local settingsVariables = {}
    local oldShowHud = showHud
    local AtlasOrdered = {}
    local notPvPZone = false

    local pipeMessage = ""
    local ReversalIsOn = nil
    local contacts = {}
    local nearPlanet = unit.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000)
    local collisionAlertStatus = false
    local collisionTarget = nil


-- Function Definitions that are used in more than one areause 
    --[[    -- EliasVilld Log Code - To use uncomment all Elias sections and put the two lines below around code to be measured.
            -- local t0 = system.getTime()
            -- <code to be checked>
            -- _logCompute.addValue(system.getTime() - t0)
    function Log(name,ty)
        local self={}
        self.Name = name or 'Log'
        self.Value = (ty == 'number' and 0) or {}
        self.Type = ty or 'mean'

        function self.Update(v)
            if self.Type == 'number' then
                self.Value = v
            else
                self.Value[#self.Value] = v
            end
        end

        function self.getString()
            if self.Type == 'number' then
                return tostring(self.Value)
            elseif self.Type == 'time' then
                return utils.round(self.getMean()*1000,0.0001) .. 'ms ('..#self.Value..")"
            elseif self.Type == 'mean' then
                return tostring(utils.round(self.getMean(),0.01));
            end
        end
        
        function self.getValue()
            if self.Type == 'number' then
                return self.value
            else
                return self.getMean()
            end
        end
            
        function self.addValue(v)
            if self.Type == 'number' then return end
            
            table.insert(self.Value,1,v)
            if #self.Value > 1000 then self.Value[1001] = nil end
        end
        
        function self.getMean()
            local m = 0;
            for i=1,#self.Value do
                m = m + self.Value[i]
            end
            return m/#self.Value;
        end

        return self
    end
    function Logger()
        local self={}
        self.Logs={}

        function self.CreateLog(name,type)
            local log = Log(name,type)
            Register(log)
            return log;
        end
        
        function self.getLogs()
            local logs = {}
            for _,l in pairs(self.Logs) do
                logs[#logs+1] = l.Name .. ': ' .. l.getString()
            end
            return logs
        end
        
        function Register(log)
            self.Logs[#self.Logs+1] = log;
        end
        return self
    end
    --]]
    --[[
    function p(msg)
        system.print(time..": "..msg)
    end
    --]]
    local function checkLOS(vector)
        local intersectBody, farSide, nearSide = galaxyReference:getPlanetarySystem(0):castIntersections(worldPos, vector,
            function(body) if body.noAtmosphericDensityAltitude > 0 then return (body.radius+body.noAtmosphericDensityAltitude) else return (body.radius+body.surfaceMaxAltitude*1.5) end end)
        local atmoDistance = farSide
        if nearSide ~= nil and farSide ~= nil then
            atmoDistance = math.min(nearSide,farSide)
        end
        if atmoDistance ~= nil then return intersectBody, atmoDistance else return nil, nil end
    end

    local function play(sound, ID, type)
        if (type == nil and not voices) or (type ~= nil and not alerts) or soundFolder == "archHUD" then return end
        if type ~= nil then
            if type == 2 then
                system.logInfo("sound_loop|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
            else
                system.logInfo("sound_notification|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
            end
        else
            system.logInfo("sound_q|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
        end
    end

    local function addTable(table1, table2) -- Function to add two tables together
        for i = 1, #table2 do
            table1[#table1 + 1 ] = table2[i]
        end
        return table1
    end

    local function saveableVariables(subset) -- returns saveable variables by catagory
        local returnSet = {}
            -- Complete list of user variables above, must be in saveableVariables to be stored on databank
            local saveableVariablesBoolean = {"userControlScheme", "soundFolder", "freeLookToggle", "BrakeToggleDefault", "RemoteFreeze", "brightHud", "RemoteHud", "VanillaRockets",
                "InvertMouse", "autoRollPreference", "ExternalAGG", "UseSatNav", "ShouldCheckDamage", 
                "CalculateBrakeLandingSpeed", "AtmoSpeedAssist", "ForceAlignment", "DisplayDeadZone", "showHud", "ShowOdometer", "hideHudOnToggleWidgets", 
                "ShiftShowsRemoteButtons", "DisplayOrbit", "SetWaypointOnExit", "AlwaysVSpd", "BarFuelDisplay", "showHelp", "Cockpit",
                "voices", "alerts", "CollisionSystem"}
            local savableVariablesHandling = {"YawStallAngle","PitchStallAngle","brakeLandingRate","MaxPitch", "ReEntryPitch","LockPitchTarget", "TargetOrbitRadius", "LowOrbitHeight",
                "AtmoSpeedLimit","SpaceSpeedLimit","AutoTakeoffAltitude","TargetHoverHeight", "LandingGearGroundHeight", "ReEntryHeight",
                "MaxGameVelocity", "AutopilotInterplanetaryThrottle","warmup","fuelTankHandlingAtmo","fuelTankHandlingSpace",
                "fuelTankHandlingRocket","ContainerOptimization","FuelTankOptimization"}
            local savableVariablesHud = {"ResolutionX","ResolutionY","circleRad","SafeR", "SafeG", "SafeB", 
                "PvPR", "PvPG", "PvPB","centerX", "centerY", "throtPosX", "throtPosY",
                "vSpdMeterX", "vSpdMeterY","altMeterX", "altMeterY","fuelX", "fuelY", "shieldX", "shieldY", "DeadZone",
                "OrbitMapSize", "OrbitMapX", "OrbitMapY", "soundVolume"}
            local savableVariablesPhysics = {"speedChangeLarge", "speedChangeSmall", "MouseXSensitivity", "MouseYSensitivity", "autoRollFactor",
                "rollSpeedFactor", "autoRollRollThreshold", "minRollVelocity", "TrajectoryAlignmentStrength",
                "torqueFactor", "pitchSpeedFactor", "yawSpeedFactor", "brakeSpeedFactor", "brakeFlatFactor", "DampingMultiplier", 
                "apTickRate",  "hudTickRate", "ExtraLongitudeTags", "ExtraLateralTags", "ExtraVerticalTags"}
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

    local function svgText(x, y, text, class, style) -- processes a svg text string, saves code lines by doing it this way
        if class == nil then class = "" end
        if style == nil then style = "" end
        return stringf([[<text class="%s" x=%s y=%s style="%s">%s</text>]], class,x, y, style, text)
    end

    local function cmdThrottle(value, dontSwitch) -- sets the throttle value to value, also switches to throttle mode (vice cruise) unless dontSwitch passed
        if navCom:getAxisCommandType(0) ~= axisCommandType.byThrottle and not dontSwitch then
            Nav.control.cancelCurrentControlMasterMode()
        end
        navCom:setThrottleCommand(axisCommandId.longitudinal, value)
        PlayerThrottle = uclamp(round(value*100,0)/100, -1, 1)
    end

    local function cmdCruise(value, dontSwitch) -- sets the cruise target speed to value, also switches to cruise mode (vice throttle) unless dontSwitch passed
        if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed and not dontSwitch then
            Nav.control.cancelCurrentControlMasterMode()
        end
        navCom:setTargetSpeedCommand(axisCommandId.longitudinal, value)
        setCruiseSpeed = value
    end

    local function float_eq(a, b) -- float equation
        if a == 0 then
            return mabs(b) < 1e-09
        end
        if b == 0 then
            return mabs(a) < 1e-09
        end
        return mabs(a - b) < math.max(mabs(a), mabs(b)) * epsilon
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

    local function ToggleVerticalTakeoff() -- Toggle vertical takeoff mode on and off
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
                cmdCruise(mfloor(adjustedAtmoSpeedLimit))
            end
        else
            OrbitAchieved = false
            GearExtended = false
            Nav.control.retractLandingGears()
            navCom:setTargetGroundAltitude(TargetHoverHeight) 
            BrakeIsOn = true
        end
        VertTakeOff = not VertTakeOff
    end

    local function ToggleIntoOrbit() -- Toggle IntoOrbit mode on and off
        OrbitAchieved = false
        orbitPitch = nil
        orbitRoll = nil
        OrbitTicks = 0
        if atmosDensity == 0 then
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

    local function ToggleAltitudeHold()  -- Toggle Altitude Hold mode on and off
        if (time - ahDoubleClick) < 1.5 then
            if planet.hasAtmosphere  then
                if atmosDensity > 0 then
                    HoldAltitude = planet.spaceEngineMinAltitude - 0.01*planet.noAtmosphericDensityAltitude
                    play("11","EP")
                else
                    if nearPlanet then
                        HoldAltitude = planet.noAtmosphericDensityAltitude + LowOrbitHeight
                        OrbitTargetOrbit = HoldAltitude
                        OrbitTargetSet = true
                        if not IntoOrbit then ToggleIntoOrbit() end
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
        if nearPlanet and atmosDensity == 0 then
            OrbitTargetOrbit = coreAltitude
            OrbitTargetSet = true
            orbitAligned = true
            ToggleIntoOrbit()
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
                play("lfs", "LS")
                AutoTakeoff = true
                if ahDoubleClick > -1 then HoldAltitude = coreAltitude + AutoTakeoffAltitude end
                GearExtended = false
                Nav.control.retractLandingGears()
                BrakeIsOn = true
                navCom:setTargetGroundAltitude(TargetHoverHeight)
                if VertTakeOffEngine and UpVertAtmoEngine then 
                    ToggleVerticalTakeoff()
                end
            else
                play("altOn","AH")
                AutoTakeoff = false
                if ahDoubleClick > -1 then
                    if nearPlanet then
                        HoldAltitude = coreAltitude
                    end
                end
                if VertTakeOff then ToggleVerticalTakeoff() end
            end
            if spaceLaunch then HoldAltitude = 100000 end
        else
            play("altOff","AH")
            if IntoOrbit then ToggleIntoOrbit() end
            if VertTakeOff then 
                ToggleVerticalTakeoff() 
            end
            autoRoll = autoRollPreference
            AutoTakeoff = false
            VectorToTarget = false
            ahDoubleClick = 0
        end
    end

    local function ToggleAutopilot() -- Toggle autopilot mode on and off

        local function ToggleVectorToTarget(SpaceTarget)
            -- This is a feature to vector toward the target destination in atmo or otherwise on-planet
            -- Uses altitude hold.  
            collisionAlertStatus = false
            VectorToTarget = not VectorToTarget
            if VectorToTarget then
                TurnBurn = false
                if not AltitudeHold and not SpaceTarget then
                    ToggleAltitudeHold()
                end
            end
            VectorStatus = "Proceeding to Waypoint"
        end

        if (time - apDoubleClick) < 1.5 and atmosDensity > 0 then
            if not SpaceEngines then
                msgText = "No space engines detected, Orbital Hop not supported"
                return
            end
            if planet.hasAtmosphere then
                if atmosDensity > 0 then
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
        if AutopilotTargetIndex > 0 and not Autopilot and not VectorToTarget and not spaceLaunch and not IntoOrbit then
            if 0.5 * Nav:maxForceForward() / core.g() < coreMass then  msgText = "WARNING: Heavy Loads may affect autopilot performance." msgTimer=5 end
            ATLAS.UpdateAutopilotTarget() -- Make sure we're updated
            AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords)

            if CustomTarget ~= nil then
                LockPitch = nil
                SpaceTarget = (CustomTarget.planetname == "Space")
                if SpaceTarget then
                    play("apSpc", "AP")
                    if atmosDensity ~= 0 then 
                        spaceLaunch = true
                        ToggleAltitudeHold()
                    else
                        Autopilot = true
                    end
                elseif planet.name  == CustomTarget.planetname then
                    StrongBrakes = true
                    if atmosDensity > 0 then
                        if not VectorToTarget then
                            play("vtt", "AP")
                            ToggleVectorToTarget(SpaceTarget)
                        end
                    else
                        play("apOn", "AP")
                        if not (autopilotTargetPlanet.name == planet.name and nearPlanet) then
                            OrbitAchieved = false
                            Autopilot = true
                        elseif not inAtmo then
                            if IntoOrbit then ToggleIntoOrbit() end -- Reset all appropriate vars
                            OrbitTargetOrbit = planet.noAtmosphericDensityAltitude + LowOrbitHeight
                            OrbitTargetSet = true
                            orbitalParams.AutopilotAlign = true
                            orbitalParams.VectorToTarget = true
                            orbitAligned = false
                            if not IntoOrbit then ToggleIntoOrbit() end
                        end
                    end
                else
                    play("apP", "AP")
                    RetrogradeIsOn = false
                    ProgradeIsOn = false
                    if atmosDensity ~= 0 then 
                        spaceLaunch = true
                        ToggleAltitudeHold() 
                    else
                        Autopilot = true
                    end
                end
            elseif atmosDensity == 0 then -- Planetary autopilot
                if CustomTarget == nil and (autopilotTargetPlanet.name == planet.name and nearPlanet) and not IntoOrbit then
                    WaypointSet = false
                    OrbitAchieved = false
                    orbitAligned = false
                    ToggleIntoOrbit() -- this works much better here
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
                ToggleAltitudeHold()
            end
        else
            play("apOff", "AP")
            spaceLaunch = false
            Autopilot = false
            AutopilotRealigned = false
            VectorToTarget = false
            apThrottleSet = false
            AutoTakeoff = false
            AltitudeHold = false
            HoldAltitude = coreAltitude
            TargetSet = false
            Reentry = false
            if IntoOrbit then ToggleIntoOrbit() end
        end
    end

    local function BrakeToggle() -- Toggle brakes on and off
        -- Toggle brakes
        BrakeIsOn = not BrakeIsOn
        if BrakeLanding then
            BrakeLanding = false
            autoRoll = autoRollPreference
        end
        if BrakeIsOn then
            play("bkOn","B",1)
            -- If they turn on brakes, disable a few things
            VectorToTarget = false
            AutoTakeoff = false
            Reentry = false
            -- We won't abort interplanetary because that would fuck everyone.
            ProgradeIsOn = false -- No reason to brake while facing prograde, but retrograde yes.
            BrakeLanding = false
            AutoLanding = false
            ReversalIsOn = nil
            if not antigravOn then
                AltitudeHold = false -- And stop alt hold
                LockPitch = nil
            end
            if VertTakeOff then
                ToggleVerticalTakeoff()
            end
            if IntoOrbit then
                ToggleIntoOrbit()
            end
            autoRoll = autoRollPreference
            spaceLand = false
            finalLand = false
            upAmount = 0
        else
            play("bkOff","B",1)
        end
    end

    local function BeginReentry() -- Begins re-entry process
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
            if HoldAltitude > planet.spaceEngineMinAltitude then HoldAltitude = planet.spaceEngineMinAltitude - 0.01*planet.noAtmosphericDensityAltitude end
            local text = getDistanceDisplayString(HoldAltitude)
            msgText = "Beginning Re-entry.  Target speed: " .. adjustedAtmoSpeedLimit .. " Target Altitude: " .. text 
            play("glide","RE")
            cmdCruise(mfloor(adjustedAtmoSpeedLimit))
        end
        AutoTakeoff = false -- This got left on somewhere.. 
    end

    local function ToggleAntigrav() -- Toggles antigrav on and off
        if antigrav and not ExternalAGG then
            if antigravOn then
                play("aggOff","AG")
                antigrav.deactivate()
                antigrav.hide()
            else
                if AntigravTargetAltitude == nil then AntigravTargetAltitude = coreAltitude end
                if AntigravTargetAltitude < 1000 then
                    AntigravTargetAltitude = 1000
                end
                play("aggOn","AG")
                antigrav.activate()
                antigrav.show()
            end
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

    local function SaveDataBank(copy) -- Save values to the databank.
        local function writeData(dataList)
            for k, v in pairs(dataList) do
                dbHud_1.setStringValue(v, jencode(_G[v]))
                if copy and dbHud_2 then
                    dbHud_2.setStringValue(v, jencode(_G[v]))
                end
            end
        end
        if dbHud_1 then
            writeData(autoVariables) 
            writeData(saveableVariables())
            system.print("Saved Variables to Datacore")
            if copy and dbHud_2 then
                msgText = "Databank copied.  Remove copy when ready."
            end
        end
    end


-- Planet Info - https://gitlab.com/JayleBreak/dualuniverse/-/tree/master/DUflightfiles/autoconf/custom with modifications to support HUD, vanilla JayleBreak will not work anymore
    local function Atlas()
        return {
            [0] = {
                [0] = {
                    GM = 0,
                    bodyId = 0,
                    center = {
                        x = 0,
                        y = 0,
                        z = 0
                    },
                    name = 'Space',
                    planetarySystemId = 0,
                    radius = 0,
                    hasAtmosphere = false,
                    gravity = 0,
                    noAtmosphericDensityAltitude = 0,
                    surfaceMaxAltitude = 0
                },
                [2] = {
                    name = "Alioth",
                    description = "Alioth is the planet selected by the arkship for landfall; it is a typical goldilocks planet where humanity may rebuild in the coming decades. The arkship geological survey reports mountainous regions alongside deep seas and lush forests. This is where it all starts.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.9401,
                    atmosphericEngineMaxAltitude = 5580,
                    biosphere = "Forest",
                    classification = "Mesoplanet",
                    bodyId = 2,
                    GM = 157470826617,
                    gravity = 1.0082568597356114,
                    fullAtmosphericDensityMaxAltitude = -10,
                    habitability = "High",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 6272,
                    numSatellites = 2,
                    positionFromSun = 2,
                    center = {
                        x = -8,
                        y = -8,
                        z = -126303
                    },
                    radius = 126067.8984375,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 3410,
                    surfaceArea = 199718780928,
                    surfaceAverageAltitude = 200,
                    surfaceMaxAltitude = 1100,
                    surfaceMinAltitude = -330,
                    systemZone = "High",
                    territories = 259472,
                    type = "Planet",
                    waterLevel = 0,
                    planetarySystemId = 0
                },
                [21] = {
                    name = "Alioth Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 21,
                    GM = 2118960000,
                    gravity = 0.24006116402380084,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 457933,
                        y = -1509011,
                        z = 115524
                    },
                    radius = 30000,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 11309733888,
                    surfaceAverageAltitude = 140,
                    surfaceMaxAltitude = 200,
                    surfaceMinAltitude = 10,
                    systemZone = nil,
                    territories = 14522,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [22] = {
                    name = "Alioth Moon 4",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 22,
                    GM = 2165833514,
                    gravity = 0.2427018259886451,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = -1692694,
                        y = 729681,
                        z = -411464
                    },
                    radius = 30330,
                    safeAreaEdgeAltitude = 500000,
                    size = "L",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 11559916544,
                    surfaceAverageAltitude = -15,
                    surfaceMaxAltitude = -5,
                    surfaceMinAltitude = -50,
                    systemZone = nil,
                    territories = 14522,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [5] = {
                    name = "Feli",
                    description = "Feli is easily identified by its massive and deep crater. Outside of the crater, the arkship geological survey reports a fairly bland and uniform planet, it also cannot explain the existence of the crater. Feli is particular for having an extremely small atmosphere, allowing life to develop in the deeper areas of its crater but limiting it drastically on the actual surface.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.5488,
                    atmosphericEngineMaxAltitude = 66725,
                    biosphere = "Barren",
                    classification = "Mesoplanet",
                    bodyId = 5,
                    GM = 16951680000,
                    gravity = 0.4801223280476017,
                    fullAtmosphericDensityMaxAltitude = 30,
                    habitability = "Low",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 78500,
                    numSatellites = 1,
                    positionFromSun = 5,
                    center = {
                        x = -43534464,
                        y = 22565536,
                        z = -48934464
                    },
                    radius = 41800,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 42800,
                    surfaceArea = 21956466688,
                    surfaceAverageAltitude = 18300,
                    surfaceMaxAltitude = 18500,
                    surfaceMinAltitude = 46,
                    systemZone = "Low",
                    territories = 27002,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [50] = {
                    name = "Feli Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 50,
                    GM = 499917600,
                    gravity = 0.11202853997062348,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = -43902841.78,
                        y = 22261034.7,
                        z = -48862386
                    },
                    radius = 14000,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2463008768,
                    surfaceAverageAltitude = 800,
                    surfaceMaxAltitude = 900,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 3002,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [120] = {
                    name = "Ion",
                    description = "Ion is nothing more than an oversized ice cube frozen through and through. It is a largely inhospitable planet due to its extremely low temperatures. The arkship geological survey reports extremely rough mountainous terrain with little habitable land.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.9522,
                    atmosphericEngineMaxAltitude = 10480,
                    biosphere = "Ice",
                    classification = "Hypopsychroplanet",
                    bodyId = 120,
                    GM = 7135606629,
                    gravity = 0.36009174603570127,
                    fullAtmosphericDensityMaxAltitude = -30,
                    habitability = "Average",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 17700,
                    numSatellites = 2,
                    positionFromSun = 12,
                    center = {
                        x = 2865536.7,
                        y = -99034464,
                        z = -934462.02
                    },
                    radius = 44950,
                    safeAreaEdgeAltitude = 500000,
                    size = "XS",
                    spaceEngineMinAltitude = 6410,
                    surfaceArea = 25390383104,
                    surfaceAverageAltitude = 500,
                    surfaceMaxAltitude = 1300,
                    surfaceMinAltitude = 250,
                    systemZone = "Average",
                    territories = 32672,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [121] = {
                    name = "Ion Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 121,
                    GM = 106830900,
                    gravity = 0.08802242599860607,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 2472916.8,
                        y = -99133747,
                        z = -1133582.8
                    },
                    radius = 11000,
                    safeAreaEdgeAltitude = 500000,
                    size = "XS",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 1520530944,
                    surfaceAverageAltitude = 100,
                    surfaceMaxAltitude = 200,
                    surfaceMinAltitude = 3,
                    systemZone = nil,
                    territories = 1922,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [122] = {
                    name = "Ion Moon 2",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 122,
                    GM = 176580000,
                    gravity = 0.12003058201190042,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 2995424.5,
                        y = -99275010,
                        z = -1378480.7
                    },
                    radius = 15000,
                    safeAreaEdgeAltitude = 500000,
                    size = "XS",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2827433472,
                    surfaceAverageAltitude = -1900,
                    surfaceMaxAltitude = -1400,
                    surfaceMinAltitude = -2100,
                    systemZone = nil,
                    territories = 3632,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [9] = {
                    name = "Jago",
                    description = "Jago is a water planet. The large majority of the planet&apos;s surface is covered by large oceans dotted by small areas of landmass across the planet. The arkship geological survey reports deep seas across the majority of the planet with sub 15 percent coverage of solid ground.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.9835,
                    atmosphericEngineMaxAltitude = 9695,
                    biosphere = "Water",
                    classification = "Mesoplanet",
                    bodyId = 9,
                    GM = 18606274330,
                    gravity = 0.5041284298678057,
                    fullAtmosphericDensityMaxAltitude = -90,
                    habitability = "Very High",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 10900,
                    numSatellites = 0,
                    positionFromSun = 9,
                    center = {
                        x = -94134462,
                        y = 12765534,
                        z = -3634464
                    },
                    radius = 61590,
                    safeAreaEdgeAltitude = 500000,
                    size = "XL",
                    spaceEngineMinAltitude = 5900,
                    surfaceArea = 47668367360,
                    surfaceAverageAltitude = 0,
                    surfaceMaxAltitude = 1200,
                    surfaceMinAltitude = -500,
                    systemZone = "Very High",
                    territories = 60752,
                    type = "Planet",
                    waterLevel = 0,
                    planetarySystemId = 0
                },
                [100] = {
                    name = "Lacobus",
                    description = "Lacobus is an ice planet that also features large bodies of water. The arkship geological survey reports deep oceans alongside a frozen and rough mountainous environment. Lacobus seems to feature regional geothermal activity allowing for the presence of water on the surface.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.7571,
                    atmosphericEngineMaxAltitude = 11120,
                    biosphere = "Ice",
                    classification = "Psychroplanet",
                    bodyId = 100,
                    GM = 13975172474,
                    gravity = 0.45611622622739767,
                    fullAtmosphericDensityMaxAltitude = -20,
                    habitability = "Average",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 12510,
                    numSatellites = 3,
                    positionFromSun = 10,
                    center = {
                        x = 98865536,
                        y = -13534464,
                        z = -934461.99
                    },
                    radius = 55650,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 6790,
                    surfaceArea = 38917074944,
                    surfaceAverageAltitude = 800,
                    surfaceMaxAltitude = 1660,
                    surfaceMinAltitude = 250,
                    systemZone = "Average",
                    territories = 50432,
                    type = "Planet",
                    waterLevel = 0,
                    planetarySystemId = 0
                },
                [102] = {
                    name = "Lacobus Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 102,
                    GM = 444981600,
                    gravity = 0.14403669598391783,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 99180968,
                        y = -13783862,
                        z = -926156.4
                    },
                    radius = 18000,
                    safeAreaEdgeAltitude = 500000,
                    size = "XL",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 4071504128,
                    surfaceAverageAltitude = 150,
                    surfaceMaxAltitude = 300,
                    surfaceMinAltitude = 10,
                    systemZone = nil,
                    territories = 5072,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [103] = {
                    name = "Lacobus Moon 2",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 103,
                    GM = 211503600,
                    gravity = 0.11202853997062348,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 99250052,
                        y = -13629215,
                        z = -1059341.4
                    },
                    radius = 14000,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2463008768,
                    surfaceAverageAltitude = -1380,
                    surfaceMaxAltitude = -1280,
                    surfaceMinAltitude = -1880,
                    systemZone = nil,
                    territories = 3002,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [101] = {
                    name = "Lacobus Moon 3",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 101,
                    GM = 264870000,
                    gravity = 0.12003058201190042,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 98905288.17,
                        y = -13950921.1,
                        z = -647589.53
                    },
                    radius = 15000,
                    safeAreaEdgeAltitude = 500000,
                    size = "L",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2827433472,
                    surfaceAverageAltitude = 500,
                    surfaceMaxAltitude = 820,
                    surfaceMinAltitude = 3,
                    systemZone = nil,
                    territories = 3632,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [1] = {
                    name = "Madis",
                    description = "Madis is a barren wasteland of a rock; it sits closest to the sun and temperatures reach extreme highs during the day. The arkship geological survey reports long rocky valleys intermittently separated by small ravines.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.8629,
                    atmosphericEngineMaxAltitude = 7165,
                    biosphere = "Barren",
                    classification = "hyperthermoplanet",
                    bodyId = 1,
                    GM = 6930729684,
                    gravity = 0.36009174603570127,
                    fullAtmosphericDensityMaxAltitude = 220,
                    habitability = "Low",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 8050,
                    numSatellites = 3,
                    positionFromSun = 1,
                    center = {
                        x = 17465536,
                        y = 22665536,
                        z = -34464
                    },
                    radius = 44300,
                    safeAreaEdgeAltitude = 500000,
                    size = "XS",
                    spaceEngineMinAltitude = 4480,
                    surfaceArea = 24661377024,
                    surfaceAverageAltitude = 750,
                    surfaceMaxAltitude = 850,
                    surfaceMinAltitude = 670,
                    systemZone = "Low",
                    territories = 30722,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [10] = {
                    name = "Madis Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 10,
                    GM = 78480000,
                    gravity = 0.08002039003323584,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 17448118.224,
                        y = 22966846.286,
                        z = 143078.82
                    },
                    radius = 10000,
                    safeAreaEdgeAltitude = 500000,
                    size = "XL",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 1256637056,
                    surfaceAverageAltitude = 210,
                    surfaceMaxAltitude = 420,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 1472,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [11] = {
                    name = "Madis Moon 2",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 11,
                    GM = 237402000,
                    gravity = 0.09602446196397631,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 17194626,
                        y = 22243633.88,
                        z = -214962.81
                    },
                    radius = 12000,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 1809557376,
                    surfaceAverageAltitude = -700,
                    surfaceMaxAltitude = 300,
                    surfaceMinAltitude = -2900,
                    systemZone = nil,
                    territories = 1922,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [12] = {
                    name = "Madis Moon 3",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 12,
                    GM = 265046609,
                    gravity = 0.12003058201190042,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 17520614,
                        y = 22184730,
                        z = -309989.99
                    },
                    radius = 15000,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2827433472,
                    surfaceAverageAltitude = 700,
                    surfaceMaxAltitude = 1100,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 3632,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [26] = {
                    name = "Sanctuary",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.9666,
                    atmosphericEngineMaxAltitude = 6935,
                    biosphere = "",
                    classification = "",
                    bodyId = 26,
                    GM = 68234043600,
                    gravity = 1.0000000427743831,
                    fullAtmosphericDensityMaxAltitude = -30,
                    habitability = "",
                    hasAtmosphere = true,
                    isSanctuary = true,
                    noAtmosphericDensityAltitude = 7800,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = -1404835,
                        y = 562655,
                        z = -285074
                    },
                    radius = 83400,
                    safeAreaEdgeAltitude = 0,
                    size = "L",
                    spaceEngineMinAltitude = 4230,
                    surfaceArea = 87406149632,
                    surfaceAverageAltitude = 80,
                    surfaceMaxAltitude = 500,
                    surfaceMinAltitude = -60,
                    systemZone = nil,
                    territories = 111632,
                    type = "",
                    waterLevel = 0,
                    planetarySystemId = 0
                },
                [6] = {
                    name = "Sicari",
                    description = "Sicari is a typical desert planet; it has survived for millenniums and will continue to endure. While not the most habitable of environments it remains a relatively untouched and livable planet of the Alioth sector. The arkship geological survey reports large flatlands alongside steep plateaus.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.897,
                    atmosphericEngineMaxAltitude = 7725,
                    biosphere = "Desert",
                    classification = "Mesoplanet",
                    bodyId = 6,
                    GM = 10502547741,
                    gravity = 0.4081039739797361,
                    fullAtmosphericDensityMaxAltitude = -625,
                    habitability = "Average",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 8770,
                    numSatellites = 0,
                    positionFromSun = 6,
                    center = {
                        x = 52765536,
                        y = 27165538,
                        z = 52065535
                    },
                    radius = 51100,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 4480,
                    surfaceArea = 32813432832,
                    surfaceAverageAltitude = 130,
                    surfaceMaxAltitude = 220,
                    surfaceMinAltitude = 50,
                    systemZone = "Average",
                    territories = 41072,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [7] = {
                    name = "Sinnen",
                    description = "Sinnen is a an empty and rocky hell. With no atmosphere to speak of it is one of the least hospitable planets in the sector. The arkship geological survey reports mostly flatlands alongside deep ravines which look to have once been riverbeds. This planet simply looks to have dried up and died, likely from solar winds.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.9226,
                    atmosphericEngineMaxAltitude = 10335,
                    biosphere = "Desert",
                    classification = "Mesoplanet",
                    bodyId = 7,
                    GM = 13033380591,
                    gravity = 0.4401121421448438,
                    fullAtmosphericDensityMaxAltitude = -120,
                    habitability = "Average",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 11620,
                    numSatellites = 1,
                    positionFromSun = 7,
                    center = {
                        x = 58665538,
                        y = 29665535,
                        z = 58165535
                    },
                    radius = 54950,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 6270,
                    surfaceArea = 37944188928,
                    surfaceAverageAltitude = 317,
                    surfaceMaxAltitude = 360,
                    surfaceMinAltitude = 23,
                    systemZone = "Average",
                    territories = 48002,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [70] = {
                    name = "Sinnen Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 70,
                    GM = 396912600,
                    gravity = 0.1360346539426409,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 58969616,
                        y = 29797945,
                        z = 57969449
                    },
                    radius = 17000,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 3631681280,
                    surfaceAverageAltitude = -2050,
                    surfaceMaxAltitude = -1950,
                    surfaceMinAltitude = -2150,
                    systemZone = nil,
                    territories = 4322,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [110] = {
                    name = "Symeon",
                    description = "Symeon is an ice planet mysteriously split at the equator by a band of solid desert. Exactly how this phenomenon is possible is unclear but some sort of weather anomaly may be responsible. The arkship geological survey reports a fairly diverse mix of flat-lands alongside mountainous formations.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.9559,
                    atmosphericEngineMaxAltitude = 6920,
                    biosphere = "Ice, Desert",
                    classification = "Hybrid",
                    bodyId = 110,
                    GM = 9204742375,
                    gravity = 0.3920998898971822,
                    fullAtmosphericDensityMaxAltitude = -30,
                    habitability = "High",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 7800,
                    numSatellites = 0,
                    positionFromSun = 11,
                    center = {
                        x = 14165536,
                        y = -85634465,
                        z = -934464.3
                    },
                    radius = 49050,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 4230,
                    surfaceArea = 30233462784,
                    surfaceAverageAltitude = 39,
                    surfaceMaxAltitude = 450,
                    surfaceMinAltitude = 126,
                    systemZone = "High",
                    territories = 38882,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [4] = {
                    name = "Talemai",
                    description = "Talemai is a planet in the final stages of an Ice Age. It seems likely that the planet was thrown into tumult by a cataclysmic volcanic event which resulted in its current state. The arkship geological survey reports large mountainous regions across the entire planet.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.8776,
                    atmosphericEngineMaxAltitude = 9685,
                    biosphere = "Barren",
                    classification = "Psychroplanet",
                    bodyId = 4,
                    GM = 14893847582,
                    gravity = 0.4641182439650478,
                    fullAtmosphericDensityMaxAltitude = -78,
                    habitability = "Average",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 10890,
                    numSatellites = 3,
                    positionFromSun = 4,
                    center = {
                        x = -13234464,
                        y = 55765536,
                        z = 465536
                    },
                    radius = 57500,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 5890,
                    surfaceArea = 41547563008,
                    surfaceAverageAltitude = 580,
                    surfaceMaxAltitude = 610,
                    surfaceMinAltitude = 520,
                    systemZone = "Average",
                    territories = 52922,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [42] = {
                    name = "Talemai Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 42,
                    GM = 264870000,
                    gravity = 0.12003058201190042,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = -13058408,
                        y = 55781856,
                        z = 740177.76
                    },
                    radius = 15000,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2827433472,
                    surfaceAverageAltitude = 720,
                    surfaceMaxAltitude = 850,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 3632,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [40] = {
                    name = "Talemai Moon 2",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 40,
                    GM = 141264000,
                    gravity = 0.09602446196397631,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = -13503090,
                        y = 55594325,
                        z = 769838.64
                    },
                    radius = 12000,
                    safeAreaEdgeAltitude = 500000,
                    size = "S",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 1809557376,
                    surfaceAverageAltitude = 250,
                    surfaceMaxAltitude = 450,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 1922,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [41] = {
                    name = "Talemai Moon 3",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 41,
                    GM = 106830900,
                    gravity = 0.08802242599860607,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = -12800515,
                        y = 55700259,
                        z = 325207.84
                    },
                    radius = 11000,
                    safeAreaEdgeAltitude = 500000,
                    size = "XS",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 1520530944,
                    surfaceAverageAltitude = 190,
                    surfaceMaxAltitude = 400,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 1922,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [8] = {
                    name = "Teoma",
                    description = "[REDACTED] The arkship geological survey [REDACTED]. This planet should not be here.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.7834,
                    atmosphericEngineMaxAltitude = 5580,
                    biosphere = "Forest",
                    classification = "Mesoplanet",
                    bodyId = 8,
                    GM = 18477723600,
                    gravity = 0.48812434578525177,
                    fullAtmosphericDensityMaxAltitude = 15,
                    habitability = "High",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 6280,
                    numSatellites = 0,
                    positionFromSun = 8,
                    center = {
                        x = 80865538,
                        y = 54665536,
                        z = -934463.94
                    },
                    radius = 62000,
                    safeAreaEdgeAltitude = 500000,
                    size = "L",
                    spaceEngineMinAltitude = 3420,
                    surfaceArea = 48305131520,
                    surfaceAverageAltitude = 700,
                    surfaceMaxAltitude = 1100,
                    surfaceMinAltitude = -200,
                    systemZone = "High",
                    territories = 60752,
                    type = "Planet",
                    waterLevel = 0,
                    planetarySystemId = 0
                },
                [3] = {
                    name = "Thades",
                    description = "Thades is a scorched desert planet. Perhaps it was once teaming with life but now all that remains is ash and dust. The arkship geological survey reports a rocky mountainous planet bisected by a massive unnatural ravine; something happened to this planet.",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0.03552,
                    atmosphericEngineMaxAltitude = 32180,
                    biosphere = "Desert",
                    classification = "Thermoplanet",
                    bodyId = 3,
                    GM = 11776905000,
                    gravity = 0.49612641213015557,
                    fullAtmosphericDensityMaxAltitude = 150,
                    habitability = "Low",
                    hasAtmosphere = true,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 32800,
                    numSatellites = 2,
                    positionFromSun = 3,
                    center = {
                        x = 29165536,
                        y = 10865536,
                        z = 65536
                    },
                    radius = 49000,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 21400,
                    surfaceArea = 30171856896,
                    surfaceAverageAltitude = 13640,
                    surfaceMaxAltitude = 13690,
                    surfaceMinAltitude = 370,
                    systemZone = "Low",
                    territories = 38882,
                    type = "Planet",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [30] = {
                    name = "Thades Moon 1",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 30,
                    GM = 211564034,
                    gravity = 0.11202853997062348,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 29214402,
                        y = 10907080.695,
                        z = 433858.2
                    },
                    radius = 14000,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2463008768,
                    surfaceAverageAltitude = 60,
                    surfaceMaxAltitude = 300,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 3002,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                },
                [31] = {
                    name = "Thades Moon 2",
                    description = "",
                    antiGravMinAltitude = 1000,
                    atmosphericDensityAboveSurface = 0,
                    atmosphericEngineMaxAltitude = 0,
                    biosphere = "",
                    classification = "",
                    bodyId = 31,
                    GM = 264870000,
                    gravity = 0.12003058201190042,
                    fullAtmosphericDensityMaxAltitude = 0,
                    habitability = "",
                    hasAtmosphere = false,
                    isSanctuary = false,
                    noAtmosphericDensityAltitude = 0,
                    numSatellites = 0,
                    positionFromSun = 0,
                    center = {
                        x = 29404193,
                        y = 10432768,
                        z = 19554.131
                    },
                    radius = 15000,
                    safeAreaEdgeAltitude = 500000,
                    size = "M",
                    spaceEngineMinAltitude = 0,
                    surfaceArea = 2827433472,
                    surfaceAverageAltitude = 70,
                    surfaceMaxAltitude = 350,
                    surfaceMinAltitude = 0,
                    systemZone = nil,
                    territories = 3632,
                    type = "",
                    waterLevel = nil,
                    planetarySystemId = 0
                }
            }
        }
    end
    local function PlanetRef()
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
            return isTable(m) and isNumber(m.latitude and m.longitude and m.altitude and m.bodyId and m.systemId)
        end
        -- Constants
        local deg2rad = math.pi / 180
        local rad2deg = 180 / math.pi
        local epsilon = 1e-10
        local num = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
        local posPattern = '::pos{' .. num .. ',' .. num .. ',' .. num .. ',' .. num .. ',' .. num .. '}'
        -- Utilities
        local utils = require('cpml.utils')
        local vec3 = require('cpml.vec3')
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
            return lhs.planetarySystemId == rhs.planetarySystemId and lhs.bodyId == rhs.bodyId and
                    float_eq(lhs.radius, rhs.radius) and float_eq(lhs.center.x, rhs.center.x) and
                    float_eq(lhs.center.y, rhs.center.y) and float_eq(lhs.center.z, rhs.center.z) and
                    float_eq(lhs.GM, rhs.GM)
        end
        local function mkBodyParameters(systemId, bodyId, radius, worldCoordinates, GM)
            -- 'worldCoordinates' can be either table or vec3
            assert(isSNumber(systemId), 'Argument 1 (planetarySystemId) must be a number:' .. type(systemId))
            assert(isSNumber(bodyId), 'Argument 2 (bodyId) must be a number:' .. type(bodyId))
            assert(isSNumber(radius), 'Argument 3 (radius) must be a number:' .. type(radius))
            assert(isTable(worldCoordinates),
                'Argument 4 (worldCoordinates) must be a array or vec3.' .. type(worldCoordinates))
            assert(isSNumber(GM), 'Argument 5 (GM) must be a number:' .. type(GM))
            return setmetatable({
                planetarySystemId = tonum(systemId),
                bodyId = tonum(bodyId),
                radius = tonum(radius),
                center = vec3(worldCoordinates),
                GM = tonum(GM)
            }, BodyParameters)
        end
        -- MapPosition: Geographical coordinates of a point on a planetary body.
        local MapPosition = {}
        MapPosition.__index = MapPosition
        MapPosition.__tostring = function(p)
            return stringf('::pos{%d,%d,%s,%s,%s}', p.systemId, p.bodyId, formatNumber(p.latitude * rad2deg),
                    formatNumber(p.longitude * rad2deg), formatNumber(p.altitude))
        end
        MapPosition.__eq = function(lhs, rhs)
            return lhs.bodyId == rhs.bodyId and lhs.systemId == rhs.systemId and
                    float_eq(lhs.latitude, rhs.latitude) and float_eq(lhs.altitude, rhs.altitude) and
                    (float_eq(lhs.longitude, rhs.longitude) or float_eq(lhs.latitude, math.pi / 2) or
                        float_eq(lhs.latitude, -math.pi / 2))
        end
        -- latitude and longitude are in degrees while altitude is in meters
        local function mkMapPosition(overload, bodyId, latitude, longitude, altitude)
            local systemId = overload -- Id or '::pos{...}' string
            
            if isString(overload) and not longitude and not altitude and not bodyId and not latitude then
                systemId, bodyId, latitude, longitude, altitude = stringmatch(overload, posPattern)
                assert(systemId, 'Argument 1 (position string) is malformed.')
            else
                assert(isSNumber(systemId), 'Argument 1 (systemId) must be a number:' .. type(systemId))
                assert(isSNumber(bodyId), 'Argument 2 (bodyId) must be a number:' .. type(bodyId))
                assert(isSNumber(latitude), 'Argument 3 (latitude) must be in degrees:' .. type(latitude))
                assert(isSNumber(longitude), 'Argument 4 (longitude) must be in degrees:' .. type(longitude))
                assert(isSNumber(altitude), 'Argument 5 (altitude) must be in meters:' .. type(altitude))
            end
            systemId = tonum(systemId)
            bodyId = tonum(bodyId)
            latitude = tonum(latitude)
            longitude = tonum(longitude)
            altitude = tonum(altitude)
            if bodyId == 0 then -- this is a hack to represent points in space
                return setmetatable({
                    latitude = latitude,
                    longitude = longitude,
                    altitude = altitude,
                    bodyId = bodyId,
                    systemId = systemId
                }, MapPosition)
            end
            return setmetatable({
                latitude = deg2rad * uclamp(latitude, -90, 90),
                longitude = deg2rad * (longitude % 360),
                altitude = altitude,
                bodyId = bodyId,
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
                    error('Invalid planetary system ID: ' .. tostring(id))
                elseif pid and id ~= pid then
                    error('Mistringmatch planetary system IDs: ' .. id .. ' and ' .. pid)
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
        -- PlanetaryReference - map planetary system ID to PlanetarySystem
        PlanetaryReference = {}
        local function mkPlanetaryReference(referenceTable)
            return setmetatable({
                galaxyAtlas = referenceTable or {}
            }, PlanetaryReference)
        end
        PlanetaryReference.__index = function(t, i)
            if type(i) == 'number' then
                local system = t.galaxyAtlas[i]
                return mkPlanetarySystem(system)
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
        function PlanetaryReference.createBodyParameters(planetarySystemId, bodyId, surfaceArea, aPosition,
            verticalAtPosition, altitudeAtPosition, gravityAtPosition)
            assert(isSNumber(planetarySystemId),
                'Argument 1 (planetarySystemId) must be a number:' .. type(planetarySystemId))
            assert(isSNumber(bodyId), 'Argument 2 (bodyId) must be a number:' .. type(bodyId))
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
            return mkBodyParameters(planetarySystemId, bodyId, radius, center, GM)
        end

        PlanetaryReference.isMapPosition = isMapPosition
        function PlanetaryReference:getPlanetarySystem(overload)
            -- if galaxyAtlas then
            if i == nil then i = 0 end
            if nv == nil then nv = 0 end
            local planetarySystemId = overload
            if isMapPosition(overload) then
                planetarySystemId = overload.systemId
            end
            if type(planetarySystemId) == 'number' then
                local system = self.galaxyAtlas[i]
                if system then
                    if getmetatable(nv) ~= PlanetarySystem then
                        system = mkPlanetarySystem(system)
                    end
                    return system
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
            local selfie = collection or self
            -- Since we don't use bodyIds anywhere, got rid of them
            -- It was two tables doing basically the same thing
            
            -- Changed this to insert the body to candidates
            for _, body in pairs(selfie) do
                table.insert(candidates, body)
            end
            -- Added this because, your knownContacts list is already sorted, can skip an expensive re-sort
            if not sorted then
                table.sort(candidates, function (b1, b2)
                    return (b1.center - origin):len() < (b2.center - origin):len()
                end)
            end
            local dir = direction:normalize()
            -- Use the body directly from the for loop instead of getting it with i
            for _, body in ipairs(candidates) do
                local c_oV3 = body.center - origin
                -- Changed to the new method.  IDK if this is how self works but I think so
                local radius = self:sizeCalculator(body)
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
            if mapPosition.bodyId == 0 then
                return 0, vec3(mapPosition.latitude, mapPosition.longitude, mapPosition.altitude)
            end
            local params = self:getBodyParameters(mapPosition)
            if params then
                return mapPosition.bodyId, params:convertToWorldCoordinates(mapPosition)
            end
        end

        function PlanetarySystem:getBodyParameters(overload)
            local bodyId = overload
            if isMapPosition(overload) then
                bodyId = overload.bodyId
            end
            assert(isSNumber(bodyId), 'Argument 1 (bodyId) must be a number:' .. type(bodyId))
            return self[bodyId]
        end

        function PlanetarySystem:getPlanetarySystemId()
            local _, v = next(self)
            return v and v.planetarySystemId
        end

        function BodyParameters:convertToMapPosition(worldCoordinates)
            assert(isTable(worldCoordinates),
                'Argument 1 (worldCoordinates) must be an array or vec3:' .. type(worldCoordinates))
            local worldVec = vec3(worldCoordinates)
            if self.bodyId == 0 then
                return setmetatable({
                    latitude = worldVec.x,
                    longitude = worldVec.y,
                    altitude = worldVec.z,
                    bodyId = 0,
                    systemId = self.planetarySystemId
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
                bodyId = self.bodyId,
                systemId = self.planetarySystemId
            }, MapPosition)
        end

        function BodyParameters:convertToWorldCoordinates(overload)
            local mapPosition = isString(overload) and mkMapPosition(overload) or overload
            if mapPosition.bodyId == 0 then -- support deep space map position
                return vec3(mapPosition.latitude, mapPosition.longitude, mapPosition.altitude)
            end
            assert(isMapPosition(mapPosition), 'Argument 1 (mapPosition) is not an instance of "MapPosition".')
            assert(mapPosition.systemId == self.planetarySystemId,
                'Argument 1 (mapPosition) has a different planetary system ID.')
            assert(mapPosition.bodyId == self.bodyId, 'Argument 1 (mapPosition) has a different planetary body ID.')
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

-- Class Definitions to organize code
    local function Kinematics() -- Part of Jaylebreak's flight files, modified slightly for hud

        local Kinematic = {} -- just a namespace
        local C = 30000000 / 3600
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
    local function Keplers() -- Part of Jaylebreak's flight files, modified slightly for hud
        local vec3 = require('cpml.vec3')
        local PlanetRef = PlanetRef()
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
                timeToApoapsis = TimeToApoapsis
            }
        end
        local function new(bodyParameters)
            local params = PlanetRef.BodyParameters(bodyParameters.planetarySystemId, bodyParameters.bodyId,
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
    local function RadarClass() -- Everything related to radar but draw data passed to HUD Class.
        local Radar = {}
        -- Radar Class locals

            local friendlies = {}
            local sizeMap = { XS = 13, S = 27, M = 55, L = 110, XL = 221}
            local knownContacts = {}
            local radarContacts
            local target
            local data
            local numKnown
            local static

        local function UpdateRadarRoutine()
            
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

            local function getTrueWorldPos()
                local function getLocalToWorldConverter()
                    local v1 = core.getConstructWorldOrientationRight()
                    local v2 = core.getConstructWorldOrientationForward()
                    local v3 = core.getConstructWorldOrientationUp()
                    local v1t = library.systemResolution3(v1, v2, v3, {1,0,0})
                    local v2t = library.systemResolution3(v1, v2, v3, {0,1,0})
                    local v3t = library.systemResolution3(v1, v2, v3, {0,0,1})
                    return function(cref)
                        return library.systemResolution3(v1t, v2t, v3t, cref)
                    end
                end
                local cal = getLocalToWorldConverter()
                local cWorldPos = core.getConstructWorldPos()
                local pos = core.getElementPositionById(1)
                local offsetPosition = {pos[1] - coreOffset, pos[2] - coreOffset, pos[3] - coreOffset}
                local adj = cal(offsetPosition)
                local adjPos = {cWorldPos[1] - adj[1], cWorldPos[2] - adj[2], cWorldPos[3] - adj[3]}
                return adjPos
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
                        if not construct.lastPos then
                            construct.center = newPos
                        elseif (construct.lastPos - newPos):len() < 2 then
                            construct.center = newPos
                            construct.skipCalc = true
                            --system.print(construct.name.." ::pos{0,0,"..newPos.x..","..newPos.y..","..newPos.z.."}")
                        end
                        construct.lastPos = newPos
                    end
                    construct.pts = {}
                else
                    local offset = {wp[1]-ref[1],wp[2]-ref[2],wp[3]-ref[3]}
                    pts[index+1] = {d,offset}
                end
            end

            if (radar_1) then
                radarContacts = #radar_1.getEntries()
                local radarData = radar_1.getData()
                local contactData = radarData:gmatch('{"constructId[^}]*}[^}]*}') 
             
                if radarContacts > 0 then
                    local wp = getTrueWorldPos()
                    local count, count2 = 0, 0
                    static, numKnown = 0, 0
                    for v in contactData do
                        local id,distance,size = v:match([[{"constructId":"([%d%.]*)","distance":([%d%.]*).-"size":"(%a+)"]])
                        local sz = sizeMap[size]
                        distance = tonum(distance)
                        if radar_1.hasMatchingTransponder(id) == 1 then
                            table.insert(friendlies,id)
                        end
                        local cType = radar_1.getConstructType(id)
                        if CollisionSystem then
                            if sz > 27 or cType == "static" or cType == "space"
                            then
                                static = static + 1
                                local name = radar_1.getConstructName(id)
                                local construct = contacts[id]
                                if construct == nil then
                                    sz = sz+coreHalfDiag
                                    contacts[id] = {pts = {}, ref = wp, name = name, i = 0, radius = sz, skipCalc = false}
                                    construct = contacts[id]
                                end
                                if not construct.skipCalc then 
                                    updateVariables(construct, distance, wp) 
                                    count2 = count2 + 1
                                end
                                if construct.center then table.insert(knownContacts, construct) end
                            end
                            count = count + 1
                            if (nearPlanet and count > 700 or count2 > 70) or (not nearPlanet and count > 300 or count2 > 30) then
                                coroutine.yield()
                                count, count2 = 0, 0
                            end
                        end
                    end
                    numKnown = #knownContacts
                    if numKnown > 0 and velMag > 20 
                    then 
                        local body, far, near, vect
                        local innerCount = 0
                        local galxRef = galaxyReference:getPlanetarySystem(0)
                        vect = constructVelocity:normalize()
                        while innerCount < numKnown do
                            coroutine.yield()
                            local innerList = { table.unpack(knownContacts, innerCount, math.min(innerCount + 75, numKnown)) }
                            body, far, near = galxRef:castIntersections(worldPos, vect, nil, nil, innerList, true)
                            if body and near then collisionTarget = {body, far, near} break end
                            innerCount = innerCount + 75
                        end
                        if not body then collisionTarget = nil end
                    else
                        collisionTarget = nil
                    end
                    knownContacts = {}
                    target = radarData:find('identifiedConstructs":%[%]')
                else
                    data = radarData:find('worksInEnvironment":false')
                end
            end
        end

        function Radar.UpdateRadar()
            local cont = coroutine.status (UpdateRadarCoroutine)
            if cont == "suspended" then 
                local value, done = coroutine.resume(UpdateRadarCoroutine)
                if done then system.print("ERROR UPDATE RADAR: "..done) end
            elseif cont == "dead" then
                UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
                local value, done = coroutine.resume(UpdateRadarCoroutine)
            end
        end

        function Radar.GetRadarHud()
            local friends = friendlies
            friendlies = {}
            return target, data, radarContacts, numKnown, static, friends
        end
        
        UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
        return Radar
    end 
    local function HudClass() -- Everything HUD display releated including tick
        local pvpDist = 0
        local gravConstant = 9.80665

        --Local Huds Functions
            -- safezone() variables
                local safeWorldPos = vec3({13771471,7435803,-128971})
                local safeRadius = 18000000
                local szradius = 500000
                local distsz, distp = math.huge
                local szsafe 
            local function safeZone(WorldPos) -- Thanks to @SeM for the base code, modified to work with existing Atlas
                distsz = vec3(WorldPos):dist(safeWorldPos)
                if distsz < safeRadius then  
                    return true, mabs(distsz - safeRadius)
                end
                distp = vec3(WorldPos):dist(vec3(planet.center))
                if distp < szradius then szsafe = true else szsafe = false end
                if mabs(distp - szradius) < mabs(distsz - safeRadius) then 
                    return szsafe, mabs(distp - szradius)
                else
                    return szsafe, mabs(distsz - safeRadius)
                end
            end

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
                local slottedTankType = ""
                local slottedTanks = 0
                local fuelUpdateDelay = (mfloor(1 / apTickRate) * 2)*hudTickRate
                local fuelTimeLeftR = {}
                local fuelPercentR = {}
                local fuelTimeLeftS = {}
                local fuelPercentS = {}
                local fuelTimeLeft = {}
                local fuelPercent = {}
            
            local function DrawTank(x, nameSearchPrefix, nameReplacePrefix, tankTable, fuelTimeLeftTable,
                fuelPercentTable)
                
                local y1 = fuelY
                local y2 = fuelY+5
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
                        local name = string.sub(tankTable[i][tankName], 1, 12)
                        local slottedIndex = 0
                        for j = 1, slottedTanks do
                            if tankTable[i][tankName] == jdecode(unit[slottedTankType .. "_" .. j].getData()).name then
                                slottedIndex = j
                                break
                            end
                        end

                        local curTime = systime()

                        if fuelTimeLeftTable[i] == nil or fuelPercentTable[i] == nil or (curTime - tankTable[i][tankLastTime]) > fuelUpdateDelay then
                            
                            local fuelMassLast
                            local fuelMass = 0
                            if slottedIndex ~= 0 then
                                fuelPercentTable[i] = jdecode(unit[slottedTankType .. "_" .. slottedIndex].getData())
                                                        .percentage
                                fuelTimeLeftTable[i] = jdecode(unit[slottedTankType .. "_" .. slottedIndex].getData())
                                                        .timeLeft
                                if fuelTimeLeftTable[i] == "n/a" then
                                    fuelTimeLeftTable[i] = 0
                                end
                            else
                                fuelMass = (eleMass(tankTable[i][tankID]) - tankTable[i][tankMassEmpty])
                                fuelPercentTable[i] = mfloor(0.5 + fuelMass * 100 / tankTable[i][tankMaxVol])
                                fuelMassLast = tankTable[i][tankLastMass]
                                if fuelMassLast <= fuelMass then
                                    fuelTimeLeftTable[i] = 0
                                else
                                    fuelTimeLeftTable[i] = mfloor(
                                                            0.5 + fuelMass /
                                                                ((fuelMassLast - fuelMass) / (curTime - tankTable[i][tankLastTime])))
                                end
                                tankTable[i][tankLastMass] = fuelMass
                                tankTable[i][tankLastTime] = curTime
                            end
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
                            if BarFuelDisplay then
                                tankMessage = tankMessage..stringf([[
                                    <g class="pdim">                        
                                    <rect fill=grey class="bar" x="%d" y="%d" width="100" height="13"></rect></g>
                                    <g class="bar txtstart">
                                    <rect fill=%s width="%d" height="13" x="%d" y="%d"></rect>
                                    <text fill=black x="%d" y="%d">%s%% %s</text>
                                    </g>]], x, y2, color, fuelPercentTable[i], x, y2, x+2, y2+10, fuelPercentTable[i], fuelTimeDisplay
                                )
                                tankMessage = tankMessage..svgText(x, y1, name, class.."txtstart pdim txtfuel") 
                                y1 = y1 - 30
                                y2 = y2 - 30
                            else
                                tankMessage = tankMessage..svgText(x, y1, name, class.."pdim txtfuel") 
                                tankMessage = tankMessage..svgText( x, y2, stringf("%d%% %s", fuelPercentTable[i], fuelTimeDisplay), "pdim txtfuel","fill:"..color)
                                y1 = y1 + 30
                                y2 = y2 + 30
                            end
                        end
                    end
                end
            end

            local function DrawVerticalSpeed(newContent, altitude) -- Draw vertical speed indicator - Code by lisa-lionheart
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
                for i = degRange+60, degRange, -5 do
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
                        newContent[#newContent + 1] = svgText(x+5,yawy-12, num )
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
                newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/>]],
                    yawx-5, yawy+10, yawx+5, yawy+10, yawx, yawy+5)
                if nearPlanet then bottomText = "HDG" end
                newContent[#newContent + 1] = svgText(yawx, yawy+25, yawC.."deg" , "pdim txt txtmid", "")
                newContent[#newContent + 1] = svgText( yawx, yawy+35, bottomText, "pdim txt txtmid","")
            end

            local function DrawArtificialHorizon(newContent, originalPitch, originalRoll, centerX, centerY, nearPlanet, atmoYaw, speed)
                -- ** CIRCLE ALTIMETER  - Base Code from Discord @Rainsome = Youtube CaptainKilmar** 
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
                                newContent[#newContent + 1] = stringf([[<g path transform="rotate(%f,%d,%d)" class="pdim txt txtmid"><text x="%d" y="%f">%d</text></g>]],(-1 * originalRoll), centerX, centerY, centerX-pitchX+10, y, i)
                                newContent[#newContent + 1] = stringf([[<g path transform="rotate(%f,%d,%d)" class="pdim txt txtmid"><text x="%d" y="%f">%d</text></g>]],(-1 * originalRoll), centerX, centerY, centerX+pitchX-10, y, i)
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
                throt = mfloor(throt+0.5) -- Hard-round it to an int
                local y1 = throtPosY+10
                local y2 = throtPosY+20
                if isRemote() == 1 and not RemoteHud then
                    y1 = 55
                    y2 = 65
                end            
                local label = "CRUISE"
                local unit = "km/h"
                local value = flightValue
                if (flightStyle == "TRAVEL" or flightStyle == "AUTOPILOT") then
                    label = "THROT"
                    unit = "%"
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
                newContent[#newContent + 1] = svgText(throtPosX+10, y2, stringf("%.0f %s", value, unit), "pbright txtstart")
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
                local ys = throtPosY-10 
                local x1 = throtPosX + 10
                newContent[#newContent + 1] = svgText(0,0,"", "pdim txt txtend")
                if isRemote() == 1 and not RemoteHud then
                    ys = 75
                end
                newContent[#newContent + 1] = svgText( x1, ys, mfloor(spd).." km/h" , "pbright txtbig txtstart")
            end

            local function DrawWarnings(newContent)

                newContent[#newContent + 1] = svgText(ConvertResolutionX(1900), ConvertResolutionY(1070), stringf("ARCH Hud Version: %.3f", VERSION_NUMBER), "hudver")
                newContent[#newContent + 1] = [[<g class="warnings">]]
                if unit.isMouseControlActivated() == 1 then
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
                if BrakeIsOn then
                    newContent[#newContent + 1] = svgText(warningX, brakeY, "Brake Engaged", "warnings")

                elseif brakeInput2 > 0 then
                    newContent[#newContent + 1] = svgText(warningX, brakeY, "Auto-Brake Engaged", "warnings", "opacity:"..brakeInput2)
                end
                if inAtmo and stalling and abvGndDet == -1 then
                    if not Autopilot and not VectorToTarget and not BrakeLanding and not antigravOn and not VertTakeOff and not AutoTakeoff then
                        newContent[#newContent + 1] = svgText(warningX, apY+50, "** STALL WARNING **", "warnings")
                        play("stall","SW",2)
                    end
                end
                if ReversalIsOn then
                    newContent[#newContent + 1] = svgText(warningX, apY+90, "Flight Assist in Progress", "warnings")
                end

                if gyroIsOn then
                    newContent[#newContent + 1] = svgText(warningX, gyroY, "Gyro Enabled", "warnings")
                end
                if GearExtended then
                    if hasGear then
                        newContent[#newContent + 1] = svgText(warningX, gearY, "Gear Extended", "warn")
                    else
                        newContent[#newContent + 1] = svgText(warningX, gearY, "Landed (G: Takeoff)", "warnings")
                    end
                    local displayText = getDistanceDisplayString(Nav:getTargetGroundAltitude())
                    newContent[#newContent + 1] = svgText(warningX, hoverY,"Hover Height: ".. displayText,"warn")
                end
                if isBoosting then
                    newContent[#newContent + 1] = svgText(warningX, ewarpY+20, "ROCKET BOOST ENABLED", "warn")
                end                  
                if antigrav and not ExternalAGG and antigravOn and AntigravTargetAltitude ~= nil then
                    if mabs(coreAltitude - antigrav.getBaseAltitude()) < 501 then
                        newContent[#newContent + 1] = svgText(warningX, apY+15, stringf("AGG On - Target Altitude: %d Singularity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), "warn")
                    else
                        newContent[#newContent + 1] = svgText( warningX, apY+15, stringf("AGG On - Target Altitude: %d Singluarity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), "warnings")
                    end
                elseif Autopilot and AutopilotTargetName ~= "None" then
                    newContent[#newContent + 1] = svgText(warningX, apY+20,  "Autopilot "..AutopilotStatus, "warn")
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
                            newContent[#newContent + 1] = svgText( warningX, apY + 50,"Throttle Up and Disengage Brake For Takeoff", "crit")
                        end
                    else
                        newContent[#newContent + 1] = svgText(warningX, apY, "Altitude Hold: ".. displayText, "warn")
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
                        newContent[#newContent + 1] = svgText(warningX, apY, "Brake-Landing", "warnings")
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
                if collisionAlertStatus then
                    local type
                    if string.find(collisionAlertStatus, "COLLISION") then type = "warnings" else type = "crit" end
                    newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, collisionAlertStatus, type)
                elseif atmosDensity == 0 then
                    local intersectBody, atmoDistance = checkLOS((constructVelocity):normalize())
                    if atmoDistance ~= nil then
                        local displayText = getDistanceDisplayString(atmoDistance)
                        local travelTime = Kinematic.computeTravelTime(velMag, 0, atmoDistance)
                        local displayCollisionType = "Collision"
                        if intersectBody.noAtmosphericDensityAltitude > 0 then displayCollisionType = "Atmosphere" end
                        newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, intersectBody.name.." "..displayCollisionType.." "..FormatTimeString(travelTime).." In "..displayText, "crit")
                    end
                end
                if VectorToTarget and not IntoOrbit then
                    newContent[#newContent + 1] = svgText(warningX, apY+35, VectorStatus, "warn")
                end
            
                newContent[#newContent + 1] = "</g>"
                return newContent
            end

            local function getSpeedDisplayString(speed) -- TODO: Allow options, for now just do kph
                return mfloor(round(speed * 3.6, 0) + 0.5) .. " km/h" -- And generally it's not accurate enough to not twitch unless we round 0
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

                local function orbitInfo(type)
                    local alt, time, speed, line
                    if type == "Periapsis" then
                        alt = orbit.periapsis.altitude
                        time = orbit.timeToPeriapsis
                        speed = orbit.periapsis.speed
                        line = 35
                    else
                        alt = orbit.apoapsis.altitude
                        time = orbit.timeToApoapsis
                        speed = orbit.apoapsis.speed
                        line = -35
                    end
                    newContent[#newContent + 1] = stringf(
                        [[<line class="pdim op30 linethick" x1="%f" y1="%f" x2="%f" y2="%f"/>]],
                        x + line, y - 5, orbitMapX + orbitMapSize / 2 - rx + xOffset, y - 5)
                    newContent[#newContent + 1] = svgText(x, y, type)
                    y = y + orbitInfoYOffset
                    local displayText = getDistanceDisplayString(alt)
                    newContent[#newContent + 1] = svgText(x, y, displayText)
                    y = y + orbitInfoYOffset
                    newContent[#newContent + 1] = svgText(x, y, FormatTimeString(time))
                    y = y + orbitInfoYOffset
                    newContent[#newContent + 1] = svgText(x, y, getSpeedDisplayString(speed))
                end

                if orbit ~= nil and atmosDensity < 0.2 and planet ~= nil and orbit.apoapsis ~= nil and
                    orbit.periapsis ~= nil and orbit.period ~= nil and orbit.apoapsis.speed > 5 and DisplayOrbit then
                    -- If orbits are up, let's try drawing a mockup
                    
                    orbitMapY = orbitMapY + pad
                    x = orbitMapX + orbitMapSize + orbitMapX / 2 + pad
                    y = orbitMapY + orbitMapSize / 2 + 5 + pad
                    rx = orbitMapSize / 4
                    xOffset = 0
            
                    newContent[#newContent + 1] = [[<g class="pbright txtorb txtmid">]]
                    -- Draw a darkened box around it to keep it visible
                    newContent[#newContent + 1] = stringf(
                                                    '<rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" style="fill:rgb(0,0,100);stroke-width:4;stroke:white;fill-opacity:0.3;" />',
                                                    orbitMapSize + orbitMapX * 2, orbitMapSize + orbitMapY, pad, pad)
            
                    if orbit.periapsis ~= nil and orbit.apoapsis ~= nil then
                        scale = (orbit.apoapsis.altitude + orbit.periapsis.altitude + planet.radius * 2) / (rx * 2)
                        ry = (planet.radius + orbit.periapsis.altitude +
                                (orbit.apoapsis.altitude - orbit.periapsis.altitude) / 2) / scale *
                                (1 - orbit.eccentricity)
                        xOffset = rx - orbit.periapsis.altitude / scale - planet.radius / scale
            
                        local ellipseColor = ""
                        if orbit.periapsis.altitude <= 0 then
                            ellipseColor = 'redout'
                        end
                        newContent[#newContent + 1] = stringf(
                                                        [[<ellipse class="%s line" cx="%f" cy="%f" rx="%f" ry="%f"/>]],
                                                        ellipseColor, orbitMapX + orbitMapSize / 2 + xOffset + pad,
                                                        orbitMapY + orbitMapSize / 2 + pad, rx, ry)
                        newContent[#newContent + 1] = stringf(
                                                        '<circle cx="%f" cy="%f" r="%f" stroke="white" stroke-width="3" fill="blue" />',
                                                        orbitMapX + orbitMapSize / 2 + pad,
                                                        orbitMapY + orbitMapSize / 2 + pad, planet.radius / scale)
                    end
            
                    if orbit.apoapsis ~= nil and orbit.apoapsis.speed < MaxGameVelocity and orbit.apoapsis.speed > 1 then
                        orbitInfo("Apoapsis")
                    end
            
                    y = orbitMapY + orbitMapSize / 2 + 5 + pad
                    x = orbitMapX - orbitMapX / 2 + 10 + pad
            
                    if orbit.periapsis ~= nil and orbit.periapsis.speed < MaxGameVelocity and orbit.periapsis.speed > 1 then
                        orbitInfo("Periapsis")
                    end
            
                    -- Add a label for the planet
                    newContent[#newContent + 1] = svgText(orbitMapX + orbitMapSize / 2 + pad, planet.name, 20 + pad, "txtorbbig")
            
                    if orbit.period ~= nil and orbit.periapsis ~= nil and orbit.apoapsis ~= nil and orbit.apoapsis.speed > 1 then
                        local apsisRatio = (orbit.timeToApoapsis / orbit.period) * 2 * math.pi
                        -- x = xr * cos(t)
                        -- y = yr * sin(t)
                        local shipX = rx * math.cos(apsisRatio)
                        local shipY = ry * math.sin(apsisRatio)
            
                        newContent[#newContent + 1] = stringf(
                                                        '<circle cx="%f" cy="%f" r="5" stroke="white" stroke-width="3" fill="white" />',
                                                        orbitMapX + orbitMapSize / 2 + shipX + xOffset + pad,
                                                        orbitMapY + orbitMapSize / 2 + shipY + pad)
                    end
            
                    newContent[#newContent + 1] = [[</g>]]
                    -- Once we have all that, we should probably rotate the entire thing so that the ship is always at the bottom so you can see AP and PE move?
                    return newContent
                else
                    return newContent
                end
            end
          

            local function DisplayHelp(newContent)
                local x = 30
                local y = 275
                local help = {"Alt-1: Increment Interplanetary Helper", "Alt-2: Decrement Interplanetary Helper", "Alt-3: Toggle Vanilla Widget view"}
                local helpAtmo = { "", "------------------IN ATMO-----------------", "Alt-4: Autopilot in atmo to target", "Alt-4-4: Autopilot to LowOrbitHeight over atmosphere and orbit to target", 
                                    "Alt-6: Altitude hold at current altitude", "Alt-6-6: Altitude Hold at 11% atmosphere", "Alt-Q/E: Hard Bankroll left/right till released", "Alt-S: 180 deg bank turn"}
                local helpSpace = {"", "------------------NO ATMO-----------------", "Alt-4 (Alt < 100k): Autopilot to Orbit and land", "Alt-4 (Alt > 100k): Autopilot to target", "Alt-6: Orbit at current altitude",
                                    "Alt-6-6: Orbit at LowOrbitHeight over atmosphere"}
                local helpGeneral = {"", "------------------ALWAYS--------------------", "Alt-5: Lock Pitch at current pitch","Alt-7: Toggle Collision System on and offset", "Alt-8: Toggle ground stabilization (underwater flight)","Alt-9: Activate Gyroscope", 
                                    "", "CTRL: Toggle Brakes on and off, cancels active AP", "LeftAlt: Tap to shift freelook on and off", "Shift: Hold while not in freelook to see Buttons",
                                    "Type /commands or /help in lua chat to see text commands"}
                if inAtmo then 
                    addTable(help, helpAtmo)
                    table.insert(help, "--------------CONDITIONAL-----------------")
                    if VertTakeOff then
                        table.insert(help,"Hit Alt-6 before exiting Atmosphere during VTO to hold in level flight")
                    end
                    if abvGndDet ~= -1 then
                        if antigrav then
                            if antigravOn then
                                table.insert(help, "Alt-6: AGG is on, will takeoff to AGG Height")
                            else
                                table.insert(help,  "Turn on AGG to takeoff to AGG Height")
                            end
                        end
                        if VertTakeOffEngine then 
                            table.insert(help, "Alt-6: Begins Vertical Takeoff.")
                        else
                            table.insert(help, "Alt-4/Alt-6: Autotakeoff if below hoverheight")
                        end
                    else
                        table.insert(help,"G: Begin BrakeLanding or Land")
                    end
                else
                    addTable(help, helpSpace)
                end
                if AltitudeHold then 
                    table.insert(help, "Alt-Spacebar/Alt-C will raise/lower target height")
                end
                addTable(help, helpGeneral)
                for i = 1, #help do
                    y=y+12
                    newContent[#newContent + 1] = svgText( x, y, help[i], "pdim txttick txtstart")
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


        local Hud = {}

        function Hud.HUDPrologue(newContent)
            notPvPZone, pvpDist = safeZone(worldPos)
            if not notPvPZone then -- misnamed variable, fix later
                PrimaryR = PvPR
                PrimaryG = PvPG
                PrimaryB = PvPB
            else
                PrimaryR = SafeR
                PrimaryG = SafeG
                PrimaryB = SafeB
            end
            rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
            rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]    
            local bright = rgb
            local dim = rgbdim
            local brightOrig = rgb
            local dimOrig = rgbdim
            if IsInFreeLook() and not brightHud then
                bright = [[rgb(]] .. mfloor(PrimaryR * 0.4 + 0.5) .. "," .. mfloor(PrimaryG * 0.4 + 0.5) .. "," ..
                            mfloor(PrimaryB * 0.3 + 0.5) .. [[)]]
                dim = [[rgb(]] .. mfloor(PrimaryR * 0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," ..
                        mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]
            end
        
            -- When applying styles, apply color first, then type (e.g. "bright line")
            -- so that "fill:none" gets applied
        
            newContent[#newContent + 1] = stringf([[
                <head>
                    <style>
                        body {margin: 0}
                        svg {position:absolute;top:0;left:0;font-family:Montserrat;} 
                        .txt {font-size:10px;font-weight:bold;}
                        .txttick {font-size:12px;font-weight:bold;}
                        .txtbig {font-size:14px;font-weight:bold;}
                        .altsm {font-size:16px;font-weight:normal;}
                        .altbig {font-size:21px;font-weight:normal;}
                        .line {stroke-width:2px;fill:none}
                        .linethick {stroke-width:3px;fill:none}
                        .warnings {font-size:26px;fill:red;text-anchor:middle;font-family:Bank}
                        .warn {fill:orange;font-size:24px}
                        .crit {fill:darkred;font-size:28px}
                        .bright {fill:%s;stroke:%s}
                        .pbright {fill:%s;stroke:%s}
                        .dim {fill:%s;stroke:%s}
                        .pdim {fill:%s;stroke:%s}
                        .red {fill:red;stroke:red}
                        .orange {fill:orange;stroke:orange}
                        .redout {fill:none;stroke:red}
                        .op30 {opacity:0.3}
                        .op10 {opacity:0.1}
                        .txtstart {text-anchor:start}
                        .txtend {text-anchor:end}
                        .txtmid {text-anchor:middle}
                        .txtvspd {font-family:sans-serif;font-weight:normal}
                        .txtvspdval {font-size:20px}
                        .txtfuel {font-size:11px;font-weight:bold}
                        .txtorb {font-size:12px}
                        .txtorbbig {font-size:18px}
                        .hudver {font-size:10px;font-weight:bold;fill:red;text-anchor:end;font-family:Bank}
                        .msg {font-size:40px;fill:red;text-anchor:middle;font-weight:normal}
                        .cursor {stroke:white}
                    </style>
                </head>
                <body>
                    <svg height="100%%" width="100%%" viewBox="0 0 %d %d">
                    ]], bright, bright, brightOrig, brightOrig, dim, dim, dimOrig, dimOrig, resolutionWidth, resolutionHeight)
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
            local throt = mfloor(unit.getThrottle())
            local spd = velMag * 3.6
            local flightValue = unit.getAxisCommandValue(0)
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
        
            -- DAMAGE
        
            newContent[#newContent + 1] = damageMessage
        
            -- RADAR
        
            newContent[#newContent + 1] = radarMessage

            -- Pipe distance

            if pipeMessage ~= "" then newContent[#newContent +1] = pipeMessage end
        

            if tankMessage ~= "" then newContent[#newContent + 1] = tankMessage end
            if shieldMessage ~= "" then newContent[#newContent +1] = shieldMessage end
            -- PRIMARY FLIGHT INSTRUMENTS
        
            DrawVerticalSpeed(newContent, coreAltitude) -- Weird this is draw during remote control...?
        
        
            if isRemote() == 0 or RemoteHud then
                -- Don't even draw this in freelook
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

            if showHelp then DisplayHelp(newContent) end

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

            local brakeValue = 0
            local flightStyle = GetFlightStyle()
            if VertTakeOffEngine then flightStyle = flightStyle.."-VERTICAL" end
            if CollisionSystem and not AutoTakeoff and not BrakeLanding and velMag > 20 then flightStyle = flightStyle.."-COLLISION ON" end
            if UseExtra ~= "Off" then flightStyle = "("..UseExtra..")-"..flightStyle end
            if TurnBurn then flightStyle = "TB-"..flightStyle end
            if not stablized then flightStyle = flightStyle.."-DeCoupled" end

            local accel = (vec3(core.getWorldAcceleration()):len() / 9.80665)
            gravity =  core.g()
            newContent[#newContent + 1] = [[<g class="pdim txt txtend">]]
            if isRemote() == 1 and not RemoteHud then
                xg = ConvertResolutionX(1120)
                yg1 = ConvertResolutionY(55)
                yg2 = yg1+10
            elseif inAtmo then -- We only show atmo when not remote
                local atX = ConvertResolutionX(770)
                newContent[#newContent + 1] = svgText(atX, yg1, "ATMOSPHERE", "pdim txt txtend")
                newContent[#newContent + 1] = svgText( atX, yg2, stringf("%.2f", atmosDensity), "pdim txt txtend","")
            end
            newContent[#newContent + 1] = svgText(xg, yg1, "GRAVITY", "pdim txt txtend")
            newContent[#newContent + 1] = svgText(xg, yg2, stringf("%.2f", (gravity / 9.80665)), "pdim txt txtend")
            newContent[#newContent + 1] = svgText(xg, yg1 + 20, "ACCEL", "pdim txt txtend")
            newContent[#newContent + 1] = svgText(xg, yg2 + 20, stringf("%.2f", accel), "pdim txt txtend") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(180), flightStyle, "txtbig txtmid")
        end

        function Hud.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
            local gravity 
            local maxMass = 0
            local reqThrust = 0
            local brakeValue = 0
            local mass = coreMass > 1000000 and round(coreMass / 1000000,2).." kTons" or round(coreMass / 1000, 2).." Tons"
            if inAtmo then brakeValue = LastMaxBrakeInAtmo else brakeValue = LastMaxBrake end
            local brkDist, brkTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, brakeValue)
            brakeValue = round((brakeValue / (coreMass * gravConstant)),2).." g"
            local maxThrust = Nav:maxForceForward()
            gravity = core.g()
            if gravity > 0.1 then
                reqThrust = coreMass * gravity
                reqThrust = round((reqThrust / (coreMass * gravConstant)),2).." g"
                maxMass = 0.5 * maxThrust / gravity
                maxMass = maxMass > 1000000 and round(maxMass / 1000000,2).." kTons" or round(maxMass / 1000, 2).." Tons"
            end
            maxThrust = round((maxThrust / (coreMass * gravConstant)),2).." g"
            newContent[#newContent + 1] = stringf([[
                <g class="pbright txt">
                <path class="linethick" d="M %d 0 L %d %d Q %d %d %d %d L %d 0"/>]],
                ConvertResolutionX(660), ConvertResolutionX(700), ConvertResolutionY(35), ConvertResolutionX(960), ConvertResolutionY(55),
                ConvertResolutionX(1240), ConvertResolutionY(35), ConvertResolutionX(1280))
            if isRemote() == 0 or RemoteHud then 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(10), stringf("BrkTime: %s", FormatTimeString(brkTime)), "txtstart")
                newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(20), stringf("Trip: %.2f km", totalDistanceTrip), "txtstart") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(30), stringf("Lifetime: %.2f kSU", (TotalDistanceTravelled / 200000)), "txtstart") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(10), stringf("BrkDist: %s", getDistanceDisplayString(brkDist)) , "txtstart")
                newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(20), "Trip Time: "..FormatTimeString(flightTime), "txtstart") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(30), "Total Time: "..FormatTimeString(TotalFlightTime), "txtstart") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(20), stringf("Mass: %s", mass), "txtstart") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(10), stringf("Max Brake: %s",  brakeValue), "txtend") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(30), stringf("Max Thrust: %s", maxThrust), "txtend") 
                if gravity > 0.1 then
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(30), stringf("Max Thrust Mass: %s", (maxMass)), "txtstart")
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(20), stringf("Req Thrust: %s", reqThrust ), "txtend") 
                else
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(30), "Max Mass: n/a", "txtstart") 
                    newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(20), "Req Thrust: n/a", "txtend") 
                end
            end
            newContent[#newContent + 1] = "</g>"
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
                unit.setTimer("msgTick", msgTimer)
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
            if #settingsVariables > 0  then
                local x = ConvertResolutionX(640)
                local y = ConvertResolutionY(200)
                newContent[#newContent + 1] = [[<g class="pbright txtvspd txtstart">]]
                for k, v in pairs(settingsVariables) do
                    newContent[#newContent + 1] = svgText(x, y, v..": ".._G[v])
                    y = y + 20
                    if k%12 == 0 then
                        x = x + ConvertResolutionX(350)
                        y = ConvertResolutionY(200)
                    end
                end
                newContent[#newContent + 1] = svgText(ConvertResolutionX(640), ConvertResolutionY(200)+260, "To Change: In Lua Chat, enter /G VariableName Value")
                newContent[#newContent + 1] = "</g>"
            end
            return newContent
        end

            -- DrawRadarInfo() variables
            local perisPanelID
            local radarX = ConvertResolutionX(1770)
            local radarY = ConvertResolutionY(350)
            local friendy = ConvertResolutionY(15)
            local friendx = ConvertResolutionX(1370)
            local msg, where
            local peris = 0

        function Hud.DrawRadarInfo()
            local function ToggleRadarPanel()
                if radarPanelID ~= nil and peris == 0 then
                    sysDestWid(radarPanelID)
                    radarPanelID = nil
                    if perisPanelID ~= nil then
                        sysDestWid(perisPanelID)
                        perisPanelID = nil
                    end
                else
                    -- If radar is installed but no weapon, don't show periscope
                    if peris == 1 then
                        sysDestWid(radarPanelID)
                        radarPanelID = nil
                        _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_periscope", "Periscope"),
                            "periscope")
                        perisPanelID = _autoconf.panels[_autoconf.panels_size]
                    end
                    placeRadar = true
                    if radarPanelID == nil and placeRadar then
                        _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
                        radarPanelID = _autoconf.panels[_autoconf.panels_size]
                        placeRadar = false
                    end
                    peris = 0
                end
            end 
            local target, data, radarContacts, numKnown, static, friendlies = RADAR.GetRadarHud()
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
                        radarMessage = radarMessage..svgText(friendx, friendy, radar_1.getConstructName(v), "pdim txtmid")
                    end
                end
                if target == nil and perisPanelID == nil then
                    peris = 1
                    ToggleRadarPanel()
                end
                if target ~= nil and perisPanelID ~= nil then
                    ToggleRadarPanel()
                end
                if radarPanelID == nil then
                    ToggleRadarPanel()
                end
            else
                if data then
                    radarMessage = svgText(radarX, radarY, "Radar: Jammed", "pbright txtbig txtmid")
                else
                    radarMessage = svgText(radarX, radarY, "Radar: No Contacts", "pbright txtbig txtmid")
                end
                if radarPanelID ~= nil then
                    peris = 0
                    ToggleRadarPanel()
                end
            end
        end

        function Hud.DrawTanks()
            -- FUEL TANKS
            if (fuelX ~= 0 and fuelY ~= 0) then
                tankMessage = svgText(fuelX, fuelY, "", "txtstart pdim txtfuel")
                DrawTank( fuelX, "Atmospheric ", "ATMO", atmoTanks, fuelTimeLeft, fuelPercent)
                DrawTank( fuelX+120, "Space fuel t", "SPACE", spaceTanks, fuelTimeLeftS, fuelPercentS)
                DrawTank( fuelX+240, "Rocket fuel ", "ROCKET", rocketTanks, fuelTimeLeftR, fuelPercentR)
            end

        end

        function Hud.DrawShield()
            local shieldState = (shield_1.getState() == 1) and "Shield Active" or "Shield Disabled"
            local pvpTime = core.getPvPTimer()
            local x, y = shieldX -60, shieldY+30
            local shieldPercent = mfloor(0.5 + shield_1.getShieldHitPoints() * 100 / shield_1.getMaxShieldHitPoints())
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
        end

        return Hud
    end 
    local function AtlasClass() -- Atlas and Interplanetary functions including Update Autopilot Target

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
            
            local function findAtlasIndex(atlasList)
                for k, v in pairs(atlasList) do
                    if v.name and v.name == CustomTarget.name then
                        return k
                    end
                end
                return -1
            end

            local function UpdateAutopilotTarget()
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
                    AutopilotTargetOrbit = 1000
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
                if not Autopilot and not VectorToTarget and not spaceLaunch and not IntoOrbit then -- added to prevent crash when index == 0
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
                        if autopilotEntry ~= nil and autopilotEntry.name == "Space" or 
                           (iphCondition == "Custom Only" and autopilotEntry.center) or
                           (iphCondition == "No Moons" and string.find(autopilotEntry.name, "Moon") ~= nil)
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
                local index = -1
                index = findAtlasIndex(atlas[0])
                if index > -1 then
                    table.remove(atlas[0], index)
                end
                -- And SavedLocations
                index = -1
                index = findAtlasIndex(SavedLocations)
                if index ~= -1 then
                    msgText = CustomTarget.name .. " saved location cleared"
                    table.remove(SavedLocations, index)
                end
                adjustAutopilotTargetIndex()
                UpdateAtlasLocationsList()
            end
            
            local function AddNewLocation(name, position, temp, safe)
                if dbHud_1 or temp then
        
                    local p = getPlanet(position)
                    local gravity = p.gravity
                    local atmo = p.atmosphericDensityAboveSurface
                    if safe then
                        atmo = atmosDensity
                        gravity = unit.getClosestPlanetInfluence()
                    end
                    local newLocation = {
                        position = position,
                        name = name,
                        atmosphere = atmo,
                        planetname = p.name,
                        gravity = gravity,
                        safe = safe, -- This indicates we can extreme land here, if this was a real positional waypoint
                    }
                    if not temp then 
                        SavedLocations[#SavedLocations + 1] = newLocation
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
                else
                    msgText = "Databank must be installed to save permanent locations"
                end
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

        function Atlas.findAtlasIndex(atlasList)
            findAtlasIndex(atlasList)
        end

        function Atlas.UpdatePosition(newName) -- Update a saved location with new position
            local index = findAtlasIndex(SavedLocations)
            if index ~= -1 then
                if newName ~= nil then
                    SavedLocations[index].name = newName
                    AutopilotTargetIndex = AutopilotTargetIndex - 1
                    adjustAutopilotTargetIndex()
                else
                    local location = SavedLocations[index]
                    location.atmosphere = atmosDensity
                    location.gravity = unit.getClosestPlanetInfluence()
                    location.position = worldPos
                    location.safe = true
                end
                --UpdateAtlasLocationsList() -- Do we need these, if we only changed the name?  They are already done in AddNewLocation otherwise
                msgText = SavedLocations[index].name .. " position updated ("..SavedLocations[index].planetname..")"
                --UpdateAutopilotTarget()
            else
                msgText = "Name Not Found"
            end
        end

        function Atlas.AddNewLocation(name, position, temp, safe)
            AddNewLocation(name, position, temp, safe)
        end

        function Atlas.ClearCurrentPosition()
            ClearCurrentPosition()
        end

        --Initial Setup
        for k, v in pairs(SavedLocations) do
            table.insert(atlas[0], v)
        end

        UpdateAtlasLocationsList()

        Atlas.UpdateAutopilotTarget()

        return Atlas
    end
    local function APClass() -- Autopiloting functions including tick
        local ap = {}
            local function GetAutopilotBrakeDistanceAndTime(speed)
                -- If we're in atmo, just return some 0's or LastMaxBrake, whatever's bigger
                -- So we don't do unnecessary API calls when atmo brakes don't tell us what we want
                local finalSpeed = AutopilotEndSpeed
                if not Autopilot then  finalSpeed = 0 end
                if not inAtmo then
                    return Kinematic.computeDistanceAndTime(speed, finalSpeed, coreMass, 0, 0,
                        LastMaxBrake - (AutopilotPlanetGravity * coreMass))
                else
                    if LastMaxBrakeInAtmo and LastMaxBrakeInAtmo > 0 then
                        return Kinematic.computeDistanceAndTime(speed, finalSpeed, coreMass, 0, 0,
                                LastMaxBrakeInAtmo - (AutopilotPlanetGravity * coreMass))
                    else
                        return 0, 0
                    end
                end
            end

            local function GetAutopilotTBBrakeDistanceAndTime(speed)
                local finalSpeed = AutopilotEndSpeed
                if not Autopilot then finalSpeed = 0 end

                return Kinematic.computeDistanceAndTime(speed, finalSpeed, coreMass, Nav:maxForceForward(),
                        warmup, LastMaxBrake - (AutopilotPlanetGravity * coreMass))
            end
        local speedLimitBreaking = false
        function ap.GetAutopilotBrakeDistanceAndTime(speed)
            return GetAutopilotBrakeDistanceAndTime(speed)
        end

        function ap.GetAutopilotTBBrakeDistanceAndTime(speed)
            return GetAutopilotTBBrakeDistanceAndTime(speed)
        end

        -- Local Functions used in apTick

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
                        vgroundDistance = vBooster.distance()
                    end
                    if hover then
                        hgroundDistance = hover.distance()
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
                if telemeter_1 then 
                    groundDistance = telemeter_1.getDistance()
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
                    if targetplanet.bodyId == 0 then
                        return setmetatable({
                            latitude = worldVec.x,
                            longitude = worldVec.y,
                            altitude = worldVec.z,
                            bodyId = 0,
                            systemId = targetplanet.planetarySystemId
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
                        bodyId = targetplanet.bodyId,
                        systemId = targetplanet.planetarySystemId
                    }, MapPosition)
                end
                local waypoint = zeroConvertToMapPosition(planet, coordinates)
                waypoint = "::pos{"..waypoint.systemId..","..waypoint.bodyId..","..waypoint.latitude..","..waypoint.longitude..","..waypoint.altitude.."}"
                if dontSet then 
                    return waypoint
                else
                    system.setWaypoint(waypoint) 
                    return true
                end
            end
            local AutopilotPaused = false

        function ap.showWayPoint(planet, coordinates, dontSet)
            return showWaypoint(planet, coordinates, dontSet)
        end

        function ap.APTick()
            local function checkCollision()
                if collisionTarget and not BrakeLanding then
                    local body = collisionTarget[1]
                    local far, near = collisionTarget[2],collisionTarget[3] 
                    local collisionDistance = math.min(far, near or far)
                    local collisionTime = collisionDistance/velMag
                    local ignoreCollision = AutoTakeoff and (velMag < 42 or abvGndDet ~= -1)
                    local apAction = (AltitudeHold or VectorToTarget or LockPitch or Autopilot)
                    if apAction and not ignoreCollision and (brakeDistance*1.5 > collisionDistance or collisionTime < 1) then
                            BrakeIsOn = true
                            cmdThrottle(0)
                            if AltitudeHold then ToggleAltitudeHold() end
                            if LockPitch then ToggleLockPitch() end
                            msgText = "Autopilot Cancelled due to possible collision"
                            if VectorToTarget or Autopilot then 
                                ToggleAutopilot()
                            end
                            StrongBrakes = true
                            BrakeLanding = true
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
                    local yawAmount = -getMagnitudeInDirection(targetVec, core.getConstructWorldOrientationRight()) * autopilotStrength
                    local pitchAmount = -getMagnitudeInDirection(targetVec, core.getConstructWorldOrientationUp()) * autopilotStrength
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
                    if mabs(yawAmount) < tolerance and mabs(pitchAmount) < tolerance then
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
                    local yawAmount = -getMagnitudeInDirection(targetVec, core.getConstructWorldOrientationRight()) * autopilotStrength
                    local pitchAmount = -getMagnitudeInDirection(targetVec, core.getConstructWorldOrientationUp()) * autopilotStrength
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
                    if mabs(yawAmount) < tolerance and mabs(pitchAmount) < tolerance then
                        return true
                    end
                    return false
                end
            end
            inAtmo = (atmosphere() > 0)
            atmosDensity = atmosphere()
            coreAltitude = core.getAltitude()
            abvGndDet = AboveGroundLevel()
            time = systime()
            lastApTickTime = time


            if CollisionSystem then checkCollision() end

            if antigrav then
                antigravOn = (antigrav.getState() == 1)
            end
            
            local MousePitchFactor = 1 -- Mouse control only
            local MouseYawFactor = 1 -- Mouse control only
            local deltaTick = time - lastApTickTime
            local currentYaw = -math.deg(signedRotationAngle(constructUp, constructVelocity, constructForward))
            local currentPitch = math.deg(signedRotationAngle(constructRight, constructVelocity, constructForward)) -- Let's use a consistent func that uses global velocity
            local up = worldVertical * -1

            stalling = inAtmo and currentYaw < -YawStallAngle or currentYaw > YawStallAngle or currentPitch < -PitchStallAngle or currentPitch > PitchStallAngle
            local deltaX = system.getMouseDeltaX()
            local deltaY = system.getMouseDeltaY()

            if InvertMouse and not holdingCtrl then deltaY = -deltaY end
            yawInput2 = 0
            rollInput2 = 0
            pitchInput2 = 0
            sys = galaxyReference[0]
            planet = sys:closestBody(core.getConstructWorldPos())
            kepPlanet = Kep(planet)
            orbit = kepPlanet:orbitalParameters(core.getConstructWorldPos(), constructVelocity)
            if coreAltitude == 0 then
                coreAltitude = (worldPos - planet.center):len() - planet.radius
            end
            nearPlanet = unit.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000)

            local gravity = planet:getGravity(core.getConstructWorldPos()):len() * coreMass
            targetRoll = 0
            maxKinematicUp = core.getMaxKinematicsParametersAlongAxis("ground", core.getConstructOrientationUp())[1]

            if sysIsVwLock() == 0 then
                if isRemote() == 1 and holdingCtrl then
                    if not Animating then
                        simulatedX = simulatedX + deltaX
                        simulatedY = simulatedY + deltaY
                    end
                else
                    simulatedX = 0
                    simulatedY = 0 -- Reset after they do view things, and don't keep sending inputs while unlocked view
                    -- Except of course autopilot, which is later.
                end
            else
                simulatedX = simulatedX + deltaX
                simulatedY = simulatedY + deltaY
                distance = msqrt(simulatedX * simulatedX + simulatedY * simulatedY)
                if not holdingCtrl and isRemote() == 0 then -- Draw deadzone circle if it's navigating
                    if userControlScheme == "virtual joystick" then -- Virtual Joystick
                        -- Do navigation things

                        if simulatedX > 0 and simulatedX > DeadZone then
                            yawInput2 = yawInput2 - (simulatedX - DeadZone) * MouseXSensitivity
                        elseif simulatedX < 0 and simulatedX < (DeadZone * -1) then
                            yawInput2 = yawInput2 - (simulatedX + DeadZone) * MouseXSensitivity
                        else
                            yawInput2 = 0
                        end

                        if simulatedY > 0 and simulatedY > DeadZone then
                            pitchInput2 = pitchInput2 - (simulatedY - DeadZone) * MouseYSensitivity
                        elseif simulatedY < 0 and simulatedY < (DeadZone * -1) then
                            pitchInput2 = pitchInput2 - (simulatedY + DeadZone) * MouseYSensitivity
                        else
                            pitchInput2 = 0
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

            local isWarping = (velMag > 8334)

            if velMag > SpaceSpeedLimit/3.6 and not inAtmo and not Autopilot and not isWarping then
                msgText = "Space Speed Engine Shutoff reached"
                cmdThrottle(0)
            end

            if not isWarping and LastIsWarping then
                if not BrakeIsOn then
                    BrakeToggle()
                end
                if Autopilot then
                    ToggleAutopilot()
                end
            end
            LastIsWarping = isWarping

            if inAtmo and atmosDensity > 0.09 then
                if velMag > (adjustedAtmoSpeedLimit / 3.6) and not AtmoSpeedAssist and not speedLimitBreaking then
                        BrakeIsOn = true
                        speedLimitBreaking  = true
                elseif not AtmoSpeedAssist and speedLimitBreaking then
                    if velMag < (adjustedAtmoSpeedLimit / 3.6) then
                        BrakeIsOn = false
                        speedLimitBreaking = false
                    end
                end    
            end

            if BrakeIsOn then
                brakeInput = 1
            else
                brakeInput = 0
            end

            if ProgradeIsOn then
                if spaceLand then 
                    BrakeIsOn = false -- wtf how does this keep turning on, and why does it matter if we're in cruise?
                    local aligned = false
                    if CustomTarget ~= nil and spaceLand ~= 1 then
                        aligned = AlignToWorldVector(CustomTarget.position-worldPos,0.1) 
                    else
                        aligned = AlignToWorldVector(vec3(constructVelocity),0.01) 
                    end
                    autoRoll = true
                    if aligned then
                        cmdCruise(mfloor(adjustedAtmoSpeedLimit))
                        if (mabs(adjustedRoll) < 2 or mabs(adjustedPitch) > 85) and velMag >= adjustedAtmoSpeedLimit/3.6-1 then
                            -- Try to force it to get full speed toward target, so it goes straight to throttle and all is well
                            BrakeIsOn = false
                            ProgradeIsOn = false
                            reentryMode = true
                            if spaceLand ~= 1 then finalLand = true end
                            spaceLand = false
                            Autopilot = false
                            --autoRoll = autoRollPreference   
                            BeginReentry()
                        end
                    elseif inAtmo and AtmoSpeedAssist then 
                        cmdThrottle(1) -- Just let them full throttle if they're in atmo
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
                if atmosDensity == 0 then 
                    reentryMode = true
                    BeginReentry()
                    spaceLand = false
                    finalLand = true
                else
                    spaceLand = false
                    ToggleAutopilot()
                end
            end

            if finalLand and CustomTarget ~= nil and (coreAltitude < (HoldAltitude + 250) and coreAltitude > (HoldAltitude - 250)) and ((velMag*3.6) > (adjustedAtmoSpeedLimit-250)) and mabs(vSpd) < 25 and atmosDensity >= 0.1
                and (CustomTarget.position-worldPos):len() > 2000 + coreAltitude then -- Only engage if far enough away to be able to turn back for it
                    ToggleAutopilot()
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
                        BrakeIsOn = true
                        upAmount = 0
                    elseif vSpd < -30 then
                        BrakeIsOn = true
                        upAmount = 15
                    elseif coreAltitude >= targetAltitude then
                        if antigravOn then 
                            if Autopilot or VectorToTarget then
                                ToggleVerticalTakeoff()

                            else
                                BrakeIsOn = true
                                VertTakeOff = false
                            end
                            msgText = "Takeoff complete. Singularity engaged"
                            play("aggLk","AG")
                        else
                            BrakeIsOn = false
                            msgText = "VTO complete. Engaging Horizontal Flight"
                            play("vtoc", "VT")
                            ToggleVerticalTakeoff()
                        end
                        upAmount = 0
                    end
                else
                    if atmosDensity > 0.08 then
                        VtPitch = 0
                        BrakeIsOn = false
                        upAmount = 20
                    elseif atmosDensity < 0.08 and atmosDensity > 0 then
                        BrakeIsOn = false
                        if SpaceEngineVertDn then
                            VtPitch = 0
                            upAmount = 20
                        else
                            upAmount = 0
                            VtPitch = 36
                            cmdCruise(3500)
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

                if orbitalParams.VectorToTarget then
                    targetVec = CustomTarget.position - worldPos
                end
                local escapeVel, endSpeed = Kep(OrbitTargetPlanet):escapeAndOrbitalSpeed((worldPos -OrbitTargetPlanet.center):len()-OrbitTargetPlanet.radius)
                local orbitalRoll = adjustedRoll
                -- Getting as close to orbit distance as comfortably possible
                if not orbitAligned then
                    local pitchAligned = false
                    local rollAligned = false

                    cmdThrottle(0)
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
                    if adjustedPitch <= orbitPitch+1 and adjustedPitch >= orbitPitch-1 then
                        pitchAligned = true
                    else
                        pitchAligned = false
                    end
                    if orbitalRoll <= orbitRoll+1 and orbitalRoll >= orbitRoll-1 then
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
                    if orbitalParams.VectorToTarget then
                        -- Orbit to target...

                        local brakeDistance, _ =  Kinematic.computeDistanceAndTime(velMag, adjustedAtmoSpeedLimit/3.6, coreMass, 0, 0, LastMaxBrake)
                        if OrbitAchieved and targetVec:len() > 15000+brakeDistance+coreAltitude then -- Triggers when we get close to passing it or within 15km+height I guess
                            orbitMsg = "Orbiting to Target"
                            if (coreAltitude - 100) <= OrbitTargetPlanet.noAtmosphericDensityAltitude or  (travelTime> orbit.timeToPeriapsis and  orbit.periapsis.altitude  < OrbitTargetPlanet.noAtmosphericDensityAltitude) then 
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
                            ToggleIntoOrbit()
                            BeginReentry()
                        end
                    end
                    if orbit.periapsis ~= nil and orbit.apoapsis ~= nil and orbit.eccentricity < 1 and coreAltitude > OrbitTargetOrbit*0.9 and coreAltitude < OrbitTargetOrbit*1.4 then
                        if orbit.apoapsis ~= nil then
                            if (orbit.periapsis.altitude >= OrbitTargetOrbit*0.99 and orbit.apoapsis.altitude >= OrbitTargetOrbit*0.99 and 
                                orbit.periapsis.altitude < orbit.apoapsis.altitude and orbit.periapsis.altitude*1.05 >= orbit.apoapsis.altitude) or OrbitAchieved then -- This should get us a stable orbit within 10% with the way we do it
                                if OrbitAchieved then
                                    BrakeIsOn = false
                                    cmdThrottle(0)
                                    orbitPitch = 0
                                    
                                    if not orbitalParams.VectorToTarget then
                                        msgText = "Orbit complete"
                                        play("orCom", "OB")
                                        ToggleIntoOrbit()
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
                                cmdCruise(endSpeed*3.6+1)
                                -- And set pitch to something that scales with vSpd
                                -- Well, a pid is made for this stuff
                                if (VSpdPID == nil) then
                                    VSpdPID = pid.new(0.5, 0, 10 * 0.1) -- Has to stay low at base to avoid overshoot
                                end
                                local speedToInject = vSpd
                                local altdiff = coreAltitude - OrbitTargetOrbit
                                local absAltdiff = mabs(altdiff)
                                if vSpd < 10 and mabs(adjustedPitch) < 10 and absAltdiff < 100 then
                                    speedToInject = vSpd*2 -- Force it to converge when it's close
                                end
                                if speedToInject < 10 and mabs(adjustedPitch) < 10 and absAltdiff < 100 then -- And do it again when it's even closer
                                    speedToInject = speedToInject*2
                                end
                                -- I really hate this, but, it really needs it still/again... 
                                if speedToInject < 5 and mabs(adjustedPitch) < 5 and absAltdiff < 100 then -- And do it again when it's even closer
                                    speedToInject = speedToInject*4
                                end
                                -- TBH these might not be super necessary anymore after changes, might can remove at least one, but two tends to make everything smoother
                                VSpdPID:inject(speedToInject)
                                orbitPitch = uclamp(-VSpdPID:get(),-90,90)
                                -- Also, add pitch to try to adjust us to our correct altitude
                                -- Dammit, that's another PID I guess... I don't want another PID... 
                                if (OrbitAltPID == nil) then
                                    OrbitAltPID = pid.new(0.15, 0, 5 * 0.1)
                                end
                                OrbitAltPID:inject(altdiff) -- We clamp this to max 15 degrees so it doesn't screw us too hard
                                -- And this will fight with the other PID to keep vspd reasonable
                                orbitPitch = uclamp(orbitPitch - uclamp(OrbitAltPID:get(),-15,15),-90,90)
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
                        cmdCruise(mfloor(pcs))
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

            if Autopilot and atmosDensity == 0 and not spaceLand then
                local function finishAutopilot(msg, orbit)
                    system.print(msg)
                    BrakeIsOn = false
                    AutopilotBraking = false
                    Autopilot = false
                    TargetSet = false
                    AutopilotStatus = "Aligning" -- Disable autopilot and reset
                    cmdThrottle(0)
                    apThrottleSet = false
                    msgText = msg
                    play("apCom","AP")
                    if orbit or spaceLand then
                        if orbit and AutopilotTargetOrbit ~= nil and not spaceLand then 
                            if not coreAltitude or coreAltitude == 0 then return end
                            OrbitTargetOrbit = coreAltitude
                            OrbitTargetSet = true
                        end
                        ToggleIntoOrbit()
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
                if CustomTarget ~= nil and CustomTarget.planetname ~= "Space" then
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
                elseif CustomTarget ~= nil and CustomTarget.planetname == "Space" then
                    AutopilotPlanetGravity = 0
                    skipAlign = true
                    TargetSet = true
                    AutopilotRealigned = true
                    targetCoords = CustomTarget.position + (worldPos - CustomTarget.position)*AutopilotTargetOrbit
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
                local intersectBody, farSide, nearSide = galaxyReference:getPlanetarySystem(0):castIntersections(worldPos, (constructVelocity):normalize(), function(body) if body.noAtmosphericDensityAltitude > 0 then return (body.radius+body.noAtmosphericDensityAltitude) else return (body.radius+body.surfaceMaxAltitude*1.5) end end)
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
                --    displayText.. '", "unit":"' .. displayUnit .. '"}')
                local aligned = true -- It shouldn't be used if the following condition isn't met, but just in case

                local projectedAltitude = (autopilotTargetPlanet.center -
                                            (worldPos +
                                                (vec3(constructVelocity):normalize() * AutopilotDistance))):len() -
                                            autopilotTargetPlanet.radius
                local displayText = getDistanceDisplayString(projectedAltitude)
                sysUpData(widgetTrajectoryAltitudeText, '{"label": "Projected Altitude", "value": "' ..
                    displayText.. '"}')
                

                local brakeDistance, brakeTime
                
                if not TurnBurn then
                    brakeDistance, brakeTime = GetAutopilotBrakeDistanceAndTime(velMag)
                else
                    brakeDistance, brakeTime = GetAutopilotTBBrakeDistanceAndTime(velMag)
                end

                --orbit.apoapsis == nil and 
                if velMag > 300 and AutopilotAccelerating then
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
                    
                end

                if projectedAltitude < AutopilotTargetOrbit*1.5 then
                    -- Recalc end speeds for the projectedAltitude since it's reasonable... 
                    if CustomTarget ~= nil and CustomTarget.planetname == "Space" then 
                        AutopilotEndSpeed = 0
                    elseif CustomTarget == nil then
                        _, AutopilotEndSpeed = Kep(autopilotTargetPlanet):escapeAndOrbitalSpeed(projectedAltitude)
                    end
                end
                if Autopilot and not AutopilotAccelerating and not AutopilotCruising and not AutopilotBraking then
                    local intersectBody, atmoDistance = checkLOS( (AutopilotTargetCoords-worldPos):normalize())
                    if autopilotTargetPlanet.name ~= planet.name then 
                        if intersectBody ~= nil and autopilotTargetPlanet.name ~= intersectBody.name then 
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
                        cmdThrottle(AutopilotInterplanetaryThrottle)
                        PlayerThrottle = round(AutopilotInterplanetaryThrottle,2)
                        apThrottleSet = true
                    end
                    local throttle = unit.getThrottle()
                    if AtmoSpeedAssist then throttle = PlayerThrottle end
                    if (coreVelocity:len() >= MaxGameVelocity or (throttle == 0 and apThrottleSet)) then
                        AutopilotAccelerating = false
                        if AutopilotStatus ~= "Cruising" then
                            play("apCru","AP")
                            AutopilotStatus = "Cruising"
                        end
                        AutopilotCruising = true
                        cmdThrottle(0)
                        --apThrottleSet = false -- We already did it, if they cancelled let them throttle up again
                    end
                    -- Check if accel needs to stop for braking
                    --if brakeForceRequired >= LastMaxBrake then
                    if AutopilotDistance <= brakeDistance then
                        AutopilotAccelerating = false
                        if AutopilotStatus ~= "Braking" then
                            play("apBrk","AP")
                            AutopilotStatus = "Braking"
                        end
                        AutopilotBraking = true
                        cmdThrottle(0)
                        apThrottleSet = false
                    end
                elseif AutopilotBraking then
                    if AutopilotStatus ~= "Orbiting to Target" then
                        BrakeIsOn = true
                        brakeInput = 1
                    end
                    if TurnBurn then
                        cmdThrottle(1,true) -- This stays 100 to not mess up our calculations
                    end
                    -- Check if an orbit has been established and cut brakes and disable autopilot if so

                    -- We'll try <0.9 instead of <1 so that we don't end up in a barely-orbit where touching the controls will make it an escape orbit
                    -- Though we could probably keep going until it starts getting more eccentric, so we'd maybe have a circular orbit
                    local _, endSpeed = Kep(autopilotTargetPlanet):escapeAndOrbitalSpeed((worldPos-planet.center):len()-planet.radius)
                    

                    local targetVec--, targetAltitude, --horizontalDistance
                    if CustomTarget ~= nil then
                        targetVec = CustomTarget.position - worldPos
                        --targetAltitude = planet:getAltitude(CustomTarget.position)
                        --horizontalDistance = msqrt(targetVec:len()^2-(coreAltitude-targetAltitude)^2)
                    end
                    if (CustomTarget ~=nil and CustomTarget.planetname == "Space" and velMag < 50) then
                        finishAutopilot("Autopilot complete, arrived at space location")
                        BrakeIsOn = true
                        brakeInput = 1
                        -- We only aim for endSpeed even if going straight in, because it gives us a smoother transition to alignment
                    elseif (CustomTarget ~= nil and CustomTarget.planetname ~= "Space") and velMag <= endSpeed and (orbit.apoapsis == nil or orbit.periapsis == nil or orbit.apoapsis.altitude <= 0 or orbit.periapsis.altitude <= 0) then
                        -- They aren't in orbit, that's a problem if we wanted to do anything other than reenter.  Reenter regardless.                  
                        finishAutopilot("Autopilot complete, commencing reentry")
                        --BrakeIsOn = true
                        --BrakeIsOn = false -- Leave brakes on to be safe while we align prograde
                        AutopilotTargetCoords = CustomTarget.position -- For setting the waypoint
                        --ProgradeIsOn = true  
                        spaceLand = true
                        AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords)
                    elseif orbit.periapsis ~= nil and orbit.periapsis.altitude > 0 and orbit.eccentricity < 1 or AutopilotStatus == "Circularizing" then
                        if AutopilotStatus ~= "Circularizing" then
                            play("apCir", "AP")
                            AutopilotStatus = "Circularizing"
                        end
                        if velMag <= endSpeed then 
                            if CustomTarget ~= nil then
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
                                brakeInput = 0
                            end
                        end
                    elseif AutopilotStatus == "Circularizing" then
                        finishAutopilot("Autopilot complete, fixing Orbit", true)
                    end
                elseif AutopilotCruising then
                    --if brakeForceRequired >= LastMaxBrake then
                    if AutopilotDistance <= brakeDistance then
                        AutopilotAccelerating = false
                        if AutopilotStatus ~= "Braking" then
                            play("apBrk","AP")
                            AutopilotStatus = "Braking"
                        end
                        AutopilotBraking = true
                    end
                    local throttle = unit.getThrottle()
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
                        if not AutopilotRealigned and CustomTarget == nil or (not AutopilotRealigned and CustomTarget ~= nil and CustomTarget.planetname ~= "Space") then
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
                                    cmdThrottle(AutopilotInterplanetaryThrottle, true)
                                    PlayerThrottle = round(AutopilotInterplanetaryThrottle,2)
                                    apThrottleSet = true
                                    BrakeIsOn = false
                                end
                        end
                    end
                    -- If it's not aligned yet, don't try to burn yet.
                end
                -- If we accidentally hit atmo while autopiloting to a custom target, cancel it and go straight to pulling up
            elseif Autopilot and (CustomTarget ~= nil and CustomTarget.planetname ~= "Space" and atmosDensity > 0) then
                msgText = "Autopilot complete, starting reentry"
                play("apCom", "AP")
                AutopilotTargetCoords = CustomTarget.position -- For setting the waypoint
                BrakeIsOn = false -- Leaving these on makes it screw up alignment...?
                AutopilotBraking = false
                Autopilot = false
                TargetSet = false
                AutopilotStatus = "Aligning" -- Disable autopilot and reset
                brakeInput = 0
                cmdThrottle(0)
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
                local pos = worldPos + vec3(unit.getMasterPlayerRelativePosition()) -- Is this related to core forward or nah?
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
                    BrakeIsOn = true
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
                if atmosDensity < 0.01 then
                    curBrake = LastMaxBrake -- Assume space brakes
                end


                local airFrictionVec = vec3(core.getWorldAirFrictionAcceleration())
                local airFriction = msqrt(airFrictionVec:len() - airFrictionVec:project_on(up):len()) * coreMass
                -- Assume it will halve over our duration, if not sqrt.  We'll try sqrt because it's underestimating atm
                -- First calculate stopping to 100 - that all happens with full brake power
                if velMag > 100 then 
                    brakeDistance, brakeTime = Kinematic.computeDistanceAndTime(velMag, 100, coreMass, 0, 0,
                                                    curBrake + airFriction)
                    -- Then add in stopping from 100 to 0 at what averages to half brake power.  Assume no friction for this
                    local lastDist, brakeTime2 = Kinematic.computeDistanceAndTime(100, 0, coreMass, 0, 0, curBrake/2)
                    brakeDistance = brakeDistance + lastDist
                else -- Just calculate it regularly assuming the value will be halved while we do it, assuming no friction
                    brakeDistance, brakeTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, curBrake/2)
                end
                -- HoldAltitude is the alt we want to hold at

                -- Dampen this.
                local altDiff = HoldAltitude - coreAltitude
                -- This may be better to smooth evenly regardless of HoldAltitude.  Let's say, 2km scaling?  Should be very smooth for atmo
                -- Even better if we smooth based on their velocity
                local minmax = 500 + velMag
                -- Smooth the takeoffs with a velMag multiplier that scales up to 100m/s
                local velMultiplier = 1
                if AutoTakeoff then velMultiplier = uclamp(velMag/100,0.1,1) end
                local targetPitch = (utils.smoothstep(altDiff, -minmax, minmax) - 0.5) * 2 * MaxPitch * velMultiplier

                            -- atmosDensity == 0 and
                if not Reentry and not spaceLand and not VectorToTarget and constructForward:dot(constructVelocity:normalize()) < 0.99 then
                    -- Widen it up and go much harder based on atmo level
                    -- Scaled in a way that no change up to 10% atmo, then from 10% to 0% scales to *20 and *2
                    targetPitch = (utils.smoothstep(altDiff, -minmax*uclamp(20 - 19*atmosDensity*10,1,20), minmax*uclamp(20 - 19*atmosDensity*10,1,20)) - 0.5) * 2 * MaxPitch * uclamp(2 - atmosDensity*10,1,2) * velMultiplier
                    --if coreAltitude > HoldAltitude and targetPitch == -85 then
                    --    BrakeIsOn = true
                    --else
                    --    BrakeIsOn = false
                    --end
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
                            cmdThrottle(1)
                        end
                    elseif throttleMode and not freeFallHeight and not inAtmo then 
                        cmdCruise(ReentrySpeed, true) 
                    end
                    if throttleMode then
                        if velMag > ReentrySpeed/3.6 and not freeFallHeight then
                            BrakeIsOn = true
                        else
                            BrakeIsOn = false
                        end
                    else
                        BrakeIsOn = false
                    end
                    if vSpd > 0 then BrakeIsOn = true end
                    if not reentryMode then
                        targetPitch = -80
                        if atmosDensity > 0.02 then
                            msgText = "PARACHUTE DEPLOYED"
                            Reentry = false
                            BrakeLanding = true
                            targetPitch = 0
                            autoRoll = autoRollPreference
                        end
                    elseif planet.noAtmosphericDensityAltitude > 0 and freeFallHeight then -- 5km is good

                        autoRoll = true -- It shouldn't actually do it, except while aligning
                    elseif not freeFallHeight then
                        if not inAtmo and (throttleMode or navCom:getTargetSpeed(axisCommandId.longitudinal) ~= ReentrySpeed) then 
                            cmdCruise(ReentrySpeed)
                        end
                        if velMag < ((ReentrySpeed/3.6)+1) then
                            BrakeIsOn = false
                            reentryMode = false
                            Reentry = false
                            autoRoll = true 
                        end
                    end
                end

                if velMag > minAutopilotSpeed and not spaceLaunch and not VectorToTarget and not BrakeLanding and ForceAlignment then -- When do we even need this, just alt hold? lol
                    AlignToWorldVector(vec3(constructVelocity))
                end
                if ReversalIsOn or ((VectorToTarget or spaceLaunch) and AutopilotTargetIndex > 0 and atmosDensity > 0.01) then
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
                    if velMag > minRollVelocity and atmosDensity > 0.01 then
                        local maxRoll = uclamp(90-targetPitch*2,-90,90) -- No downwards roll allowed? :( 
                        targetRoll = uclamp(targetYaw*2, -maxRoll, maxRoll)
                        local origTargetYaw = targetYaw
                        -- 4x weight to pitch consideration because yaw is often very weak compared and the pid needs help?
                        targetYaw = uclamp(uclamp(targetYaw,-YawStallAngle*0.80,YawStallAngle*0.80)*math.cos(rollRad) + 4*(adjustedPitch-targetPitch)*math.sin(math.rad(adjustedRoll)),-YawStallAngle*0.80,YawStallAngle*0.80) -- We don't want any yaw if we're rolled
                        targetPitch = uclamp(uclamp(targetPitch*math.cos(rollRad),-PitchStallAngle*0.80,PitchStallAngle*0.80) + mabs(uclamp(mabs(origTargetYaw)*math.sin(rollRad),-PitchStallAngle*0.80,PitchStallAngle*0.80)),-PitchStallAngle*0.80,PitchStallAngle*0.80) -- Always yaw positive 
                    else
                        targetRoll = 0
                        targetYaw = uclamp(targetYaw,-YawStallAngle*0.80,YawStallAngle*0.80)
                    end


                    local yawDiff = currentYaw-targetYaw

                    if ReversalIsOn and mabs(yawDiff) <= 0.0001 and
                                        ((type(ReversalIsOn) == "table") or 
                                         (type(ReversalIsOn) ~= "table" and ReversalIsOn < 0 and mabs(adjustedRoll) < 1)) then
                        if ReversalIsOn == -2 then ToggleAltitudeHold() end
                        ReversalIsOn = nil
                        play("180Off", "BR")
                        return
                    end

                    if not stalling and velMag > minRollVelocity and atmosDensity > 0.01 then
                        if (yawPID == nil) then
                            yawPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                        end
                        yawPID:inject(yawDiff)
                        local autoYawInput = uclamp(yawPID:get(),-1,1) -- Keep it reasonable so player can override
                        yawInput2 = yawInput2 + autoYawInput
                    elseif (inAtmo and abvGndDet > -1 or velMag < minRollVelocity) then

                        AlignToWorldVector(targetVec) -- Point to the target if on the ground and 'stalled'
                    elseif stalling and atmosDensity > 0.01 then
                        -- Do this if we're yaw stalling
                        if (currentYaw < -YawStallAngle or currentYaw > YawStallAngle) and atmosDensity > 0.01 then
                            AlignToWorldVector(constructVelocity) -- Otherwise try to pull out of the stall, and let it pitch into it
                        end
                        -- Only do this if we're stalled for pitch
                        if (currentPitch < -PitchStallAngle or currentPitch > PitchStallAngle) and atmosDensity > 0.01 then
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
                        local distanceToTarget = msqrt(targetVec:len()^2-(coreAltitude-targetAltitude)^2)

                        --local targetPosAtAltitude = CustomTarget.position + worldVertical*(coreAltitude - targetAltitude) - planet.center
                        --local worldPosPlanetary = worldPos - planet.center
                        --local distanceToTarget = (planet.radius+coreAltitude) * math.atan(worldPosPlanetary:cross(targetPosAtAltitude):len(), worldPosPlanetary:dot(targetPosAtAltitude))

                        local hSpd = constructVelocity:len() - mabs(vSpd)
                    
                        --StrongBrakes = ((planet.gravity * 9.80665 * coreMass) < LastMaxBrakeInAtmo)
                        StrongBrakes = true -- We don't care about this or glide landing anymore and idk where all it gets used
                        
                        -- Fudge it with the distance we'll travel in a tick - or half that and the next tick accounts for the other? idk
                        if (not spaceLaunch and not Reentry and distanceToTarget <= brakeDistance + (velMag*deltaTick)/2 and 
                                (constructVelocity:project_on_plane(worldVertical):normalize():dot(targetVec:project_on_plane(worldVertical):normalize()) > 0.99  or VectorStatus == "Finalizing Approach")) then 
                            VectorStatus = "Finalizing Approach" 
                            cmdThrottle(0) -- Kill throttle in case they weren't in cruise
                            if AltitudeHold then
                                -- if not OrbitAchieved then
                                    ToggleAltitudeHold() -- Don't need this anymore
                                -- end
                                VectorToTarget = true -- But keep this on
                            end
                            BrakeIsOn = true
                        elseif not AutoTakeoff then
                            BrakeIsOn = false
                        end
                        if (VectorStatus == "Finalizing Approach" and (hSpd < 0.1 or distanceToTarget < 0.1 or (LastDistanceToTarget ~= nil and LastDistanceToTarget < distanceToTarget))) then
                            if not antigravOn then  
                                play("bklOn","BL")
                                BrakeLanding = true 
                            end
                            VectorToTarget = false
                            VectorStatus = "Proceeding to Waypoint"
                            collisionAlertStatus = false
                        end
                        LastDistanceToTarget = distanceToTarget
                    end
                elseif VectorToTarget and atmosDensity == 0 and HoldAltitude > planet.noAtmosphericDensityAltitude and not (spaceLaunch or Reentry) then
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
                                    BeginReentry()
                                end
                            end
                            LastDistanceToTarget = distanceToTarget
                        end
                    end
                end

                -- Altitude hold and AutoTakeoff orbiting
                if atmosDensity == 0 and (AltitudeHold and HoldAltitude > planet.noAtmosphericDensityAltitude) and not (spaceLaunch or IntoOrbit or Reentry ) then
                    if not OrbitAchieved and not IntoOrbit then
                        OrbitTargetOrbit = HoldAltitude -- If AP/VectorToTarget, AP already set this.  
                        OrbitTargetSet = true
                        if VectorToTarget then orbitalParams.VectorToTarget = true end
                        ToggleIntoOrbit() -- Should turn off alt hold
                        VectorToTarget = false -- WTF this gets stuck on? 
                        orbitAligned = true
                    end
                end

                if stalling and atmosDensity > 0.01 and abvGndDet == -1 and velMag > minRollVelocity and VectorStatus ~= "Finalizing Approach" then
                    AlignToWorldVector(constructVelocity) -- Otherwise try to pull out of the stall, and let it pitch into it
                    targetPitch = uclamp(adjustedPitch-currentPitch,adjustedPitch - PitchStallAngle*0.80, adjustedPitch + PitchStallAngle*0.80) -- Just try to get within un-stalling range to not bounce too much
                end


                pitchInput2 = oldInput
                local groundDistance = -1

                if BrakeLanding then
                    targetPitch = 0

                    local skipLandingRate = false
                    local distanceToStop = 30 
                    if maxKinematicUp ~= nil and maxKinematicUp > 0 then

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
                            local knownAltitude = (CustomTarget ~= nil and planet:getAltitude(CustomTarget.position) > 0 and CustomTarget.safe)
                            
                            if knownAltitude then
                                local targetAltitude = planet:getAltitude(CustomTarget.position)
                                local distanceToGround = coreAltitude - targetAltitude - 100 -- Try to aim for like 100m above the ground, give it lots of time
                                -- We don't have to squeeze out the little bits of performance
                                local targetVec = CustomTarget.position - worldPos
                                local horizontalDistance = msqrt(targetVec:len()^2-(coreAltitude-targetAltitude)^2)

                                if horizontalDistance > 100 then
                                    -- We are too far off, don't trust our altitude data
                                    knownAltitude = false
                                elseif distanceToGround <= stopDistance or stopDistance == -1 then
                                    BrakeIsOn = true
                                    skipLandingRate = true
                                else
                                    BrakeIsOn = false
                                    skipLandingRate = true
                                end
                            end
                            
                            if not knownAltitude and CalculateBrakeLandingSpeed then
                                if stopDistance >= distanceToStop then -- 10% padding
                                    BrakeIsOn = true
                                else
                                    BrakeIsOn = false
                                end
                                skipLandingRate = true
                            end
                        end
                    end
                    if not throttleMode then
                        cmdThrottle(0)
                    end
                    navCom:setTargetGroundAltitude(500)
                    navCom:activateGroundEngineAltitudeStabilization(500)
                    stablized = true

                    groundDistance = abvGndDet
                    if groundDistance > -1 then 
                            autoRoll = autoRollPreference                
                            if velMag < 1 or constructVelocity:normalize():dot(worldVertical) < 0 then -- Or if they start going back up
                                BrakeLanding = false
                                AltitudeHold = false
                                GearExtended = true
                                if hasGear then
                                    Nav.control.extendLandingGears()
                                    play("grOut","LG",1)
                                end
                                navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                                upAmount = 0
                                BrakeIsOn = true
                            else
                                BrakeIsOn = true
                            end
                    elseif StrongBrakes and (constructVelocity:normalize():dot(-up) < 0.999) then
                        BrakeIsOn = true
                    elseif vSpd < -brakeLandingRate and not skipLandingRate then
                        BrakeIsOn = true
                    elseif not skipLandingRate then
                        BrakeIsOn = false
                    end
                end
                if AutoTakeoff or spaceLaunch then
                    local intersectBody, nearSide, farSide
                    if AutopilotTargetCoords ~= nil then
                        intersectBody, nearSide, farSide = galaxyReference:getPlanetarySystem(0):castIntersections(worldPos, (AutopilotTargetCoords-worldPos):normalize(), function(body) return (body.radius+body.noAtmosphericDensityAltitude) end)
                    end
                    if antigravOn then
                        if coreAltitude >= (HoldAltitude-50) then
                            AutoTakeoff = false
                            if not Autopilot and not VectorToTarget then
                                BrakeIsOn = true
                                cmdThrottle(0)
                            end
                        else
                            HoldAltitude = antigrav.getBaseAltitude()
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
                            cmdThrottle(0)
                        elseif spaceLaunch then
                            cmdThrottle(0)
                            BrakeIsOn = true
                        end --coreAltitude > 75000
                    elseif spaceLaunch and atmosDensity == 0 and autopilotTargetPlanet ~= nil and (intersectBody == nil or intersectBody.name == autopilotTargetPlanet.name) then
                        Autopilot = true
                        spaceLaunch = false
                        AltitudeHold = false
                        AutoTakeoff = false
                        if not throttleMode then
                            cmdThrottle(0)
                        end
                        AutopilotAccelerating = true -- Skip alignment and don't warm down the engines
                    end
                end
                -- Copied from autoroll let's hope this is how a PID works... 
                -- Don't pitch if there is significant roll, or if there is stall
                local onGround = abvGndDet > -1
                local pitchToUse = adjustedPitch

                if (VectorToTarget or spaceLaunch or ReversalIsOn) and not onGround and velMag > minRollVelocity and atmosDensity > 0.01 then
                    local rollRad = math.rad(mabs(adjustedRoll))
                    pitchToUse = adjustedPitch*mabs(math.cos(rollRad))+currentPitch*math.sin(rollRad)
                end
                -- TODO: These clamps need to be related to roll and YawStallAngle, we may be dealing with yaw?
                local pitchDiff = uclamp(targetPitch-pitchToUse, -PitchStallAngle*0.80, PitchStallAngle*0.80)
                if atmosDensity < 0.01 and VectorToTarget then
                    pitchDiff = uclamp(targetPitch-pitchToUse, -85, MaxPitch) -- I guess
                elseif atmosDensity < 0.01 then
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
                        antigrav.setBaseAltitude(desiredBaseAltitude)
                    end
            end
        end
        abvGndDet = AboveGroundLevel()
        return ap
    end
-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
    function script.onStart()
        -- Local functions for onStart
            local ControlButtons = {}
            local SettingButtons = {}
            local valuesAreSet = false
            local function LoadVariables()

                local function processVariableList(varList)
                    local hasKey = dbHud_1.hasKey
                    for k, v in pairs(varList) do
                        if hasKey(v) then
                            local result = jdecode(dbHud_1.getStringValue(v))
                            if result ~= nil then
                                _G[v] = result
                                valuesAreSet = true
                            end
                        end
                    end
                end

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
                        resolutionWidth = ResolutionX
                        resolutionHeight = ResolutionY
                        BrakeToggleStatus = BrakeToggleDefault
                        userControlScheme = string.lower(userControlScheme)
                        autoRoll = autoRollPreference
                        adjustedAtmoSpeedLimit = AtmoSpeedLimit
                        rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) ..
                        [[)]]
                        rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..
                        mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]  
                    elseif not useTheseSettings then
                        msgText = "No Saved Variables Found - Exit HUD to save settings"
                    end
                else
                    msgText = "No databank found. Attach one to control unit and rerun \nthe autoconfigure to save preferences and locations"
                end
            
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
                    antigrav.setBaseAltitude(AntigravTargetAltitude)
                end

                VectorStatus = "Proceeding to Waypoint"
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

                local eleName = core.getElementNameById
                local checkTanks = (fuelX ~= 0 and fuelY ~= 0)
                for k in pairs(elementsID) do --Look for space engines, landing gear, fuel tanks if not slotted and core size
                    local type = core.getElementTypeById(elementsID[k])
                    if stringmatch(type, '^.*Atmospheric Engine$') then
                        if stringmatch(tostring(core.getElementTagsById(elementsID[k])), '^.*vertical.*$') then
                            UpVertAtmoEngine = true
                        end
                    end

                    if stringmatch(type, '^.*Space Engine$') then
                        SpaceEngines = true
                        if stringmatch(tostring(core.getElementTagsById(elementsID[k])), '^.*vertical.*$') then
                            local enrot = core.getElementRotationById(elementsID[k])
                            if enrot[4] < 0 then
                                if round(-enrot[4],0.1) == 0.5 then
                                    SpaceEngineVertUp = true
                                end
                            else
                                if round(enrot[4],0.1) == 0.5 then
                                    SpaceEngineVertDn = true
                                end
                            end
                        end
                    end
                    if (type == "Landing Gear") then
                        hasGear = true
                    end
                    if (type == "Dynamic Core Unit") then
                        local hp = eleMaxHp(elementsID[k])
                        if hp > 10000 then
                            coreOffset = 128
                            coreHalfDiag = 110
                        elseif hp > 1000 then
                            coreOffset = 64
                            coreHalfDiag = 55
                        elseif hp > 150 then
                            coreOffset = 32
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
                            atmoTanks[#atmoTanks + 1] = {elementsID[k], eleName(elementsID[k]),
                                                        vanillaMaxVolume, massEmpty, curMass, curTime}
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
                            rocketTanks[#rocketTanks + 1] = {elementsID[k], eleName(elementsID[k]),
                                                            vanillaMaxVolume, massEmpty, curMass, curTime}
                        end
                        if (type == "Space Fuel Tank") then
                            local vanillaMaxVolume = 2400
                            local massEmpty = 182.67
                            if hp > 10000 then
                                vanillaMaxVolume = 76800 -- volume in kg of L tank
                                massEmpty = 5480
                            elseif hp > 1300 then
                                vanillaMaxVolume = 9600 -- volume in kg of M
                                massEmpty = 988.67
                            end
                            curMass = mass - massEmpty
                            if fuelTankHandlingSpace > 0 then
                                vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingSpace * 0.2))
                            end
                            vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                            spaceTanks[#spaceTanks + 1] = {elementsID[k], eleName(elementsID[k]),
                                                        vanillaMaxVolume, massEmpty, curMass, curTime}
                        end
                    end
                end
                if not UpVertAtmoEngine then
                    VertTakeOff, VertTakeOffEngine = false, false
                end
            end
            
            local function SetupChecks()
                
                if gyro ~= nil then
                    gyroIsOn = gyro.getState() == 1
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
                    antigravOn = (antigrav.getState() == 1)
                    if antigravOn and not ExternalAGG then antigrav.show() end
                end
                -- unfreeze the player if he is remote controlling the construct
                if isRemote() == 1 and RemoteFreeze then
                    system.freeze(1)
                else
                    system.freeze(0)
                end
                if hasGear then
                    GearExtended = (Nav.control.isAnyLandingGearExtended() == 1)
                    if GearExtended then
                        Nav.control.extendLandingGears()
                    else
                        Nav.control.retractLandingGears()
                    end
                end

                -- Engage brake and extend Gear if either a hover detects something, or they're in space and moving very slowly
                if abvGndDet ~= -1 or (not inAtmo and coreVelocity:len() < 50) then
                    BrakeIsOn = true
                    GearExtended = true
                    if hasGear then
                        Nav.control.extendLandingGears()
                    end
                else
                    BrakeIsOn = false
                end
            
                navCom:setTargetGroundAltitude(targetGroundAltitude)
            
                -- Store their max kinematic parameters in ship-up direction for use in brake-landing
                if inAtmo and abvGndDet ~= -1 then 
                    maxKinematicUp = core.getMaxKinematicsParametersAlongAxis("ground", core.getConstructOrientationUp())[1]
                end
            
                WasInAtmo = inAtmo
            end

            local function MakeButton(enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition, buttonList)
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
                    hovered = false
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
                    settingsVariables = {}
                    showHud = true
                end
            end

            local function ToggleButtons()
                showSettings = not showSettings 
                if showSettings then 
                    Buttons = SettingButtons
                    msgText = "Hold SHIFT to see Settings" 
                    oldShowHud = showHud
                else
                    Buttons = ControlButtons
                    msgText = "Hold SHIFT to see Control Buttons"
                    ToggleShownSettings()
                    showHud = oldShowHud
                end
            end

            local function ToggleBoolean(v)

                _G[v] = not _G[v]
                if _G[v] then 
                    msgText = v.." set to true"
                else
                    msgText = v.." set to false"
                end
                if v == "showHud" then
                    oldShowHud = _G[v]
                elseif v == "BrakeToggleDefault" then 
                    BrakeToggleStatus = BrakeToggleDefault
                elseif v == "Cockpit" then
                    system.showScreen(0)
                    dbHud_1.setStringValue("content", "")
                end
            end

            local function SettingsButtons()
                local buttonHeight = 50
                local buttonWidth = 340 -- Defaults
                local x = 500
                local y = resolutionHeight / 2 - 400
                local cnt = 0
                for k, v in pairs(saveableVariables("boolean")) do
                    if type(_G[v]) == "boolean" then
                        MakeButton(v, v, buttonWidth, buttonHeight, x, y,
                            function() return _G[v] end, 
                            function() ToggleBoolean(v) end,
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
                    if radar_1 then -- Just match the first one
                        local id,_ = radar_1.getData():match('"constructId":"([0-9]*)","distance":([%d%.]*)')
                        if id ~= nil and id ~= "" then
                            name = name .. " " .. radar_1.getConstructName(id)
                        end
                    end
                    
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

                local function UpdatePosition()
                    ATLAS.UpdatePosition()
                end
                local function ClearCurrentPosition()
                    -- So AutopilotTargetIndex is special and not a real index.  We have to do this by hand.
                        ATLAS.ClearCurrentPosition()
                end
                
                local function getAPEnableName()
                    local name = AutopilotTargetName
                    if name == nil then
                        local displayText = getDistanceDisplayString((worldPos - CustomTarget.position):len())
                        name = CustomTarget.name .. " " .. displayText
                                
                    end
                    if name == nil then
                        name = "None"
                    end
                    return "Engage Autopilot: " .. name
                end

                local function getAPDisableName()
                    local name = AutopilotTargetName
                    if name == nil then
                        name = CustomTarget.name
                    end
                    if name == nil then
                        name = "None"
                    end
                    return "Disable Autopilot: " .. name
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
                            BrakeIsOn = true
                            autoRoll = autoRollPreference
                            GearExtended = OldGearExtended
                            if GearExtended then
                                Nav.control.extendLandingGears()
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
                local apbutton = MakeButton(getAPEnableName, getAPDisableName, 600, 60, resolutionWidth / 2 - 600 / 2,
                                        resolutionHeight / 2 - 60 / 2 - 400, function()
                        return Autopilot
                    end, ToggleAutopilot)
                MakeButton("Save Position", "Save Position", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y,
                    function()
                        return false
                    end, AddNewLocation, function()
                        return AutopilotTargetIndex == 0 or CustomTarget == nil
                    end)
                MakeButton("Update Position", "Update Position", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y,
                    function()
                        return false
                    end, UpdatePosition, function()
                        return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                    end)
                MakeButton("Clear Position", "Clear Position", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y,
                    function()
                        return true
                    end, ClearCurrentPosition, function()
                        return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                    end)
                -- The rest are sort of standardized
                buttonHeight = 60
                buttonWidth = 300
                local x = 10
                local y = resolutionHeight / 2 - 500
                MakeButton("Show Help", "Hide Help", buttonWidth, buttonHeight, x, y, function() return showHelp end, function() showHelp = not showHelp end)
                y = y + buttonHeight + 20
                MakeButton("View Settings", "View Settings", buttonWidth, buttonHeight, x, y, function() return true end, ToggleButtons)
                local y = resolutionHeight / 2 - 300
                MakeButton("Enable Turn and Burn", "Disable Turn and Burn", buttonWidth, buttonHeight, x, y, function()
                    return TurnBurn
                end, ToggleTurnBurn)
                MakeButton("Horizontal Takeoff Mode", "Vertical Takeoff Mode", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
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
                MakeButton("Show Orbit Display", "Hide Orbit Display", buttonWidth, buttonHeight, x, y,
                    function()
                        return DisplayOrbit
                    end, function()
                        DisplayOrbit = not DisplayOrbit
                        if (DisplayOrbit) then
                            msgText = "Orbit Display Enabled"
                        else
                            msgText = "Orbit Display Disabled"
                        end
                    end)
                -- prevent this button from being an option until you're in atmosphere
                MakeButton("Engage Orbiting", "Cancel Orbiting", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                        function()
                            return IntoOrbit
                        end, ToggleIntoOrbit, function()
                            return (atmosDensity == 0 and nearPlanet)
                        end)
                y = y + buttonHeight + 20
                MakeButton("Glide Re-Entry", "Cancel Glide Re-Entry", buttonWidth, buttonHeight, x, y,
                    function() return Reentry end, function() spaceLand = 1 gradeToggle(1) end, function() return (planet.hasAtmosphere and not inAtmo) end )
                MakeButton("Parachute Re-Entry", "Cancel Parachute Re-Entry", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                    function() return Reentry end, BeginReentry, function() return (planet.hasAtmosphere and not inAtmo) end )
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
                    return antigravOn end, ToggleAntigrav, function()
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

            AP = APClass()
            SetupChecks() -- All the if-thens to set up for particular ship.  Specifically override these with the saved variables if available
          
            SettingsButtons()
            ControlsButtons() -- Set up all the pushable buttons.
            Buttons = ControlButtons
            coroutine.yield() -- Just to make sure

            -- Set up Jaylebreak and atlas
            atlas = Atlas() -- Actual planet info
            PlanetaryReference = PlanetRef()
            galaxyReference = PlanetaryReference(Atlas())

            -- Setup Modular Classes
            Kinematic = Kinematics()
            Kep = Keplers()

            RADAR = RadarClass()
            HUD = HudClass()

            ATLAS = AtlasClass()

            --AP = APClass()

         
            coroutine.yield()
 
            unit.hide()
            system.showScreen(1)
            -- That was a lot of work with dirty strings and json.  Clean up
            collectgarbage("collect")
            -- Start timers
            coroutine.yield()

            unit.setTimer("apTick", apTickRate)
            unit.setTimer("radarTick", apTickRate)
            unit.setTimer("hudTick", hudTickRate)
            unit.setTimer("oneSecond", 1)
            unit.setTimer("tenthSecond", 1/10)
            unit.setTimer("fiveSecond", 5) 
            play("start","SU")
        end)
        coroutine.resume(beginSetup)
    end

    function script.onStop()
        _autoconf.hideCategoryPanels()
        if antigrav ~= nil  and not ExternalAGG then
            antigrav.hide()
        end
        if warpdrive ~= nil then
            warpdrive.hide()
        end
        core.hide()
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
        SaveDataBank()
        if button then
            button.activate()
        end
        if SetWaypointOnExit then AP.showWayPoint(planet, worldPos) end
        play("stop","SU")
        --[[ --EliasVilld Log Code for printing timing checks.
        for _,s in pairs(Logs.getLogs()) do
            system.print(s)
        end
        --]]
    end

    function script.onTick(timerId)
        local lastMaxBrakeAtG = nil
        -- Various tick timers
        if timerId == "contact" then
            if not contactTimer then contactTimer = 0 end
            if time > contactTimer+10 then
                msgText = "Radar Contact" 
                play("rdrCon","RC")
                contactTimer = time
            end
            unit.stopTimer("contact")
        elseif timerId == "tenthSecond" then -- Timer executed ever tenth of a second
            -- Local Functions for tenthSecond

                local function SetupInterplanetaryPanel() -- Interplanetary helper
                    local sysCrData = system.createData
                    local sysCrWid = system.createWidget
                    panelInterplanetary = system.createWidgetPanel("Interplanetary Helper")
                
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
                local function GetAutopilotTravelTime()
                    if not Autopilot then
                        if CustomTarget == nil or CustomTarget.planetname ~= planet.name then
                            AutopilotDistance = (autopilotTargetPlanet.center - worldPos):len() -- This updates elsewhere if we're already piloting
                        else
                            AutopilotDistance = (CustomTarget.position - worldPos):len()
                        end
                    end
                    local speed = velMag
                    local throttle = unit.getThrottle()/100
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
                        gravity = core.g()
                    end
                    gravity = round(gravity, 5) -- round to avoid insignificant updates
                    if (force ~= nil and force) or (lastMaxBrakeAtG == nil or lastMaxBrakeAtG ~= gravity) then
                        local speed = coreVelocity:len()
                        local maxBrake = jdecode(unit.getData()).maxBrake 
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
            RefreshLastMaxBrake(nil, true) -- force refresh, in case we took damage
            if setCruiseSpeed ~= nil then
                if navCom:getTargetSpeed(axisCommandId.longitudinal) ~= setCruiseSpeed then
                    cmdCruise(setCruiseSpeed, TRUE)
                else
                    setCruiseSpeed = nil
                end
            end
            if AutopilotTargetName ~= "None" then
                if panelInterplanetary == nil then
                    SetupInterplanetaryPanel()
                end
                if AutopilotTargetName ~= nil then
                    local customLocation = CustomTarget ~= nil
                    local planetMaxMass = 0.5 * LastMaxBrakeInAtmo /
                        (autopilotTargetPlanet:getGravity(
                        autopilotTargetPlanet.center + (vec3(0, 0, 1) * autopilotTargetPlanet.radius))
                        :len())
                    planetMaxMass = planetMaxMass > 1000000 and round(planetMaxMass / 1000000,2).." kTons" or round(planetMaxMass / 1000, 2).." Tons"
                    sysUpData(interplanetaryHeaderText,
                        '{"label": "Target", "value": "' .. AutopilotTargetName .. '", "unit":""}')
                    travelTime = GetAutopilotTravelTime() -- This also sets AutopilotDistance so we don't have to calc it again
                    if customLocation and not Autopilot then -- If in autopilot, keep this displaying properly
                        distance = (worldPos - CustomTarget.position):len()
                    else
                        distance = (AutopilotTargetCoords - worldPos):len() -- Don't show our weird variations
                    end
                    if not TurnBurn then
                        brakeDistance, brakeTime = AP.GetAutopilotBrakeDistanceAndTime(velMag)
                        maxBrakeDistance, maxBrakeTime = AP.GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
                    else
                        brakeDistance, brakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(velMag)
                        maxBrakeDistance, maxBrakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
                    end
                    local displayText = getDistanceDisplayString(distance)
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
                    if atmosDensity > 0 and not WasInAtmo then
                        system.removeDataFromWidget(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
                        system.removeDataFromWidget(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
                        system.removeDataFromWidget(widgetCurBrakeTimeText, widgetCurBrakeTime)
                        system.removeDataFromWidget(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
                        system.removeDataFromWidget(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
                        WasInAtmo = true
                        if not throttleMode and AtmoSpeedAssist and (AltitudeHold or Reentry or finalLand) then
                            -- If they're reentering atmo from cruise, and have atmo speed Assist
                            -- Put them in throttle mode at 100%
                            cmdThrottle(1)
                            BrakeIsOn = false
                            WasInCruise = false -- And override the thing that would reset it, in this case
                        end
                    end
                    if atmosDensity == 0 and WasInAtmo then
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
                if jdecode(warpdrive.getData()).destination ~= "Unknown" and jdecode(warpdrive.getData()).distance > 400000 then
                    warpdrive.show()
                    showWarpWidget = true
                else
                    warpdrive.hide()
                    showWarpWidget = false
                end
            end
            HUD.DrawTanks()
            if shield_1 then HUD.DrawShield() end
        elseif timerId == "oneSecond" then -- Timer for evaluation every 1 second
            -- Local Functions for oneSecond

                local function CheckDamage(newContent)
                    local percentDam = 0
                    damageMessage = ""
                    local maxShipHP = eleTotalMaxHp
                    local curShipHP = 0
                    local damagedElements = 0
                    local disabledElements = 0
                    local colorMod = 0
                    local color = ""
                    local eleHp = core.getElementHitPointsById
    
                    for k in pairs(elementsID) do
                        local hp = 0
                        local mhp = 0
                        mhp = eleMaxHp(elementsID[k])
                        hp = eleHp(elementsID[k])
                        curShipHP = curShipHP + hp
                        if (hp < mhp) then
                            if (hp == 0) then
                                disabledElements = disabledElements + 1
                            else
                                damagedElements = damagedElements + 1
                            end
                            -- Thanks to Jerico for the help and code starter for arrow markers!
                            if repairArrows and #markers == 0 then
                                position = vec3(core.getElementPositionById(elementsID[k]))
                                local x = position.x - coreOffset
                                local y = position.y - coreOffset
                                local z = position.z - coreOffset
                                table.insert(markers, core.spawnArrowSticker(x, y, z + 1, "down"))
                                table.insert(markers, core.spawnArrowSticker(x, y, z + 1, "down"))
                                core.rotateSticker(markers[2], 0, 0, 90)
                                table.insert(markers, core.spawnArrowSticker(x + 1, y, z, "north"))
                                table.insert(markers, core.spawnArrowSticker(x + 1, y, z, "north"))
                                core.rotateSticker(markers[4], 90, 90, 0)
                                table.insert(markers, core.spawnArrowSticker(x - 1, y, z, "south"))
                                table.insert(markers, core.spawnArrowSticker(x - 1, y, z, "south"))
                                core.rotateSticker(markers[6], 90, -90, 0)
                                table.insert(markers, core.spawnArrowSticker(x, y - 1, z, "east"))
                                table.insert(markers, core.spawnArrowSticker(x, y - 1, z, "east"))
                                core.rotateSticker(markers[8], 90, 0, 90)
                                table.insert(markers, core.spawnArrowSticker(x, y + 1, z, "west"))
                                table.insert(markers, core.spawnArrowSticker(x, y + 1, z, "west"))
                                core.rotateSticker(markers[10], -90, 0, 90)
                                table.insert(markers, elementsID[k])
                            end
                        elseif repairArrows and #markers > 0 and markers[11] == elementsID[k] then
                            for j in pairs(markers) do
                                core.deleteSticker(markers[j])
                            end
                            markers = {}
                        end
                    end
                    percentDam = mfloor((curShipHP / maxShipHP)*100)
                    if percentDam < 100 then
                        newContent[#newContent + 1] = svgText(0,0,"", "pbright txt")
                        colorMod = mfloor(percentDam * 2.55)
                        color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                        if percentDam < 100 then
                            newContent[#newContent + 1] = svgText("50%", 1035, "Elemental Integrity: "..percentDam.."%", "txtbig txtmid","fill:"..color )
                            if (disabledElements > 0) then
                                newContent[#newContent + 1] = svgText("50%",1055, "Disabled Modules: "..disabledElements.." Damaged Modules: "..damagedElements, "txtbig txtmid","fill:"..color)
                            elseif damagedElements > 0 then
                                newContent[#newContent + 1] = svgText("50%", 1055, "Damaged Modules: "..damagedElements, "txtbig txtmid", "fill:" .. color)
                            end
                        end
                    end
                end
                local function updateWeapons()
                    if weapon then
                        if  WeaponPanelID==nil and (radarPanelID ~= nil or GearExtended)  then
                            _autoconf.displayCategoryPanel(weapon, weapon_size, L_TEXT("ui_lua_widget_weapon", "Weapons"), "weapon", true)
                            WeaponPanelID = _autoconf.panels[_autoconf.panels_size]
                        elseif WeaponPanelID ~= nil and radarPanelID == nil and not GearExtended then
                            sysDestWid(WeaponPanelID)
                            WeaponPanelID = nil
                        end
                    end
                end    
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

            updateDistance()
            HUD.UpdatePipe()
            
            updateWeapons()
            -- Update odometer output string
            local newContent = {}
            HUD.ExtraData(newContent)
            if ShowOdometer then 
                newContent = HUD.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime) 
            end
            if ShouldCheckDamage then
                CheckDamage(newContent)
            end
            lastOdometerOutput = table.concat(newContent, "")
            collectgarbage("collect")
        elseif timerId == "fiveSecond" then -- Timer executed every 5 seconds (SatNav only stuff for now)
            if not UseSatNav then return end
            -- Support for SatNav by Trog
            myAutopilotTarget = dbHud_1.getStringValue("SPBAutopilotTargetName")
            if myAutopilotTarget ~= nil and myAutopilotTarget ~= "" and myAutopilotTarget ~= "SatNavNotChanged" then
                local result = jdecode(dbHud_1.getStringValue("SavedLocations"))
                if result ~= nil then
                    _G["SavedLocations"] = result        
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
                        system.print("Index = "..AutopilotTargetIndex.." "..AtlasOrdered[i].name)          
                        ATLAS.UpdateAutopilotTarget()
                        dbHud_1.setStringValue("SPBAutopilotTargetName", "SatNavNotChanged")
                        break            
                    end     
                end
            end
        elseif timerId == "msgTick" then -- Timer executed whenever msgText is applied somwehere
            -- This is used to clear a message on screen after a short period of time and then stop itself
            local newContent = {}
            HUD.DisplayMessage(newContent, "empty")
            msgText = "empty"
            unit.stopTimer("msgTick")
            msgTimer = 3
        elseif timerId == "animateTick" then -- Timer for animation
            Animated = true
            Animating = false
            simulatedX = 0
            simulatedY = 0
            unit.stopTimer("animateTick")
        elseif timerId == "hudTick" then -- Timer for all hud updates not called elsewhere

            -- Local Functions for hudTick
                local function DrawCursorLine(newContent)
                    local strokeColor = mfloor(uclamp((distance / (resolutionWidth / 4)) * 255, 0, 255))
                    newContent[#newContent + 1] = stringf(
                                                    "<line x1='0' y1='0' x2='%fpx' y2='%fpx' style='stroke:rgb(%d,%d,%d);stroke-width:2;transform:translate(50%%, 50%%)' />",
                                                    simulatedX, simulatedY, mfloor(PrimaryR + 0.5) + strokeColor,
                                                    mfloor(PrimaryG + 0.5) - strokeColor, mfloor(PrimaryB + 0.5) - strokeColor)
                end
                local function CheckButtons()
                    for _, v in pairs(Buttons) do
                        if v.hovered then
                            if not v.drawCondition or v.drawCondition() then
                                v.toggleFunction()
                            end
                            v.hovered = false
                        end
                    end
                end    
                local function SetButtonContains()

                    local function Contains(mousex, mousey, x, y, width, height)
                        if mousex > x and mousex < (x + width) and mousey > y and mousey < (y + height) then
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
                end
                local function DrawButtons(newContent)

                    local function DrawButton(newContent, toggle, hover, x, y, w, h, activeColor, inactiveColor, activeText, inactiveText)
                        if type(activeText) == "function" then
                            activeText = activeText()
                        end
                        if type(inactiveText) == "function" then
                            inactiveText = inactiveText()
                        end
                        newContent[#newContent + 1] = stringf("<rect x='%f' y='%f' width='%f' height='%f' fill='", x, y, w, h)
                        if toggle then
                            newContent[#newContent + 1] = stringf("%s'", activeColor)
                        else
                            newContent[#newContent + 1] = inactiveColor
                        end
                        if hover then
                            newContent[#newContent + 1] = " style='stroke:white; stroke-width:2'"
                        else
                            newContent[#newContent + 1] = " style='stroke:black; stroke-width:1'"
                        end
                        newContent[#newContent + 1] = "></rect>"
                        newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='24' fill='", x + w / 2,
                                                        y + (h / 2) + 5)
                        if toggle then
                            newContent[#newContent + 1] = "black"
                        else
                            newContent[#newContent + 1] = "white"
                        end
                        newContent[#newContent + 1] = "' text-anchor='middle' font-family='Montserrat'>"
                        if toggle then
                            newContent[#newContent + 1] = stringf("%s</text>", activeText)
                        else
                            newContent[#newContent + 1] = stringf("%s</text>", inactiveText)
                        end
                    end    
                
                    local defaultColor = "rgb(50,50,50)'"
                    local onColor = "rgb(210,200,200)"
                    local draw = DrawButton
                    for _, v in pairs(Buttons) do
                        -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                        local disableName = v.disableName
                        local enableName = v.enableName
                        if type(disableName) == "function" then
                            disableName = disableName()
                        end
                        if type(enableName) == "function" then
                            enableName = enableName()
                        end
                        if not v.drawCondition or v.drawCondition() then -- If they gave us a nil condition
                            draw(newContent, v.toggleVar(), v.hovered, v.x, v.y, v.width, v.height, onColor, defaultColor,
                                disableName, enableName)
                        end
                    end
                end
                local halfResolutionX = round(ResolutionX / 2,0)
                local halfResolutionY = round(ResolutionY / 2,0)
            local newContent = {}
            --local t0 = system.getTime()
            HUD.HUDPrologue(newContent)

            if showHud then
                --local t0 = system.getTime()
                HUD.UpdateHud(newContent) -- sets up Content for us
                --_logCompute.addValue(system.getTime() - t0)
            else
                if AlwaysVSpd then HUD.DrawVerticalSpeed(newContent, coreAltitude) end
                HUD.DisplayOrbitScreen(newContent)
                HUD.DrawWarnings(newContent)
            end
            if showSettings and settingsVariables ~= {} then 
                HUD.DrawSettings(newContent) 
            end
            if radar_1 then HUD.DrawRadarInfo() end

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

            if sysIsVwLock() == 0 then
                if isRemote() == 1 and holdingCtrl then
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
                        unit.setTimer("animateTick", 0.5)
                        local content = table.concat(newContent, "")
                        system.setScreen(content)
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
                if not holdingCtrl and isRemote() == 0 then -- Draw deadzone circle if it's navigating
                    CheckButtons()
                    if distance > DeadZone then -- Draw a line to the cursor from the screen center
                        -- Note that because SVG lines fucking suck, we have to do a translate and they can't use calc in their params
                        if DisplayDeadZone then DrawCursorLine(newContent) end
                    end
                elseif not AltIsOn or (AltIsOn and holdingCtrl) then
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

        elseif timerId == "apTick" then -- Timer for all autopilot functions
            AP.APTick()
        elseif timerId == "radarTick" then
            RADAR.UpdateRadar()
        elseif timerId == "tagTick" then
            if UseExtra == "Off" then UseExtra = "All"
            elseif UseExtra == "All" then UseExtra = "Longitude"
            elseif UseExtra == "Longitude" then UseExtra = "Lateral"
            elseif UseExtra == "Lateral" then UseExtra = "Vertical"
            else UseExtra = "Off"
            end
            msgText = "Extra Engine Tags: "..UseExtra 
            unit.stopTimer("tagTick")
        end
    end

    function script.onFlush()
        -- Local functions for onFlush
            local function composeAxisAccelerationFromTargetSpeedV(commandAxis, targetSpeed)

                local axisCRefDirection = vec3()
                local axisWorldDirection = vec3()
            
                if (commandAxis == axisCommandId.longitudinal) then
                    axisCRefDirection = vec3(core.getConstructOrientationForward())
                    axisWorldDirection = constructForward
                elseif (commandAxis == axisCommandId.vertical) then
                    axisCRefDirection = vec3(core.getConstructOrientationUp())
                    axisWorldDirection = constructUp
                elseif (commandAxis == axisCommandId.lateral) then
                    axisCRefDirection = vec3(core.getConstructOrientationRight())
                    axisWorldDirection = constructRight
                else
                    return vec3()
                end
            
                local gravityAcceleration = vec3(core.getWorldGravity())
                local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
            
                local airResistanceAcceleration = vec3(core.getWorldAirFrictionAcceleration())
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
                --system.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
                --system.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())
            
                return finalAcceleration
            end

            local function composeAxisAccelerationFromTargetSpeed(commandAxis, targetSpeed)

                local axisCRefDirection = vec3()
                local axisWorldDirection = vec3()
            
                if (commandAxis == axisCommandId.longitudinal) then
                    axisCRefDirection = vec3(core.getConstructOrientationForward())
                    axisWorldDirection = constructForward
                elseif (commandAxis == axisCommandId.vertical) then
                    axisCRefDirection = vec3(core.getConstructOrientationUp())
                    axisWorldDirection = constructUp
                elseif (commandAxis == axisCommandId.lateral) then
                    axisCRefDirection = vec3(core.getConstructOrientationRight())
                    axisWorldDirection = constructRight
                else
                    return vec3()
                end
            
                local gravityAcceleration = vec3(core.getWorldGravity())
                local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
            
                local airResistanceAcceleration = vec3(core.getWorldAirFrictionAcceleration())
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
                --system.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
                --system.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())
            
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

        if antigrav and not ExternalAGG then
            if not antigravOn and antigrav.getBaseAltitude() ~= AntigravTargetAltitude then 
                antigrav.setBaseAltitude(AntigravTargetAltitude) 
            end
        end

        throttleMode = (navCom:getAxisCommandType(0) == axisCommandType.byThrottle)
    
        if throttleMode and WasInCruise then
            -- Not in cruise, but was last tick
            cmdThrottle(0)
            WasInCruise = false
        elseif not throttleMode and not WasInCruise then
            -- Is in cruise, but wasn't last tick
            PlayerThrottle = 0 -- Reset this here too, because, why not
            WasInCruise = true
        end

        -- validate params
        pitchSpeedFactor = math.max(pitchSpeedFactor, 0.01)
        yawSpeedFactor = math.max(yawSpeedFactor, 0.01)
        rollSpeedFactor = math.max(rollSpeedFactor, 0.01)
        torqueFactor = math.max(torqueFactor, 0.01)
        brakeSpeedFactor = math.max(brakeSpeedFactor, 0.01)
        brakeFlatFactor = math.max(brakeFlatFactor, 0.01)
        autoRollFactor = math.max(autoRollFactor, 0.01)
        -- final inputs
        local finalPitchInput = uclamp(pitchInput + pitchInput2 + system.getControlDeviceForwardInput(),-1,1)
        local finalRollInput = uclamp(rollInput + rollInput2 + system.getControlDeviceYawInput(),-1,1)
        local finalYawInput = uclamp((yawInput + yawInput2) - system.getControlDeviceLeftRightInput(),-1,1)
        local finalBrakeInput = brakeInput

        -- Axis
        worldVertical = vec3(core.getWorldVertical()) -- along gravity
        if worldVertical == nil or worldVertical:len() == 0 then
            worldVertical = (planet.center - worldPos):normalize() -- I think also along gravity hopefully?
        end

        constructUp = vec3(core.getConstructWorldOrientationUp())
        constructForward = vec3(core.getConstructWorldOrientationForward())
        constructRight = vec3(core.getConstructWorldOrientationRight())
        constructVelocity = vec3(core.getWorldVelocity())
        coreVelocity = vec3(core.getVelocity())
        worldPos = vec3(core.getConstructWorldPos())
        coreMass =  core.getConstructMass()
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
        local constructAngularVelocity = vec3(core.getWorldAngularVelocity())
        local targetAngularVelocity =
            finalPitchInput * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward +
                finalYawInput * yawSpeedFactor * constructUp

        if autoRoll == true and worldVertical:len() > 0.01 then
            -- autoRoll on AND adjustedRoll is big enough AND player is not rolling
            local currentRollDelta = mabs(targetRoll-adjustedRoll)
            if ((( ProgradeIsOn or Reentry or BrakeLanding or spaceLand or AltitudeHold or IntoOrbit) and currentRollDelta > 0) or
                (atmosDensity > 0.0 and currentRollDelta < autoRollRollThreshold and autoRollPreference))  
                and finalRollInput == 0 and mabs(adjustedPitch) < 85 then
                local targetRollDeg = targetRoll
                local rollFactor = autoRollFactor
                if atmosDensity == 0 then
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

        if system.getMouseWheel() > 0 then
            if AltIsOn then
                if atmosDensity > 0 or Reentry then
                    adjustedAtmoSpeedLimit = uclamp(adjustedAtmoSpeedLimit + speedChangeLarge,0,AtmoSpeedLimit)
                elseif Autopilot then
                    MaxGameVelocity = uclamp(MaxGameVelocity + speedChangeLarge/3.6*100,0, 8333.00)
                end
            elseif mousePause then
                local currentPlayerThrot = PlayerThrottle
                PlayerThrottle = round(uclamp(PlayerThrottle + speedChangeLarge/100, -1, 1),2)
                if PlayerThrottle >= 0 and currentPlayerThrot < 0 then 
                    PlayerThrottle = 0 
                    mousePause = false
                end
            end
        elseif system.getMouseWheel() < 0 then
            if AltIsOn then
                if atmosDensity > 0 or Reentry then
                    adjustedAtmoSpeedLimit = uclamp(adjustedAtmoSpeedLimit - speedChangeLarge,0,AtmoSpeedLimit)
                elseif Autopilot then
                    MaxGameVelocity = uclamp(MaxGameVelocity - speedChangeLarge/3.6*100,0, 8333.00)
                end
            elseif mousePause then 
                local currentPlayerThrot = PlayerThrottle
                PlayerThrottle = round(uclamp(PlayerThrottle - speedChangeLarge/100, -1, 1),2)
                if PlayerThrottle <= 0 and currentPlayerThrot > 0 then 
                    PlayerThrottle = 0 
                    mousePause = false
                end
            end
        else
            mousePause = true
        end

        brakeInput2 = 0


        if inAtmo and AtmoSpeedAssist and throttleMode then
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
                throttlePID = pid.new(0.5, 0, 1) -- First param, higher means less range in which to PID to a proper value
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
            throttlePID:inject(adjustedAtmoSpeedLimit/3.6 - constructVelocity:dot(constructForward))
            local pidGet = throttlePID:get()
            calculatedThrottle = uclamp(pidGet,-1,1)
            if calculatedThrottle < PlayerThrottle and (atmosDensity > 0.005) then -- We can limit throttle all the way to 0.05% probably
                ThrottleLimited = true
                navCom:setThrottleCommand(axisCommandId.longitudinal, uclamp(calculatedThrottle,0.01,1))
            else
                ThrottleLimited = false
                navCom:setThrottleCommand(axisCommandId.longitudinal, PlayerThrottle)
            end

            
            -- Then additionally
            if (brakePID == nil) then
                brakePID = pid.new(1 * 0.01, 0, 1 * 0.1)
            end
            brakePID:inject(constructVelocity:len() - (adjustedAtmoSpeedLimit/3.6)) 
            local calculatedBrake = uclamp(brakePID:get(),0,1)
            if (atmosDensity > 0 and vSpd < -80) or atmosDensity > 0.005 then -- Don't brake-limit them at <5% atmo if going up (or mostly up), it's mostly safe up there and displays 0% so people would be mad
                brakeInput2 = calculatedBrake
            end
            --if calculatedThrottle < 0 then
            --    brakeInput2 = brakeInput2 + mabs(calculatedThrottle)
            --end
            if brakeInput2 > 0 then
                if ThrottleLimited and calculatedThrottle == 0.01 then
                    navCom:setThrottleCommand(axisCommandId.longitudinal, 0) -- We clamped it to >0 before but, if braking and it was at that clamp, 0 is good.
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
                navCom:setThrottleCommand(axisCommandId.longitudinal, PlayerThrottle) -- Use PlayerThrottle always.
            end

            local targetSpeed = unit.getAxisCommandValue(0)

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
                if (brakeInput ~= 0 or autoNavigationUseBrake or mabs(constructVelocityDir:dot(constructForward)) < 0.8)
                then
                    autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
                end
                Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '',
                    '', tolerancePercentToSkipOtherPriorities)
            end
        end

        -- Rotation
        local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
        local airAcceleration = vec3(core.getWorldAirFrictionAngularAcceleration())
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
                local throttle = unit.getThrottle()
                if AtmoSpeedAssist then throttle = PlayerThrottle*100 end
                local targetSpeed = (throttle/100)
                if atmosphere == 0 then
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

    function script.onUpdate()
        if not SetupComplete then
            local cont = coroutine.status (beginSetup)
            if cont == "suspended" then 
                local value, done = coroutine.resume(beginSetup)
                if done then system.print("ERROR STARTUP: "..done) end
            elseif cont == "dead" then
                SetupComplete = true
            end
        end
        if SetupComplete then
            Nav:update()
            if not Animating and content ~= LastContent then
                if not Cockpit then 
                    system.setScreen(content) 
                else
                    dbHud_1.setStringValue("content", content)
                end
            end
            LastContent = content
        end
    end

    function script.onActionStart(action)
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
                    if holdingCtrl and down then
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
                        if holdingCtrl then
                            OrbitTargetOrbit = nextTargetHeight(OrbitTargetOrbit, down) 
                        else                          
                            OrbitTargetOrbit = OrbitTargetOrbit + mult*holdAltitudeButtonModifier
                        end
                        if OrbitTargetOrbit < planet.noAtmosphericDensityAltitude then OrbitTargetOrbit = planet.noAtmosphericDensityAltitude end
                    else
                        if holdingCtrl and inAtmo then
                            HoldAltitude = nextTargetHeight(HoldAltitude, down)
                        else
                            HoldAltitude = HoldAltitude + mult*holdAltitudeButtonModifier
                        end
                    end
                else
                    navCom:updateTargetGroundAltitudeFromActionStart(mult*1.0)
                end
            end
            local function changeSpd(down)
                local mult=1
                if down then mult = -1 end
                if not holdingCtrl then
                    if AtmoSpeedAssist and not AltIsOn then
                        PlayerThrottle = uclamp(PlayerThrottle + mult*speedChangeLarge/100, -1, 1)
                    else
                        navCom:updateCommandFromActionStart(axisCommandId.longitudinal, mult*speedChangeLarge)
                    end
                else
                    if down then mult = 1 else mult = nil end
                    ATLAS.adjustAutopilotTargetIndex(mult)
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
                            ToggleAutopilot() 
                        end
                        play("180On", "BR")
                    elseif vectorType==1 then
                        play("bnkLft","BR")
                    else
                        play("bnkRht", "BR")
                    end
                    if not AltitudeHold and not Autopilot and not VectorToTarget then 
                        ToggleAltitudeHold() 
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
        if action == "gear" then
            GearExtended = not GearExtended
            if GearExtended then
                VectorToTarget = false
                LockPitch = nil
                cmdThrottle(0)
                if vBooster or hover then 
                    if inAtmo and abvGndDet == -1 then
                        play("bklOn", "BL")
                        StrongBrakes = true -- We don't care about this anymore
                        Reentry = false
                        AutoTakeoff = false
                        VertTakeOff = false
                        AltitudeHold = false
                        BrakeLanding = true
                        autoRoll = true
                        GearExtended = false -- Don't actually toggle the gear yet though
                    else
                        if hasGear then
                            play("grOut","LG",1)
                            Nav.control.extendLandingGears()                            
                        end
                        navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                        if inAtmo then
                            BrakeIsOn = true
                        end
                    end
                end
                if hasGear and not BrakeLanding and not (vBooster or hover) then
                    play("grOut","LG",1)
                    Nav.control.extendLandingGears() -- Actually extend
                end
            else
                if hasGear then
                    play("grIn","LG",1)
                    Nav.control.retractLandingGears()
                end
                navCom:setTargetGroundAltitude(TargetHoverHeight)
            end
        elseif action == "light" then
            if Nav.control.isAnyHeadlightSwitchedOn() == 1 then
                Nav.control.switchOffHeadlights()
            else
                Nav.control.switchOnHeadlights()
            end
        elseif action == "forward" then
            pitchInput = pitchInput - 1
        elseif action == "backward" then
            if AltIsOn then
                assistedFlight(-constructVelocity*5000)
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
        elseif action == "yawleft" then
            yawInput = yawInput + 1
        elseif action == "straferight" then
                navCom:updateCommandFromActionStart(axisCommandId.lateral, 1.0)
                LeftAmount = 1
        elseif action == "strafeleft" then
                navCom:updateCommandFromActionStart(axisCommandId.lateral, -1.0)
                LeftAmount = -1
        elseif action == "up" then
            upAmount = upAmount + 1
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
            ATLAS.adjustAutopilotTargetIndex()
            toggleView = false
        elseif action == "option2" then
            ATLAS.adjustAutopilotTargetIndex(1)
            toggleView = false
        elseif action == "option3" then
            local function ToggleWidgets()
                UnitHidden = not UnitHidden
                if not UnitHidden then
                    play("wid","DH")
                    unit.show()
                    core.show()
                    if atmofueltank_size > 0 then
                        _autoconf.displayCategoryPanel(atmofueltank, atmofueltank_size,
                            L_TEXT("ui_lua_widget_atmofuel", "Atmo Fuel"), "fuel_container")
                        fuelPanelID = _autoconf.panels[_autoconf.panels_size]
                    end
                    if spacefueltank_size > 0 then
                        _autoconf.displayCategoryPanel(spacefueltank, spacefueltank_size,
                            L_TEXT("ui_lua_widget_spacefuel", "Space Fuel"), "fuel_container")
                        spacefuelPanelID = _autoconf.panels[_autoconf.panels_size]
                    end
                    if rocketfueltank_size > 0 then
                        _autoconf.displayCategoryPanel(rocketfueltank, rocketfueltank_size,
                            L_TEXT("ui_lua_widget_rocketfuel", "Rocket Fuel"), "fuel_container")
                        rocketfuelPanelID = _autoconf.panels[_autoconf.panels_size]
                    end
                    if shield_1 ~= nil then shield_1.show() end
                else
                    play("hud","DH")
                    unit.hide()
                    core.hide()
                    if fuelPanelID ~= nil then
                        sysDestWid(fuelPanelID)
                        fuelPanelID = nil
                    end
                    if spacefuelPanelID ~= nil then
                        sysDestWid(spacefuelPanelID)
                        spacefuelPanelID = nil
                    end
                    if rocketfuelPanelID ~= nil then
                        sysDestWid(rocketfuelPanelID)
                        rocketfuelPanelID = nil
                    end
                    if shield_1 ~= nil then shield_1.hide() end
                end
            end

            if hideHudOnToggleWidgets then
                if showHud then
                    showHud = false
                else
                    showHud = true
                end
            end
            ToggleWidgets()
            toggleView = false
        elseif action == "option4" then
            ReversalIsOn = nil
            ToggleAutopilot()
            toggleView = false            
        elseif action == "option5" then
            if AltIsOn and holdingCtrl and shield_1 then 
                shield_1.toggle() 
                toggleView = false 
                return 
            end
            function ToggleLockPitch()
                if LockPitch == nil then
                    play("lkPOn","LP")
                    if not holdingCtrl then LockPitch = adjustedPitch
                    else LockPitch = LockPitchTarget end
                    AutoTakeoff = false
                    AltitudeHold = false
                    BrakeLanding = false
                else
                    play("lkPOff","LP")
                    LockPitch = nil
                end
            end
            ToggleLockPitch()
            toggleView = false
        elseif action == "option6" then
            ToggleAltitudeHold()
            toggleView = false
        elseif action == "option7" then
            CollisionSystem = not CollisionSystem
            if CollisionSystem then 
                msgText = "Collision System Enabled"
            else 
                msgText = "Collision System Secured"
            end
            toggleView = false
        elseif action == "option8" then
            stablized = not stablized
            if not stablized then
                msgText = "DeCoupled Mode - Ground Stabilization off"
                navCom:deactivateGroundEngineAltitudeStabilization()
                play("gsOff", "GS")
            else
                msgText = "Coupled Mode - Ground Stabilization on"
                navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                Nav:setEngineForceCommand('hover', vec3(), 1)
                play("gsOn", "GS") 
            end
            toggleView = false
        elseif action == "option9" then
            if AltIsOn and holdingCtrl then 
                navCom:resetCommand(axisCommandId.longitudinal)
                navCom:resetCommand(axisCommandId.lateral)
                navCom:resetCommand(axisCommandId.vertical)
                cmdThrottle(0)
                unit.setTimer("tagTick",0.1)
            elseif gyro ~= nil then
                gyro.toggle()
                gyroIsOn = gyro.getState() == 1
                if gyroIsOn then play("gyOn", "GA") else play("gyOff", "GA") end
            end
            toggleView = false
        elseif action == "lshift" then
            if AltIsOn then holdingCtrl = true end
            if sysIsVwLock() == 1 then
                holdingCtrl = true
                PrevViewLock = sysIsVwLock()
                sysLockVw(1)
            elseif isRemote() == 1 and ShiftShowsRemoteButtons then
                holdingCtrl = true
                Animated = false
                Animating = false
            end
        elseif action == "brake" then
            if BrakeToggleStatus then
                BrakeToggle()
            elseif not BrakeIsOn then
                BrakeToggle() -- Trigger the cancellations
            else
                BrakeIsOn = true -- Should never happen
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
                    BrakeIsOn = false
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
                end
            end
            clearAll()
            clearAllCheck = time
            if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed then
                if PlayerThrottle ~= 0 then
                    navCom:resetCommand(axisCommandId.longitudinal)
                    cmdThrottle(0)
                else
                    cmdThrottle(100)
                end
            else
                if navCom:getTargetSpeed(axisCommandId.longitudinal) ~= 0 then
                    navCom:resetCommand(axisCommandId.longitudinal)
                else
                    if inAtmo then 
                        cmdCruise(AtmoSpeedLimit) 
                    else
                        cmdCruise(MaxGameVelocity*3.6)
                    end
                end
            end
        elseif action == "speedup" then
            changeSpd()
        elseif action == "speeddown" then
            changeSpd(true)
        elseif action == "antigravity" and not ExternalAGG then
            if antigrav ~= nil then
                ToggleAntigrav()
            end
        end
    end

    function script.onActionStop(action)
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
                Nav:setEngineForceCommand('hover', vec3(), 1) 
            end
        elseif action == "down" then
            upAmount = 0
            navCom:updateCommandFromActionStop(axisCommandId.vertical, 1.0)
            if stablized then 
                navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                Nav:setEngineForceCommand('hover', vec3(), 1) 
            end
        elseif action == "groundaltitudeup" then
            groundAltStop()
            toggleView = false
        elseif action == "groundaltitudedown" then
            groundAltStop()
            toggleView = false
        elseif action == "lshift" then
            if sysIsVwLock() == 1 then
                simulatedX = 0
                simulatedY = 0 -- Reset for steering purposes
                sysLockVw(PrevViewLock)
            elseif isRemote() == 1 and ShiftShowsRemoteButtons then
                Animated = false
                Animating = false
            end
            holdingCtrl = false
        elseif action == "brake" then
            if not BrakeToggleStatus then
                if BrakeIsOn then
                    BrakeToggle()
                else
                    BrakeIsOn = false -- Should never happen
                end
            end
        elseif action == "lalt" then
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

    function script.onActionLoop(action)
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
                        BrakeIsOn = false
                    else
                        AntigravTargetAltitude = desiredBaseAltitude + mult*100
                        BrakeIsOn = false
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
                if not holdingCtrl then
                    if AtmoSpeedAssist and not AltIsOn then
                        PlayerThrottle = uclamp(PlayerThrottle + mult*speedChangeSmall/100, -1, 1)
                    else
                        navCom:updateCommandFromActionLoop(axisCommandId.longitudinal, mult*speedChangeSmall)
                    end
                end
            end
        if action == "groundaltitudeup" then
            if not holdingCtrl then groundLoop() end
        elseif action == "groundaltitudedown" then
            if not holdingCtrl then groundLoop(true) end
        elseif action == "speedup" then
            spdLoop()
        elseif action == "speeddown" then
            spdLoop(true)
        end
    end

    function script.onInputText(text)
        -- Local functions for onInputText
            local function wipeSaveVariables()
                for k, v in pairs(saveableVariables()) do
                    dbHud_1.setStringValue(v, jencode(nil))
                end
                for k, v in pairs(autoVariables) do
                    if v ~= "SavedLocations" then dbHud_1.setStringValue(v, jencode(nil)) end
                end
                msgText =
                    "Databank wiped except Save Locations. New variables will save after re-enter seat and exit"
                msgTimer = 5
            end

            local function AddNewLocationByWaypoint(savename, pos, temp)

                local function zeroConvertToWorldCoordinates(pos) -- Many thanks to SilverZero for this.
                    local num  = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
                    local posPattern = '::pos{' .. num .. ',' .. num .. ',' ..  num .. ',' .. num ..  ',' .. num .. '}'    
                    local systemId, bodyId, latitude, longitude, altitude = stringmatch(pos, posPattern)
                    if (systemId == "0" and bodyId == "0") then
                        return vec3(tonum(latitude),
                                    tonum(longitude),
                                    tonum(altitude))
                    end
                    longitude = math.rad(longitude)
                    latitude = math.rad(latitude)
                    local planet = atlas[tonum(systemId)][tonum(bodyId)]  
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
                "/iphWP - displays current IPH target's ::pos waypoint in lua chat"
        i = string.find(text, " ")
        command = text
        if i ~= nil then
            command = string.sub(text, 0, i-1)
            arguement = string.sub(text, i+1)
        end
        if command == "/help" or command == "/commands" then
            for str in string.gmatch(commandhelp, "([^\n]+)") do
                system.print(str)
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
        elseif command == "/addlocation" or string.find(text, "::pos") ~= nil then
            local temp = false
            local savename = "0-Temp"
            if arguement == nil or arguement == "" then
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
                    if type(_G[v]) == "boolean" then
                        if _G[v] == true then
                            system.print(v.." true")
                        else
                            system.print(v.." false")
                        end
                    elseif _G[v] == nil then
                        system.print(v.." nil")
                    else
                        system.print(v.." ".._G[v])
                    end
                end
                return
            end
            i = string.find(arguement, " ")
            local globalVariableName = string.sub(arguement,0, i-1)
            local newGlobalValue = string.sub(arguement,i+1)
            for k, v in pairs(saveableVariables()) do
                if v == globalVariableName then
                    msgText = "Variable "..globalVariableName.." changed to "..newGlobalValue
                    local varType = type(_G[v])
                    if varType == "number" then
                        newGlobalValue = tonum(newGlobalValue)
                    elseif varType == "boolean" then
                        if string.lower(newGlobalValue) == "true" then
                            newGlobalValue = true
                        else
                            newGlobalValue = false
                        end
                    end
                    _G[v] = newGlobalValue
                    return
                end
            end
            msgText = "No such global variable: "..globalVariableName
        elseif command == "/copydatabank" then 
            if dbHud_2 then 
                SaveDataBank(true) 
            else
                msgText = "Spare Databank required to copy databank"
            end

        elseif command == "/iphWP" then
            if AutopilotTargetIndex > 0 then
                system.print(AP.showWayPoint(autopilotTargetPlanet, AutopilotTargetCoords, true)) 
                msgText = "::pos waypoint shown in lua chat"
            else
                msgText = "No target selected in IPH"
            end
        end
    end

    function script.onEnter(id)
        if radar_1 and not inAtmo and not notPvPZone then 
            unit.setTimer("contact",0.1) 
        end
    end

    function script.onLeave(id)
        if radar_1 and CollisionSystem then 
            if #contacts > 650 then 
                id = tostring(id)
                contacts[id] = nil 
            end
        end
    end

-- Execute Script
    script.onStart() 