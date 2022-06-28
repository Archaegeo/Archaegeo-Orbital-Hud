-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Gyro
--
-- A general kinematic unit to obtain information about the ship orientation, velocity, and acceleration.
-----------------------------------------------------------------------------------

require("element")

--- A general kinematic unit to obtain information about the ship orientation, velocity, and acceleration.
---@class Gyro
Gyro = {}
Gyro.__index = Gyro
function Gyro()
    local self = Element()

    --- Selects this gyro as the main gyro used for ship orientation
    function self.activate() end

    --- Deselects this gyro as the main gyro used for ship orientation, using the Core Unit instead
    function self.deactivate() end

    --- Toggle the activation state of the gyro
    function self.toggle() end

    --- Returns the activation state of the gyro
    ---@return integer
    function self.isActive() end
    ---@deprecated Gyro.getState() is deprecated, use Gyro.isActive() instead.
    function self.getState() error("Gyro.getDistance() is deprecated, use Gyro.isActive() instead.") end

    --- The pitch value relative to the gyro orientation and the local gravity
    ---@return number pitch The pitch angle in degrees, relative to the gyro orientation and the local gravity
    function self.getPitch() end

    --- The roll value relative to the gyro orientation and the local gravity
    ---@return number roll The roll angle in degrees, relative to the gyro orientation and the local gravity
    function self.getRoll() end
    
    ---@deprecated Gyro.localUp() is deprecated, use Gyro.getUp() instead.
    function self.localUp() error("Gyro.localUp() is deprecated, use Gyro.getUp() instead.") end
    ---@deprecated Gyro.localForward() is deprecated, use Gyro.getForward() instead.
    function self.localForward() error("Gyro.localForward() is deprecated, use Gyro.getForward() instead.") end
    ---@deprecated Gyro.localRight() is deprecated, use Gyro.getRight() instead.
    function self.localRight() error("Gyro.localRight() is deprecated, use Gyro.getRight() instead.") end
    ---@deprecated Gyro.worldUp() is deprecated, use Gyro.getWorldUp() instead.
    function self.worldUp() error("Gyro.worldUp() is deprecated, use Gyro.getWorldUp() instead.") end
    ---@deprecated Gyro.worldForward() is deprecated, use Gyro.getWorldForward() instead.
    function self.worldForward() error("Gyro.worldForward() is deprecated, use Gyro.getWorldForward() instead.") end
    ---@deprecated Gyro.worldRight() is deprecated, use Gyro.getWorldRight() instead.
    function self.worldRight() error("Gyro.worldRight() is deprecated, use Gyro.getWorldRight() instead.") end

    return setmetatable(self, Gyro)
end