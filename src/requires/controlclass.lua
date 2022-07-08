function ControlClass(N, C, U, S, antigrav, saveableVariables, SaveDataBank)
    local c = DUConstruct
    local Control = {}
    local NAC = N.axisCommandManager
    local UnitHidden = true

    function Control.startControl(action)
        -- Local function for onActionStart items in more than one

        if action == "gear" then
            gearExtended = not gearExtended
            if gearExtended then
                U.deployLandingGears()
            else
                U.retractLandingGears()
            end
        elseif action == "light" then
            if U.isAnyHeadlightSwitchedOn() == 1 then
                U.switchOffHeadlights()
            else
                U.switchOnHeadlights()
            end
        elseif action == "forward" then
            pitchInput = pitchInput - 1
        elseif action == "backward" then
            pitchInput = pitchInput + 1
        elseif action == "left" then
            rollInput = rollInput - 1
        elseif action == "right" then
            rollInput = rollInput + 1
        elseif action == "yawright" then
            yawInput = yawInput - 1
        elseif action == "yawleft" then
            yawInput = yawInput + 1
        elseif action == "straferight" then
            NAC:updateCommandFromActionStart(axisCommandId.lateral, 1.0)
        elseif action == "strafeleft" then
            NAC:updateCommandFromActionStart(axisCommandId.lateral, -1.0)
        elseif action == "up" then
            NAC:deactivateGroundEngineAltitudeStabilization()
            NAC:updateCommandFromActionStart(axisCommandId.vertical, 1.0)
        elseif action == "down" then
            NAC:deactivateGroundEngineAltitudeStabilization()
            NAC:updateCommandFromActionStart(axisCommandId.vertical, -1.0)
        elseif action == "groundaltitudeup" then
            NAC:updateTargetGroundAltitudeFromActionStart(1.0)
        elseif action == "groundaltitudedown" then
            NAC:updateTargetGroundAltitudeFromActionStart(-1.0)
        elseif action == "option1" then
        elseif action == "option2" then
        elseif action == "option3" then
        elseif action == "option4" then
        elseif action == "option5" then 
        elseif action == "option6" then
        elseif action == "option7" then
        elseif action == "option8" then
        elseif action == "option9" then
        elseif action == "lshift" then
        elseif action == "brake" then
            if BrakeToggleDefault then 
                AP.BrakeToggle("Manual")
            else
                BrakeIsOn = true
            end
        elseif action == "lalt" then

        elseif action == "booster" then
            N:toggleBoosters()
        elseif action == "stopengines" then
            NAC:resetCommand(axisCommandId.longitudinal)
        elseif action == "speedup" then
            NAC:updateCommandFromActionStart(axisCommandId.longitudinal, 5.0)
        elseif action == "speeddown" then
            NAC:updateCommandFromActionStart(axisCommandId.longitudinal, -5.0)
        elseif action == "antigravity" and not ExternalAGG then
            if antigrav ~= nil then antigrav.toggle() end
        elseif action == "leftmouse" then
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
            pitchInput = pitchInput + 1
        elseif action == "backward" then
            pitchInput = pitchInput - 1
        elseif action == "left" then
            rollInput = rollInput + 1
        elseif action == "right" then
            rollInput = rollInput - 1
        elseif action == "yawright" then
            yawInput = yawInput + 1
        elseif action == "yawleft" then
            yawInput = yawInput - 1
        elseif action == "straferight" then
            NAC:updateCommandFromActionStop(axisCommandId.lateral, -1.0)
        elseif action == "strafeleft" then
            NAC:updateCommandFromActionStop(axisCommandId.lateral, 1.0)
        elseif action == "up" then
            NAC:updateCommandFromActionStop(axisCommandId.vertical, -1.0)
            NAC:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
        elseif action == "down" then
            NAC:updateCommandFromActionStop(axisCommandId.vertical, 1.0)
            NAC:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
        elseif action == "groundaltitudeup" then
            --
        elseif action == "groundaltitudedown" then
            --
        elseif action == "brake" then
            if not BrakeToggleDefault then 
                BrakeIsOn = false
            end
        elseif action == "lalt" then
        end

    end

    function Control.loopControl(action)
        -- Local functions onActionLoop

        if action == "groundaltitudeup" then
            NAC:updateTargetGroundAltitudeFromActionLoop(1.0)
        elseif action == "groundaltitudedown" then
            NAC:updateTargetGroundAltitudeFromActionLoop(-1.0)
        elseif action == "speedup" then
            NAC:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0)
        elseif action == "speeddown" then
            NAC:updateCommandFromActionLoop(axisCommandId.longitudinal, -1.0)
        end
    end

    function Control.inputTextControl(text)
        -- Local functions for onInputText
        local i
        local command, arguement = nil, nil
        local commandhelp = "Command List:\n/commands \n/setname <newname> - Updates current selected saved position name\n/G VariableName newValue - Updates global variable to new value\n"..
                "/G dump - shows all variables updatable by /G\n/agg <targetheight> - Manually set agg target height\n"..
                "/copydatabank - copies dbHud databank to a blank databank\n"
        i = string.find(text, " ")
        command = text
        if i ~= nil then
            command = string.sub(text, 0, i-1)
            arguement = string.sub(text, i+1)
        end
        if command == "/help" or command == "/commands" then
            for str in string.gmatch(commandhelp, "([^\n]+)") do
                S.print(str)
            end
            return   
        elseif command == "/G" then
            if arguement == nil or arguement == "" then
                msgText = "Usage: /G VariableName variablevalue\n/G dump - shows all variables"
                return
            end
            if arguement == "dump" then
                for k, v in pairs(saveableVariables()) do
                    if type(v.get()) == "boolean" then
                        if v.get() == true then
                            S.print(k.." true")
                        else
                            S.print(k.." false")
                        end
                    elseif v.get() == nil then
                        S.print(k.." nil")
                    else
                        S.print(k.." "..v.get())
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
        
        elseif command == "/copydatabank" then 
            if dbHud_2 then 
                SaveDataBank(true) 
            else
                msgText = "Spare Databank required to copy databank"
            end

        end
    end

    if userControl then 
        for k,v in pairs(userControl) do Control[k] = v end 
    end  

    return Control
end