-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Rocket Engines
--
-- Rocket engines are engines capable of producing enormous thrust in a short period of time.
-- They consume fuel but do not need time to warm up.
-----------------------------------------------------------------------------------

require("fueledengine")

--- Rocket engines are engines capable of producing enormous thrust in a short period of time.
--- They consume fuel but do not need time to warm up.
---@class RocketEngine
RocketEngine = {}
RocketEngine.__index = RocketEngine
function RocketEngine()
    local self = FueledEngine()

    ---@deprecated RocketEngine.getDistance() is deprecated.
    function self.getDistance() error("RocketEngine.getDistance() is deprecated.") end

    return setmetatable(self, RocketEngine)
end