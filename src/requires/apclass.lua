function APClass(Nav, c, u, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1,
    mabs, mfloor, atmosphere, isRemote, atan, systime, uclamp, 
    navCom, sysUpData, sysIsVwLock, msqrt, round, play, addTable, float_eq,
    getDistanceDisplayString, FormatTimeString, SaveDataBank, jdecode)  
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
        local shipsMass = 0

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
        local vMaxDistance
        local hMaxDistance
        if hover then hMaxDistance = hover.getMaxDistance()*2 end
        if vBooster then vMaxDistance = vBooster.getMaxDistance()*2 end
        local function AboveGroundLevel()
            local function hoverDetectGround()
                local vgroundDistance = -1
                local hgroundDistance = -1
                if vBooster then
                    vgroundDistance = vBooster.getDistance()
                    if vgroundDistance > vMaxDistance then vgroundDistance = -1 end
                end
                if hover then
                    hgroundDistance = hover.getDistance()
                    if hgroundDistance > hMaxDistance then hgroundDistance = -1 end
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
                if groundDistance == 0 then groundDistance = -1 end
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
            CONTROL.landingGear(eLL)
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

    local function vertical(factor,stop)
        if stop then
            upAmount = 0
            navCom:updateCommandFromActionStop(axisCommandId.vertical, stop)
            if stablized then 
                navCom:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
                sEFC = true
            end
        else
            upAmount = upAmount + factor
            navCom:deactivateGroundEngineAltitudeStabilization()
            navCom:updateCommandFromActionStart(axisCommandId.vertical, factor)
        end
    end

    function ap.vertical(factor, stop)
        vertical(factor,stop)
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
        HoverMode = false
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
            HoverMode = false
            if planet.hasAtmosphere then
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
        if nearPlanet and not inAtmo and abvGndDet == -1 then
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
            if abvGndDet ~= -1 then 
                if not GearExtended and not VectorToTarget then
                    HoldAltitude = coreAltitude 
                    HoverMode = abvGndDet
                    navCom:setTargetGroundAltitude(HoverMode)
                elseif velMag < 20 then
                    if GearExtended then CONTROL.landingGear() end
                    play("lfs", "LS")
                    AutoTakeoff = true
                    if inAtmo then 
                        HoldAltitude = coreAltitude + AutoTakeoffAltitude 
                    else
                        HoldAltitude = planet.surfaceMaxAltitude+100  
                    end
                    BrakeIsOn = "ATO Hold"
                    navCom:setTargetGroundAltitude(TargetHoverHeight)
                    if VertTakeOffEngine and UpVertAtmoEngine then 
                        AP.ToggleVerticalTakeoff()
                    end
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
            HoverMode = false
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
        ships = C.getDockedConstructs() 
        passengers = C.getPlayersOnBoard()
        shipsMass = 0
        for i=1, #ships do
            shipsMass = shipsMass + C.getDockedConstructMass(ships[i])
        end
        local passengersMass = 0
        for i=1, #passengers do
            passengersMass = passengersMass + C.getBoardedPlayerMass(passengers[i])
        end
        if passengersMass > 20000 then shipsMass = shipsMass + passengersMass - 20000 end
        notPvPZone, pvpDist = safeZone()
        MaxSpeed = C.getMaxSpeed()  
        if AutopilotTargetName ~= "None" and (autopilotTargetPlanet or CustomTarget) then
            travelTime = GetAutopilotTravelTime() -- This also sets AutopilotDistance so we don't have to calc it again
        end
        RefreshLastMaxBrake(nil, true) -- force refresh, in case we took damage
    end



    -- Local functions and static variables for onFlush
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
        -- Engine commands
        local keepCollinearity = 1 -- for easier reading
        local dontKeepCollinearity = 0 -- for easier reading
        local tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities
        local MousePitchFactor = 1 -- Mouse control only
        local MouseYawFactor = 1 -- Mouse control only
        local spaceBrake = false
    function ap.onFlush()
        if antigrav and not ExternalAGG and not antigravOn and antigrav.getBaseAltitude() ~= AntigravTargetAltitude then
                sba = AntigravTargetAltitude
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
        coreMass =  C.getMass() + shipsMass
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
        local targetAngularVelocity = finalPitchInput * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward +
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
                    simulatedX = uclamp(simulatedX + deltaX/2,-ResolutionX/2,ResolutionX/2)
                    simulatedY = uclamp(simulatedY + deltaY/2,-ResolutionY/2,ResolutionY/2)
                end
            else
                simulatedX = 0
                simulatedY = 0 -- Reset after they do view things, and don't keep sending inputs while unlocked view
                -- Except of course autopilot, which is later.
            end
        else
            simulatedX = uclamp(simulatedX + deltaX/2,-ResolutionX/2,ResolutionX/2)
            simulatedY = uclamp(simulatedY + deltaY/2,-ResolutionY/2,ResolutionY/2)
            mouseDistance = msqrt(simulatedX * simulatedX + simulatedY * simulatedY)
            if not holdingShift and isRemote() == 0 then -- Draw deadzone circle if it's navigating
                local dx,dy = 1,1
                if SelectedTab == "SCOPE" then
                    dx,dy = (scopeFOV/90),(scopeFOV/90)
                end
                if userControlScheme == "virtual joystick" then -- Virtual Joystick
                    -- Do navigation things

                    if mouseDistance > DeadZone then
                        yawInput2 = yawInput2 - (uclamp(mabs(simulatedX)-DeadZone,0,ResolutionX/2)*utils.sign(simulatedX)) * MouseXSensitivity * dx
                        pitchInput2 = pitchInput2 - (uclamp(mabs(simulatedY)-DeadZone,0,ResolutionY/2)*utils.sign(simulatedY)) * MouseYSensitivity * dy
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
                aligned = AlignToWorldVector(CustomTarget.position-worldPos,0.1) 
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
            local orbitHeightString = getDistanceDisplayString(OrbitTargetOrbit,3)

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
                        if (orbitCheck() or OrbitAchieved) and not MaintainOrbit then -- This should get us a stable orbit within 10% with the way we do it
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
                            if orbitCheck() then 
                                orbitMsg = "Maintaining " 
                            else
                                orbitMsg = "Adjusting " 
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
                            orbitMsg = orbitMsg .." - OrbitHeight: "..orbitHeightString
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
                ProgradeIsOn = false
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
                    if not TurnBurn then 
                        ProgradeIsOn = true 
                        autoRoll = true
                    end
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
                    if not TurnBurn then 
                        ProgradeIsOn = true 
                        autoRoll = true
                    end
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
            local pos = vec3(DUPlayer.getWorldPosition()) -- Is this related to c forward or nah?
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
            if HoverMode then 
                if abvGndDet == -1 then 
                    HoldAltitude = HoldAltitude - 0.2 
                else
                    HoldAltitude = coreAltitude + (HoverMode - abvGndDet) 
                end
            end
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
            if not inAtmo and abvGndDet == -1 and (AltitudeHold and HoldAltitude > planet.noAtmosphericDensityAltitude) and not (spaceLaunch or IntoOrbit or Reentry ) then
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
                    spaceBrake = false
                    if not throttleMode then
                        cmdT = 0
                    end
                    navCom:setTargetGroundAltitude(500)
                    navCom:activateGroundEngineAltitudeStabilization(500)
                    stablized = true
                    if not inAtmo then spaceBrake = true end
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
                            if not aggBase and not GearExtended then
                                eLL = true
                                navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                            end
                            if (velMag < 1 or constructVelocity:normalize():dot(worldVertical) < 0) and not alignHeading and groundDistance-5 < LandingGearGroundHeight then -- Or if they start going back up
                                BrakeLanding = false
                                AltitudeHold = false
                                upAmount = 0
                                if spaceBrake then
                                    vertical(0,1)
                                end
                                BrakeIsOn = "BL Complete"
                                autoRoll = autoRollPreference 
                                apBrk = false
                                initBL = false
                            else
                                if vSpd < -5 or absHspd > 0.05 then 
                                    BrakeIsOn = "BL Slowing"
                                else
                                    BrakeIsOn = false
                                end
                            end
                    elseif not skipLandingRate then
                        if StrongBrakes and (constructVelocity:normalize():dot(-up) < 0.999) then
                            BrakeIsOn = "BL Strong"
                            AlignToWorldVector()
                        elseif absHspd > 10 or (absHspd > 0.05 and apBrk) then
                            BrakeIsOn = "BL hSpd"
                        elseif vSpd < -brakeLandingRate then
                            BrakeIsOn = "BL BLR"
                            if spaceBrake then
                                vertical(0,1)
                            end
                        else
                            if spaceBrake then
                                vertical(-1)
                            end
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
            if ExtraEscapeThrust > 0 and not Reentry and atmosDensity > 0.005 and atmosDensity < 0.1 and vSpd > -10 then
                local fbs = C.getFrictionBurnSpeed() * ExtraEscapeThrust
                local aasl = adjustedAtmoSpeedLimit/3.6
                if fbs > aasl then addThrust = fbs - aasl - 1 end
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
            if ExtraLongitudeTags ~= "none" and (UseExtra=="All" or UseExtra=="Longitude") then longitudinalEngineTags = longitudinalEngineTags..ExtraLongitudeTags end
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
            if ExtraLateralTags ~= "none" and (UseExtra=="All" or UseExtra=="Lateral") then lateralStrafeEngineTags = lateralStrafeEngineTags..ExtraLateralTags end
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
            if ExtraVerticalTags ~= "none" and (UseExtra=="All" or UseExtra=="Vertical") then verticalStrafeEngineTags = verticalStrafeEngineTags..ExtraVerticalTags end
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