function programClass(Nav, c, u, s, library, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield_1, gyro, warpdrive, weapon, screenHud_1)
    
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
        local systime = s.getTime
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
                    if #SavedLocations>0 then customlocations = addTable(customlocations, SavedLocations) end
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
                if pcall(require, "autoconf/custom/archhud/privatelocations") then
                    if #privatelocations>0 then customlocations = addTable(customlocations, privatelocations) end
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
                    BrakeIsOn = "Startup"
                    GearExtended = true
                    if hasGear then
                        Nav.control.extendLandingGears()
                    end
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
                        if planet.name == "Lacobus" then planet.noAtmosphericDensityAltitude = 12510 end
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

            AP = APClass(Nav, c, u, s, atlas, vBooster, hover, telemeter_1, antigrav, warpdrive, dbHud_1,
                mabs, mfloor, atmosphere, isRemote, atan, systime, uclamp, 
                navCom, sysUpData, sysIsVwLock, msqrt, round, play, addTable, float_eq, 
                getDistanceDisplayString, FormatTimeString, SaveDataBank, jdecode, stringf, sysAddData)

            SetupChecks() -- All the if-thens to set up for particular ship.  Specifically override these with the saved variables if available

            coroutine.yield() -- Just to make sure

            atlasSetup()
            if radar_1 then RADAR = RadarClass(c, s, u, library, radar_1, radar_2, 
            mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) end
            HUD = HudClass(Nav, c, u, s, atlas, radar_1, radar_2, antigrav, hover, shield_1, warpdrive, weapon,
            mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, 
            navCom, sysAddData, sysUpData, sysDestWid, sysIsVwLock, msqrt, round, svgText, play, addTable, saveableVariables,
            getDistanceDisplayString, FormatTimeString, elementsID, eleTotalMaxHp)
            HUD.ButtonSetup()
            CONTROL = ControlClass(Nav, c, u, s, atlas, vBooster, hover, antigrav, shield_1, dbHud_2, gyro, screenHud_1,
                isRemote, navCom, sysIsVwLock, sysLockVw, sysDestWid, round, stringmatch, tonum, uclamp, play, saveableVariables, SaveDataBank)
            if shield_1 then SHIELD = ShieldClass(shield_1, stringmatch, mfloor) end
            coroutine.yield()
            u.hide()
            s.showScreen(1)
            s.showHelper(0)
            if screenHud_1 then screenHud_1.clear() end
            -- That was a lot of work with dirty strings and json.  Clean up
            collectgarbage("collect")
            -- Start timers
            coroutine.yield()

            u.setTimer("apTick", apTickRate)
            if radar_1 then u.setTimer("radarTick", apTickRate) end
            u.setTimer("hudTick", hudTickRate)
            u.setTimer("oneSecond", 1)
            u.setTimer("tenthSecond", 1/10)
            u.setTimer("fiveSecond", 5) 
            if shield_1 then u.setTimer("shieldTick", apTickRate) end
            if userOnStart then
                userOnStart(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
            end
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
            if userOnUpdate then
                userOnUpdate(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
            end
            LastContent = content
        end
    end

    function program.onFlush()
        if SetupComplete then
            AP.onFlush()
            if userOnFlush then
                userOnFlush(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
            end
        end
    end

    function program.onStop()
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
        s.print(HUD.FuelUsed("atmofueltank")..", "..HUD.FuelUsed("spacefueltank")..", "..HUD.FuelUsed("rocketfueltank"))
        if userOnStop then
            userOnStop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1)
        end
        play("stop","SU")
    end

    function program.controlStart(action)
        if SetupComplete then
            CONTROL.startControl(action)
            if userControlStart then
                userControlStart(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
            end
        end
    end

    function program.controlStop(action)
        if SetupComplete then
            CONTROL.stopControl(action)
            if userControlStop then
                userControlStop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
            end
        end
    end

    function program.controlLoop(action)
        if SetupComplete then
            CONTROL.loopControl(action)
            if userControlLoop then
                userControlLoop(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, action)
            end
        end
    end

    function program.controlInput(text)
        if SetupComplete then
            CONTROL.inputTextControl(text)
            if userControlInput then
                userControlInput(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, text)
            end
        end
    end

    function program.radarEnter(id)
        RADAR.onEnter(id)
        if userRadarEnter then
            userRadarEnter(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, id)
        end
    end

    function program.radarLeave(id)
        RADAR.onLeave(id)
        if userRadarLeave then
            userRadarLeave(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, id)
        end
    end

    function program.onTick(timerId)
        if timerId == "tenthSecond" then -- Timer executed ever tenth of a second
            AP.TenthTick()
            HUD.TenthTick()
        elseif timerId == "oneSecond" then -- Timer for evaluation every 1 second
            HUD.OneSecondTick()
        elseif timerId == "fiveSecond" then -- Timer executed every 5 seconds (SatNav only stuff for now)
            AP.SatNavTick()
        elseif timerId == "msgTick" then -- Timer executed whenever msgText is applied somwehere
            HUD.MsgTick()
        elseif timerId == "animateTick" then -- Timer for animation
            HUD.AnimateTick()
        elseif timerId == "hudTick" then -- Timer for all hud updates not called elsewhere
            HUD.hudtick()
        elseif timerId == "apTick" then -- Timer for all autopilot functions
            AP.APTick()
        elseif timerId == "radarTick" then
            RADAR.UpdateRadar()
        elseif timerId == "shieldTick" then
            SHIELD.shieldTick()
        elseif timerId == "tagTick" then
            CONTROL.tagTick()
        elseif timerId == "contact" then
            RADAR.ContactTick()
        end
        if userOnTick then
            userOnTick(Nav, c, u, s, atlas, radar_1, radar_2, vBooster, hover, antigrav, hover, shield_1, warpdrive, weapon, dbHud_1, dbHud_2, gyro, screenHud_1, timerId)
        end
    end

    return program
end