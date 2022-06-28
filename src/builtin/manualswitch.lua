-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Manual Switch
--
-- A Manual Switch that can be in an on/off state.
-----------------------------------------------------------------------------------

require("element")

--- A Manual Switch that can be in an on/off state.
---@class ManualSwitch
ManualSwitch = {}
ManualSwitch.__index = ManualSwitch
function ManualSwitch()
    local self = Element()

    --- Emitted when the button is pressed
    self.onPressed = Event:new()
    self.pressed = Event:new()
    self.pressed:addAction(function(self) error("ManualSwitch.pressed() event is deprecated, use ManualSwitch.onPressed() instead.") end, true, 1)

    --- Emitted when the button is released
    self.onReleased = Event:new()
    self.released = Event:new()
    self.released:addAction(function(self) error("ManualSwitch.released() event is deprecated, use ManualSwitch.onReleased() instead.") end, true, 1)

    --- Switches the switch on
    function self.activate() end

    --- Switches the switch off
    function self.deactivate() end

    --- Toggle the switch
    function self.toggle() end

    --- Checks if the switch is active
    ---@return integer
    function self.isActive() end
    ---@deprecated ManualSwitch.getState() is deprecated, use ManualSwitch.isActive() instead.
    function self.getState() error("ManualSwitch.getState() is deprecated, use ManualSwitch.isActive() instead.") end

    return setmetatable(self, ManualSwitch)
end