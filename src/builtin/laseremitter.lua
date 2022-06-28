-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Laser Emitter
--
-- Emits a Laser ray that can be use to detect the passage of a player or on a Laser Detector unit.
-----------------------------------------------------------------------------------

require("element")

--- Emits a Laser ray that can be use to detect the passage of a player or on a Laser Detector unit.
---@class LaserEmitter
LaserEmitter = {}
LaserEmitter.__index = LaserEmitter
function LaserEmitter()
    local self = Element()

    --- Activates the laser emitter
    function self.activate() end

    --- Deactivates the laser emitter
    function self.deactivate() end

    --- Toggle the laser emitter
    function self.toggle() end

    --- Checks if the laser emitter is active
    ---@return integer
    function self.isActive() end
    ---@deprecated LaserEmitter.getState() is deprecated, use LaserEmitter.isActive() instead.
    function self.getState() error("LaserEmitter.getState() is deprecated, use LaserEmitter.isActive() instead.") end

    return setmetatable(self, LaserEmitter)
end