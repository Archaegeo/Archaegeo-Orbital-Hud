-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Screen Unit
--
-- Screens can display any HTML code or text message, and you can use them to create visually interactive
-- feedback for your running Lua script by connecting one or more of them to your Control Unit
-----------------------------------------------------------------------------------

require("element")

--- Screens can display any HTML code or text message, and you can use them to create visually interactive
--- feedback for your running Lua script by connecting one or more of them to your Control Unit
---@class Screen
Screen = {}
Screen.__index = Screen
function Screen()
    local self = Element()


    --- Emitted when the player starts a click on the screen
    ---@param x number X-coordinate of the click in percentage (between 0 and 1) of the screen width
    ---@param y number Y-coordinate of the click in percentage (between 0 and 1) the screen height
    self.onMouseDown = Event:new()
    self.mouseDown = Event:new()
    self.mouseDown:addAction(function(self,x,y) error("Screen.mouseDown(x,y) event is deprecated, use Screen.onMouseDown(x,y) instead.") end, true, 1)

    --- Emitted when the player releases a click on the screen
    ---@param x number X-coordinate of the click in percentage (between 0 and 1) of the screen width
    ---@param y number Y-coordinate of the click in percentage (between 0 and 1) the screen height
    self.onMouseUp = Event:new()
    self.mouseUp = Event:new()
    self.mouseUp:addAction(function(self,x,y) error("Screen.mouseUp(x,y) event is deprecated, use Screen.onMouseUp(x,y) instead.") end, true, 1)

    --- Emitted when the output of the screen is changed
    ---@param output string The output string of the screen
    self.onOutputChanged = Event:new()


    --- Switch on the screen
    function self.activate() end

    --- Switch off the screen
    function self.deactivate() end

    --- Checks if the screen is on
    ---@return integer 1 if the screen is on
    function self.isActive() end
    ---@deprecated Screen.getState() is deprecated, use Screen.isActive() instead.
    function self.getState() error("Screen.getState() is deprecated, use Screen.isActive() instead.") end

    --- Toggle the state of the screen
    function self.toggle() end

    --- Displays the given text at the given coordinates in the screen, and returns an ID to move it later
    ---@param x number Horizontal position, as a percentage (between 0 and 100) of the screen width
    ---@param y number Vertical position, as a percentage (between 0 and 100) of the screen height
    ---@param fontSize number Text font size, as a percentage of the screen width
    ---@param text string The text to display
    ---@return integer
    function self.addText(x,y,fontSize,text) end

    --- Displays the given text centered in the screen with a font to maximize its visibility
    ---@param text string The text to display
    function self.setCenteredText(text) end

    --- Set the whole screen HTML content (overrides anything already set)
    ---@param html string The HTML content to display
    function self.setHTML(html) end

    --- Set the screen render script, switching the screen to native rendering mode
    ---@param script string The Lua render script
    function self.setRenderScript(script) end

    --- Defines the input of the screen rendering script, which will be automatically defined during the execution of Lua
    ---@param input string A string that can be retrieved by calling getInput in a render script
    function self.setScriptInput(input) end

    --- Set the screen render script output to the empty string
    function self.clearScriptOutput() end

    --- Get the screen render script output
    ---@return string value The contents of the last render script setOutput call, or an empty string
    function self.getScriptOutput() end

    --- Displays the given HTML content at the given coordinates in the screen, and returns an ID to move it later
    ---@param x number Horizontal position, as a percentage (between 0 and 100) of the screen width
    ---@param y number Vertical position, as a percentage (between 0 and 100) of the screen height
    ---@param html string The HTML content to display, which can contain SVG html elements to make drawings
    ---@return integer
    function self.addContent(x,y,html) end

    --- Displays SVG code (anything that fits within a <svg> section), which overrides any preexisting content
    ---@param svg string The SVG content to display, which fits inside a 1920x1080 canvas
    function self.setSVG(svg) end

    --- Update the html element with the given ID (returned by addContent) with a new HTML content
    ---@param id integer An integer ID that is used to identify the html element in the screen. Methods such as addContent return the ID that you can store to use later here
    ---@param html string The HTML content to display, which can contain SVG html elements to make drawings
    function self.resetContent(id,html) end

    --- Delete the html element with the given ID (returned by addContent)
    ---@param id integer An integer ID that is used to identify the html element in the screen. Methods such as addContent return the id that you can store to use later here
    function self.deleteContent(id) end

    --- Update the visibility of the html element with the given ID (returned by addContent)
    ---@param id integer An integer ID that is used to identify the html element in the screen. Methods such as addContent return the ID that you can store to use later here
    ---@param state boolean true to show the content, false to hide
    function self.showContent(id,state) end

    --- Move the html element with the given id (returned by addContent) to a new position in the screen
    ---@param id integer An integer id that is used to identify the html element in the screen. Methods such as addContent return the ID that you can store to use later here
    ---@param x number Horizontal position, as a percentage (between 0 and 100) of the screen width
    ---@param y number Vertical position, as a percentage (between 0 and 100) of the screen height
    function self.moveContent(id,x,y) end

    --- Returns the x-coordinate of the position point at in the screen
    ---@return number x The x-position as a percentage (between 0 and 1) of screen width; -1 if nothing is point at
    function self.getMouseX() end

    --- Returns the y-coordinate of the position point at in the screen
    ---@return number y The y-position as a percentage (between 0 and 1) of screen height; -1 if nothing is point at
    function self.getMouseY() end

    --- Returns the state of the mouse click
    ---@return integer 1 if the mouse is pressed, otherwise 0
    function self.getMouseState() end

    --- Clear the screen
    function self.clear() end

    return setmetatable(self, Door)
end