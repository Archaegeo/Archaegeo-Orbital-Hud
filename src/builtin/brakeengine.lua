-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Brake Engines
-----------------------------------------------------------------------------------

require("engine")

---@class BrakeEngine
BrakeEngine = {}
BrakeEngine.__index = BrakeEngine
function BrakeEngine()
    local self = Engine()

    --- Start the brake at full power (works only when run inside a cockpit or under remote control)
    function self.activate() end

    --- Stops the brake (works only when run inside a cockpit or under remote control)
    function self.deactivate() end

    --- Checks if the brake is active
    ---@return integer
    function self.isActive() end
    ---@deprecated BrakeEngine.getState() is deprecated, use BrakeEngine.isActive().
    function self.getState() error("BrakeEngine.getState() is deprecated, use BrakeEngine.isActive().") end

    --- Toggle the state of the brake
    function self.toggle() end

    --- Set the thrust of the brake. Note that brakes can generate a force only in the movement opposite direction
    ---@param thrust number The brake thrust in newtons (limited by the maximum thrust)
    function self.setThrust(thrust) end

    --- Returns the current thrust of the brake
    ---@return number
    function self.getThrust() end

    --- Returns the maximal thrust the brake can deliver in principle, under optimal conditions.
    --- Note that the actual current min thrust will most of the time be less than max thrust
    ---@return number
    ---@diagnostic disable-next-line
    function self.getMaxThrust() end
    ---@deprecated BrakeEngine.getMaxThrustBase() is deprecated, use BrakeEngine.getMaxThrust().
    function self.getMaxThrustBase() error("BrakeEngine.getMaxThrustBase() is deprecated, use BrakeEngine.getMaxThrust().") end

    --- Returns the minimal thrust the brake can deliver at the moment (can be more than zero),
    --- which will depend on various conditions like atmospheric density, obstruction, orientation, etc
    --- Most of the time, this will be 0 but it can be greater than 0, particularly for Ailerons, in which case
    --- the actual thrust will be at least equal to minThrust
    ---@return number
    function self.getCurrentMinThrust() end
    ---@deprecated BrakeEngine.getMinThrust() is deprecated, use BrakeEngine.getCurrentMinThrust().
    function self.getMinThrust() error("BrakeEngine.getMinThrust() is deprecated, use BrakeEngine.getCurrentMinThrust().") end

    --- Returns the maximal thrust the brake can deliver at the moment, which might depend on
    --- various conditions like atmospheric density, obstruction, orientation, etc. The actual thrust will be
    --- anything below this maxThrust, which defines the current max capability of the brake
    ---@return number
    function self.getCurrentMaxThrust() end
    ---@deprecated BrakeEngine.getMaxThrust() is deprecated, use BrakeEngine.getCurrentMaxThrust().
    ---@diagnostic disable-next-line
    function self.getMaxThrust() error("BrakeEngine.getMaxThrust() is deprecated, use BrakeEngine.getCurrentMaxThrust().") end

    --- Returns the ratio between the current maximum thrust and the optimal maximum thrust
    ---@return number
    function self.getMaxThrustEfficiency() end
    
    --- Returns the brake thrust direction in construct local coordinates
    ---@return table
    function self.getThrustAxis() end

    --- Returns the brake thrust direction in world coordinates
    ---@return table
    function self.getWorldThrustAxis() end
    ---@deprecated BrakeEngine.thrustAxis() is deprecated, use BrakeEngine.getWorldThrustAxis().
    function self.thrustAxis() error("BrakeEngine.thrustAxis() is deprecated, use BrakeEngine.getWorldThrustAxis().") end


    ---@deprecated BrakeEngine.isOutOfFuel() is deprecated.
    function self.isOutOfFuel() error("BrakeEngine.isOutOfFuel() is deprecated.") end
    ---@deprecated BrakeEngine.hasFunctionalFuelTank() is deprecated.
    function self.hasFunctionalFuelTank() error("BrakeEngine.hasFunctionalFuelTank() is deprecated.") end
    ---@deprecated BrakeEngine.getCurrentFuelRate() is deprecated.
    function self.getCurrentFuelRate() error("BrakeEngine.getCurrentFuelRate() is deprecated.") end
    ---@deprecated BrakeEngine.getFuelRateEfficiency() is deprecated.
    function self.getFuelRateEfficiency() error("BrakeEngine.getFuelRateEfficiency() is deprecated.") end
    ---@deprecated BrakeEngine.getFuelConsumption() is deprecated.
    function self.getFuelConsumption() error("BrakeEngine.getFuelConsumption() is deprecated.") end
    ---@deprecated BrakeEngine.getDistance() is deprecated.
    function self.getDistance() error("BrakeEngine.getDistance() is deprecated.") end
    ---@deprecated BrakeEngine.getT50() is deprecated.
    function self.getT50() error("BrakeEngine.getT50() is deprecated.") end
    ---@deprecated BrakeEngine.torqueAxis() is deprecated.
    function self.torqueAxis() error("BrakeEngine.torqueAxis() is deprecated.") end


    return setmetatable(self, BrakeEngine)
end