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
    ecuThrottle = {}
    HoverMode = false
    autoVariables = {VertTakeOff={set=function (i)VertTakeOff=i end,get=function() return VertTakeOff end}, VertTakeOffEngine={set=function (i)VertTakeOffEngine=i end,get=function() return VertTakeOffEngine end},SpaceTarget={set=function (i)SpaceTarget=i end,get=function() return SpaceTarget end},BrakeToggleStatus={set=function (i)BrakeToggleStatus=i end,get=function() return BrakeToggleStatus end}, BrakeIsOn={set=function (i)BrakeIsOn=i end,get=function() return BrakeIsOn end}, RetrogradeIsOn={set=function (i)RetrogradeIsOn=i end,get=function() return RetrogradeIsOn end}, ProgradeIsOn={set=function (i)ProgradeIsOn=i end,get=function() return ProgradeIsOn end},
    Autopilot={set=function (i)Autopilot=i end,get=function() return Autopilot end}, TurnBurn={set=function (i)TurnBurn=i end,get=function() return TurnBurn end}, AltitudeHold={set=function (i)AltitudeHold=i end,get=function() return AltitudeHold end}, BrakeLanding={set=function (i)BrakeLanding=i end,get=function() return BrakeLanding end},
    Reentry={set=function (i)Reentry=i end,get=function() return Reentry end}, AutoTakeoff={set=function (i)AutoTakeoff=i end,get=function() return AutoTakeoff end}, HoldAltitude={set=function (i)HoldAltitude=i end,get=function() return HoldAltitude end}, AutopilotAccelerating={set=function (i)AutopilotAccelerating=i end,get=function() return AutopilotAccelerating end}, AutopilotBraking={set=function (i)AutopilotBraking=i end,get=function() return AutopilotBraking end},
    AutopilotCruising={set=function (i)AutopilotCruising=i end,get=function() return AutopilotCruising end}, AutopilotRealigned={set=function (i)AutopilotRealigned=i end,get=function() return AutopilotRealigned end}, AutopilotEndSpeed={set=function (i)AutopilotEndSpeed=i end,get=function() return AutopilotEndSpeed end}, AutopilotStatus={set=function (i)AutopilotStatus=i end,get=function() return AutopilotStatus end},
    AutopilotPlanetGravity={set=function (i)AutopilotPlanetGravity=i end,get=function() return AutopilotPlanetGravity end}, PrevViewLock={set=function (i)PrevViewLock=i end,get=function() return PrevViewLock end}, AutopilotTargetName={set=function (i)AutopilotTargetName=i end,get=function() return AutopilotTargetName end}, AutopilotTargetCoords={set=function (i)AutopilotTargetCoords=i end,get=function() return AutopilotTargetCoords end},
    AutopilotTargetIndex={set=function (i)AutopilotTargetIndex=i end,get=function() return AutopilotTargetIndex end}, TotalDistanceTravelled={set=function (i)TotalDistanceTravelled=i end,get=function() return TotalDistanceTravelled end},
    TotalFlightTime={set=function (i)TotalFlightTime=i end,get=function() return TotalFlightTime end}, SavedLocations={set=function (i)SavedLocations=i end,get=function() return SavedLocations end}, VectorToTarget={set=function (i)VectorToTarget=i end,get=function() return VectorToTarget end}, LocationIndex={set=function (i)LocationIndex=i end,get=function() return LocationIndex end}, LastMaxBrake={set=function (i)LastMaxBrake=i end,get=function() return LastMaxBrake end}, 
    LockPitch={set=function (i)LockPitch=i end,get=function() return LockPitch end}, LastMaxBrakeInAtmo={set=function (i)LastMaxBrakeInAtmo=i end,get=function() return LastMaxBrakeInAtmo end}, AntigravTargetAltitude={set=function (i)AntigravTargetAltitude=i end,get=function() return AntigravTargetAltitude end}, LastStartTime={set=function (i)LastStartTime=i end,get=function() return LastStartTime end}, iphCondition={set=function (i)iphCondition=i end,get=function() return iphCondition end}, stablized={set=function (i)stablized=i end,get=function() return stablized end}, UseExtra={set=function (i)UseExtra=i end,get=function() return UseExtra end}, SelectedTab={set=function (i)SelectedTab=i end,get=function() return SelectedTab end}, saveRoute={set=function (i)saveRoute=i end,get=function() return saveRoute end},
    apRoute={set=function (i)apRoute=i end,get=function() return apRoute end}, ecuThrottle={set=function (i)ecuThrottle=i end,get=function() return ecuThrottle end}, HoverMode={set=function (i)HoverMode=i end,get=function() return HoverMode end}}

-- Unsaved Globals - Do not edit unless you know what you are doing
    function globalDeclare(c, u, systime, mfloor, atmosphere) -- # is how many classes variable is in
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
        leftmouseclick = false
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