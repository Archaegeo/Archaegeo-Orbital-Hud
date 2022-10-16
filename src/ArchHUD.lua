require 'src.slots'
local s=system
local c=core
local u=unit
local C=DUConstruct

local Nav = Navigator.new(s, c, u)
local atlas = require("atlas")

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 0.001
-- These values are a default set for 1920x1080 ResolutionX and Y settings. 

-- User variables. Must be global to work with databank system

-- Ship Handling variables
    -- NOTE: savableVariablesHandling below must contain any Ship Handling variables that needs to be saved/loaded from databank system
-- HUD Postioning variables
    -- NOTE: savableVariablesHud below must contain any HUD Postioning variables that needs to be saved/loaded from databank system
-- Ship flight physics variables - Change with care, can have large effects on ships performance.
    -- NOTE: savableVariablesPhysics below must contain any Ship flight physics variables that needs to be saved/loaded from databank system
    pitchSpeedFactor = 0.8 --export: This factor will increase/decrease the player input along the pitch axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
    yawSpeedFactor =  1 --export: This factor will increase/decrease the player input along the yaw axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
    rollSpeedFactor = 1.5 --export: This factor will increase/decrease the player input along the roll axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    brakeSpeedFactor = 3 --export: When braking, this factor will increase the brake force by brakeSpeedFactor * velocity<br>Valid values: Superior or equal to 0.01
    brakeFlatFactor = 1 --export: When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction><br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    autoRoll = false --export: [Only in atmosphere]<br>When the pilot stops rolling,  flight model will try to get back to horizontal (no roll)
    autoRollFactor = 2 --export: [Only in atmosphere]<br>When autoRoll is engaged, this factor will increase to strength of the roll back to 0<br>Valid values: Superior or equal to 0.01

    turnAssist = true --export: [Only in atmosphere]<br>When the pilot is rolling, the flight model will try to add yaw and pitch to make the construct turn better<br>The flight model will start by adding more yaw the more horizontal the construct is and more pitch the more vertical it is
    turnAssistFactor = 2 --export: [Only in atmosphere]<br>This factor will increase/decrease the turnAssist effect<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    torqueFactor = 2 -- Force factor applied to reach rotationSpeed<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
-- Auto Variable declarations that store status of ship on databank. Do not edit directly here unless you know what you are doing, these change as ship flies.

    ---[[ timestamped print function for debugging
        function p(msg)
            s.print(time..": "..msg)
        end
    --]]

-- Class Definitions to organize code

