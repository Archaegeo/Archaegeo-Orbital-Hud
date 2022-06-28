-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Space mining unit
--
-- Extracts a regular amount of resources from the space surrouding an alien core
-----------------------------------------------------------------------------------

require("element")

--- Extracts a regular amount of resources from the space surrouding an alien core
---@class SpaceMiningUnit
SpaceMiningUnit = {}
SpaceMiningUnit.__index = SpaceMiningUnit
function SpaceMiningUnit()
    local self = Element()

    --- Returns the current state of the space mining unit
    ---@return integer state The status of the space mining unit can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no output container = 4)
    function self.getState() end
    ---@deprecated MiningUnit.getStatus() is deprecated, use MiningUnit.getState() instead.
    function self.getStatus() error("SpaceMiningUnit.getStatus() is deprecated, use SpaceMiningUnit.getState() instead.") end

    --- Returns the remaining time of the current batch extraction process.
    ---@return number
    function self.getRemainingTime() end

    --- Returns the item ID of the currently selected ore.
    ---@return integer
    function self.getActiveOre() end

    --- Returns the list of available ore pools
    ---@return table pool A list of tables composed with {[int] oreId, [float] available, [float] maximum);
    function self.getOrePools() end

    --- Returns the base production rate of the space mining unit.
    ---@return number
    function self.getBaseRate() end

    --- Returns the efficiency rate of the space mining unit.
    ---@return number
    function self.getEfficiency() end

    --- Returns the calibration rate of the space mining unit.
    ---@return number
    function self.getCalibrationRate() end

    --- Returns the optimal calibration rate of the space mining unit.
    ---@return number
    function self.getOptimalRate() end

    --- Returns the current production rate of the space mining unit.
    ---@return number
    function self.getProductionRate() end

    --- Emitted when the space mining unit started a new extraction process.
    ---@param oreId number The item ID of the ore mined during the extraction process
    self.onStarted = Event:new()

    --- Emitted when the space mining unit complete a batch.
    ---@param oreId number The item ID of the ore mined during the extraction process
    ---@param amount number Amount of ore mined
    self.onCompleted = Event:new()
    self.completed = Event:new()
    self.completed:addAction(function(self,oreId,amount) error("SpaceMiningUnit.completed(oreId,amount) event is deprecated, use SpaceMiningUnit.onCompleted(oreId,amount) instead.") end, true, 1)

    --- Emitted when the space mining unit status is changed.
    ---@param status integer The status of the space mining unit can be
    self.onStatusChanged = Event:new()
    self.statusChanged = Event:new()
    self.statusChanged:addAction(function(self,status) error("SpaceMiningUnit.statusChanged(status) event is deprecated, use SpaceMiningUnit.onStatusChanged(status) instead.") end, true, 1)

    --- Emitted when the space mining unit stopped the extraction process.
    self.onStopped = Event:new()


    return setmetatable(self, SpaceMiningUnit)
end