require 'src.slots'
require("autoconf/custom/archhud/globals")

local s=system
local c=core
local u=unit

local Nav = Navigator.new(s, c, u)
local atlas = require("atlas")

require("autoconf/custom/archhud/hudclass")
require("autoconf/custom/archhud/apclass")
require("autoconf/custom/archhud/radarclass")
require("autoconf/custom/archhud/controlclass")
require("autoconf/custom/archhud/atlasclass")
script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 1.706

-- function localizations for improved performance when used frequently or in loops.
    local mabs = math.abs
    local mfloor = math.floor
    local stringf = string.format
    local jdecode = json.decode
    local jencode = json.encode
    local eleMaxHp = c.getElementMaxHitPointsById
    local atmosphere = u.getAtmosphereDensity
    local eleMass = c.getElementMassById
    local isRemote = Nav.control.isRemoteControlled
    local atan = math.atan
    local stringmatch = string.match
    local systime = s.getTime
    local uclamp = utils.clamp
    local navCom = Nav.axisCommandManager
    local sysDestWid = s.destroyWidgetPanel
    local sysUpData = s.updateData
    local sysAddData = s.addDataToWidget
    local sysLockVw = s.lockView
    local sysIsVwLock = s.isViewLocked
    local msqrt = math.sqrt
    local tonum = tonumber

    local function round(num, numDecimalPlaces) -- rounds variable num to numDecimalPlaces
        local mult = 10 ^ (numDecimalPlaces or 0)
        return mfloor(num * mult + 0.5) / mult
    end
-- Variables that we declare local outside script because they will be treated as global but get local effectiveness
    time = systime()
    clearAllCheck = systime()
    local coreHalfDiag = 13
    PrimaryR = SafeR
    PrimaryB = SafeB
    PrimaryG = SafeG
    PlayerThrottle = 0
    brakeInput2 = 0
    ThrottleLimited = false
    calculatedThrottle = 0
    WasInCruise = false
    apThrottleSet = false -- Do not save this, because when they re-enter, throttle won't be set anymore
    minAutopilotSpeed = 55 -- Minimum speed for autopilot to maneuver in m/s.  Keep above 25m/s to prevent nosedives when boosters kick in
    reentryMode = false
    hasGear = false
    pitchInput = 0
    pitchInput2 = 0
    yawInput2 = 0
    rollInput = 0
    yawInput = 0
    brakeInput = 0
    rollInput2 = 0
    followMode = false 
    holdingShift = false
    msgText = "empty"

    isBoosting = false -- Dodgin's Don't Die Rocket Govenor
    brakeDistance = 0
    brakeTime = 0
    local maxBrakeDistance = 0
    local maxBrakeTime = 0
    autopilotTargetPlanet = nil
    totalDistanceTrip = 0
    flightTime = 0
    upAmount = 0
    simulatedX = 0
    simulatedY = 0        
    msgTimer = 3
    distance = 0
    lastOdometerOutput = ""
    spaceLand = false
    spaceLaunch = false
    finalLand = false
    abvGndDet = -1
    local myAutopilotTarget=""
    inAtmo = (atmosphere() > 0)
    atmosDensity = atmosphere()
    coreAltitude = c.getAltitude()
    local elementsID = c.getElementIdList()
    lastTravelTime = systime()
    coreMass = c.getConstructMass()
    mousePause = false
    gyroIsOn = nil
    rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
    rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]
    local markers = {}
    damageMessage = ""

    resolutionWidth = ResolutionX
    resolutionHeight = ResolutionY
    atmoTanks = {}
    spaceTanks = {}
    rocketTanks = {}
    local eleTotalMaxHp = 0
    repairArrows = false
    local PlanetaryReference = nil
    galaxyReference = nil
    Kinematic = nil
    maxKinematicUp = nil
    Kep = nil
    HUD = nil
    ATLAS = nil
    AP = nil
    RADAR = nil
    CONTROL = nil
    Animating = false
    Animated = false
    autoRoll = autoRollPreference
    local targetGroundAltitude = LandingGearGroundHeight -- So it can tell if one loaded or not
    stalling = false
    targetRoll = 0
    adjustedAtmoSpeedLimit = AtmoSpeedLimit
    VtPitch = 0
    orbitMsg = nil
    orbitalParams = { VectorToTarget = false } 
    OrbitTargetOrbit = 0
    OrbitAchieved = false
    local SpaceEngineVertUp = false
    SpaceEngineVertDn = false
    SpaceEngines = false
    constructUp = vec3(c.getConstructWorldOrientationUp())
    constructForward = vec3(c.getConstructWorldOrientationForward())
    constructRight = vec3(c.getConstructWorldOrientationRight())
    coreVelocity = vec3(c.getVelocity())
    constructVelocity = vec3(c.getWorldVelocity())
    velMag = vec3(constructVelocity):len()
    worldVertical = vec3(c.getWorldVertical())
    vSpd = -worldVertical:dot(constructVelocity)
    worldPos = vec3(c.getConstructWorldPos())
    UpVertAtmoEngine = false
    antigravOn = false
    setCruiseSpeed = nil
    throttleMode = true
    adjustedPitch = 0
    adjustedRoll = 0
    AtlasOrdered = {}
    notPvPZone = false
    pvpDist = 50000
    ReversalIsOn = nil
    contacts = {}
    nearPlanet = u.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000)
    collisionAlertStatus = false
    collisionTarget = nil

    apButtonsHovered = false
    apScrollIndex = 0
    passengers = nil
    ships = nil
    planetAtlas = {}
    scopeFOV = 90
    oldShowHud = showHud

