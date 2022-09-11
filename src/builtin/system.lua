-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- System
--
-- System is a virtual Element that represents your computer. It gives access to events like key strokes or mouse movements
-- that can be used inside your scripts. It also gives you access to regular updates that can be used to pace the execution
-- of your script
-----------------------------------------------------------------------------------

--- Actions available on onActionStart, onActionStop and onActionLoop events
LUA_ACTION = {
    FORWARD = "forward",
    BACKWARD = "backward",
    YAWLEFT = "yawleft",
    YAWRIGHT = "yawright",
    STRAFELEFT = "strafeleft",
    STRAFERIGHT = "straferight",
    LEFT = "left",
    RIGHT = "right",
    UP = "up",
    DOWN = "down",
    GROUNDALTITUDEUP = "groundaltitudeup",
    GROUNDALTITUDEDOWN = "groundaltitudedown",
    LALT = "lalt",
    LSHIFT = "lshift",
    GEAR = "gear",
    LIGHT = "light",
    BRAKE = "brake",
    OPTION1 = "option1",
    OPTION2 = "option2",
    OPTION3 = "option3",
    OPTION4 = "option4",
    OPTION5 = "option5",
    OPTION6 = "option6",
    OPTION7 = "option7",
    OPTION8 = "option8",
    OPTION9 = "option9",
    LEFTMOUSE = "leftmouse",
    STOPENGINES = "stopengines",
    SPEEDUP = "speedup",
    SPEEDDOWN = "speeddown",
    ANTIGRAVITY = "antigravity",
    BOOSTER = "booster"
}


