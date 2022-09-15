-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Transponder
--
-- Broadcasts data to radars, that can access more information if their transponder tags are matching
-----------------------------------------------------------------------------------

require("element")

--- Broadcasts data to radars, that can access more information if their transponder tags are matching
---@class Transponder
Transponder = {}
Transponder.__index = Transponder
function Transponder()
    local self = Element()

    --- Activate the transponder
    function self.activate() end

    --- Deactivate the transponder
    function self.deactivate() end

    --- Toggle the state of the transponder
    function self.toggle() end

    --- Checks if the transponder is active
    ---@return integer
    function self.isActive() end
    ---@deprecated Transponder.getState() is deprecated, use Transponder.isActive().
    function self.getState() error("Transponder.getState() is deprecated, use Transponder.isActive().") end

    --- Set the tags list with up to 8 entries. Returns 1 if the application was successful, 0 if the tag
    --- format is invalid.
    ---@param tags table List of up to 8 transponder tag strings
    ---@return integer
    function self.setTags(tags) end

    --- Returns the tag list
    ---@return table tags List of up to 8 transponder tag strings
    function self.getTags() end

    --- Emitted when the transponder is started or stopped
    ---@param active integer 1 if the element was activated, 0 otherwise
    self.onToggled = Event:new()
    self.toggled = Event:new()
    self.toggled:addAction(function(self,active) error("Transponder.toggled(active) event is deprecated, use Transponder.onToggled(active) instead.") end, true, 1)


    return setmetatable(self, Transponder)
end
