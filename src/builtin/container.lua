-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Container
--
-- Containers are elements designed to store items and resources
-----------------------------------------------------------------------------------

require("element")

---@class Container
Container = {}
Container.__index = Container
function Container()
    local self = Element()

    --- Returns the mass of the container element(as if it were empty).
    ---@return number
    function self.getSelfMass() end

    --- Returns the container content mass(the sum of the mass of all items it contains).
    ---@return number
    function self.getItemsMass() end
    
    --- Returns the container content volume(the sum of the volume of all items it contains).
    ---@return number
    function self.getItemsVolume() end
    
    --- Returns the maximum volume of the container.
    ---@return number
    function self.getMaxVolume() end

    --- Returns a table describing the contents of the container, as a pair itemId and quantity per slot.
    ---@return table content The content of the container as a table with fields {[int] id, [float] quantity} per slot
    function self.getContent() end
    ---@deprecated Container.getItemsList() is deprecated, use Container.getContent() instead.
    function self.getItemsList() error("Container.getItemsList() is deprecated, use Container.getContent() instead.")  end

    --- Send a request to get an update of the content of the container, limited to one call allowed per 30 seconds.
    --- The onContentUpdate event is emitted by the container when the content is updated.
    ---@return number time If the request is not yet possible, returns the remaining time to wait for.
    function self.updateContent() end
    ---@deprecated Container.acquireStorage() is deprecated, use Container.updateContent() instead.
    function self.acquireStorage() error("Container.acquireStorage() is deprecated, use Container.updateContent() instead.") end

    --- Emitted when the container content is updated(storage update or after a manual request made with updateContent())
    self.onContentUpdate = Event:new()
    self.storageAcquired = Event:new()
    self.storageAcquired:addAction(function(self) error("Container.storageAcquired() event is deprecated, use Container.onContentUpdate() instead.") end, true, 1)

    return setmetatable(self, Container)
end