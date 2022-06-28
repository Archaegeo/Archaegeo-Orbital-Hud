-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Base shield generator
--
-- Generates a protective shield around the space construct
-----------------------------------------------------------------------------------

require("element")

---@class BaseShieldGenerator
BaseShieldGenerator = {}
BaseShieldGenerator.__index = BaseShieldGenerator
function BaseShieldGenerator()
    local self = Element()

    --- Emitted when we started or stopped the shield generator
    ---@param active integer 1 if the element was activated, 0 otherwise
    self.onToggled = Event:new()
    self.toggled = Event:new()
    self.toggled:addAction(function(self, active) error("BaseShieldGenerator.toggled(active) event is deprecated") end, true, 1)

    --- Emitted when the shield absorbed incoming damage
    ---@param hitpoints number Damage the shield absorbed
    ---@param rawHitpoints number Total damage without taking resistances into account
    self.onAbsorbed = Event:new()
    self.absorbed = Event:new()
    self.absorbed:addAction(function(self, hitpoints, rawHitpoints) error("BaseShieldGenerator.absorbed(hitpoints, rawHitpoints) event is deprecated") end, true, 1)

    --- Emitted when the shield hit points reached 0 due to damage
    self.onDown = Event:new()
    self.down = Event:new()
    self.down:addAction(function(self) error("BaseShieldGenerator.down() event is deprecated") end, true, 1)

    --- Emitted when the shield hit points were fully restored
    self.onRestored = Event:new()
    self.restored = Event:new()
    self.restored:addAction(function(self) error("BaseShieldGenerator.restored() event is deprecated") end, true, 1)

    --- Emitted when the shield enters lockdown
    self.onEnterLockdown = Event:new()
    self.enterLockdown = Event:new()
    self.enterLockdown:addAction(function(self) error("BaseShieldGenerator.enterLockdown() event is deprecated") end, true, 1)

    --- Emitted when the shield exits the lockdown
    self.onLeaveLockdown = Event:new()
    self.leaveLockdown = Event:new()
    self.leaveLockdown:addAction(function(self) error("BaseShieldGenerator.leaveLockdown() event is deprecated") end, true, 1)


    --- Activate the shield
    function self.activate() end

    --- Deactivate the shield
    function self.deactivate() end

    --- Toggle the state of the shield
    function self.toggle() end

    --- Returns the activation state of the shield
    ---@return integer
    function self.isActive() end
    ---@deprecated BaseShieldGenerator.getState() is deprecated, use BaseShieldGenerator.isActive() instead.
    function self.getState() error("BaseShieldGenerator.getState() is deprecated, use BaseShieldGenerator.isActive() instead.") end

    --- Returns the current hit points of the shield
    ---@return number
    function self.getShieldHitpoints() end

    --- Returns the maximal hit points of the shield
    ---@return number
    function self.getMaxShieldHitpoints() end

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

    --- Returns whether the base shield is currently in lockdown
    ---@return integer
    function self.inLockdown() end

    --- Returns the remaining time of the base shield lockdown
    ---@return number
    function self.getLockdownRemaining() end

    --- Returns the hour since midnight of the preferred lockdown exit
    ---@return integer
    function self.getLockdownExitTime() end

    --- Set hour since midnight for the preferred lockdown exit
    ---@param hour integer Preferred lockdown exit hour UTC
    ---@return integer
    function self.setLockdownExitTime(hour) end
    
    return setmetatable(self, BaseShieldGenerator)
end