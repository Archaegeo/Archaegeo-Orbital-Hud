-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Radar
--
-- Get information about the Radar and its current targets
-----------------------------------------------------------------------------------

require("element")

--- Get information about the Radar and its current targets
---@class Radar
Radar = {}
Radar.__index = Radar
function Radar()
    local self = Element()


    --- Returns 1 if the radar is not broken, works in the current environment and is not used by another control unit
    ---@return integer state 1 if the radar is operational, otherwise: 0 = broken, -1 = bad environment, -2 = obstructed, -3 = already in use
    function self.getOperationalState() end
    ---@deprecated Radar.isOperational() is deprecated, use Radar.getOperationalState() instead.
    function self.isOperational() error("Radar.isOperational() is deprecated, use Radar.getOperationalState() instead.") end

    --- Returns the scan range of the radar
    ---@return number value The scan range
    function self.getRange() end

    --- Returns ranges to identify a target based on its core size
    ---@return table ranges The list of float values for ranges in meters as { xsRange, sRange, mRange, lRange }
    function self.getIdentifyRanges() end

    --- Returns the list of construct IDs in the scan range
    ---@return table
    function self.getConstructIds() end

    --- Returns the list of identified construct IDs
    ---@return table
    function self.getIdentifiedConstructIds() end

    --- Returns the ID of the target construct
    ---@return integer
    function self.getTargetId() end

    --- Returns the distance to the given construct
    ---@return number
    function self.getConstructDistance(id) end

    --- Returns 1 if the given construct is identified
    ---@return integer
    function self.isConstructIdentified(id) end

    --- Returns 1 if the given construct was abandoned
    ---@return integer
    function self.isConstructAbandoned(id) end

    --- Returns the core size of the given construct
    ---@return string size The core size name; can be 'XS', 'S', 'M', 'L', 'XL'
    function self.getConstructCoreSize(id) end

    --- Returns the threat rate your construct is for the given construct
    ---@return integer threat The threat rate index (None = 1, Identified = 2, Threatened and identified = 3, Threatened = 4, Attacked = 5), can be -1 if the radar is not operational
    function self.getThreatRateTo(id) end
    ---@deprecated Radar.getThreatTo(id) is deprecated, use Radar.getThreatRateTo(id) instead.
    function self.getThreatTo() error("Radar.getThreatTo(id) is deprecated, use Radar.getThreatRateTo(id) instead.") end

    --- Returns the threat rate the given construct is for your construct
    ---@return string threat The threat rate index (None = 1, Identified = 2, Threatened and identified = 3, Threatened = 4, Attacked = 5), can be -1 if the radar is not operational
    function self.getThreatRateFrom(id) end
    ---@deprecated Radar.getThreatFrom(id) is deprecated, use Radar.getThreatRateFrom(id) instead.
    function self.getThreatFrom() error("Radar.getThreatFrom(id) is deprecated, use Radar.getThreatRateFrom(id) instead.") end

    --- Returns whether the target has an active Transponder with matching tags
    ---@return integer
    function self.hasMatchingTransponder(id) end

    --- Returns a table with id of the owner entity (player or organization) of the given construct, if in range and if active transponder tags match for owned dynamic constructs.
    ---@param id integer The ID of the construct
    ---@return table entity A table with fields {[int] id, [bool] isOrganization} describing the owner. Use system.getPlayerName(id) and system.getOrganization(id) to retrieve info about it
    function self.getConstructOwnerEntity(id) end
    ---@deprecated Radar.getConstructOwner(id) is deprecated, use Radar.getConstructOwnerEntity(id) instead.
    function self.getConstructOwner() error("Radar.getConstructOwner(id) is deprecated, use Radar.getConstructOwnerEntity(id) instead.") end

    --- Return the size of the bounding box of the given construct, if in range
    ---@param id integer The ID of the construct
    ---@return table
    function self.getConstructSize(id) end

    --- Return the kind of the given construct
    ---@param id integer The ID of the construct
    ---@return integer kind The kind index of the construct (Universe = 1, Planet = 2,Asteroid = 3,Static = 4,Dynamic = 5,Space = 6,Alien = 7)
    function self.getConstructKind(id) end
    ---@deprecated Radar.getConstructType(id) is deprecated, use Radar.getConstructKind(id) instead.
    function self.getConstructType() error("Radar.getConstructType(id) is deprecated, use Radar.getConstructKind(id) instead.") end

    --- Returns the position of the given construct in construct local coordinates, if active transponder tags match for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return table
    function self.getConstructPos(id) end

    ---  Returns the position of the given construct in world coordinates, if in range and if active transponder tags match for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return table
    function self.getConstructWorldPos(id) end

    --- Returns the velocity vector of the given construct in construct local coordinates, if identified and if active transponder tags match for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return table
    function self.getConstructVelocity(id) end

    --- Returns the velocity vector of the given construct in world coordinates, if identified and if active transponder tags match for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return table
    function self.getConstructWorldVelocity(id) end

    --- Returns the mass of the given construct, if identified for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return number mass The mass of the construct in kilograms
    function self.getConstructMass(id) end

    --- Return the name of the given construct, if defined
    ---@param id integer The ID of the construct
    ---@return string
    function self.getConstructName(id) end

    --- Returns a table of working elements on the given construction, if identified for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return table info A table with fields : {[float] weapons, [float] radars, [float] antiGravity, [float] atmoEngines, [float] spaceEngines, [float] rocketEngines} with values between 0.0 and 1.0. Exceptionally antiGravity and rocketEngines are always 1.0 if present, even if broken
    function self.getConstructInfos(id) end

    --- Returns the speed of the given construct, if identified for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return number speed The speed of the construct relative to the universe in meters per second
    function self.getConstructSpeed(id) end

    --- Returns the angular speed of the given construct to your construct, if identified for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return number speed The angular speed of the construct relative to our construct in radians per second
    function self.getConstructAngularSpeed(id) end

    --- Returns the radial speed of the given construct to your construct, if identified for owned dynamic constructs
    ---@param id integer The ID of the construct
    ---@return number speed The radial speed of the construct relative to our construct in meters per second
    function self.getConstructRadialSpeed(id) end

    --- Emitted when a Construct enters the scan range of the radar
    ---@param id integer The ID of the construct
    self.onEnter = Event:new()
    self.enter = Event:new()
    self.enter:addAction(function(self,id) error("Radar.enter(id) event is deprecated, use Radar.onEnter(id) instead.") end, true, 1)

    --- Emitted when a construct leaves the range of the radar
    ---@param id integer The ID of the construct
    self.onLeave = Event:new()
    self.leave = Event:new()
    self.leave:addAction(function(self,id) error("Radar.leave(id) event is deprecated, use Radar.onLeave(id) instead.") end, true, 1)

    --- Emitted when a construct is identified
    ---@param id integer The ID of the construct
    self.onIdentified = Event:new()


    return setmetatable(self, Radar)
end