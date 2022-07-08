require 'src.slots'

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
        saveableVariablesBoolean = {BrakeToggleDefault={set=function (i)BrakeToggleDefault=i end,get=function() return BrakeToggleDefault end}}

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
        speedChangeLarge = 5.0 --export: (Default: 5) Example Variable, no effect
        savableVariablesPhysics = {speedChangeLarge={set=function (i)speedChangeLarge=i end,get=function() return speedChangeLarge end}}

local requireTable = {"autoconf/custom/archhud/globals","autoconf/custom/archhud/hudclass", "autoconf/custom/archhud/apclass", "autoconf/custom/archhud/controlclass",
                      "autoconf/custom/archhud/atlasclass", "autoconf/custom/archhud/baseclass", "autoconf/custom/archhud/shieldclass",
                      "autoconf/custom/archhud/radarclass", "autoconf/custom/archhud/axiscommandoverride", "autoconf/custom/archhud/userclass"}

for k,v in ipairs(requireTable) do
    pcall(require,requireTable[k])
end

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 1.000


-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
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
    globalDeclare(C, U) -- Variables that need to be Global, arent user defined, and are declared in globals.lua due to use across multple modules where there values can change.
    BASE = baseClass(N, C, U, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield, gyro, warpdrive, weapon, screenHud_1)

    script.onStart() 