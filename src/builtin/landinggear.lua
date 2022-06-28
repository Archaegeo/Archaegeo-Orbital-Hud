-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Landing Gear
--
-- A Landing Gear that can be opened or closed.
-----------------------------------------------------------------------------------

require("element")

---@class LandingGear
LandingGear = {}
LandingGear.__index = LandingGear
function LandingGear()
    local self = Element()

    --- Deploys the landing gear
    function self.deploy() end
    ---@deprecated LandingGear.activate() is deprecated, use LandingGear.deploy() instead.
    function self.activate() error("LandingGear.activate() is deprecated, use LandingGear.deploy() instead.") end

    --- Retracts the landing gear
    function self.retract() end
    ---@deprecated ForceField.deactivate() is deprecated, use ForceField.retract() instead.
    function self.deactivate() error("ForceField.deactivate() is deprecated, use ForceField.retract() instead.") end

    --- Checks if the landing gear is deployed
    ---@return integer
    function self.isDeployed() end
    ---@deprecated ForceField.getState() is deprecated, use ForceField.isDeployed() instead.
    function self.getState() error("ForceField.getState() is deprecated, use ForceField.isDeployed() instead.") end

    --- Toggle the landing gear
    function self.toggle() end

    return setmetatable(self, LandingGear)
end