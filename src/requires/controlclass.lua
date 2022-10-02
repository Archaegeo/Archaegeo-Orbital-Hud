function ControlClass(Nav, c, u, s, atlas, vBooster, hover, antigrav, shield, dbHud_2, gyro, screenHud_1,
    isRemote, navCom, sysIsVwLock, sysLockVw, sysDestWid, round, stringmatch, tonum, uclamp, play, saveableVariables, SaveDataBank)
    local C = DUConstruct
    local Control = {}
    local UnitHidden = true
    local holdAltitudeButtonModifier = 5
    local antiGravButtonModifier = 5
    local currentHoldAltModifier = holdAltitudeButtonModifier
    local currentAggModifier = antiGravButtonModifier
    local clearAllCheck = time

    function Control.landingGear(eLL)
        GearExtended = not GearExtended
        if GearExtended then
            VectorToTarget = false
            LockPitch = nil
            AP.cmdThrottle(0)
            if vBooster or hover then 
                if (inAtmo or coreAltitude < 20000) and not eLL then
                    play("bklOn", "BL")
                    StrongBrakes = true -- We don't care about this anymore
                    Reentry = false
                    AutoTakeoff = false
                    VertTakeOff = false
                    if IntoOrbit then AP.ToggleIntoOrbit() end
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
                AltitudeHold = false
                HoverMode = false
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
                            HoverMode = false 
                        else
                            HoldAltitude = HoldAltitude + mult*holdAltitudeButtonModifier
                            if HoverMode then 
                                if HoldAltitude > 100 then 
                                    HoverMode = false 
                                else
                                    navCom:updateTargetGroundAltitudeFromActionStart(mult*1.0)
                                    HoverMode = Nav:getTargetGroundAltitude()
                                end
                            end
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
            AP.vertical(1)
            if abvGndDet - 3 < LandingGearGroundHeight and coreAltitude > 0 and GearExtended then CONTROL.landingGear() end
        elseif action == "down" then
            AP.vertical(-1)
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
                if RADAR then RADAR.ToggleRadarPanel() end
            end
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
                gyroIsOn = gyro.isActive() == 1
                if gyroIsOn then play("gyOn", "GA") else play("gyOff", "GA") end
            else
                msgText = "No gyro found"
            end
        elseif action == "lshift" then
            if AltIsOn then holdingShift = true end
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
                if AltIsOn then
                    if adjustedAtmoSpeedLimit > 0 then adjustedAtmoSpeedLimit = 0 else adjustedAtmoSpeedLimit = AtmoSpeedLimit end
                elseif PlayerThrottle ~= 0 then
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
            leftmouseclick=true 
            if holdingShift then
                holdingShiftOff() 
                toggleView = false
            else
                    holdingShift = true
                    PrevViewLock = sysIsVwLock()
                    sysLockVw(1)
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
            AP.vertical(0,-1)
        elseif action == "down" then
            AP.vertical(0,1)
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