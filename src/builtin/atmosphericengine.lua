-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Atmospheric Engines
--
-- Atmospheric engines are engines designed to operate optimally in the atmosphere
-----------------------------------------------------------------------------------

require("fueledengine")

--- Atmospheric engines are engines designed to operate optimally in the atmosphere
---@class AtmosphericEngine
AtmosphericEngine = {}
AtmosphericEngine.__index = AtmosphericEngine
function AtmosphericEngine()
    local self = FueledEngine()

    ---@deprecated AtmosphericEngine.getDistance() is deprecated.
    function self.getDistance() error("AtmosphericEngine.getDistance() is deprecated.") end

    return setmetatable(self, AtmosphericEngine)
end