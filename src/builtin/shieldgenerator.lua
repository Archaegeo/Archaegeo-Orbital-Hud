-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Shield generator
--
-- Generates a protective shield around the construct
-----------------------------------------------------------------------------------

require("element")

---@class ShieldGenerator
ShieldGenerator = {}
ShieldGenerator.__index = ShieldGenerator
function ShieldGenerator()
    local self = Element()

    --- Emitted when we started or stopped the shield generator
    ---@param active integer 1 if the element was activated, 0 otherwise
    self.onToggled = Event:new()
    self.toggled = Event:new()
    self.toggled:addAction(function(self, active) error("ShieldGenerator.toggled(active) event is deprecated") end, true, 1)

    --- Emitted when the shield absorbed incoming damage
    ---@param hitpoints number Damage the shield absorbed
    ---@param rawHitpoints number Total damage without taking resistances into account
    self.onAbsorbed = Event:new()
    self.absorbed = Event:new()
    self.absorbed:addAction(function(self, hitpoints, rawHitpoints) error("ShieldGenerator.absorbed(hitpoints, rawHitpoints) event is deprecated") end, true, 1)

    --- Emitted when venting started, stopped or restored some hitpoints
    ---@param active integer 1 when venting is active, 0 otherwise
    ---@param restoredHitpoints number Hitpoints restored since the last venting step
    self.onVenting = Event:new()
    self.venting = Event:new()
    self.venting:addAction(function(self, active, restoredHitpoints) error("ShieldGenerator.absorbed(active, restoredHitpoints) event is deprecated") end, true, 1)

    --- Emitted when the shield hit points reached 0 due to damage
    self.onDown = Event:new()
    self.down = Event:new()
    self.down:addAction(function(self) error("ShieldGenerator.down() event is deprecated") end, true, 1)

    --- Emitted when the shield hit points were fully restored
    self.onRestored = Event:new()
    self.restored = Event:new()
    self.restored:addAction(function(self) error("ShieldGenerator.restored() event is deprecated") end, true, 1)


    --- Activate the shield
    function self.activate() end

    --- Deactivate the shield
    function self.deactivate() end

    --- Toggle the state of the shield
    function self.toggle() end

    --- Returns the activation state of the shield
    ---@return integer
    function self.isActive() end
    ---@deprecated ShieldGenerator.getState() is deprecated, use ShieldGenerator.isActive() instead.
    function self.getState() error("ShieldGenerator.getState() is deprecated, use ShieldGenerator.isActive() instead.") end


    --- Returns the current hit points of the shield
    ---@return number
    function self.getShieldHitpoints() end

    --- Returns the maximal hit points of the shield
    ---@return number
    function self.getMaxShieldHitpoints() end


    --- Activate shield venting to restore hit points
    ---@return integer state 1 if venting started, 0 if an error occurred
    function self.startVenting() end

    --- Stop shield venting
    ---@return integer state 1 if venting stopped, 0 if an error occurred
    function self.stopVenting() end

    --- Check whether venting is in progress
    ---@return integer state 1 if venting is ongoing, 0 otherwise
    function self.isVenting() end

    --- Returns time after which venting is possible again
    ---@return number value Remaining seconds of the venting cooldown
    function self.getVentingCooldown() end

    --- Returns maximal cooldown between venting
    ---@return number value Maximal seconds of the venting cooldown
    function self.getVentingMaxCooldown() end


    --- Returns distribution of resistance pool over resistance types
    ---@return table resistances Resistance to damage type {antimatter, electromagnetic, kinetic, thermic}
    function self.getResistances() end

    --- Distribute the resistance pool according to damage type
    ---@param antimatter number Antimatter damage resistance
    ---@param electromagnetic number Electromagnetic damage resistance
    ---@param kinetic number Kinetic damage resistance
    ---@param thermic number Thermic damage resistance
    ---@return integer
    function self.setResistances(antimatter,electromagnetic,kinetic,thermic) end

    --- Returns time after which adjusting resistances is possible again
    ---@return number
    function self.getResistancesCooldown() end

    --- Returns maximal cooldown between adjusting resistances
    ---@return number
    function self.getResistancesMaxCooldown() end

    --- Returns total resistance pool that may be distributed
    ---@return number
    function self.getResistancesPool() end

    --- Returns the remaining amount of the resistance pool that can be distributed
    ---@return number
    function self.getResistancesRemaining() end

    --- Returns ratio per damage type of recent weapon impacts after applying resistance
    ---@return table stress Stress ratio due to damage type {antimatter, electromagnetic, kinetic, thermic}
    function self.getStressRatio() end

    --- Returns ratio per damage type of recent weapon impacts without resistance
    ---@return table stress Stress ratio due to damage type {antimatter, electromagnetic, kinetic, thermic}
    function self.getStressRatioRaw() end

    --- Returns stress, that is the total hit points of recent weapon impacts after applying resistance
    ---@return number
    function self.getStressHitpoints() end

    --- Returns stress, that is the total hit points of recent weapon impacts without resistance
    ---@return number
    function self.getStressHitpointsRaw() end

    return setmetatable(self, ShieldGenerator)
end