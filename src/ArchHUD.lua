require 'src.slots'

local Nav = Navigator.new(system, core, unit)
local atlas = require("atlas")
--
function p(msg)
    system.print(system.getTime()..": "..msg)
end
--]]
local requireTable = {"autoconf/custom/archhud/globals", "autoconf/custom/archhud/hudclass", "autoconf/custom/archhud/apclass", "autoconf/custom/archhud/controlclass",
                      "autoconf/custom/archhud/atlasclass", "autoconf/custom/archhud/baseclass", "autoconf/custom/archhud/shieldclass",
                      "autoconf/custom/archhud/radarclass", "autoconf/custom/archhud/axiscommandoverride", "autoconf/custom/archhud/userclass"}

for k,v in ipairs(requireTable) do
    pcall(require,requireTable[k])
end

script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 1.723


-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
    function script.onStart()
        PROGRAM.onStart()
    end

    function script.onStop()
        PROGRAM.onStop()
    end

    function script.onTick(timerId)  
        PROGRAM.onTick(timerId)       -- Various tick timers
    end

    function script.onFlush()
        PROGRAM.onFlush()
    end

    function script.onUpdate()
        PROGRAM.onUpdate()
    end

    function script.onActionStart(action)
        PROGRAM.controlStart(action)
    end

    function script.onActionStop(action)
        PROGRAM.controlStop(action)
    end

    function script.onActionLoop(action)
        PROGRAM.controlLoop(action)
    end

    function script.onInputText(text)
        PROGRAM.controlInput(text)
    end

    function script.onEnter(id)
        PROGRAM.radarEnter(id)
    end

    function script.onLeave(id)
        PROGRAM.radarLeave(id)
    end

-- Execute Script
    globalDeclare(system, core, unit, system.getTime, math.floor, unit.getAtmosphereDensity) -- Variables that need to be Global, arent user defined, and are declared in globals.lua due to use across multple modules where there values can change.
    PROGRAM = programClass(Nav, core, unit, system, library, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield_1, gyro, warpdrive, weapon, screenHud_1)

    script.onStart() 