-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Telemeter
--
-- Measures the distance to an obstacle in front of it.
-----------------------------------------------------------------------------------

require("element")

--- Measures the distance to an obstacle in front of it.
---@class Telemeter
Telemeter = {}
Telemeter.__index = Telemeter
function Telemeter()
    local self = Element()

    ---@deprecated Telemeter.getDistance() is deprecated, use Telemeter.raycast().distance instead.
    function self.getDistance() error("Telemeter.getDistance() is deprecated, use Telemeter.raycast().distance instead.") end

    --- Emits a raycast from the telemeter, returns a raycastHit object
    ---@return table hit A table with fields : {[bool] hit, [float] distance, [vec3] point}
    function self.raycast() end

    --- Returns telemeter raycast origin in local construct coordinates
    ---@return table
    function self.getRayOrigin() end

    --- Returns telemeter raycast origin in world coordinates
    ---@return table
    function self.getRayWorldOrigin() end

    --- Returns telemeter raycast axis in local construct coordinates
    ---@return table
    function self.getRayAxis() end

    --- Returns telemeter raycast axis in world coordinates
    ---@return table
    function self.getRayWorldAxis() end

    --- Returns the max distance from which an obstacle can be detected (default is 100m)
    ---@return number
    function self.getMaxDistance() end

    return setmetatable(self, Telemeter)
end