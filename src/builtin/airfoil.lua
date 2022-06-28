-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Airfoils
--
-- Airfoils are aerodynamic elements that produce a lift force according to their aerodynamic profile ;
-- as wings, stabilizers and ailerons
-----------------------------------------------------------------------------------

require("engine")

--- Airfoils are aerodynamic elements that produce a lift force according to their aerodynamic profile ;
--- as wings, stabilizers and ailerons
---@class Airfoil
Airfoil = {}
Airfoil.__index = Airfoil
function Airfoil()
    local self = Engine()

    --- Returns the current lift of the airfoil
    ---@return number
    function self.getLift() end
    ---@deprecated Airfoil.getThrust() is deprecated, use Airfoil.getLift().
    function self.getThrust() error("Airfoil.getThrust() is deprecated, use Airfoil.getLift().") end

    --- Gives the maximum lift that the airfoil can generate, under optimal conditions.
    --- Note that the actual maximum lift will most of the time be less than this value
    ---@return number
    function self.getMaxLift() end
    ---@deprecated Airfoil.getMaxThrustBase() is deprecated, use Airfoil.getMaxLift().
    function self.getMaxThrustBase() error("Airfoil.getMaxThrustBase() is deprecated, use Airfoil.getMaxLift().") end

    --- Returns the current drag of the airfoil
    ---@return number
    function self.getDrag() end

    --- The ratio between lift and drag, depending of the aerodynamic profile of the airfoil
    ---@return number
    function self.getDragRatio() end

    --- Returns the minimal lift the airfoil can deliver at the moment (can be higher than zero),
    --- which will depend on various conditions like atmospheric density, obstruction, orientation, etc
    ---@return number
    function self.getCurrentMinLift() end
    ---@deprecated Airfoil.getMinThrust() is deprecated, use Airfoil.getCurrentMinLift().
    function self.getMinThrust() error("Airfoil.getMinThrust() is deprecated, use Airfoil.getCurrentMinLift().") end

    --- Returns the maximal lift the aifoil can deliver at the moment, which might depend on
    --- various conditions like atmospheric density, obstruction, orientation, etc. The actual lift will be
    --- anything below this maximum lift, which defines the current max capability of the airfoil
    ---@return number
    function self.getCurrentMaxLift() end
    ---@deprecated Airfoil.getMaxThrust() is deprecated, use Airfoil.getCurrentMaxLift().
    function self.getMaxThrust() error("Airfoil.getMaxThrust() is deprecated, use Airfoil.getCurrentMaxLift().") end

    --- Returns the ratio between the current maximum lift and the optimal maximum lift
    ---@return number
    function self.getMaxLiftEfficiency() end
    ---@deprecated Airfoil.getMaxThrustEfficiency() is deprecated, use Airfoil.getMaxLiftEfficiency().
    function self.getMaxThrustEfficiency() error("Airfoil.getMaxThrustEfficiency() is deprecated, use Airfoil.getMaxLiftEfficiency().") end

    --- Returns the airfoil lift direction in construct local coordinates
    ---@return table
    function self.getLiftAxis() end
    
    --- Returns the airfoil torque axis in construct local coordinates
    ---@return table
    function self.getTorqueAxis() end

    --- Returns the airfoil lift direction in world coordinates
    ---@return table
    function self.getWorldLiftAxis() end
    ---@deprecated Airfoil.thrustAxis() is deprecated, use Airfoil.getWorldLiftAxis().
    function self.thrustAxis() error("Airfoil.thrustAxis() is deprecated, use Airfoil.getWorldLiftAxis().") end

    --- Returns the adjustor torque axis in world coordinates
    ---@return table 
    function self.getWorldTorqueAxis() end
    ---@deprecated Airfoil.torqueAxis() is deprecated, use Airfoil.getWorldTorqueAxis().
    function self.torqueAxis() error("Airfoil.torqueAxis() is deprecated, use Airfoil.getWorldTorqueAxis().") end

    --- Checks if the airfoil is stalled
    ---@return integer
    function self.isStalled() end

    --- Returns the airfoil stall angle
    ---@return number
    function self.getStallAngle() end

    --- Returns the minimum angle to produce the maximum lift of the airfoil
    --- Note that the airfoil will produce lift at a lower angle but not optimally
    ---@return number
    function self.getMinAngle() end

    --- Returns the maximum angle to produce the maximum lift of the airfoil
    --- Note that the airfoil will produce lift at a higher angle but not optimally
    ---@return number
    function self.getMaxAngle() end

    ---@deprecated Airfoil.activate() is deprecated.
    function self.activate() error("Airfoil.activate() is deprecated.") end
    ---@deprecated Airfoil.deactivate() is deprecated.
    function self.deactivate() error("Airfoil.deactivate() is deprecated.") end
    ---@deprecated Airfoil.getState() is deprecated.
    function self.getState() error("Airfoil.getState() is deprecated.") end
    ---@deprecated Airfoil.toggle() is deprecated.
    function self.toggle() error("Airfoil.toggle() is deprecated.") end
    ---@deprecated Airfoil.setThrust(thrust) is deprecated.
    function self.setThrust(thrust) error("Airfoil.setThrust(thrust) is deprecated.") end
    ---@deprecated Airfoil.isOutOfFuel() is deprecated.
    function self.isOutOfFuel() error("Airfoil.isOutOfFuel() is deprecated.") end
    ---@deprecated Airfoil.hasFunctionalFuelTank() is deprecated.
    function self.hasFunctionalFuelTank() error("Airfoil.hasFunctionalFuelTank() is deprecated.") end
    ---@deprecated Airfoil.getCurrentFuelRate() is deprecated.
    function self.getCurrentFuelRate() error("Airfoil.getCurrentFuelRate() is deprecated.") end
    ---@deprecated Airfoil.getFuelRateEfficiency() is deprecated.
    function self.getFuelRateEfficiency() error("Airfoil.getFuelRateEfficiency() is deprecated.") end
    ---@deprecated Airfoil.getFuelConsumption() is deprecated.
    function self.getFuelConsumption() error("Airfoil.getFuelConsumption() is deprecated.") end
    ---@deprecated Airfoil.getDistance() is deprecated.
    function self.getDistance() error("Airfoil.getDistance() is deprecated.") end
    ---@deprecated Airfoil.getT50() is deprecated.
    function self.getT50() error("Airfoil.getT50() is deprecated.") end

    return setmetatable(self, Airfoil)
end