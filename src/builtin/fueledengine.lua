-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Fueled Engines
-----------------------------------------------------------------------------------

require("engine")

---@class FueledEngine
FueledEngine = {}
FueledEngine.__index = FueledEngine
function FueledEngine()
    local self = Engine()

    --- Start the engine at full power (works only when run inside a cockpit or under remote control)
    function self.activate() end

    --- Stops the engine (works only when run inside a cockpit or under remote control)
    function self.deactivate() end

    --- Checks if the engine is active
    ---@return integer
    function self.isActive() end
    ---@deprecated FueledEngine.getState() is deprecated, use FueledEngine.isActive().
    function self.getState() error("FueledEngine.getState() is deprecated, use FueledEngine.isActive().") end

    --- Toggle the state of the engine
    function self.toggle() end

    --- Set the thrust of the engine
    ---@param thrust number The engine thrust in newtons (limited by the maximum thrust)
    function self.setThrust(thrust) end

    --- Returns the current thrust of the engine
    ---@return number
    function self.getThrust() end

    --- Returns the maximal thrust the engine can deliver in principle, under optimal conditions.
    --- Note that the actual maxThrust will most of the time be less than maxThrustBase
    ---@return number
    ---@diagnostic disable-next-line
    function self.getMaxThrust() end
    ---@deprecated FueledEngine.getMaxThrustBase() is deprecated, use FueledEngine.getMaxThrust().
    function self.getMaxThrustBase() error("FueledEngine.getMaxThrustBase() is deprecated, use FueledEngine.getMaxThrust().") end

    --- Returns the minimal thrust the engine can deliver at the moment (can be more than zero),
    --- which will depend on various conditions like atmospheric density, obstruction, orientation, etc
    --- Most of the time, this will be 0 but it can be greater than 0, particularly for Ailerons, in which case
    --- the actual thrust will be at least equal to minThrust
    ---@return number
    function self.getCurrentMinThrust() end
    ---@deprecated FueledEngine.getMinThrust() is deprecated, use FueledEngine.getCurrentMinThrust().
    function self.getMinThrust() error("FueledEngine.getMinThrust() is deprecated, use FueledEngine.getCurrentMinThrust().") end

    --- Returns the maximal thrust the engine can deliver at the moment, which might depend on
    --- various conditions like atmospheric density, obstruction, orientation, etc. The actual thrust will be
    --- anything below this maxThrust, which defines the current max capability of the engine
    ---@return number
    function self.getCurrentMaxThrust() end
    ---@deprecated FueledEngine.getMaxThrust() is deprecated, use FueledEngine.getCurrentMaxThrust().
    ---@diagnostic disable-next-line
    function self.getMaxThrust() error("FueledEngine.getMaxThrust() is deprecated, use FueledEngine.getCurrentMaxThrust().") end

    --- Returns the ratio between the current maximum thrust and the optimal maximum thrust
    ---@return number
    function self.getMaxThrustEfficiency() end
    
    --- Checks if the torque generation is enabled on the engine
    ---@return integer
    function self.isTorqueEnabled() end
    
    --- Sets the torque generation state on the engine
    ---@param state boolean
    function self.enableTorque(state) end


    --- Returns the engine thrust direction in construct local coordinates
    ---@return table
    function self.getThrustAxis() end

    --- Returns the engine torque axis in construct local coordinates
    ---@return table
    function self.getTorqueAxis() end

    --- Returns the engine exhaust thrust direction in world coordinates
    ---@return table
    function self.getWorldThrustAxis() end
    ---@deprecated FueledEngine.thrustAxis() is deprecated, use FueledEngine.getWorldThrustAxis().
    function self.thrustAxis() error("FueledEngine.thrustAxis() is deprecated, use FueledEngine.getWorldThrustAxis().") end

    --- Returns the engine torque axis in world coordinates
    ---@return table
    function self.getWorldTorqueAxis() end
    ---@deprecated FueledEngine.torqueAxis() is deprecated, use FueledEngine.getWorldTorqueAxis().
    function self.torqueAxis() error("FueledEngine.torqueAxis() is deprecated, use FueledEngine.getWorldTorqueAxis().") end

    --- Checks if the engine out of fuel
    ---@return integer
    function self.isOutOfFuel() end

    --- Returns the item ID of the fuel currently used by the engine
    ---@return integer
    function self.getFuelId() end

    ---Returns the local ID of the fueltank linked to the engine
    ---@return integer
    function self.getFuelTankId() end

    --- Checks if the engine linked to a functional Fuel Tank (not broken or colliding)?
    ---@return integer
    function self.hasFunctionalFuelTank() end
    ---@deprecated FueledEngine.hasBrokenFuelTank() is deprecated, use FueledEngine.hasFunctionalFuelTank().
    function self.hasBrokenFuelTank() error("FueledEngine.hasBrokenFuelTank() is deprecated, use FueledEngine.hasFunctionalFuelTank().") end

    --- Returns the engine fuel consumption rate per newton of thrust delivered per second
    ---@return number
    function self.getCurrentFuelRate() end

    --- Returns the ratio between the current fuel rate and the theoretical nominal fuel rate
    ---@return number
    function self.getFuelRateEfficiency() end

    --- Returns the current fuel consumption rate
    ---@return number
    function self.getFuelConsumption() end

    --- Returns the T50; the time needed for the engine to reach 50% of its maximal thrust (all engines
    --- do not instantly reach the thrust that is set for them, but they can take time to "warm up" to
    --- the final value)
    ---@return number
    function self.getWarmupTime() end
    ---@deprecated FueledEngine.getT50() is deprecated, use FueledEngine.getWarmupTime().
    function self.getT50() error("FueledEngine.getT50() is deprecated, use FueledEngine.getWarmupTime().") end

    return setmetatable(self, FueledEngine)
end