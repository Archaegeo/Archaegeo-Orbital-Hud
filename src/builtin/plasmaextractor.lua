-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Plasma extractor
--
-- Extracts a regular amount of plasma from the space surrouding an alien core
-----------------------------------------------------------------------------------

require("element")

--- Extracts a regular amount of plasma from the space surrouding an alien core
---@class PlasmaExtractor
PlasmaExtractor = {}
PlasmaExtractor.__index = PlasmaExtractor
function PlasmaExtractor()
    local self = Element()

    --- Returns the current status of the plasma extractor
    ---@return integer status The status of the plasma extractor can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no output container = 4)
    function self.getStatus() end

    --- Returns the remaining time of the current batch extraction process.
    ---@return number
    function self.getRemainingTime() end

    --- Returns the list of available plasma pools
    ---@return table pool A list of tables composed with {[int] oreId, [float] available, [float] maximum);
    function self.getPlasmaPools() end

    --- Emitted when the plasma extractor started a new extraction process
    self.onStarted = Event:new()

    ---Emitted when the plasma extractor complete a batch
    self.onCompleted = Event:new()

    --- Emitted when the plasma extractor status is changed
    ---@param status integer The status of the plasma extractor can be (Stopped = 1, Running = 2, Jammed output full = 3, Jammed no output container = 4)
    self.onStatusChanged = Event:new()

    --- Emitted when the plasma extractor stopped the extraction process
    self.onStopped = Event:new()


    return setmetatable(self, PlasmaExtractor)
end