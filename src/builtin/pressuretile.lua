-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Pressure Tile
--
-- Emits a signal when a player walks on the tile.
-----------------------------------------------------------------------------------

require("element")

--- Emits a signal when a player walks on the tile.
---@class PressureTile
PressureTile = {}
PressureTile.__index = PressureTile
function PressureTile()
    local self = Element()

    --- Emitted when the pressure tile is pressed
    self.onPressed = Event:new()
    self.pressed = Event:new()
    self.pressed:addAction(function(self) error("PressureTile.pressed() event is deprecated, use PressureTile.onPressed() instead.") end, true, 1)

    --- Emitter when the pressure tile is released
    self.onReleased = Event:new()
    self.released = Event:new()
    self.released:addAction(function(self) error("PressureTile.released() event is deprecated, use PressureTile.onReleased() instead.") end, true, 1)

    --- Checks if the pressure tile is down
    ---@return integer
    function self.isDown() end
    ---@deprecated PressureTile.getState() is deprecated, use PressureTile.isDown() instead.
    function self.getState() error("PressureTile.getState() is deprecated, use PressureTile.isDown() instead.") end

    return setmetatable(self, ManualSwitch)
end