--- This class represents the System who is executing the control unit
---@class System
System = {}
System.__index = System
function System()
    local self = {}


    --- Emitted when an action starts
    ---@param action string The action name, represented as a string taken among the set of predefined Lua-available actions (you can check the drop down list to see what is available)
    self.onActionStart = Event:new()
    self.actionStart = Event:new()
    self.actionStart:addAction(function(self,action) error("System.actionStart(action) event is deprecated, use System.onActionStart(action) instead.") end, true, 1)

    --- Emitted when an action stops
    ---@param action string The action name, represented as a string taken among the set of predefined Lua-available actions (you can check the drop down list to see what is available)
    self.onActionStop = Event:new()
    self.actionStop = Event:new()
    self.actionStop:addAction(function(self,action) error("System.actionStop(action) event is deprecated, use System.onActionStop(action) instead.") end, true, 1)

    --- Emitted at each update as long as the action is maintained
    ---@param action string The action name, represented as a string taken among the set of predefined Lua-available actions (you can check the drop down list to see what is available)
    self.onActionLoop = Event:new()
    self.actionLoop = Event:new()
    self.actionLoop:addAction(function(self,action) error("System.actionLoop(action) event is deprecated, use System.onActionLoop(action) instead.") end, true, 1)

    --- Game update event. This is equivalent to a timer set at 0 seconds, as updates will go as fast as the FPS can go
    self.onUpdate = Event:new()
    self.update = Event:new()
    self.update:addAction(function(self,action) error("System.update() event is deprecated, use System.onUpdate() instead.") end, true, 1)

    --- Physics update. Do not use to put anything else by a call to updateICC on your Control Unit, as many functions are
    --- disabled when called from 'onFlush'. This is only to update the physics (engine control, etc), not to setup some gameplay code
    self.onFlush = Event:new()
    self.flush = Event:new()
    self.flush:addAction(function(self,action) error("System.flush() event is deprecated, use System.onFlush() instead.") end, true, 1)

    --- A new message has been entered in the Lua tab of the chat, acting like a command line interface
    ---@param text string The message entered
    self.onInputText = Event:new()
    self.inputText = Event:new()
    self.inputText:addAction(function(self,text) error("System.inputText(text) event is deprecated, use System.onInputText(text) instead.") end, true, 1)

    --- Emitted when the player changes the camera mode.
    ---@param mode integer The camera mode, represented by an integer (First Person View = 1, Look Around Construct View = 2, Follow Construct View = 3)
    self.onCameraChanged = Event:new()
    self.cameraChanged = Event:new()
    self.cameraChanged:addAction(function(self,mode) error("System.cameraChanged(mode) event is deprecated, use System.onCameraChanged(mode) instead.") end, true, 1)

    --- Return the currently key bound to the given action. Useful to display tips.
    ---@param actionName string The action name, represented as a string taken among the set of predefined Lua-available actions (you can check the drop down list to see what is available)
    ---@return string value The key associated to the given action name
    function self.getActionKeyName(actionName) end

    --- Control the display of the Control Unit custom screen, where you can define customized display information in HTML. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param bool boolean True to show the screen, false to hide the screen
    function self.showScreen(bool) end

    --- Set the content of the Control Unit custom screen with some HTML code. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param content string The HTML content you want to display on the screen widget. You can also use SVG here to make drawings.
    function self.setScreen(content) end
    
    --- Create an empty panel. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param label string The title of the panel
    ---@return string value The panel ID, or "" on failure
    function self.createWidgetPanel(label) end
    
    --- Destroy the panel. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param panelId string The panel ID
    ---@return integer value 1 on success, 0 on failure.
    function self.destroyWidgetPanel(panelId) end

    --- Create an empty widget and add it to a panel. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param panelId string The panel ID
    ---@param type string Widget type, determining how it will display data attached to ID
    ---@return string value The widget ID, or "" on failure.
    function self.createWidget(panelId, type) end

    --- Destroy the widget. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param widgetId string The widget ID
    ---@return integer value 1 on success, 0 on failure.
    function self.destroyWidget(widgetId) end

    --- Create data. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param dataJson string The data fields as JSON
    ---@return string value The data ID, or "" on failure.
    function self.createData(dataJson) end

    --- Destroy the data. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param dataId string The data ID
    ---@return integer value 1 on success, 0 on failure.
    function self.destroyData(dataId) end

    --- Update JSON associated to data. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param dataId string The data ID
    ---@param dataJson string The data fields as JSON
    ---@return integer value 1 on success, 0 on failure.
    function self.updateData(dataId, dataJson) end

    --- Add data to widget. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param dataId string The data ID
    ---@param widgetId string The widget ID
    ---@return integer value 1 on success, 0 on failure.
    function self.addDataToWidget(dataId, widgetId) end

    --- Remove data from widget. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param dataId string The data ID
    ---@param widgetId string The widget ID
    ---@return integer value 1 on success, 0 on failure.
    function self.removeDataFromWidget(dataId, widgetId) end
    
    --- Return the current value of the mouse wheel
    ---@return number value The current value of the mouse wheel
    function self.getMouseWheel() end

    --- Return the current value of the mouse delta X
    ---@return number value The current value of the mouse delta X
    function self.getMouseDeltaX() end

    --- Return the current value of the mouse delta Y
    ---@return number value The current value of the mouse delta Y
    function self.getMouseDeltaY() end

    --- Return the current value of the mouse pos X
    ---@return number value The current value of the mouse pos X
    function self.getMousePosX() end

    --- Return the current value of the mouse pos Y
    ---@return number value The current value of the mouse pos Y
    function self.getMousePosY() end
    
    --- Return the value of mouse sensitivity game setting
    ---@return number value Sensitivity setting value
    function self.getMouseSensitivity() end

    --- Return the current value of the screen height
    ---@return integer value The current value of the screen height
    function self.getScreenHeight() end

    --- Return the current value of the screen width
    ---@return integer value The current value of the screen width
    function self.getScreenWidth() end

    --- Return the current value of the player's horizontal field of view
    ---@return number value The current value of the player's horizontal field of view
    function self.getCameraHorizontalFov() end
    ---@deprecated System.getFov() is deprecated, use System.getCameraHorizontalFov().
    function self.getFov() error("System.getFov() is deprecated, use System.getCameraHorizontalFov().") end
    
    --- Return the current value of the player's vertical field of view
    ---@return number value The current value of the player's vertical field of view
    function self.getCameraVerticalFov() end

    --- Returns the active camera mode.
    ---@return integer mode 1: First Person View, 2: Look Around Construct View, 3: Follow Construct View
    function self.getCameraMode() end

    --- Checks if the active camera is in first person view.
    ---@return integer value 1 if the camera is in first person view.
    function self.isFirstPerson() end

    --- Returns the position of the camera, in construct local coordinates.
    ---@return table value Camera position in construct local coordinates.
    function self.getCameraPos() end
    
    --- Returns the position of the camera, in world coordinates.
    ---@return table value Camera position in world coordinates.
    function self.getCameraWorldPos() end

    --- Returns the forward direction vector of the active camera, in world coordinates.
    ---@return table value Camera forward direction vector in world coordinates.
    function self.getCameraWorldForward() end

    --- Returns the right direction vector of the active camera, in world coordinates.
    ---@return table value Camera right direction vector in world coordinates.
    function self.getCameraWorldRight() end

    --- Returns the up direction vector of the active camera, in world coordinates.
    ---@return table value Camera up direction vector in world coordinates.
    function self.getCameraWorldUp() end

    --- Returns the forward direction vector of the active camera, in construct local coordinates.
    ---@return table value Camera forward direction vector in construct local coordinates.
    function self.getCameraForward() end

    --- Returns the right direction vector of the active camera, in construct local coordinates.
    ---@return table value Camera right direction vector in construct local coordinates.
    function self.getCameraRight() end

    --- Returns the up direction vector of the active camera, in construct local coordinates.
    ---@return table value Camera up direction vector in construct local coordinates.
    function self.getCameraUp() end

    --- Return the current value of the mouse wheel (for the throttle speedUp/speedDown action)
    --- This value will go through the control scheme, devices and sensitivity
    ---@return number value The current input
    function self.getThrottleInputFromMouseWheel() end
       
    --- Return the mouse input for the ship control action (forward/backward)
    --- This value will go through the control scheme to know on which input the mouse is mapped and its current sensitivity
    ---@return number value The current input
    function self.getControlDeviceForwardInput() end
    
    --- Return the mouse input for the ship control action  (yaw right/left)
    --- This value will go through the control scheme to know on which input the mouse is mapped and its current sensitivity
    ---@return number value The current input
    function self.getControlDeviceYawInput() end

    --- Return the mouse input for the ship control action  (right/left)
    --- This value will go through the control scheme to know on which input the mouse is mapped and its current sensitivity
    ---@return number value The current value of the mouse delta Y
    function self.getControlDeviceLeftRightInput() end

    --- Lock or unlock the mouse free look.
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param state boolean true to lock and false to unlock
    function self.lockView(state) end

    --- Return the lock state of the mouse free look
    ---@return integer value 1 when locked and 0 when unlocked
    function self.isViewLocked() end

    ---@deprecated System.freeze() is deprecated, use Player.freeze().
    function self.freeze(state) error("System.freeze(state) is deprecated, use Player.freeze(state) instead.") end
    ---@deprecated System.isFrozen() is deprecated, use Player.isFrozen().
    function self.isFrozen() error("System.isFrozen() is deprecated, use Player.isFrozen() instead.") end

    --- Return the current time since the arrival of the Arkship on September 30th, 2017
    ---@return number value Time in seconds
    function self.getArkTime() end
    ---@deprecated System.getTime() is deprecated, use System.getArkTime().
    function self.getTime() error("System.getTime() is deprecated, use System.getArkTime() instead.") end

    --- Return the current time since January 1st, 1970.
    ---@return number value Time in seconds
    function self.getUtcTime() end

    --- Return the time offset between local timezone and UTC
    ---@return number value Time in seconds
    function self.getUtcOffset() end

    --- Return the locale in which the game is currently running
    ---@return string value The locale, currently one of "en-US", "fr-FR", or "de-DE"
    function self.getLocale() end

    --- Return delta time of action updates (to use in ActionLoop)
    ---@return number value The delta time in seconds
    function self.getActionUpdateDeltaTime() end

    --- Return the name of the given player, if in range of visibility or broadcasted by a transponder
    ---@param id integer The ID of the player
    ---@return string value The name of the player
    function self.getPlayerName(id) end

    --- Return the world position of the given player, if in range of visibility
    ---@param id integer The ID of the player
    ---@return table value The coordinates of the player in world coordinates
    function self.getPlayerWorldPos(id) end
    
    --- Return the item table corresponding to the given item ID.
    ---@param id integer The ID of the item
    ---@return table value An item table with fields: {[int] id, [string] name, [string] displayName, [string] locDisplayName, [string] displayNameWithSize, [string] locDisplayNameWithSize, [string] description, [string] locDescription, [string] type, [number] unitMass, [number] unitVolume, [integer] tier, [string] scale, [string] iconPath, [table] schematics, [table] products}
    function self.getItem(id) end

    --- Returns a list of recipes producing the given item from its id.
    ---@param itemId integer The ID of the item
    ---@return table value A list of recipe table with field: {[int] id, [int] tier,[double] time, [bool] nanocraftable, [table] products:{{[int] id, [double] quantity},...}, [table] ingredients:{{[int] id, [double] quantity},...}}
    function self.getRecipes(itemId) end
    ---@deprecated System.getSchematic(id) is deprecated, use System.getRecipes(itemId).tag.
    function self.getSchematic(id) error("System.getSchematic(id) is deprecated, use System.getRecipes(itemId) instead.") end


    --- Returns the corresping organization to the given organization id, if known, e.g. broadcasted by a transponder
    ---@param id integer The ID of the organization
    ---@return table value A table containing information about the given organization {[string] name, [string] tag}
    function self.getOrganization(id) end
    ---@deprecated System.getOrganizationName() is deprecated, use System.getOrganization(id).name .
    function self.getOrganizationName() error("System.getOrganizationName() is deprecated, use System.getOrganization(id).name instead.") end
    ---@deprecated System.getOrganizationTag() is deprecated, use System.getOrganization(id).tag .
    function self.getOrganizationTag() error("System.getOrganizationTag() is deprecated, use System.getOrganization(id).tag instead.") end

    --- Return the player's world position as a waypoint string, starting with '::pos' (only in explicit runs)
    ---@return string value The waypoint as a string
    function self.getWaypointFromPlayerPos() end
    
    --- Set a waypoint at the destination described by the waypoint string, of the form '::pos{...}' (only in explicit runs)
    ---@param waypointStr string The waypoint as a string
    ---@param notify boolean (Optional) True to display a notification on waypoint change
    function self.setWaypoint(waypointStr,notify) end
    
    --- Clear the active destination waypoint. (only in explicit runs)'
    ---@param notify boolean (Optional) True to display a notification about the waypoint's clearing
    function self.clearWaypoint(notify) end

    --- Set the visibility of the helper top menu.
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal).
    ---@param show boolean True to show the top helper menu, false to hide the top helper menu
    function self.showHelper(show) end

    --- Play a sound file from your audio folder (located in "My documents/NQ/DualUniverse/audio"). Only one sound can be played at a time.
    ---@param filePath string Relative path to audio folder (.mp3, .wav)
    function self.playSound(filePath) end
    --- Checks if a sound is playing
    ---@return integer value 1 if a sound is playing
    function self.isPlayingSound() end
    --- Stop the current playing sound
    function self.stopSound() end


    --- Print the given string in the Lua chat channel
    ---@param msg string
    function self.print(msg) end

    return setmetatable(self, System)
end

--- Global alias available out of the game
DUSystem = System