-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
    function script.onStart()
        pitchInput = 0
        rollInput = 0
        yawInput = 0
        brakeInput = 0

        Nav = Navigator.new(system, core, unit)
        Nav.axisCommandManager:setupCustomTargetSpeedRanges(axisCommandId.longitudinal, {1000, 5000, 10000, 20000, 30000})
        Nav.axisCommandManager:setTargetGroundAltitude(4)

        -- Parenting widget
        parentingPanelId = system.createWidgetPanel("Docking")
        parentingWidgetId = system.createWidget(parentingPanelId,"parenting")
        system.addDataToWidget(unit.getWidgetDataId(),parentingWidgetId)

        -- Combat stress widget
        coreCombatStressPanelId = system.createWidgetPanel("Core combat stress")
        coreCombatStressgWidgetId = system.createWidget(coreCombatStressPanelId,"core_stress")
        system.addDataToWidget(core.getWidgetDataId(),coreCombatStressgWidgetId)

        -- element widgets
        -- For now we have to alternate between PVP and non-PVP widgets to have them on the same side.
        _autoconf.displayCategoryPanel(weapon, weapon_size, L_TEXT("ui_lua_widget_weapon", "Weapons"), "weapon", true)
        core.showWidget()
        _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_periscope", "Periscope"), "periscope")
        placeRadar = true
        if atmofueltank_size > 0 then
            _autoconf.displayCategoryPanel(atmofueltank, atmofueltank_size, L_TEXT("ui_lua_widget_atmofuel", "Atmo Fuel"), "fuel_container")
            if placeRadar then
                _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
                placeRadar = false
            end
        end
        if spacefueltank_size > 0 then
            _autoconf.displayCategoryPanel(spacefueltank, spacefueltank_size, L_TEXT("ui_lua_widget_spacefuel", "Space Fuel"), "fuel_container")
            if placeRadar then
                _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
                placeRadar = false
            end
        end
        _autoconf.displayCategoryPanel(rocketfueltank, rocketfueltank_size, L_TEXT("ui_lua_widget_rocketfuel", "Rocket Fuel"), "fuel_container")
        if placeRadar then -- We either have only rockets or no fuel tanks at all, uncommon for usual vessels
            _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
            placeRadar = false
        end
        if antigrav ~= nil then antigrav.showWidget() end
        if warpdrive ~= nil then warpdrive.showWidget() end
        if gyro ~= nil then gyro.showWidget() end
        if shield ~= nil then shield.showWidget() end

        -- freeze the player in he is remote controlling the construct
        if unit.isRemoteControlled() == 1 then
            player.freeze(1)
        end

        -- landing gear
        -- make sure every gears are synchonized with the first
        gearExtended = (unit.isAnyLandingGearDeployed() == 1) -- make sure it's a lua boolean
        if gearExtended then
            unit.deployLandingGears()
        else
            unit.retractLandingGears()
        end
    end

    function script.onOnStop()
        _autoconf.hideCategoryPanels()
        if antigrav ~= nil then antigrav.hideWidget() end
        if warpdrive ~= nil then warpdrive.hideWidget() end
        if gyro ~= nil then gyro.hideWidget() end
        core.hideWidget()
        unit.switchOffHeadlights()
    end

    function script.onTick(timerId)  

    end

    function script.onOnFlush()
        -- validate params
            pitchSpeedFactor = math.max(pitchSpeedFactor, 0.01)
            yawSpeedFactor = math.max(yawSpeedFactor, 0.01)
            rollSpeedFactor = math.max(rollSpeedFactor, 0.01)
            torqueFactor = math.max(torqueFactor, 0.01)
            brakeSpeedFactor = math.max(brakeSpeedFactor, 0.01)
            brakeFlatFactor = math.max(brakeFlatFactor, 0.01)
            autoRollFactor = math.max(autoRollFactor, 0.01)
            turnAssistFactor = math.max(turnAssistFactor, 0.01)

        -- final inputs
            local finalPitchInput = pitchInput + system.getControlDeviceForwardInput()
            local finalRollInput = rollInput + system.getControlDeviceYawInput()
            local finalYawInput = yawInput - system.getControlDeviceLeftRightInput()
            local finalBrakeInput = brakeInput

        -- Axis
            local worldVertical = vec3(core.getWorldVertical()) -- along gravity
            local constructUp = vec3(construct.getWorldOrientationUp())
            local constructForward = vec3(construct.getWorldOrientationForward())
            local constructRight = vec3(construct.getWorldOrientationRight())
            local constructVelocity = vec3(construct.getWorldVelocity())
            local constructVelocityDir = vec3(construct.getWorldVelocity()):normalize()
            local currentRollDeg = getRoll(worldVertical, constructForward, constructRight)
            local currentRollDegAbs = math.abs(currentRollDeg)
            local currentRollDegSign = utils.sign(currentRollDeg)

        -- Rotation
            local constructAngularVelocity = vec3(construct.getWorldAngularVelocity())
            local targetAngularVelocity = finalPitchInput * pitchSpeedFactor * constructRight
                                            + finalRollInput * rollSpeedFactor * constructForward
                                            + finalYawInput * yawSpeedFactor * constructUp

        -- In atmosphere?
            if worldVertical:len() > 0.01 and unit.getAtmosphereDensity() > 0.0 then
                local autoRollRollThreshold = 1.0
                -- autoRoll on AND currentRollDeg is big enough AND player is not rolling
                if autoRoll == true and currentRollDegAbs > autoRollRollThreshold and finalRollInput == 0 then
                    local targetRollDeg = utils.clamp(0,currentRollDegAbs-30, currentRollDegAbs+30);  -- we go back to 0 within a certain limit
                    if (rollPID == nil) then
                        rollPID = pid.new(autoRollFactor * 0.01, 0, autoRollFactor * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
                    end
                    rollPID:inject(targetRollDeg - currentRollDeg)
                    local autoRollInput = rollPID:get()

                    targetAngularVelocity = targetAngularVelocity + autoRollInput * constructForward
                end
                local turnAssistRollThreshold = 20.0
                -- turnAssist AND currentRollDeg is big enough AND player is not pitching or yawing
                if turnAssist == true and currentRollDegAbs > turnAssistRollThreshold and finalPitchInput == 0 and finalYawInput == 0 then
                    local rollToPitchFactor = turnAssistFactor * 0.1 -- magic number tweaked to have a default factor in the 1-10 range
                    local rollToYawFactor = turnAssistFactor * 0.025 -- magic number tweaked to have a default factor in the 1-10 range

                    -- rescale (turnAssistRollThreshold -> 180) to (0 -> 180)
                    local rescaleRollDegAbs = ((currentRollDegAbs - turnAssistRollThreshold) / (180 - turnAssistRollThreshold)) * 180
                    local rollVerticalRatio = 0
                    if rescaleRollDegAbs < 90 then
                        rollVerticalRatio = rescaleRollDegAbs / 90
                    elseif rescaleRollDegAbs < 180 then
                        rollVerticalRatio = (180 - rescaleRollDegAbs) / 90
                    end

                    rollVerticalRatio = rollVerticalRatio * rollVerticalRatio

                    local turnAssistYawInput = - currentRollDegSign * rollToYawFactor * (1.0 - rollVerticalRatio)
                    local turnAssistPitchInput = rollToPitchFactor * rollVerticalRatio

                    targetAngularVelocity = targetAngularVelocity
                                        + turnAssistPitchInput * constructRight
                                        + turnAssistYawInput * constructUp
                end
            end

        -- Engine commands
            local keepCollinearity = 1 -- for easier reading
            local dontKeepCollinearity = 0 -- for easier reading
            local tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities

        -- Rotation
            local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
            local airAcceleration = vec3(construct.getWorldAirFrictionAngularAcceleration())
            angularAcceleration = angularAcceleration - airAcceleration -- Try to compensate air friction
            Nav:setEngineTorqueCommand('torque', angularAcceleration, keepCollinearity, 'airfoil', '', '', tolerancePercentToSkipOtherPriorities)

        -- Brakes
            local brakeAcceleration = -finalBrakeInput * (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
            Nav:setEngineForceCommand('brake', brakeAcceleration)

        -- AutoNavigation regroups all the axis command by 'TargetSpeed'
            local autoNavigationEngineTags = ''
            local autoNavigationAcceleration = vec3()
            local autoNavigationUseBrake = false

        -- Longitudinal Translation
            local longitudinalEngineTags = 'thrust analog longitudinal'
            local longitudinalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.longitudinal)
            if (longitudinalCommandType == axisCommandType.byThrottle) then
                local longitudinalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromThrottle(longitudinalEngineTags,axisCommandId.longitudinal)
                Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)
            elseif  (longitudinalCommandType == axisCommandType.byTargetSpeed) then
                local longitudinalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.longitudinal)
                autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. longitudinalEngineTags
                autoNavigationAcceleration = autoNavigationAcceleration + longitudinalAcceleration
                if (Nav.axisCommandManager:getTargetSpeed(axisCommandId.longitudinal) == 0 or -- we want to stop
                    Nav.axisCommandManager:getCurrentToTargetDeltaSpeed(axisCommandId.longitudinal) < - Nav.axisCommandManager:getTargetSpeedCurrentStep(axisCommandId.longitudinal) * 0.5) -- if the longitudinal velocity would need some braking
                then
                    autoNavigationUseBrake = true
                end

            end

        -- Lateral Translation
            local lateralStrafeEngineTags = 'thrust analog lateral'
            local lateralCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.lateral)
            if (lateralCommandType == axisCommandType.byThrottle) then
                local lateralStrafeAcceleration =  Nav.axisCommandManager:composeAxisAccelerationFromThrottle(lateralStrafeEngineTags,axisCommandId.lateral)
                Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralStrafeAcceleration, keepCollinearity)
            elseif  (lateralCommandType == axisCommandType.byTargetSpeed) then
                local lateralAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral)
                autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. lateralStrafeEngineTags
                autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration
            end

        -- Vertical Translation
            local verticalStrafeEngineTags = 'thrust analog vertical'
            local verticalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.vertical)
            if (verticalCommandType == axisCommandType.byThrottle) then
                local verticalStrafeAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromThrottle(verticalStrafeEngineTags,axisCommandId.vertical)
                Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity, 'airfoil', 'ground', '', tolerancePercentToSkipOtherPriorities)
            elseif  (verticalCommandType == axisCommandType.byTargetSpeed) then
                local verticalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.vertical)
                autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. verticalStrafeEngineTags
                autoNavigationAcceleration = autoNavigationAcceleration + verticalAcceleration
            end

        -- Auto Navigation (Cruise Control)
            if (autoNavigationAcceleration:len() > constants.epsilon) then
                if (brakeInput ~= 0 or autoNavigationUseBrake or math.abs(constructVelocityDir:dot(constructForward)) < 0.95)  -- if the velocity is not properly aligned with the forward
                then
                    autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
                end
                Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '', '', tolerancePercentToSkipOtherPriorities)
            end

        -- Rockets
            Nav:setBoosterCommand('rocket_engine')

    end

    function script.onOnUpdate()
        Nav:update()
    end

    function script.onActionStart(action)
        if action == "gear" then
            gearExtended = not gearExtended
            if gearExtended then
                unit.deployLandingGears()
            else
                unit.retractLandingGears()
            end
        elseif action == "light" then
            if unit.isAnyHeadlightSwitchedOn() == 1 then
                unit.switchOffHeadlights()
            else
                unit.switchOnHeadlights()
            end
        elseif action == "forward" then
            pitchInput = pitchInput - 1
        elseif action == "backward" then
            pitchInput = pitchInput + 1
        elseif action == "left" then 
            rollInput = rollInput - 1
        elseif action == "right" then 
            rollInput = rollInput + 1
        elseif action == "strafeleft" then 
            Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.lateral, -1.0)
        elseif action == "straferight" then 
            Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.lateral, 1.0)
        elseif action == "up" then
            Nav.axisCommandManager:deactivateGroundEngineAltitudeStabilization()
            Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.vertical, 1.0)
        elseif action == "down" then
            Nav.axisCommandManager:deactivateGroundEngineAltitudeStabilization()
            Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.vertical, -1.0)
        elseif action == "groundaltitudeup" then
            Nav.axisCommandManager:updateTargetGroundAltitudeFromActionStart(1.0)
        elseif action == "groundaltitudedown" then
            Nav.axisCommandManager:updateTargetGroundAltitudeFromActionStart(-1.0)
        elseif action == "yawleft" then 
            yawInput = yawInput + 1
        elseif action == "yawright" then 
            yawInput = yawInput - 1
        elseif action == "brake" then
            brakeInput = brakeInput + 1
            local longitudinalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.longitudinal)
            if (longitudinalCommandType == axisCommandType.byTargetSpeed) then
                local targetSpeed = Nav.axisCommandManager:getTargetSpeed(axisCommandId.longitudinal)
                if (math.abs(targetSpeed) > constants.epsilon) then
                    Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, - utils.sign(targetSpeed))
                end
            end
        elseif action == "booster" then
            Nav:toggleBoosters()
        elseif action == "stopengines" then
            Nav.axisCommandManager:resetCommand(axisCommandId.longitudinal)
        elseif action == "speedup" then
            Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, 5.0)
        elseif action == "speeddown" then
            Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, -5.0)
        elseif action == "antigravity" then
            if antigrav ~= nil then antigrav.toggle() end
        end
    end

    function script.onActionStop(action)
        if action == "forward" then
            pitchInput = pitchInput + 1    
        elseif action == "backward" then
            pitchInput = pitchInput - 1
        elseif action == "left" then 
            rollInput = rollInput + 1
        elseif action == "right" then 
            rollInput = rollInput - 1
        elseif action == "strafeleft" then 
            Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.lateral, 1.0)
        elseif action == "straferight" then 
            Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.lateral, -1.0)
        elseif action == "up" then
            Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.vertical, -1.0)
            Nav.axisCommandManager:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
        elseif action == "down" then
            Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.vertical, 1.0)
            Nav.axisCommandManager:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
        elseif action == "yawleft" then 
            yawInput = yawInput - 1
        elseif action == "yawright" then 
            yawInput = yawInput + 1
        elseif action == "brake" then
            brakeInput = brakeInput - 1
        end
    end

    function script.onActionLoop(action)
        if action == "groundaltitudeup" then
            Nav.axisCommandManager:updateTargetGroundAltitudeFromActionLoop(1.0)
        elseif action == "groundaltitudedown" then
            Nav.axisCommandManager:updateTargetGroundAltitudeFromActionLoop(-1.0)
        elseif action == "brake" then
            local longitudinalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.longitudinal)
            if (longitudinalCommandType == axisCommandType.byTargetSpeed) then
                local targetSpeed = Nav.axisCommandManager:getTargetSpeed(axisCommandId.longitudinal)
                if (math.abs(targetSpeed) > constants.epsilon) then
                    Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, - utils.sign(targetSpeed))
                end
            end
        elseif action == "speedup" then
            Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0)
        elseif action == "speeddown" then
            Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, -1.0)
        end
    end

    function script.onInputText(text)

    end

    function script.onEnter(id)

    end

    function script.onLeave(id)

    end
-- Execute Script
    script.onStart()