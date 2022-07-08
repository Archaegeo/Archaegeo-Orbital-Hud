function baseClass(N, C, U, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield, gyro, warpdrive, weapon, screenHud_1)
    local S = DUSystem
    local c = DUConstruct
    local P = DUPlayer

    -- Local variables
        local base = {}
    -- Local Redefines
        local stringf = string.format
        local jdecode = json.decode
        local jencode = json.encode
        local stringmatch = string.match
        local msqrt = math.sqrt
        local tonum = tonumber
        local mabs = math.abs
        local mfloor = math.floor
        local uclamp = utils.clamp
    -- Local Functions
        local function float_eq(a, b) -- float equation
            if a == 0 then
                return mabs(b) < 1e-09
            end
            if b == 0 then
                return mabs(a) < 1e-09
            end
            return mabs(a - b) < math.max(mabs(a), mabs(b)) * epsilon
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
                p("Saved Variables to Datacore")
                if copy and dbHud_2 then
                    p("Databank copied.  Remove copy when ready.")
                end
            end
        end
        local function getDistanceDisplayString(distance, places) -- Turn a distance into a string to a number of places
            local function round(num, numDecimalPlaces) -- rounds variable num to numDecimalPlaces
                local mult = 10 ^ (numDecimalPlaces or 0)
                return mfloor(num * mult + 0.5) / mult
            end
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
                return minutes .. "m " .. seconds .. "S"
            elseif seconds > 0 then 
                return seconds .. "S"
            else
                return "0s"
            end
        end

    -- Class Functions
        function base.onStart() -- the function called when you first sit down
            -- Local functions for onStart
                local valuesAreSet = false
                local function LoadVariables() -- Databank variable loading

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
                            p("Updated user preferences used.  Will be saved when you exit seat.\nToggle off useTheseSettings to use saved values")
                            valuesAreSet = false
                        end
                        coroutine.yield()
                        if valuesAreSet then
                            p("Loaded Saved Variables")
                        elseif not useTheseSettings then
                            p("No Databank Saved Variables Found\nVariables will save to Databank on standing")
                        end
                    else
                        p("No databank found. Attach one to control U and rerun \nthe autoconfigure to save preferences and locations")
                    end
                    resolutionWidth = S.getScreenWidth()
                    resolutionHeight = S.getScreenHeight()
                    MaxGameVelocity = c.getMaxSpeed()-0.1
                end

                local function ProcessElements() -- Processing of elements
                    local elementsID = C.getElementIdList()
                    for k in pairs(elementsID) do --Look for space engines, landing gear, fuel tanks if not slotted and C size
                        local type = C.getElementDisplayNameById(elementsID[k])
                        --[[ EXAMPLES
                            if stringmatch(type, '^.*Space Engine$') then
                            end
                            if (type == "Landing Gear") then
                            end
                        --]]
                    end
                end
                
                local function SetupChecks() -- Things to check on startup
                    pitchInput = 0
                    rollInput = 0
                    yawInput = 0
                    BrakeIsOn = "Startup"
                    N.axisCommandManager:setupCustomTargetSpeedRanges(axisCommandId.longitudinal, {1000, 5000, 10000, 20000, 30000})
                    N.axisCommandManager:setTargetGroundAltitude(4)

                    -- freeze the player in he is remote controlling the construct
                    if U.isRemoteControlled() == 1 then
                        P.freeze(1)
                    end

                    gearExtended = (U.isAnyLandingGearDeployed() == 1) -- make sure it's a lua boolean
                    if gearExtended then
                        U.deployLandingGears()
                    else
                        U.retractLandingGears()
                    end
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

                    local altTable = { [1]=4480, [6]=4480, [7]=6270, [27]=8437 } -- Alternate min space engine altitudes for madis, sinnen, sicari, haven
                    -- No Atmo Heights for Madis, Alioth, Thades, Talemai, Feli, Sicari, Sinnen, Teoma, Jago, Sanctuary, Haven, Lacobus, Symeon, Ion.
                    local noAtmoAlt = {[1]=8041,[2]=6263,[3]=39281,[4]=10881,[5]=78382,[6]=8761,[7]=11616,[8]=6272,[9]=10891,[26]=7791,[27]=15554,[100]=12511,[110]=7792,[120]=11766} 
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
                    PlanetaryReference = PlanetRef(N, C, U, S, stringf, uclamp, tonum, msqrt, float_eq)
                    galaxyReference = PlanetaryReference(atlasCopy)
                    -- Setup Modular Classes
                    Kinematic = Kinematics(N, C, U, S, msqrt, mabs)
                    Kep = Keplers(N, C, U, S, stringf, uclamp, tonum, msqrt, float_eq)

                    ATLAS = AtlasClass(N, C, U, S, atlas)
                    planet = galaxyReference[0]:closestBody(c.getWorldPosition())
                end

            SetupComplete = false

            beginSetup = coroutine.create(function()
                
                -- Load Saved Variables
                LoadVariables() -- Databank variable loading
                coroutine.yield() -- Give it some time to breathe before we do the rest

                -- Find elements we care about
                --ProcessElements() -- Processing of elements
                coroutine.yield() -- Give it some time to breathe before we do the rest


                SetupChecks() -- All the if-thens to set up for particular ship.  Specifically override these with the saved variables if available

                FLIGHT = FlightClass(N, C, U, S) -- AUTOPILOT CLASS (contains onFlush code)

                coroutine.yield() -- Just to make sure

                atlasSetup() -- SETUP ATLAS
                if radar_1 and RadarClass then RADAR = RadarClass(C, S, U, radar_1, radar_2) end

                if HudClass then 
                    HUD = HudClass(N, C, U, S, antigrav, warpdrive, gyro, shield, weapon)
                end
                CONTROL = ControlClass(N, C, U, S, antigrav, saveableVariables, SaveDataBank) -- User Controls
                if shield and ShieldClass then SHIELD = ShieldClass(shield) end
                coroutine.yield()
                S.showScreen(1)
                S.showHelper(0)
                if screenHud_1 then screenHud_1.clear() end
                -- Start timers
                coroutine.yield()


                if userBase then BASE.ExtraOnStart() end
            end)
            coroutine.resume(beginSetup)
        end
        
        function base.onUpdate() -- the function called by Update, executes 60 times a second or framerate fps, whichever is lower
            if not SetupComplete then
                local cont = coroutine.status (beginSetup)
                if cont == "suspended" then 
                    local value, done = coroutine.resume(beginSetup)
                    if done then p("ERROR STARTUP: "..done) end
                elseif cont == "dead" then
                    SetupComplete = true
                end
            end
            if SetupComplete then
                N:update()
                if userBase then BASE.ExtraOnUpdate() end
            end
        end

        function base.onFlush() -- on Flush, meant for flight physics, executes 60 times a second regardless of framerate
            if SetupComplete then
                FLIGHT.onFlush()
                if userBase then BASE.ExtraOnFlush() end
            end
        end

        function base.onStop() -- the function call when the script stops
            _autoconf.hideCategoryPanels()
            if antigrav ~= nil then antigrav.hideWidget() end
            if warpdrive ~= nil then warpdrive.hideWidget() end
            if gyro ~= nil then gyro.hideWidget() end
            C.hideWidget()
            U.switchOffHeadlights()
            SaveDataBank()
            if userBase then BASE.ExtraOnStop() end
        end

        function base.controlStart(action) -- Called whenever a control key is used
            if SetupComplete then
                CONTROL.startControl(action)
            end
        end

        function base.controlStop(action) -- called whenever a control key is released
            if SetupComplete then
                CONTROL.stopControl(action)
            end
        end

        function base.controlLoop(action) -- called when a control key is held down
            if SetupComplete then
                CONTROL.loopControl(action)
            end
        end

        function base.controlInput(text) -- called when input is typed into lua chat
            if SetupComplete then
                CONTROL.inputTextControl(text)
            end
        end

        function base.radarEnter(id) -- called whenever a radar contact enters radar range
            if RADAR then RADAR.onEnter(id) end
        end

        function base.radarLeave(id) -- called whenever a radar contact leaves radar range
            if RADAR then RADAR.onLeave(id) end
        end

        function base.onTick(timerId)  -- called to execute tick timers in various classes if set up in onStart or elsewhere
            -- Tick calls to various Class files
        end

    if userBase then -- support for extra functions not defined here
        for k,v in pairs(userBase) do base[k] = v end 
    end  

    return base
end