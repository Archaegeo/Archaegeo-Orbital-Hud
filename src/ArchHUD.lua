require 'src.slots'

-- Redefine globals to locals
local S = system
local C = core
local U = unit
local N = Navigator.new(S, C, U)

local atlas = require("atlas")

--prints a timestamped message to lua chat
function p(msg)
    S.print(S.getArkTime()..": "..msg)
end


-- User variables. Must be global to work with databank system
    useTheseSettings = false --export:  Change this to true to override databank saved settings
    -- True/False variables
        -- NOTE: saveableVariablesBoolean below must contain any True/False variables that needs to be saved/loaded from databank.
        BrakeToggleDefault = true --export: (Default: true) Whether your brake toggle is on/off by default. 
        autoRoll = false --export: [Only in atmosphere]<br>When the pilot stops rolling,  flight model will try to get back to horizontal (no roll)
        turnAssist = true --export: [Only in atmosphere]<br>When the pilot is rolling, the flight model will try to add yaw and pitch to make the construct turn better<br>The flight model will start by adding more yaw the more horizontal the construct is and more pitch the more vertical it is
        saveableVariablesBoolean = {BrakeToggleDefault={set=function (i)BrakeToggleDefault=i end,get=function() return BrakeToggleDefault end},autoRoll={set=function (i)autoRoll=i end,get=function() return autoRoll end},
            turnAssist={set=function (i)turnAssist=i end,get=function() return turnAssist end}}

    -- Ship Handling variables
        -- NOTE: savableVariablesHandling below must contain any Ship Handling variables that needs to be saved/loaded from databank system
        YawStallAngle = 35 --export: (Default: 35) Example Variable, no effect
        savableVariablesHandling = {YawStallAngle={set=function (i)YawStallAngle=i end,get=function() return YawStallAngle end}}

    -- HUD Postioning variables
        -- NOTE: savableVariablesHud below must contain any HUD Postioning variables that needs to be saved/loaded from databank system
        ThrottleX = 1920 --export: (Default: 1920) Example Variable, no effect
        ThrottleY = 1080 --export: (Default: 1080) Example Variable, no effect
        savableVariablesHud = {ThrottleX={set=function (i)ThrottleX=i end,get=function() return ThrottleX end},ThrottleY={set=function (i)ThrottleY=i end,get=function() return ThrottleY end}}

    -- Ship flight physics variables - Change with care, can have large effects on ships performance.
        -- NOTE: savableVariablesPhysics below must contain any Ship flight physics variables that needs to be saved/loaded from databank system
        pitchSpeedFactor = 0.8 --export: This factor will increase/decrease the player input along the pitch axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
        yawSpeedFactor =  1 --export: This factor will increase/decrease the player input along the yaw axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
        rollSpeedFactor = 1.5 --export: This factor will increase/decrease the player input along the roll axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
        brakeSpeedFactor = 3 --export: When braking, this factor will increase the brake force by brakeSpeedFactor * velocity<br>Valid values: Superior or equal to 0.01
        brakeFlatFactor = 1 --export: When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction><br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
        autoRollFactor = 2 --export: [Only in atmosphere]<br>When autoRoll is engaged, this factor will increase to strength of the roll back to 0<br>Valid values: Superior or equal to 0.01
        turnAssistFactor = 2 --export: [Only in atmosphere]<br>This factor will increase/decrease the turnAssist effect<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
        torqueFactor = 2 --export: Force factor applied to reach rotationSpeed<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
        savableVariablesPhysics = {pitchSpeedFactor={set=function (i)pitchSpeedFactor=i end,get=function() return pitchSpeedFactor end},yawSpeedFactor={set=function (i)yawSpeedFactor=i end,get=function() return yawSpeedFactor end},
            rollSpeedFactor={set=function (i)rollSpeedFactor=i end,get=function() return rollSpeedFactor end},brakeSpeedFactor={set=function (i)brakeSpeedFactor=i end,get=function() return brakeSpeedFactor end},
            brakeFlatFactor={set=function (i)brakeFlatFactor=i end,get=function() return brakeFlatFactor end},autoRollFactor={set=function (i)autoRollFactor=i end,get=function() return autoRollFactor end},
            turnAssistFactor={set=function (i)turnAssistFactor=i end,get=function() return turnAssistFactor end},torqueFactor={set=function (i)torqueFactor=i end,get=function() return torqueFactor end},}

-- Require files to segregate code into seperate files
    local requireTable = {"autoconf/custom/archhud/globals","autoconf/custom/archhud/hudclass", "autoconf/custom/archhud/flightclass", "autoconf/custom/archhud/controlclass",
        "autoconf/custom/archhud/atlasclass", "autoconf/custom/archhud/baseclass", "autoconf/custom/archhud/shieldclass",
        "autoconf/custom/archhud/radarclass", "autoconf/custom/archhud/axiscommandoverride", "autoconf/custom/archhud/userclass"}
    for k,v in ipairs(requireTable) do
        pcall(require,requireTable[k])  -- pcall lets it continue executing if the require file isnt present.
    end

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 1.000


-- DU Events 
    function script.onStart()
        BASE.onStart()
    end

    function script.onOnStop()
        BASE.onStop()
    end

    function script.onTick(timerId)  
        BASE.onTick(timerId)       -- Various tick timers
    end

    function script.onOnFlush()
        BASE.onFlush()
    end

    function script.onOnUpdate()
        BASE.onUpdate()
    end

    function script.onActionStart(action)
        BASE.controlStart(action)
    end

    function script.onActionStop(action)
        BASE.controlStop(action)
    end

    function script.onActionLoop(action)
        BASE.controlLoop(action)
    end

    function script.onInputText(text)
        BASE.controlInput(text)
    end

    function script.onEnter(id)
        BASE.radarEnter(id)
    end

    function script.onLeave(id)
        BASE.radarLeave(id)
    end

-- Execute Script
    globalDeclare() -- Variables that need to be Global, but arent user defined and not saved to databank.  These are declared in globals.lua due to use across multple modules where there values can change.

-- Start the system by setting base and then calling onStart    
    BASE = baseClass(N, C, U, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield, gyro, warpdrive, weapon, screenHud_1)

    script.onStart() 