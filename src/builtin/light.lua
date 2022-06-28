-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Light
--
-- Emits a source of light.
-----------------------------------------------------------------------------------

require("element")

--- Emits a source of light.
---@class Light
Light = {}
Light.__index = Light
function Light()
    local self = Element()

    --- Switches the light on
    function self.activate() end

    --- Switches the light off
    function self.deactivate() end

    --- Checks if the light is on
    ---@return integer
    function self.isActive() end
    ---@deprecated Light.getState() is deprecated, use Light.isActive() instead.
    function self.getState() error("Light.getState() is deprecated, use Light.isActive() instead.") end

    --- Toggle the state of the light
    function self.toggle() end


    --- Set the light color in RGB. Lights can use HDR color values above 1.0 to glow.
    ---@param r number The red component, between 0.0 and 1.0, up to 5.0 for HDR colors.
    ---@param g number The green component, between 0.0 and 1.0, up to 5.0 for HDR colors.
    ---@param b number The blue component, between 0.0 and 1.0, up to 5.0 for HDR colors.
    function self.setColor(r,g,b) end
    ---@deprecated Light.setRGBColor(r,g,b) is deprecated, use Light.setColor(r,g,b) instead.
    function self.setRGBColor(r,g,b) error("Light.setRGBColor(r,g,b) is deprecated, use Light.setColor(r,g,b) instead.") end

    --- Returns the light color in RGB
    ---@return table color  A vec3 for the red, blue and green components of the light, with values between 0.0 and 1.0, up to 5.0.
    function self.getColor() end
    ---@deprecated Light.getRGBColor() is deprecated, use Light.getColor() instead.
    function self.getRGBColor() error("Light.getRGBColor() is deprecated, use Light.getColor() instead.") end

    --- Returns the blinking state of the light
    ---@param state boolean True to enable light blinking
    function self.setBlinkingState(state) end

    --- Checks if the light blinking is enabled
    ---@return integer
    function self.isBlinking() end

    --- Returns the light 'on' blinking duration
    ---@return number
    function self.getOnBlinkingDuration() end

    --- Set the light 'on' blinking duration
    ---@param time number The duration of the 'on' blinking in seconds
    function self.setOnBlinkingDuration(time) end

    --- Returns the light 'off' blinking duration
    ---@return number
    function self.getOffBlinkingDuration() end

    --- Set the light 'off' blinking duration
    ---@param time number The duration of the 'off' blinking in seconds
    function self.setOffBlinkingDuration(time) end

    --- Returns the light blinking time shift
    ---@return number
    function self.getBlinkingTimeShift() end

    --- Set the light blinking time shift
    ---@param shift number The time shift of the blinking
    function self.setBlinkingTimeShift(shift) end


    return setmetatable(self, Light)
end