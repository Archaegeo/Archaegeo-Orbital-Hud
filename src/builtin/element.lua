-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Generic Element
--
-- All Elements share the same generic methods described below
-----------------------------------------------------------------------------------

Event = require("utils/event")

---@class Element
Element = {}
Element.__index = Element
function Element()
    local self = {}

    --- Show the element widget in the in-game widget stack
    function self.showWidget() end
    ---@deprecated Element.show() is deprecated, use Element.showWidget() instead.
    function self.show() error("Element.show() is deprecated, use Element.showWidget() instead.") end

    --- Hide the element widget in the in-game widget stack
    function self.hideWidget() end
    ---@deprecated Element.hide() is deprecated, use Element.hideWidget() instead.
    function self.hide() error("Element.hide() is deprecated, use Element.hideWidget() instead.") end

    --- Returns the widget type compatible with the element data
    ---@return string
    function self.getWidgetType() end

    --- Returns the element data as JSON
    ---@return string
    function self.getWidgetData() end
    ---@deprecated Element.getData() is deprecated, use Element.getWidgetData() instead.
    function self.getData() error("Element.getData() is deprecated, use Element.getWidgetData() instead.") end

    --- Returns the element data ID
    ---@return string
    function self.getWidgetDataId() end
    ---@deprecated Element.getDataId() is deprecated, use Element.getWidgetDataId() instead.
    function self.getDataId() error("Element.getDataId() is deprecated, use Element.getWidgetDataId() instead.") end

    --- Returns the element name
    ---@return string
    function self.getName() end

    --- Returns the class of the Element
    ---@return string
    function self.getClass() end
    ---@deprecated Element.getElementClass() is deprecated, use Element.getClass() instead.
    function self.getElementClass() error("Element.getElementClass() is deprecated, use Element.getClass() instead.") end

    --- Returns the mass of the element (includes the included items' mass when the Element is a Container)
    ---@return number
    function self.getMass() end

    --- Returns the element item ID (to be used with system.getItem() function to get information about the element).
    ---@return integer
    function self.getItemId() end

    --- Returns the unique local ID of the element
    ---@return integer
    function self.getLocalId() end
    ---@deprecated Element.getId() is deprecated, use Element.getLocalId() instead.
    function self.getId() error("Element.getId() is deprecated, use Element.getLocalId() instead.") end

    --- Returns the element integrity between 0 and 100
    ---@return number
    function self.getIntegrity() end

    --- Returns the element's current hit points (0 = destroyed)
    ---@return number
    function self.getHitPoints() end

    --- Returns the element's maximal hit points
    ---@return number
    function self.getMaxHitPoints() end

    --- Returns the element's remaining number of restorations
    ---@return integer
    function self.getRemainingRestorations() end

    --- Returns the element's maximal number of restorations
    ---@return integer
    function self.getMaxRestorations() end

    --- Returns the position of the Element in construct local coordinates.
    ---@return table
    function self.getPosition() end

    --- Returns the bounding box dimensions of the element.
    ---@return table
    function self.getBoundingBoxSize() end

    --- Returns the position of the center of bounding box of the element in local construct coordinates.
    ---@return table
    function self.getBoundingBoxCenter() end

    --- Returns the up direction vector of the Element in construct local coordinates
    ---@return table
    function self.getUp() end

    --- Returns the right direction vector of the Element in construct local coordinates
    ---@return table
    function self.getRight() end

    --- Returns the forward direction vector of the Element in construct local coordinates
    ---@return table
    function self.getForward() end

    --- Returns the up direction vector of the Element in world coordinates
    ---@return table
    function self.getWorldUp() end

    --- Returns the right direction vector of the Element in world coordinates
    ---@return table
    function self.getWorldRight() end

    --- Returns the forward direction vector of the Element in world coordinates
    ---@return table
    function self.getWorldForward() end

    --- Set the value of a signal in the specified IN plug of the Element.
    --- Standard plug names are built with the following syntax: direction-type-index. 'Direction' can be IN or OUT.
    --- 'type' is one of the following: ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number between 0 and
    --- the total number of plugs of the given type in the given direction. Some plugs have special names like 'on' or 'off' for the
    --- Manual Switch Unit. Just check in-game for the plug names if you have a doubt.
    ---@param plug string The plug name, in the form of IN-SIGNAL-index
    ---@param state integer The plug signal state
    function self.setSignalIn(plug, state) end

    --- Returns the value of a signal in the specified IN plug of the Element.
    --- Standard plug names are built with the following syntax: direction-type-index. 'Direction' can be IN or OUT.
    --- 'type' is one of the following: ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number between 0 and
    --- the total number of plugs of the given type in the given direction. Some plugs have special names like 'on' or 'off' for the
    --- Manual Switch Unit. Just check in-game for the plug names if you have a doubt.
    ---@param plug string The plug name, in the form of IN-SIGNAL-index
    ---@return integer value The plug signal state
    function self.getSignalIn(plug) end

    --- Returns the value of a signal in the specified OUT plug of the Element.
    --- Standard plug names are built with the following syntax: direction-type-index. 'Direction' can be IN or OUT.
    --- 'type' is one of the following: ITEM, FUEL, ELECTRICITY, SIGNAL, HEAT, FLUID, CONTROL, and 'index' is a number between 0 and
    --- the total number of plugs of the given type in the given direction. Some plugs have special names like 'on' or 'off' for the
    --- Manual Switch Unit. Just check in-game for the plug names if you have a doubt.
    ---@param plug string The plug name, in the form of IN-SIGNAL-index
    ---@return integer value The plug signal state
    function self.getSignalOut(plug) end

    return setmetatable(self, Element)
end