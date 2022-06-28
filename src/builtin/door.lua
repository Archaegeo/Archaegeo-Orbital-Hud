-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Door
--
-- A door that can be opened or closed.
-----------------------------------------------------------------------------------

require("element")

---@class Door
Door = {}
Door.__index = Door
function Door()
    local self = Element()

    --- Open the door
    function self.open() end
    ---@deprecated Door.activate() is deprecated, use Door.open() instead.
    function self.activate() error("Door.activate() is deprecated, use Door.open() instead.") end

    --- Close the door
    function self.close() end
    ---@deprecated Door.deactivate() is deprecated, use Door.close() instead.
    function self.deactivate() error("Door.deactivate() is deprecated, use Door.close() instead.") end

    --- Return the opening status of the door
    ---@return integer
    function self.isOpen() end
    ---@deprecated Door.getState() is deprecated, use Door.isOpen() instead.
    function self.getState() error("Door.getState() is deprecated, use Door.isOpen() instead.") end

    --- Toggle the door
    function self.toggle() end

    return setmetatable(self, Door)
end