-- Function Definitions that are used in more than one areause 
    --[[    -- EliasVilld Log Code - To use uncomment all Elias sections and put the two lines below around code to be measured.
            -- local t0 = s.getTime()
            -- <code to be checked>
            -- _logCompute.addValue(s.getTime() - t0)
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
    --
    function p(msg)
        s.print(time..": "..msg)
    end
    --]]

    function play(sound, ID, type)
        if (type == nil and not voices) or (type ~= nil and not alerts) or soundFolder == "archHUD" then return end
        if type ~= nil then
            if type == 2 then
                s.logInfo("sound_loop|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
            else
                s.logInfo("sound_notification|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
            end
        else
            s.logInfo("sound_q|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
        end
    end

    function addTable(table1, table2) -- Function to add two tables together
        for k,v in pairs(table2) do
            if type(k)=="string" then
                table1[k] = v
            else
                table1[#table1 + 1 ] = table2[k]
            end
        end
        return table1
    end

    function saveableVariables(subset) -- returns saveable variables by catagory
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

    local function svgText(x, y, text, class, style) -- processes a svg text string, saves code lines by doing it this way
        if class == nil then class = "" end
        if style == nil then style = "" end
        return stringf([[<text class="%s" x=%s y=%s style="%s">%s</text>]], class,x, y, style, text)
    end

    function float_eq(a, b) -- float equation
        if a == 0 then
            return mabs(b) < 1e-09
        end
        if b == 0 then
            return mabs(a) < 1e-09
        end
        return mabs(a - b) < math.max(mabs(a), mabs(b)) * epsilon
    end

    function getDistanceDisplayString(distance, places) -- Turn a distance into a string to a number of places
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

    function FormatTimeString(seconds) -- Format a time string for display
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

    function SaveDataBank(copy) -- Save values to the databank.
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

-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
    function script.onStart()
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
                    if LastVersionUpdate < 1.500 then
                        if LowOrbitHeight < 2000 then
                            msgText = "Updating LowOrbitHeight to new minimum default of 2000."
                            LowOrbitHeight = 2000
                        end
                    end
                    LastVersionUpdate = VERSION_NUMBER
                else
                    msgText = "No databank found. Attach one to control u and rerun \nthe autoconfigure to save preferences and locations"
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

                local eleName = c.getElementNameById
                local checkTanks = (fuelX ~= 0 and fuelY ~= 0)
                for k in pairs(elementsID) do --Look for space engines, landing gear, fuel tanks if not slotted and c size
                    local type = c.getElementTypeById(elementsID[k])
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
                    s.freeze(1)
                else
                    s.freeze(0)
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
                    maxKinematicUp = c.getMaxKinematicsParametersAlongAxis("ground", c.getConstructOrientationUp())[1]
                end
            
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

                local altTable = { [1]=4480, [6]=4480, [7]=6270} -- Alternate altitudes for madis, sinnen, sicari
                for galaxyId,galaxy in pairs(atlas) do
                    -- Create a copy of Space with the appropriate SystemId for each galaxy
                    atlas[galaxyId][0] = getSpaceEntry()
                    atlas[galaxyId][0].systemId = galaxyId
                    atlasCopy[galaxyId] = {} -- Prepare a copy galaxy

                    for planetId,planet in pairs(atlas[galaxyId]) do
                        planet.gravity = planet.gravity/9.8
                        planet.center = vec3(planet.center)
                        planet.name = planet.name[1]
                
                        planet.noAtmosphericDensityAltitude = planet.atmosphereThickness or (planet.atmosphereRadius-planet.radius)
                        planet.spaceEngineMinAltitude = altTable[planet.id] or 0.68377*(planet.atmosphereThickness or (planet.atmosphereRadius-planet.radius))
                                
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
                PlanetaryReference = PlanetRef(Nav, c, u, s, stringf, uclamp)
                galaxyReference = PlanetaryReference(atlasCopy)
                -- Setup Modular Classes
                Kinematic = Kinematics(Nav, c, u, s, msqrt)
                Kep = Keplers(Nav, c, u, s, msqrt)

                ATLAS = AtlasClass(Nav, c, u, s, dbHud_1, atlas, sysUpData, sysAddData, mfloor, tonum, msqrt)
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

            AP = APClass(Nav, c, u, s, atlas, vBooster, hover, telemeter_1, antigrav,
                mabs, mfloor, atmosphere, isRemote, atan, systime, uclamp, 
                navCom, sysUpData, sysIsVwLock, msqrt, round)
            SetupChecks() -- All the if-thens to set up for particular ship.  Specifically override these with the saved variables if available
          
            coroutine.yield() -- Just to make sure

            atlasSetup()
            RADAR = RadarClass(c, s, library, radar_1, radar_2, 
                mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag)
            HUD = HudClass(Nav, c, u, s, atlas, radar_1, radar_2, antigrav, hover, shield_1,
                mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, 
                navCom, sysDestWid, sysIsVwLock, msqrt, round, svgText)
            HUD.ButtonSetup()
            CONTROL = ControlClass(Nav, c, u, s, atlas, vBooster, hover, antigrav, shield_1, dbHud_2,
                isRemote, navCom, sysIsVwLock, sysLockVw, sysDestWid, round, stringmatch, tonum, uclamp)
            coroutine.yield()
 
            u.hide()
            s.showScreen(1)
            s.showHelper(0)
            -- That was a lot of work with dirty strings and json.  Clean up
            collectgarbage("collect")
            -- Start timers
            coroutine.yield()

            u.setTimer("apTick", apTickRate)
            u.setTimer("radarTick", apTickRate)
            u.setTimer("hudTick", hudTickRate)
            u.setTimer("oneSecond", 1)
            u.setTimer("tenthSecond", 1/10)
            u.setTimer("fiveSecond", 5) 
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
        c.hide()
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
        play("stop","SU")
        --[[ --EliasVilld Log Code for printing timing checks.
        for _,s in pairs(Logs.getLogs()) do
            s.print(s)
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
            u.stopTimer("contact")
        elseif timerId == "tenthSecond" then -- Timer executed ever tenth of a second
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
                        gravity = c.g()
                    end
                    gravity = round(gravity, 5) -- round to avoid insignificant updates
                    if (force ~= nil and force) or (lastMaxBrakeAtG == nil or lastMaxBrakeAtG ~= gravity) then
                        local speed = coreVelocity:len()
                        local maxBrake = jdecode(u.getData()).maxBrake 
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
                if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed or navCom:getTargetSpeed(axisCommandId.longitudinal) ~= setCruiseSpeed then
                    AP.cmdCruise(setCruiseSpeed)
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
            HUD.TenthTick()

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
                    local eleHp = c.getElementHitPointsById
    
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
                            _autoconf.displayCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true)
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

            passengers = c.getPlayersOnBoard()
            ships = c.getDockedConstructs()
            updateWeapons()
            -- Update odometer output string
            local newContent = {}
            HUD.OneSecond(newContent)

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
        elseif timerId == "msgTick" then -- Timer executed whenever msgText is applied somwehere
            -- This is used to clear a message on screen after a short period of time and then stop itself
            local newContent = {}
            HUD.DisplayMessage(newContent, "empty")
            msgText = "empty"
            u.stopTimer("msgTick")
            msgTimer = 3
        elseif timerId == "animateTick" then -- Timer for animation
            Animated = true
            Animating = false
            simulatedX = 0
            simulatedY = 0
            u.stopTimer("animateTick")
        elseif timerId == "hudTick" then -- Timer for all hud updates not called elsewhere
            HUD.hudtick()
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
            u.stopTimer("tagTick")
        end
    end

    function script.onFlush()
        -- Local functions for onFlush
            local function composeAxisAccelerationFromTargetSpeedV(commandAxis, targetSpeed)

                local axisCRefDirection = vec3()
                local axisWorldDirection = vec3()
            
                if (commandAxis == axisCommandId.longitudinal) then
                    axisCRefDirection = vec3(c.getConstructOrientationForward())
                    axisWorldDirection = constructForward
                elseif (commandAxis == axisCommandId.vertical) then
                    axisCRefDirection = vec3(c.getConstructOrientationUp())
                    axisWorldDirection = constructUp
                elseif (commandAxis == axisCommandId.lateral) then
                    axisCRefDirection = vec3(c.getConstructOrientationRight())
                    axisWorldDirection = constructRight
                else
                    return vec3()
                end
            
                local gravityAcceleration = vec3(c.getWorldGravity())
                local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
            
                local airResistanceAcceleration = vec3(c.getWorldAirFrictionAcceleration())
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
                    axisCRefDirection = vec3(c.getConstructOrientationForward())
                    axisWorldDirection = constructForward
                elseif (commandAxis == axisCommandId.vertical) then
                    axisCRefDirection = vec3(c.getConstructOrientationUp())
                    axisWorldDirection = constructUp
                elseif (commandAxis == axisCommandId.lateral) then
                    axisCRefDirection = vec3(c.getConstructOrientationRight())
                    axisWorldDirection = constructRight
                else
                    return vec3()
                end
            
                local gravityAcceleration = vec3(c.getWorldGravity())
                local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
            
                local airResistanceAcceleration = vec3(c.getWorldAirFrictionAcceleration())
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

        if antigrav and not ExternalAGG then
            if not antigravOn and antigrav.getBaseAltitude() ~= AntigravTargetAltitude then 
                antigrav.setBaseAltitude(AntigravTargetAltitude) 
            end
        end

        throttleMode = (navCom:getAxisCommandType(0) == axisCommandType.byThrottle)
    
        if throttleMode and WasInCruise then
            -- Not in cruise, but was last tick
            AP.cmdThrottle(0)
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
        local finalPitchInput = uclamp(pitchInput + pitchInput2 + s.getControlDeviceForwardInput(),-1,1)
        local finalRollInput = uclamp(rollInput + rollInput2 + s.getControlDeviceYawInput(),-1,1)
        local finalYawInput = uclamp((yawInput + yawInput2) - s.getControlDeviceLeftRightInput(),-1,1)
        local finalBrakeInput = brakeInput

        -- Axis
        worldVertical = vec3(c.getWorldVertical()) -- along gravity
        if worldVertical == nil or worldVertical:len() == 0 then
            worldVertical = (planet.center - worldPos):normalize() -- I think also along gravity hopefully?
        end

        constructUp = vec3(c.getConstructWorldOrientationUp())
        constructForward = vec3(c.getConstructWorldOrientationForward())
        constructRight = vec3(c.getConstructWorldOrientationRight())
        constructVelocity = vec3(c.getWorldVelocity())
        coreVelocity = vec3(c.getVelocity())
        worldPos = vec3(c.getConstructWorldPos())
        coreMass =  c.getConstructMass()
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
        local constructAngularVelocity = vec3(c.getWorldAngularVelocity())
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
        local wheel = s.getMouseWheel()

        if wheel > 0 then
            AP.changeSpd()
        elseif wheel < 0 then
            AP.changeSpd(true)
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
                if (brakeInput ~= 0 or autoNavigationUseBrake or mabs(constructVelocityDir:dot(constructForward)) < 0.5)
                then
                    autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
                end
                Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '',
                    '', tolerancePercentToSkipOtherPriorities)
            end
        end

        -- Rotation
        local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
        local airAcceleration = vec3(c.getWorldAirFrictionAngularAcceleration())
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
                if done then s.print("ERROR STARTUP: "..done) end
            elseif cont == "dead" then
                SetupComplete = true
            end
        end
        if SetupComplete then
            Nav:update()
            if not Animating and content ~= LastContent then
                s.setScreen(content) 
            end
            LastContent = content
        end
    end

    function script.onActionStart(action)
        CONTROL.startControl(action)
    end

    function script.onActionStop(action)
        CONTROL.stopControl(action)
    end

    function script.onActionLoop(action)
        CONTROL.loopControl(action)
    end

    function script.onInputText(text)
        CONTROL.inputTextControl(text)
    end

    function script.onEnter(id)
        if radar_1 and not inAtmo and not notPvPZone then 
            u.setTimer("contact",0.1) 
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