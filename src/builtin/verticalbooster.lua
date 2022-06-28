-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Vertical Boosters
--
-- Vertical boosters are engines designed to produce powerful vertical thrust over a limited distance.
-- They consume space fuel but operate in the atmosphere and in the space void.
-----------------------------------------------------------------------------------

require("surfaceengine")

--- Vertical boosters are engines designed to produce powerful vertical thrust over a limited distance.
--- They consume space fuel but operate in the atmosphere and in the space void.
---@class VerticalBooster
VerticalBooster = {}
VerticalBooster.__index = VerticalBooster
function VerticalBooster()
    local self = SurfaceEngine()

    return setmetatable(self, VerticalBooster)
end