-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Surface Engines
-----------------------------------------------------------------------------------

require("fueledengine")

---@class SurfaceEngine
SurfaceEngine = {}
SurfaceEngine.__index = SurfaceEngine
function SurfaceEngine()
    local self = FueledEngine()

    --- Returns the distance to the first object detected in the direction of the thrust
    ---@return number
    function self.getDistance() end

    --- Returns the maximum functional distance from the ground
    ---@return number
    function self.getMaxDistance() end

    return setmetatable(self, SurfaceEngine)
end