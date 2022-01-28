require 'src.slots'

local s=system
local c=core
local u=unit

local Nav = Navigator.new(s, c, u)
local atlas = require("atlas")

local globalDeclare=require("autoconf/custom/archhud/globals")
require("autoconf/custom/archhud/hudclass")
require("autoconf/custom/archhud/apclass")
require("autoconf/custom/archhud/radarclass")
require("autoconf/custom/archhud/controlclass")
require("autoconf/custom/archhud/atlasclass")
require("autoconf/custom/archhud/baseclass")
script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

VERSION_NUMBER = 1.713

globalDeclare(s, c, u, s.getTime, math.floor, u.getAtmosphereDensity) -- Variables that need to be Global and are declared in globals.lua due to use across multple modules where there values can change.

--
function p(msg)
    s.print(time..": "..msg)
end
--]]

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
    PROGRAM = programClass(Nav, c, u, s, library, atlas, vBooster, hover, telemeter_1, antigrav, dbHud_1, dbHud_2, radar_1, radar_2, shield_1, gyro, warpdrive, weapon, screenHud_1)
    script.onStart() 