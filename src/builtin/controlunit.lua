-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Control Unit
--
-- Control Units come in various forms: cockpits, programming boards, emergency Control Units, etc.
-- A Control Unit stores a set of Lua scripts that can be used to control the Elements that are plugged on its CONTROL plugs.
-- Kinematics Control Units like cockpit or command seats are also capable of controlling the ship's engines via the
-- update ICC method.
-----------------------------------------------------------------------------------

require("element")

---@class ControlUnit
ControlUnit = {}
ControlUnit.__index = ControlUnit
function ControlUnit()
    local self = Element()

    --- Stops the Control Unit's Lua code and exits. Warning: calling this might cause your ship to fall from the sky,
    --- use it with care. It is typically used in the coding of emergency Control Unit scripts to stop control once the ECU
    --- thinks that the ship has safely landed.
    function self.exit() end

    ---@deprecated ControlUnit.getMasterPlayerId() is deprecated, use player.getId() instead.
    function self.getMasterPlayerId() error("ControlUnit.getMasterPlayerId() is deprecated, use player.getId() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerOrgIds() is deprecated, use player.getOrgIds() instead.
    function self.getMasterPlayerOrgIds() error("ControlUnit.getMasterPlayerOrgIds() is deprecated, use player.getOrgIds() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerPosition() is deprecated, use player.getPosition() instead.
    function self.getMasterPlayerPosition() error("ControlUnit.getMasterPlayerPosition() is deprecated, use player.getPosition() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerWorldPosition() is deprecated, use player.getWorldPosition() instead.
    function self.getMasterPlayerWorldPosition() error("ControlUnit.getMasterPlayerWorldPosition() is deprecated, use player.getWorldPosition() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerForward() is deprecated, use player.getForward() instead.
    function self.getMasterPlayerForward() error("ControlUnit.getMasterPlayerForward() is deprecated, use player.getForward() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerUp() is deprecated, use player.getUp() instead.
    function self.getMasterPlayerUp() error("ControlUnit.getMasterPlayerUp() is deprecated, use player.getUp() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerRight() is deprecated, use player.getRight() instead.
    function self.getMasterPlayerRight() error("ControlUnit.getMasterPlayerRight() is deprecated, use player.getRight() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerWorldForward() is deprecated, use player.getWorldForward() instead.
    function self.getMasterPlayerWorldForward() error("ControlUnit.getMasterPlayerWorldForward() is deprecated, use player.getWorldForward() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerWorldUp() is deprecated, use player.getWorldUp() instead.
    function self.getMasterPlayerWorldUp() error("ControlUnit.getMasterPlayerWorldUp() is deprecated, use player.getWorldUp() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerWorldRight() is deprecated, use player.getWorldRight() instead.
    function self.getMasterPlayerWorldRight() error("ControlUnit.getMasterPlayerWorldRight() is deprecated, use player.getWorldRight() instead.") end
    ---@deprecated ControlUnit.isMasterPlayerSeated() is deprecated, use player.isSeated() instead.
    function self.isMasterPlayerSeated() error("ControlUnit.isMasterPlayerSeated() is deprecated, use player.isSeated() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerSeatId() is deprecated, use player.getSeatId() instead.
    function self.getMasterPlayerSeatId() error("ControlUnit.getMasterPlayerSeatId() is deprecated, use player.getSeatId() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerParent() is deprecated, use player.getParent() instead.
    function self.getMasterPlayerParent() error("ControlUnit.getMasterPlayerParent() is deprecated, use player.getParent() instead.") end
    ---@deprecated ControlUnit.getMasterPlayerMass() is deprecated, use player.getMass() instead.
    function self.getMasterPlayerMass() error("ControlUnit.getMasterPlayerMass() is deprecated, use player.getMass() instead.") end


    --- Set up a timer with a given tag in a given period. This will start to trigger the 'onTimer' event with
    --- the corresponding tag as an argument, to help you identify what is ticking, and when.
    ---@param tag string The tag of the timer, as a string, which will be used in the 'onTimer' event to identify this particular timer
    ---@param period number The period of the timer, in seconds. The time resolution is limited by the framerate here, so you cannot set arbitrarily fast timers
    function self.setTimer(tag, period) end

    --- Stop the timer with the given tag
    ---@param tag string The tag of the timer to stop, as a string
    function self.stopTimer(tag) end

    --- Emitted when the timer with the tag 'tag' is ticking
    ---@param tag string The tag of the timer that just ticked (see setTimer to set a timer with a given tag)
    self.onTimer = Event:new()
    self.tick = Event:new()
    self.tick:addAction(function(self,tag) error("Radar.tick(timerId) event is deprecated, use Radar.onTimer(tag) instead.") end, true, 1)

    --- Returns the ambient atmospheric density
    ---@return number density The atmospheric density(between 0 and 1)
    function self.getAtmosphereDensity() end

    --- Returns the influence rate of the nearest planet
    ---@return number rate The planet influence rate(between 0 and 1)
    function self.getClosestPlanetInfluence() end

    --- Checks if the control unit is protected by DRM
    ---@return integer
    function self.hasDRM() end
    --- Check if the construct is remote controlled
    ---@return integer
    function self.isRemoteControlled() end


    --- Automatically assign the engines within the taglist
    --- to result in the given acceleration and angular acceleration provided. Can only be called within the system.onFlush event
    --- If engines designated by the tags are not capable of producing the desired command, setEngineCommand will try to do its best
    --- to approximate it
    --- This function must be used on a piloting controller in onFlush event
    ---@param taglist string Comma (for union) or space (for intersection) separated list of tags. You can set tags directly on the engines in the right-click menu
    ---@param acceleration table The desired acceleration expressed in world coordinates in m/s2
    ---@param angularAcceleration table The desired angular acceleration expressed in world coordinates in rad/s2
    ---@param keepForceCollinearity boolean Forces the resulting acceleration vector to be collinear to the acceleration parameter
    ---@param keepTorqueCollinearity boolean Forces the resulting angular acceleration vector to be collinear to the angular acceleration parameter
    ---@param priority1SubTags string Comma (for union) or space (for intersection) separated list of tags of included engines to use as priority 1
    ---@param priority2SubTags string Comma (for union) or space (for intersection) separated list of tags of included engines to use as priority 2
    ---@param priority3SubTags string Comma (for union) or space (for intersection) separated list of tags of included engines to use as priority 3
    --- Other included engines not in any priority will be used last
    ---@param toleranceRatioToStopCommand number When going through with priorities, if we reach a command that is achieved within this tolerance, we will stop there
    function self.setEngineCommand(taglist, acceleration, angularAcceleration, keepForceCollinearity, keepTorqueCollinearity, priority1SubTags, priority2SubTags, priority3SubTags, toleranceRatioToStopCommand) end

    --- Sets the thrust values for all engines in the tag list
    --- This function must be used on a piloting controller
    ---@param taglist string Comma separated list of tags. You can set tags directly on the engines in the right-click menu
    ---@param thrust number The desired thrust in newtons (note that for boosters, any non zero value here will set them to 100%)
    function self.setEngineThrust(taglist, thrust) end

    --- Returns the total thrust values of all engines in the tag list
    --- This function must be used on a piloting controller
    ---@param taglist string Comma separated list of tags. You can set tags directly on the engines in the right-click menu
    ---@return table The total thrust in newtons
    function self.getEngineThrust(taglist) end

    --- Set the value of throttle in the cockpit, which will be displayed in the cockpit widget when flying
    --- This function must be used on a piloting controller
    ---@param axis integer Longitudinal = 0, lateral = 1, vertical = 2
    ---@param commandValue number In 'by throttle', the value of the throttle position: -1 = full reverse, 1 = full forward. Or In 'By Target Speed', the value of the target speed in km/h
    function self.setAxisCommandValue(axis, commandValue) end

    --- Get the value of throttle in the cockpit
    --- This function must be used on a piloting controller
    ---@param axis integer Longitudinal = 0, lateral = 1, vertical = 2
    ---@return number value In travel mode, return the value of the throttle position: -1 = full reverse, 1 = full forward or in cruise mode, return the value of the target speed
    function self.getAxisCommandValue(axis) end

    --- Set the properties of an axis command
    --- This function must be used on a piloting controller
    --- These properties will be used to display the command in UI
    ---@param axis integer Longitudinal = 0, lateral = 1, vertical = 2
    ---@param commandType integer By throttle = 0, by target speed = 1, hidden = 2
    ---@param targetSpeedRanges table This is to specify the cruise control target speed ranges (for now, only for the longitudinal axis) in m/s
    function self.setupAxisCommandProperties(axis, commandType, targetSpeedRanges) end

    --- Returns the current control mode. The mode is set by clicking the UI button or using the associated keybinding
    --- This function must be used on a piloting controller
    ---@return integer The current control mode (for now, only 2 are available, 0 and 1)
    function self.getControlMode() end
    ---@deprecated ControlUnit.getControlMasterModeId() is deprecated, use ControlUnit.getControlMode() instead.
    function self.getControlMasterModeId() error("ControlUnit.getControlMasterModeId() is deprecated, use ControlUnit.getControlMode() instead.") end

    --- Cancel the current master mode in use
    --- This function must be used on a piloting controller
    function self.cancelCurrentControlMasterMode() end

    --- Check if a mouse control scheme is selected
    --- This function must be used on a piloting controller
    ---@return integer
    function self.isMouseControlActivated() end

    --- Check if the mouse control direct scheme is selected
    --- This function must be used on a piloting controller
    ---@return integer
    function self.isMouseDirectControlActivated() end

    --- Check if the mouse control virtual joystick scheme is selected
    --- This function must be used on a piloting controller
    ---@return integer
    function self.isMouseVirtualJoystickActivated() end

    --- The ground engines will stabilize to this altitude within their limits
    --- The stabilization will be done by adjusting thrust to never go over the target altitude
    --- This includes VerticalBooster and HoverEngine
    --- This function must be used on a piloting controller
    ---@param targetAltitude number The stabilization target altitude in m
    function self.activateGroundEngineAltitudeStabilization(targetAltitude) end

    --- Return the ground engines' stabilization altitude
    --- This function must be used on a piloting controller
    ---@return number Stab altitude in m or 0 if none is set
    function self.getSurfaceEngineAltitudeStabilization() end

    --- The ground engines will behave like regular engine
    --- This includes VerticalBooster and HoverEngine
    --- This function must be used on a piloting controller
    function self.deactivateGroundEngineAltitudeStabilization() end

    --- Returns ground engine stabilization altitude capabilities (lower and upper ranges)
    --- This function must be used on a piloting controller
    ---@return table range Stabilization altitude capabilities for the least powerful engine and the most powerful engine
    function self.computeGroundEngineAltitudeStabilizationCapabilities() end

    --- Return the current throttle value
    --- This function must be used on a piloting controller
    ---@return number value Throttle value between -100 and 100
    function self.getThrottle() end

    --- Set the label of a control mode buttons shown in the control unit widget
    --- This function must be used on a piloting controller
    ---@param modeId integer The control mode: 0=Travel Mode, 1=Cruise Control by default
    ---@param label string The display name of the control mode, displayed on the widget button
    function self.setWidgetControlModeLabel(modeId, label) end
    ---@deprecated ControlUnit.setupControlMasterModeProperties() is deprecated, use ControlUnit.setWidgetControlModeLabel() instead.
    function self.setupControlMasterModeProperties() error("ControlUnit.setupControlMasterModeProperties() is deprecated, use ControlUnit.setWidgetControlModeLabel() instead.") end

    --- Checks if any landing gear is deployed
    ---@return 0 or 1 1 if any landing gear is deployed
    function self.isAnyLandingGearDeployed() end
    ---@deprecated ControlUnit.isAnyLandingGearDeployed() is deprecated, use ControlUnit.isAnyLandingGearExtended() instead.
    function self.isAnyLandingGearExtended() error("ControlUnit.isAnyLandingGearDeployed() is deprecated, use ControlUnit.isAnyLandingGearExtended() instead.") end

    --- Deploy a end
    function self.deployLandingGears() end
    ---@deprecated ControlUnit.extendLandingGears() is deprecated, use ControlUnit.deployLandingGears() instead.
    function self.extendLandingGears() error("ControlUnit.extendLandingGears() is deprecated, use ControlUnit.deployLandingGears() instead.") end
    --- Retract all landing gears
    function self.retractLandingGears() end


    --- Check construct lights status
    ---@return integer
    function self.isAnyHeadlightSwitchedOn() end

    --- Turn on the construct headlights
    function self.switchOnHeadlights() end

    --- Turn off the construct headlights
    function self.switchOffHeadlights() end

    return setmetatable(self, ControlUnit)
end