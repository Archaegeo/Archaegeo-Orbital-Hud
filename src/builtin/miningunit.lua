-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Mining unit
--
-- Extracts a regular amount of resources from the ground.
-----------------------------------------------------------------------------------

require("element")

--- Extracts a regular amount of resources from the ground.
---@class MiningUnit
MiningUnit = {}
MiningUnit.__index = MiningUnit
function MiningUnit()
    local self = Element()

    --- Returns the current state of the mining unit
    ---@return integer state The status of the mining unit can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no output container = 4)
    function self.getState() end
    ---@deprecated MiningUnit.getStatus() is deprecated, use MiningUnit.getState() instead.
    function self.getStatus() error("MiningUnit.getStatus() is deprecated, use MiningUnit.getState() instead.") end

    --- Returns the remaining time of the current batch extraction process.
    ---@return number
    function self.getRemainingTime() end

    --- Returns the item ID of the currently selected ore.
    ---@return integer
    function self.getActiveOre() end

    --- Returns the list of available ore pools
    ---@return table pool A list of tables composed with {[int] oreId, [float] available, [float] maximum);
    function self.getOrePools() end

    --- Returns the base production rate of the mining unit.
    ---@return number
    function self.getBaseRate() end

    --- Returns the efficiency rate of the mining unit.
    ---@return number
    function self.getEfficiency() end

    --- Returns the calibration rate of the mining unit.
    ---@return number
    function self.getCalibrationRate() end

    --- Returns the optimal calibration rate of the mining unit.
    ---@return number
    function self.getOptimalRate() end

    --- Returns the current production rate of the mining unit.
    ---@return number
    function self.getProductionRate() end

    --- Returns the territory's adjacency bonus to the territory of the mining unit. Note: This value is updated only when a new batch is started.
    ---@return number
    function self.getAdjacencyBonus() end

    --- Returns the position of the last calibration excavation, in world coordinates.
    ---@return table
    function self.getLastExtractionPosition() end

    --- Returns the ID of the last player who calibrated the mining unit.
    ---@return integer
    function self.getLastExtractingPlayerId() end

    --- Returns the time in seconds since the last calibration of the mining unit.
    ---@return number
    function self.getLastExtractionTime() end

    --- Returns the item ID of the ore extracted during the last calibration excavation.
    ---@return integer
    function self.getLastExtractedOre() end

    --- Returns the volume of ore extracted during the last calibration excavation.
    ---@return number
    function self.getLastExtractedVolume() end

    --- Emitted when the mining unit is calibrated.
    ---@param oreId integer The item ID of the ore extracted during the calibration process
    ---@param amount number Amount of ore extracted during the calibration process
    ---@param rate number The new calibration rate after calibration process
    self.onCalibrated = Event:new()
    self.calibrated = Event:new()
    self.calibrated:addAction(function(self,oreId,amount,rate) error("MiningUnit.calibrated(oreId,amount,rate) event is deprecated, use Industry.onCalibrated(oreId,amount,rate) instead.") end, true, 1)
    
    --- Emitted when the mining unit started a new extraction process.
    ---@param oreId number The item ID of the ore mined during the extraction process
    self.onStarted = Event:new()

    --- Emitted when the mining unit complete a batch.
    ---@param oreId number The item ID of the ore mined during the extraction process
    ---@param amount number Amount of ore mined
    self.onCompleted = Event:new()
    self.completed = Event:new()
    self.completed:addAction(function(self,oreId,amount) error("MiningUnit.completed(oreId,amount) event is deprecated, use MiningUnit.onCompleted(oreId,amount) instead.") end, true, 1)

    --- Emitted when the mining unit status is changed.
    ---@param status integer The status of the mining unit can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no output container = 4)
    self.onStatusChanged = Event:new()
    self.statusChanged = Event:new()
    self.statusChanged:addAction(function(self,status) error("MiningUnit.statusChanged(status) event is deprecated, use MiningUnit.onStatusChanged(status) instead.") end, true, 1)

    --- Emitted when the mining unit stopped the extraction process.
    self.onStopped = Event:new()


    return setmetatable(self, MiningUnit)
end