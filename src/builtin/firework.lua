-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Fireworks
--
-- A firework launcher capable to launch Fireworks that are stored in the attached Container.
-----------------------------------------------------------------------------------

require("element")

---@class Firework
Firework = {}
Firework.__index = Firework
function Firework()
    local self = Element()

    --- Emitted when a firework has just been fired
    self.onFired = Event:new()


    --- Fire the firework
    function self.fire() end
    ---@deprecated Firework.activate() is deprecated, use Firework.open() instead.
    function self.activate() error("Firework.activate() is deprecated, use Firework.fire() instead.") end

    --- Set the delay before the launched Fireworks explodes
    ---@param delay number The delay before explosion in seconds (maximum 5s)
    function self.setExplosionDelay(delay) end

    --- Returns the delay before the launched Fireworks explodes
    ---@return number
    function self.getExplosionDelay(delay) end

    --- Set the speed at which the firework will be launched (impacts its altitude, depending on the local gravity).
    ---@param speed number The launch speed in m/s (maximum 200m/s)
    function self.setLaunchSpeed(speed) end

    --- Returns the speed at which the firework will be launched
    ---@return number
    function self.getLaunchSpeed() end

    --- Set the type of launched firework (will affect which firework is picked in the attached Container)
    ---@param type integer The type index of the firework (Ball = 1, Ring = 2, Palmtree = 3, Shower = 4)
    function self.setType(type) end

    --- Returns the type of launched firework
    ---@return integer
    function self.getType() end

    --- Set the color of the launched firework (will affect which firework is picked in the attached Container)
    ---@param color integer The color index of the firework (Blue = 1, Gold = 2, Green = 3, Purple = 4, Red = 5, Silver = 6)
    function self.setColor(color) end

    --- Returns the color of the launched firework
    ---@return integer
    function self.getColor() end


    return setmetatable(self, Firework)
end