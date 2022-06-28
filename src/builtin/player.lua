-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Player
--
-- Player represents the player who is using the control unit
-----------------------------------------------------------------------------------


--- Player represents the player who is using the control unit
---@class Player
Player = {}
Player.__index = Player
function Player()
    local self = {}


    --- Returns the player name
    ---@return string value The player name
    function self.getName() end
    --- Return the ID of the player
    ---@return integer value The ID of the player
    function self.getId() end

    --- Returns the player mass
    ---@return number value The mass of the player in kilograms
    function self.getMass() end
    --- Returns the player's nanopack content mass
    ---@return number value The player's nanopack content mass in kilograms
    function self.getNanopackMass() end
    --- Returns the player's nanopack content volume
    ---@return number value The player's nanopack content volume in liters
    function self.getNanopackVolume() end
    --- Returns the player's nanopack maximum volume
    ---@return number value The player's nanopack maximum volume in liters
    function self.getNanopackMaxVolume() end

    --- Returns the list of organization IDs of the player
    ---@return table value The list of organization IDs
    function self.getOrgIds() end
    --- Returns the position of the player, in construct local coordinates
    ---@return table value The position in construct local coordinates
    function self.getPosition() end
    --- Returns the position of the player, in world coordinates
    ---@return table value The position in world coordinates
    function self.getWorldPosition() end
    --- Returns the position of the head of the player's character, in construct local coordinates
    ---@return table value The position of the head in construct local coordinates
    function self.getHeadPosition() end
    --- Returns the position of the head of the player's character, in world coordinates
    ---@return table value The position of the head in world coordinates
    function self.getWorldHeadPosition() end

    --- Returns the velocity vector of the player, in construct local coordinates
    ---@return table value The velocity vector in construct local coordinates
    function self.getVelocity() end
    --- Returns the velocity vector of the player, in world coordinates
    ---@return table value The velocity vector in world coordinates
    function self.getWorldVelocity() end
    --- Returns the absolute velocity vector of the player, in world coordinates
    ---@return table value The velocity absolute vector in world coordinates
    function self.getAbsoluteVelocity() end

    --- Returns the forward direction vector of the player, in construct local coordinates
    ---@return table value The forward direction vector in construct local coordinates
    function self.getForward() end
    --- Returns the right direction vector of the player, in construct local coordinates
    ---@return table value The right direction vector in construct local coordinates
    function self.getRight() end
    --- Returns the up direction vector of the player, in construct local coordinates
    ---@return table value The up direction vector in construct local coordinates
    function self.getUp() end
    --- Returns the forward direction vector of the player, in world coordinates
    ---@return table value The forward direction vector in world coordinates
    function self.getWorldForward() end
    --- Returns the right direction vector of the player, in world coordinates
    ---@return table value The right direction vector in world coordinates
    function self.getWorldRight() end
    --- Returns the up direction vector of the player, in world coordinates
    ---@return table value The up direction vector in world coordinates
    function self.getWorldUp() end

    --- Returns the id of the planet the player is located on
    ---@return integer value The id of the planet, 0 if none
    function self.getPlanet() end
    --- Returns the identifier of the construct to which the player is parented
    ---@return integer value The id of the construct, 0 if none
    function self.getParent() end

    --- Checks if the player is seated
    ---@return integer value 1 if the player is seated
    function self.isSeated() end
    --- Returns the local id of the seat on which the player is sitting
    ---@return integer value The local id of the seat, or 0 is not seated
    function self.getSeatId() end
    --- Checks if the player is parented to the given construct
    ---@param id integer The construct id
    ---@return integer value 1 if the player is parented to the given construct
    function self.isParentedTo(id) end

    --- Checks if the player is currently sprinting
    ---@return integer value 1 if the player is sprinting
    function self.isSprinting() end
    --- Checks if the player's jetpack is on
    ---@return integer value 1 if the player's jetpack is on
    function self.isJetpackOn() end

    --- Returns the state of the headlight of the player
    ---@return integer 1 if the player has his headlight on
    function self.isHeadlightOn() end
    --- Set the state of the headlight of the player
    ---@param state boolean : True to turn on headlight
    function self.setHeadlightOn(state) end


    --- Freezes the player movements, liberating the associated movement keys to be used by the script. 
    --- Note that this function is disabled if the player is not running the script explicitly (pressing F on the Control Unit, vs. via a plug signal)
    ---@param state boolean 1 freeze the character, 0 unfreeze the character
    function self.freeze(state) end
    --- Checks if the player movements are frozen
    ---@return integer value 1 if the player is frozen, 0 otherwise
    function self.isFrozen() end

    --- Checks if the player has DRM autorization to the control unit
    ---@return integer value 1 if the player has DRM autorization on the control unit
    function self.hasDRMAutorization() end

    --- Emitted when the player parent change
    ---@param oldId integer The previous parent construct ID
    ---@param newId integer The new parent construct ID
    self.onParentChanged = Event:new()


    return setmetatable(self, Player)
end

--- Global alias available out of the game
DUPlayer = Player
