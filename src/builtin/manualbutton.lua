-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Manual Button
--
-- Emits a signal for the duration it is pressed.
-----------------------------------------------------------------------------------

require("element")

--- Emits a signal for the duration it is pressed.
---@class ManualButton
ManualButton = {}
ManualButton.__index = ManualButton
function ManualButton()
    local self = Element()

    --- Emitted when the button is pressed
    self.onPressed = Event:new()
    self.pressed = Event:new()
    self.pressed:addAction(function(self) error("ManualButton.pressed() event is deprecated, use ManualButton.onPressed() instead.") end, true, 1)

    --- Emitted when the button is released
    self.onReleased = Event:new()
    self.released = Event:new()
    self.released:addAction(function(self) error("ManualButton.released() event is deprecated, use ManualButton.onReleased() instead.") end, true, 1)

    --- Checks if the manual button is down
    ---@return integer
    function self.isDown() end
    ---@deprecated ManualButton.getState() is deprecated, use ManualButton.isDown() instead.
    function self.getState() error("ManualButton.getState() is deprecated, use ManualButton.isDown() instead.") end

    return setmetatable(self, ManualButton)
end