-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Construct
--
-- Construct represents your construct. It gives access to the properties of your constructions and to the events linked to them, which can be used in your scripts.
-----------------------------------------------------------------------------------


--- Construct represents your construct. It gives access to the properties of your constructions and to the events linked to them, which can be used in your scripts.
---@class Construct
Construct = {}
Construct.__index = Construct
function Construct()
    local self = {}


    --- Returns the name of the construct
    ---@return string
    function self.getName() end
    --- Returns the construct unique ID
    ---@return integer
    function self.getId() end
    --- Returns the owner entity
    ---@return table entity The owner entity table with fields {[int] id, [bool] isOrganization} describing the owner. Use system.getPlayerName(id) and system.getOrganization(id) to retrieve info about it
    function self.getOwner() end
    --- Returns the creator entity
    ---@return integer entity The owner entity table with fields {[int] id, [bool] isOrganization} describing the owner. Use system.getPlayerName(id) and system.getOrganization(id) to retrieve info about it
    function self.getCreator() end


    --- Checks if the construct is currently warping
    ---@return integer
    function self.isWarping() end
    --- Returns the current warp state
    ---@return integer state The current warp state index (Idle = 1, Engage = 2, Align = 3, Spool = 4, Accelerate = 5, Cruise = 6, Decelerate = 7, Stopping = 8, Disengage = 9)
    function self.getWarpState() end


    --- Checks if the construct is in PvP zone
    ---@return integer
    function self.isInPvPZone() end
    --- Returns the distance between the construct and the nearest safe zone
    ---@return number distance The distance to the nearest safe zone border in meters. Positive value if the construct is outside of any safe zone
    function self.getDistanceToSafeZone() end
    --- Returns the current construct PvP timer state
    ---@return number time The remaining time of the PvP timer, or 0.0 if elapsed
    function self.getPvPTimer() end


    --- Returns the mass of the construct
    ---@return number
    function self.getMass() end
    --- Returns the inertial mass of the construct, calculated as 1/3 of the trace of the inertial tensor
    ---@return number
    function self.getInertialMass() end
    --- Returns the inertial tensor of the construct
    ---@return table
    function self.getInertialTensor() end
    --- Returns the position of the center of mass of the construct, in local construct coordinates
    ---@return table
    function self.getCenterOfMass() end
    --- Returns the position of the center of mass of the construct, in world coordinates
    ---@return table
    function self.getWorldCenterOfMass() end
    --- Returns the construct's cross sectional surface in the current direction of movement
    ---@return number value The construct's surface exposed in the current direction of movement in meters square
    function self.getCrossSection() end
    --- Returns the size of the building zone of the construct
    ---@return table
    function self.getSize() end
    --- Returns the size of the bounding box of the construct
    ---@return table
    function self.getBoundingBoxSize() end
    --- Returns the position of the center of bounding box of the construct in local construct coordinates
    ---@return table
    function self.getBoundingBoxCenter() end


    --- Returns the max speed along current moving direction
    ---@return number value The max speed along current moving direction in m/s
    function self.getMaxSpeed() end
    --- Returns the max angular speed
    ---@return number value The max angular speed in rad/s
    function self.getMaxAngularSpeed() end
    --- Returns the max speed per axis
    ---@return table value The max speed along axes {x, -x, y, -y, z, -z} in m/s
    function self.getMaxSpeedPerAxis() end
    --- Returns the construct max kinematics parameters in both atmo and space range, in newtons. Kinematics
    --- parameters designate here the maximal positive and negative base force the construct is capable of producing along the chosen
    --- Axisvector, as defined by the Core Unit or the gyro unit, if active. In practice, this gives you an estimate of the maximum
    --- thrust your ship is capable of producing in space or in atmosphere, as well as the max reverse thrust. These are theoretical
    --- estimates and correspond with the addition of the maxThrustBase along the corresponding axis. It might not reflect the
    --- accurate current max thrust capacity of your ship, which depends on various local conditions (atmospheric density,
    --- orientation, obstruction, engine damage, etc)
    --- This is typically used in conjunction with the Control Unit throttle to setup the desired forward acceleration
    ---@param taglist string Comma (for union) or space (for intersection) separated list of tags. You can set tags directly on the engines in the right-click menu
    ---@param CRefAxis table Axis along which to compute the max force (in construct reference)
    ---@return table value The kinematics parameters in Newtons in the order: atmoRange.FMaxPlus, atmoRange.FMaxMinus, spaceRange.FMaxPlus, spaceRange.FMaxMinus
    function self.getMaxThrustAlongAxis(taglist, CRefAxis) end
    --- Returns the current braking force generated by construct brakes
    ---@return number value The current braking force in Newtons
    function self.getCurrentBrake() end
    --- Returns the maximum braking force that can currently be generated by the construct brakes
    ---@return number value The maximum braking force in Newtons
    function self.getMaxBrake() end

    --- Returns the world position of the construct
    ---@return table value The xyz world coordinates of the construct center position in meters
    function self.getWorldPosition() end
    --- The construct's linear velocity, relative to its parent, in construct local coordinates
    ---@return table value Relative linear velocity vector, in construct local coordinates in m/s
    function self.getVelocity() end
    --- The construct's linear velocity, relative to its parent, in world coordinates
    ---@return table value Relative linear velocity vector, in world coordinates in m/s
    function self.getWorldVelocity() end
    --- The construct's absolute linear velocity, in construct local coordinates
    ---@return table value Absolute linear velocity vector, in construct local coordinates in m/s
    function self.getAbsoluteVelocity() end
    --- The construct's absolute linear velocity, in world coordinates
    ---@return table value Absolute linear velocity vector, in world coordinates in m/s
    function self.getWorldAbsoluteVelocity() end
    --- The construct's linear acceleration, in construct local coordinates
    ---@return table value Linear acceleration vector, in construct local coordinates in m/s2
    function self.getAcceleration() end
    --- The construct's linear acceleration, in world coordinates
    ---@return table value Linear acceleration vector, in world coordinates in m/s2
    function self.getWorldAcceleration() end
    --- The construct's angular velocity, in construct local coordinates
    ---@return table value Angular velocity vector, in construct local coordinates in rad/s
    function self.getAngularVelocity() end
    --- The construct's angular velocity, in world coordinates
    ---@return table value Angular velocity vector, in world coordinates in rad/s
    function self.getWorldAngularVelocity() end
    --- The construct's angular acceleration, in construct local coordinates
    ---@return table value Angular acceleration vector, in construct local coordinates in rad/s2
    function self.getAngularAcceleration() end
    --- The construct's angular acceleration, in world coordinates
    ---@return table value Angular acceleration vector, in world coordinates in rad/s2
    function self.getWorldAngularAcceleration() end
    --- Returns the acceleration generated by air resistance
    ---@return table value The xyz world acceleration generated by air resistance
    function self.getWorldAirFrictionAcceleration() end
    --- Returns the acceleration torque generated by air resistance
    ---@return table value The xyz world acceleration torque generated by air resistance
    function self.getWorldAirFrictionAngularAcceleration() end
    --- Returns the speed at which your construct will suffer damage due to friction with the air
    ---@return number value The construct speed to get damages due to friction in m/s
    function self.getFrictionBurnSpeed() end

    --- Returns the forward vector of the construct coordinates system
    ---@return table value The forward vector of the construct coordinates system. It's a static value equal to (0,1,0)
    function self.getForward() end
    --- Returns the right vector of the construct coordinates system
    ---@return table value The right vector of the construct coordinates system. It's a static value equal to (1,0,0)
    function self.getRight() end
    --- Returns the up direction vector of the construct coordinates system
    ---@return table value The up vector of the construct coordinates system.. It's a static value equal to (0,0,1)
    function self.getUp() end
    --- Returns the forward direction vector of the construct, in world coordinates
    ---@return table value The forward direction vector of the construct, in world coordinates
    function self.getWorldForward() end
    --- Returns the right direction vector of the construct, in world coordinates
    ---@return table value The right direction vector of the construct, in world coordinates
    function self.getWorldRight() end
    --- Returns the up direction vector of the construct, in world coordinates
    ---@return table value The up direction vector of the construct, in world coordinates
    function self.getWorldUp() end

    --- Returns the local id of the current active orientation unit (core unit or gyro unit)
    ---@return integer value local id of the current active orientation unit (core unit or gyro unit)
    function self.getOrientationUnitId() end
    --- Returns the forward direction vector of the active orientation unit, in construct local coordinates
    ---@return table value Forward direction vector of the active orientation unit, in construct local coordinates
    function self.getOrientationForward() end
    --- Returns the right direction vector of the active orientation unit, in construct local coordinates
    ---@return table value Right direction vector of the active orientation unit, in construct local coordinates
    function self.getOrientationRight() end
    --- Returns the up direction vector of the active orientation unit, in construct local coordinates
    ---@return table value Up direction vector of the active orientation unit, in construct local coordinates
    function self.getOrientationUp() end
    --- Returns the forward direction vector of the active orientation unit, in world coordinates
    ---@return table value Forward direction vector of the active orientation unit, in world coordinates
    function self.getWorldOrientationForward() end
    --- Returns the right direction vector of the active orientation unit, in world coordinates
    ---@return table value Right direction vector of the active orientation unit, in world coordinates
    function self.getWorldOrientationRight() end
    --- Returns the up direction vector of the active orientation unit, in world coordinates
    ---@return table value Up direction vector of the active orientation unit, in world coordinates
    function self.getWorldOrientationUp() end

    --- Returns the id of the parent construct of our active construct
    ---@return integer
    function self.getParent() end
    --- Returns the id of the nearest constructs, on which the construct can dock
    ---@return integer
    function self.getClosestParent() end
    --- Returns the list of ids of nearby constructs, on which the construct can dock
    ---@return table
    function self.getCloseParents() end

    --- Returns the position of the construct's parent when docked in local coordinates
    ---@return table value The position of the construct's parent in local coordinates
    function self.getParentPosition() end
    --- Returns the position of the construct's parent when docked in world coordinates
    ---@return table value The position of the construct's parent in world coordinates
    function self.getParentWorldPosition() end
    --- Returns the construct's parent forward direction vector, in local coordinates
    ---@return table value The construct's parent forward direction vector, in local coordinates
    function self.getParentForward() end
    --- Returns the construct's parent right direction vector, in construct local coordinates
    ---@return table value The construct's parent right direction vector, in construct local coordinates
    function self.getParentRight() end
    --- Returns the construct's parent up direction vector, in construct local coordinates
    ---@return table value The construct's parent up direction vector, in construct local coordinates
    function self.getParentUp() end
    --- Returns the construct's parent forward direction vector, in world coordinates
    ---@return table value The construct's parent forward direction vector, in world coordinates
    function self.getParentWorldForward() end
    --- Returns the construct's parent right direction vector, in world coordinates
    ---@return table value The construct's parent right direction vector, in world coordinates
    function self.getParentWorldRight() end
    --- Returns the construct's parent up direction vector, in world coordinates
    ---@return table value The construct's parent up direction vector, in world coordinates
    function self.getParentWorldUp() end


    --- Returns the list of player IDs on board the construct
    ---@return table
    function self.getPlayersOnBoard() end
    --- Returns the list of player ids on board the construct inside a VR Station
    ---@return table
    function self.getPlayersOnBoardInVRStation() end
    --- Checks if the given player is on board in the construct
    ---@param id integer The player id
    ---@return integer
    function self.isPlayerBoarded(id) end
    --- Returns 1 if the given player is boarded to the construct inside a VR Station
    ---@param id integer The player id
    ---@return integer
    function self.isPlayerBoardedInVRStation(id) end
    --- Returns the mass of the given player or surrogate if it is on board the construct
    ---@param id integer The player id
    ---@return number
    function self.getBoardedPlayerMass(id) end
    --- Returns the mass of the given player if in VR station on board the construct
    ---@param id integer The player id
    ---@return number
    function self.getBoardedInVRStationAvatarMass(id) end

    --- Returns the list of IDs of constructs docked to the construct
    ---@return table
    function self.getDockedConstructs() end
    --- Checks if the given construct is docked to the construct
    ---@param id integer The construct id
    ---@return integer
    function self.isConstructDocked(id) end
    --- Returns the mass of the given construct if it is docked to the construct
    ---@param id integer The construct id
    ---@return number
    function self.getDockedConstructMass(id) end

    --- Sets the docking mode
    ---@param mode integer The docking mode (Manual = 1, Automatic = 2, Semi-automatic = 3)
    ---@return integer
    function self.setDockingMode(mode) end
    --- Returns the current docking mode
    ---@return integer mode The docking mode (Manual = 1, Automatic = 2, Semi-automatic = 3)
    function self.getDockingMode() end
    --- Sends a request to dock to the given construct. Limited to piloting controllers
    ---@param id integer The parent construct id
    ---@return integer
    function self.dock(id) end
    --- Sends a request to undock the construct. Limited to piloting controllers
    ---@return integer
    function self.undock() end

    --- Sends a request to deboard a player or surrogate with the given id
    ---@param id integer The player id
    ---@return integer
    function self.forceDeboard(id) end
    --- Sends a request to undock a construct with the given id
    ---@param id integer The construct id
    ---@return integer
    function self.forceUndock(id) end
    --- Sends a request to interrupt the surrogate session of a player with the given id
    ---@param id integer The player id
    ---@return integer
    function self.forceInterruptVRSession(id) end


    --- Emitted when the construct becomes docked
    ---@param id integer The parent id
    self.onDocked = Event:new()

    --- Emitted when the construct is undocked
    ---@param id integer The previous parent id
    self.onUndocked = Event:new()

    ---Emitted when a player or surrogate boards the construct
    ---@param id integer The id of the boarding player
    self.onPlayerBoarded = Event:new()

    --- Emitted when a player enters a VR Station
    ---@param id integer The id of the boarding player
    self.onVRStationEntered = Event:new()

    --- Emitted when another construct docks this construct
    ---@param id integer The id of the docking construct
    self.onConstructDocked = Event:new()

    --- Emitted when the PvP timer started or elapsed
    ---@param active boolean 1 if the timer started, false when the timer elapsed
    self.onPvPTimer = Event:new()


    return setmetatable(self, Construct)
end

--- Global alias available out of the game
DUConstruct = Construct
