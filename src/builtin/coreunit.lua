-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Core Unit
--
-- It is the heart of your construct. It gives access to the elements of the construction and information on the environment.
-----------------------------------------------------------------------------------

require("element")

--- It is the heart of your construct. It gives access to the elements of the construction and information on the environment.
---@class CoreUnit
CoreUnit = {}
CoreUnit.__index = CoreUnit
function CoreUnit()
    local self = Element()

    self.pvpTimer = Event:new()
    self.pvpTimer:addAction(function(self,active) error("CoreUnit.completed(active) event is deprecated, use construct.onPvPTimer(active) instead.") end, true, 1)

    self.playerBoarded = Event:new()
    self.playerBoarded:addAction(function(self,id) error("CoreUnit.playerBoarded(pid) event is deprecated, use construct.onPlayerBoarded(id) instead.") end, true, 1)

    self.VRStationEntered = Event:new()
    self.VRStationEntered:addAction(function(self,id) error("CoreUnit.VRStationEntered(pid) event is deprecated, use construct.onVRStationEntered(id) instead.") end, true, 1)

    self.constructDocked = Event:new()
    self.constructDocked:addAction(function(self,id) error("CoreUnit.constructDocked(cid) event is deprecated, use construct.onConstructDocked(id) instead.") end, true, 1)

    self.docked = Event:new()
    self.docked:addAction(function(self,id) error("CoreUnit.docked(cid) event is deprecated, use construct.onDocked(id) instead.") end, true, 1)

    self.undocked = Event:new()
    self.undocked:addAction(function(self,id) error("CoreUnit.undocked(cid) event is deprecated, use construct.onUndocked(id) instead.") end, true, 1)


    ---@deprecated CoreUnit.getConstructId() is deprecated, use construct.getId() instead.
    function self.getConstructId() error("CoreUnit.getConstructId() is deprecated, use construct.getId() instead.") end
    ---@deprecated CoreUnit.getConstructName() is deprecated, use construct.getName() instead.
    function self.getConstructName() error("CoreUnit.getConstructName() is deprecated, use construct.getName() instead.") end
    ---@deprecated CoreUnit.getConstructWorldPos() is deprecated, use construct.getWorldPosition() instead.
    function self.getConstructWorldPos() error("CoreUnit.getConstructWorldPos() is deprecated, use construct.getWorldPosition() instead.") end
    ---@deprecated CoreUnit.getWorldAirFrictionAcceleration() is deprecated, use construct.getWorldAirFrictionAcceleration() instead.
    function self.getWorldAirFrictionAcceleration() error("CoreUnit.getWorldAirFrictionAcceleration() is deprecated, use construct.getWorldAirFrictionAcceleration() instead.") end
    ---@deprecated CoreUnit.getWorldAirFrictionAngularAcceleration() is deprecated, use construct.getWorldAirFrictionAngularAcceleration() instead.
    function self.getWorldAirFrictionAngularAcceleration() error("CoreUnit.getWorldAirFrictionAngularAcceleration() is deprecated, use construct.getWorldAirFrictionAngularAcceleration() instead.") end
    ---@deprecated CoreUnit.getSchematicInfo(schematicId) is deprecated, use construct.getSchematic(id) instead.
    function self.getSchematicInfo(schematicId) error("CoreUnit.getSchematicInfo() is deprecated, use construct.getSchematic(id) instead.") end
    ---@deprecated CoreUnit.getAngularVelocity() is deprecated, use construct.getAngularVelocity() instead.
    function self.getAngularVelocity() error("CoreUnit.getAngularVelocity() is deprecated, use construct.getAngularVelocity() instead.") end
    ---@deprecated CoreUnit.getWorldAngularVelocity() is deprecated, use construct.getWorldAngularVelocity() instead.
    function self.getWorldAngularVelocity() error("CoreUnit.getWorldAngularVelocity() is deprecated, use construct.getWorldAngularVelocity() instead.") end
    ---@deprecated CoreUnit.getAngularAcceleration() is deprecated, use construct.getAngularAcceleration() instead.
    function self.getAngularAcceleration() error("CoreUnit.getAngularAcceleration() is deprecated, use construct.getAngularAcceleration() instead.") end
    ---@deprecated CoreUnit.getWorldAngularAcceleration() is deprecated, use construct.getWorldAngularAcceleration() instead.
    function self.getWorldAngularAcceleration() error("CoreUnit.getWorldAngularAcceleration() is deprecated, use construct.getWorldAngularAcceleration() instead.") end
    ---@deprecated CoreUnit.getVelocity() is deprecated, use construct.getVelocity() instead.
    function self.getVelocity() error("CoreUnit.getVelocity() is deprecated, use construct.getVelocity() instead.") end
    ---@deprecated CoreUnit.getWorldVelocity() is deprecated, use construct.getWorldVelocity() instead.
    function self.getWorldVelocity() error("CoreUnit.getWorldVelocity() is deprecated, use construct.getWorldVelocity() instead.") end
    ---@deprecated CoreUnit.getAbsoluteVelocity() is deprecated, use construct.getAbsoluteVelocity() instead.
    function self.getAbsoluteVelocity() error("CoreUnit.getAbsoluteVelocity() is deprecated, use construct.getAbsoluteVelocity() instead.") end
    ---@deprecated CoreUnit.getWorldAbsoluteVelocity() is deprecated, use construct.getWorldAbsoluteVelocity() instead.
    function self.getWorldAbsoluteVelocity() error("CoreUnit.getWorldAbsoluteVelocity() is deprecated, use construct.getWorldAbsoluteVelocity() instead.") end
    ---@deprecated CoreUnit.getWorldAcceleration() is deprecated, use construct.getWorldAcceleration() instead.
    function self.getWorldAcceleration() error("CoreUnit.getWorldAcceleration() is deprecated, use construct.getWorldAcceleration() instead.") end
    ---@deprecated CoreUnit.getAcceleration() is deprecated, use construct.getAcceleration() instead.
    function self.getAcceleration() error("CoreUnit.getAcceleration() is deprecated, use construct.getAcceleration() instead.") end
    ---@deprecated CoreUnit.getOrientationUnitId() is deprecated, use construct.getOrientationUnitId() instead.
    function self.getOrientationUnitId() error("CoreUnit.getOrientationUnitId() is deprecated, use construct.getOrientationUnitId() instead.") end
    ---@deprecated CoreUnit.getConstructOrientationUp() is deprecated, use construct.getOrientationUp() instead.
    function self.getConstructOrientationUp() error("CoreUnit.getConstructOrientationUp() is deprecated, use construct.getOrientationUp() instead.") end
    ---@deprecated CoreUnit.getConstructOrientationRight() is deprecated, use construct.getOrientationRight() instead.
    function self.getConstructOrientationRight() error("CoreUnit.getConstructOrientationRight() is deprecated, use construct.getOrientationRight() instead.") end
    ---@deprecated CoreUnit.getConstructOrientationForward() is deprecated, use construct.getOrientationForward() instead.
    function self.getConstructOrientationForward() error("CoreUnit.getConstructOrientationForward() is deprecated, use construct.getOrientationForward() instead.") end
    ---@deprecated CoreUnit.getConstructWorldOrientationUp() is deprecated, use construct.getWorldOrientationUp() instead.
    function self.getConstructWorldOrientationUp() error("CoreUnit.getConstructWorldOrientationUp() is deprecated, use construct.getWorldOrientationUp() instead.") end
    ---@deprecated CoreUnit.getConstructWorldOrientationRight() is deprecated, use construct.getWorldOrientationRight() instead.
    function self.getConstructWorldOrientationRight() error("CoreUnit.getConstructWorldOrientationRight() is deprecated, use construct.getWorldOrientationRight() instead.") end
    ---@deprecated CoreUnit.getConstructWorldOrientationForward() is deprecated, use construct.getWorldOrientationForward() instead.
    function self.getConstructWorldOrientationForward() error("CoreUnit.getConstructWorldOrientationForward() is deprecated, use construct.getWorldOrientationForward() instead.") end
    ---@deprecated CoreUnit.getConstructWorldUp() is deprecated, use construct.getWorldUp() instead.
    function self.getConstructWorldUp() error("CoreUnit.getConstructWorldUp() is deprecated, use construct.getWorldUp() instead.") end
    ---@deprecated CoreUnit.getConstructWorldRight() is deprecated, use construct.getWorldRight() instead.
    function self.getConstructWorldRight() error("CoreUnit.getConstructWorldRight() is deprecated, use construct.getWorldRight() instead.") end
    ---@deprecated CoreUnit.getConstructWorldForward() is deprecated, use construct.getWorldForward() instead.
    function self.getConstructWorldForward() error("CoreUnit.getConstructWorldForward() is deprecated, use construct.getWorldForward() instead.") end
    ---@deprecated CoreUnit.getPvPTimer() is deprecated, use construct.getPvPTimer() instead.
    function self.getPvPTimer() error("CoreUnit.getPvPTimer() is deprecated, use construct.getPvPTimer() instead.") end
    ---@deprecated CoreUnit.getPlayersOnBoard() is deprecated, use construct.getPlayersOnBoard() instead.
    function self.getPlayersOnBoard() error("CoreUnit.getPlayersOnBoard() is deprecated, use construct.getPlayersOnBoard() instead.") end
    ---@deprecated CoreUnit.getPlayersOnBoardInVRStation() is deprecated, use construct.getPlayersOnBoardInVRStation() instead.
    function self.getPlayersOnBoardInVRStation() error("CoreUnit.getPlayersOnBoardInVRStation() is deprecated, use construct.getPlayersOnBoardInVRStation() instead.") end
    ---@deprecated CoreUnit.getDockedConstructs() is deprecated, use construct.getDockedConstructs() instead.
    function self.getDockedConstructs() error("CoreUnit.getDockedConstructs() is deprecated, use construct.getDockedConstructs() instead.") end
    ---@deprecated CoreUnit.isPlayerBoarded(pid) is deprecated, use construct.isPlayerBoarded(id) instead.
    function self.isPlayerBoarded(pid) error("CoreUnit.isPlayerBoarded() is deprecated, use construct.isPlayerBoarded(id) instead.") end
    ---@deprecated CoreUnit.isPlayerBoardedInVRStation(pid) is deprecated, use construct.isPlayerBoardedInVRStation(id) instead.
    function self.isPlayerBoardedInVRStation(pid) error("CoreUnit.isPlayerBoardedInVRStation(pid) is deprecated, use construct.isPlayerBoardedInVRStation(id) instead.") end
    ---@deprecated CoreUnit.isConstructDocked(cid) is deprecated, use construct.isConstructDocked(id) instead.
    function self.isConstructDocked(cid) error("CoreUnit.isConstructDocked(cid) is deprecated, use construct.isConstructDocked(id) instead.") end
    ---@deprecated CoreUnit.forceDeboard(pid) is deprecated, use construct.forceDeboard(id) instead.
    function self.forceDeboard(pid) error("CoreUnit.forceDeboard(pid) is deprecated, use construct.forceDeboard(id) instead.") end
    ---@deprecated CoreUnit.forceInterruptVRSession(pid) is deprecated, use construct.forceInterruptVRSession(id) instead.
    function self.forceInterruptVRSession(pid) error("CoreUnit.forceInterruptVRSession(pid) is deprecated, use construct.forceInterruptVRSession(id) instead.") end
    ---@deprecated CoreUnit.forceUndock(cid) is deprecated, use construct.forceUndock(id) instead.
    function self.forceUndock(cid) error("CoreUnit.forceUndock(cid) is deprecated, use construct.forceUndock(id) instead.") end
    ---@deprecated CoreUnit.getBoardedPlayerMass(pid) is deprecated, use construct.getBoardedPlayerMass(id) instead.
    function self.getBoardedPlayerMass(pid) error("CoreUnit.getBoardedPlayerMass(pid) is deprecated, use construct.getBoardedPlayerMass(id) instead.") end
    ---@deprecated CoreUnit.getBoardedInVRStationAvatarMass(pid) is deprecated, use construct.getId() instead.
    function self.getBoardedInVRStationAvatarMass(pid) error("CoreUnit.getBoardedInVRStationAvatarMass(pid) is deprecated, use construct.getId() instead.") end
    ---@deprecated CoreUnit.getDockedConstructMass(cid) is deprecated, use construct.getDockedConstructMass(id) instead.
    function self.getDockedConstructMass(cid) error("CoreUnit.getDockedConstructMass(cid) is deprecated, use construct.getDockedConstructMass(id) instead.") end
    ---@deprecated CoreUnit.getParent() is deprecated, use construct.getParent() instead.
    function self.getParent() error("CoreUnit.getParent() is deprecated, use construct.getParent() instead.") end
    ---@deprecated CoreUnit.getCloseParents() is deprecated, use construct.getCloseParents() instead.
    function self.getCloseParents() error("CoreUnit.getCloseParents() is deprecated, use construct.getCloseParents() instead.") end
    ---@deprecated CoreUnit.getClosestParent() is deprecated, use construct.getClosestParent() instead.
    function self.getClosestParent() error("CoreUnit.getClosestParent() is deprecated, use construct.getClosestParent() instead.") end
    ---@deprecated CoreUnit.dock(cid) is deprecated, use construct.dock(id) instead.
    function self.dock(cid) error("CoreUnit.dock(cid) is deprecated, use construct.dock(id) instead.") end
    ---@deprecated CoreUnit.undock() is deprecated, use construct.undock() instead.
    function self.undock() error("CoreUnit.undock() is deprecated, use construct.undock() instead.") end
    ---@deprecated CoreUnit.setDockingMode(mode) is deprecated, use construct.setDockingMode(mode) instead.
    function self.setDockingMode(mode) error("CoreUnit.setDockingMode(mode) is deprecated, use construct.setDockingMode(mode) instead.") end
    ---@deprecated CoreUnit.getDockingMode() is deprecated, use construct.getDockingMode() instead.
    function self.getDockingMode() error("CoreUnit.getDockingMode() is deprecated, use construct.getDockingMode() instead.") end
    ---@deprecated CoreUnit.getParentPosition() is deprecated, use construct.getParentPosition() instead.
    function self.getParentPosition() error("CoreUnit.getParentPosition() is deprecated, use construct.getParentPosition() instead.") end
    ---@deprecated CoreUnit.getParentWorldPosition() is deprecated, use construct.getParentWorldPosition() instead.
    function self.getParentWorldPosition() error("CoreUnit.getParentWorldPosition() is deprecated, use construct.getParentWorldPosition() instead.") end
    ---@deprecated CoreUnit.getParentForward() is deprecated, use construct.getParentForward() instead.
    function self.getParentForward() error("CoreUnit.getParentForward() is deprecated, use construct.getParentForward() instead.") end
    ---@deprecated CoreUnit.getParentUp() is deprecated, use construct.getParentUp() instead.
    function self.getParentUp() error("CoreUnit.getParentUp() is deprecated, use construct.getParentUp() instead.") end
    ---@deprecated CoreUnit.getParentRight() is deprecated, use construct.getParentRight() instead.
    function self.getParentRight() error("CoreUnit.getParentRight() is deprecated, use construct.getParentRight() instead.") end
    ---@deprecated CoreUnit.getParentWorldForward() is deprecated, use construct.getParentWorldForward() instead.
    function self.getParentWorldForward() error("CoreUnit.getParentWorldForward() is deprecated, use construct.getParentWorldForward() instead.") end
    ---@deprecated CoreUnit.getParentWorldUp() is deprecated, use construct.getParentWorldUp() instead.
    function self.getParentWorldUp() error("CoreUnit.getParentWorldUp() is deprecated, use construct.getParentWorldUp() instead.") end
    ---@deprecated CoreUnit.getParentWorldRight() is deprecated, use construct.getParentWorldRight() instead.
    function self.getParentWorldRight() error("CoreUnit.getParentWorldRight() is deprecated, use construct.getParentWorldRight() instead.") end
    ---@deprecated CoreUnit.getMaxSpeed() is deprecated, use construct.getMaxSpeed() instead.
    function self.getMaxSpeed() error("CoreUnit.getMaxSpeed() is deprecated, use construct.getMaxSpeed() instead.") end
    ---@deprecated CoreUnit.getMaxAngularSpeed() is deprecated, use construct.getMaxAngularSpeed() instead.
    function self.getMaxAngularSpeed() error("CoreUnit.getMaxAngularSpeed() is deprecated, use construct.getMaxAngularSpeed() instead.") end
    ---@deprecated CoreUnit.getMaxSpeedPerAxis() is deprecated, use construct.getMaxSpeedPerAxis() instead.
    function self.getMaxSpeedPerAxis() error("CoreUnit.getMaxSpeedPerAxis() is deprecated, use construct.getMaxSpeedPerAxis() instead.") end

    ---@deprecated CoreUnit.getConstructMass() is deprecated, use construct.getMass() instead.
    function self.getConstructMass() error("CoreUnit.getConstructMass() is deprecated, use construct.getMass() instead.") end
    ---@deprecated CoreUnit.getConstructIMass() is deprecated, use construct.getInertialMass() instead.
    function self.getConstructIMass() error("CoreUnit.getConstructIMass() is deprecated, use construct.getInertialMass() instead.") end
    ---@deprecated CoreUnit.getConstructCrossSection() is deprecated, use construct.getCrossSection() instead.
    function self.getConstructCrossSection() error("CoreUnit.getConstructCrossSection() is deprecated, use construct.getCrossSection() instead.") end
    ---@deprecated CoreUnit.getMaxKinematicsParametersAlongAxis(taglist, CRefAxis) is deprecated, use construct.getMaxThrustAlongAxis(taglist, CRefAxis) instead.
    function self.getMaxKinematicsParametersAlongAxis(taglist, CRefAxis) error("CoreUnit.getMaxKinematicsParametersAlongAxis(taglist, CRefAxis) is deprecated, use construct.getMaxThrustAlongAxis(taglist, CRefAxis) instead.") end


    --- Returns the list of all the local IDs of the Elements of this construct
    ---@return table
    function self.getElementIdList() end

    --- Returns the name of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return string
    function self.getElementNameById(localId) end

    --- Returns the class of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return string
    function self.getElementClassById(localId) end

    --- Returns the display name of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return string
    function self.getElementDisplayNameById(localId) end
    ---@deprecated CoreUnit.getElementTypeById(localId) is deprecated, use CoreUnit.getElementDisplayNameById(localId) instead.
    function self.getElementTypeById(localId) error("CoreUnit.getElementTypeById(localId) is deprecated, use CoreUnit.getElementDisplayNameById(localId) instead.") end

    --- Returns the item ID of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return integer
    function self.getElementItemIdById(localId) end

    --- Returns the current level of hit points of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return number
    function self.getElementHitPointsById(localId) end

    --- Returns the maximum level of hit points of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return number
    function self.getElementMaxHitPointsById(localId) end

    --- Returns the mass of the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return number
    function self.getElementMassById(localId) end

    --- Returns the position of the Element, identified by its local ID, in construct local coordinates.
    ---@param localId integer The local ID of the Element
    ---@return table
    function self.getElementPositionById(localId) end

    --- Returns the up direction vector of the Element, identified by its local ID, in construct local coordinates
    ---@param localId integer The local ID of the Element
    ---@return table
    function self.getElementUpById(localId) end

    --- Returns the right direction vector of the Element, identified by its local ID, in construct local coordinates
    ---@param localId integer The local ID of the Element
    ---@return table
    function self.getElementRightById(localId) end

    --- Returns the forward direction vector of the Element, identified by its local ID, in construct local coordinates
    ---@param localId integer The local ID of the Element
    ---@return table
    function self.getElementForwardById(localId) end

    --- Returns the status of the Industry Unit Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return table info If the Element is an Industry Unit, a table with fields {[int] state, [bool] stopRequested, [int] schematicId (deprecated = 0), [int] schematicsRemaining, [int] unitsProduced, [int] remainingTime, [int] batchesRequested, [int] batchesRemaining, [float] maintainProductAmount, [int] currentProductAmount, [table] currentProducts:{{[int] id, [double] quantity},...}}
    function self.getElementIndustryInfoById(localId) end
    ---@deprecated CoreUnit.getElementIndustryStatusById(localId) is deprecated, use CoreUnit.getElementIndustryInfoById(localId) instead.
    function self.getElementIndustryStatusById(localId) error("CoreUnit.getElementIndustryStatusById(localId) is deprecated, use CoreUnit.getElementIndustryInfoById(localId) instead.") end

    --- Returns the list of tags associated to the Element, identified by its local ID
    ---@param localId integer The local ID of the Element
    ---@return string
    function self.getElementTagsById(localId) end


    --- Returns the altitude above sea level, with respect to the closest planet (0 in space)
    ---@return number
    function self.getAltitude() end

    --- Returns the local gravity intensity
    ---@return number
    function self.getGravityIntensity() end
    ---@deprecated CoreUnit.g() is deprecated, use CoreUnit.getGravityIntensity() instead.
    function self.g() error("CoreUnit.g() is deprecated, use CoreUnit.getGravityIntensity() instead.") end

    --- Returns the local gravity vector in world coordinates
    ---@return table
    function self.getWorldGravity() end

    --- Returns the vertical unit vector along gravity, in world coordinates (0 in space)
    ---@return table
    function self.getWorldVertical() end

    --- Returns the id of the current close stellar body
    ---@return integer
    function self.getCurrentPlanetId() end


    --- Returns the core's current stress, destroyed when reaching max stress
    ---@return number
    function self.getCoreStress() end

    --- Returns the maximal stress the core can bear before it gets destroyed
    ---@return number
    function self.getMaxCoreStress() end

    --- Returns the core's current stress to max stress ratio
    ---@return number
    function self.getCoreStressRatio() end

    --- Emitted when core unit stress changed
    ---@param stress number Difference to previous stress value
    self.onStressChanged = Event:new()
    self.stressChanged = Event:new()
    self.stressChanged:addAction(function(self) error("CoreUnit.stressChanged event is deprecated, use CoreUnit.onStressChanged instead.") end, true, 1)


    --- Spawns a number sticker in the 3D world, with coordinates relative to the construct
    ---@param nb integer The number to display 0 to 9
    ---@param x number The x-coordinate in the construct in meters. 0 = center
    ---@param y number The y-coordinate in the construct in meters. 0 = center
    ---@param z number The z-coordinate in the construct in meters. 0 = center
    ---@param orientation string Orientation of the number. Possible values are "front", "side"
    ---@return integer
    function self.spawnNumberSticker(nb,x,y,z,orientation) end

    --- Spawns an arrow sticker in the 3D world, with coordinates relative to the construct
    ---@param x number The x-coordinate in the construct in meters. 0 = center
    ---@param y number the y-coordinate in the construct in meters. 0 = center
    ---@param z number The z-coordinate in the construct in meters. 0 = center
    ---@param orientation string Orientation of the arrow. Possible values are "up", "down", "north", "south", "east", "west"
    ---@return integer
    function self.spawnArrowSticker(x,y,z,orientation) end

    --- Delete the referenced sticker
    ---@param index integer Index of the sticker to delete
    ---@return integer
    function self.deleteSticker(index) end

    --- Move the referenced sticker
    ---@param index integer Index of the sticker to move
    ---@param x number The x-coordinate in the construct in meters. 0 = center
    ---@param y number The y-coordinate in the construct in meters. 0 = center
    ---@param z number The z-coordinate in the construct in meters. 0 = center
    ---@return integer
    function self.moveSticker(index,x,y,z) end
    
    --- Rotate the referenced sticker.
    ---@param index integer Index of the sticker to rotate
    ---@param angle_x number Rotation along the x-axis in degrees
    ---@param angle_y number Rotation along the y-axis in degrees
    ---@param angle_z number Rotation along the z-axis in degrees
    ---@return integer
    function self.rotateSticker(index,angle_x,angle_y,angle_z) end


    return setmetatable(self, CoreUnit)
end
