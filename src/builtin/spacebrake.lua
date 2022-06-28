-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Space Brakes
--
-- Space brakes are retro-rocket elements designed to produce thrust opposite to the movement of a construct in space, acting as a space brake.
-- It that can be used to slow down your construct.
-----------------------------------------------------------------------------------

require("brakeengine")

--- Space brakes are retro-rocket elements designed to produce thrust opposite to the movement of a construct in space, acting as a space brake.
--- It that can be used to slow down your construct.
---@class SpaceBrake
SpaceBrake = {}
SpaceBrake.__index = SpaceBrake
function SpaceBrake()
    local self = BrakeEngine()

    return setmetatable(self, SpaceBrake)
end