-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Hover Engines
--
-- Hover engines are engines made for ground-based vehicules in atmosphere; it requires a surface to produce a thrust.
-----------------------------------------------------------------------------------

require("surfaceengine")

--- Hover engines are engines made for ground-based vehicules in atmosphere; it requires a surface to produce a thrust.
---@class HoverEngine
HoverEngine = {}
HoverEngine.__index = HoverEngine
function HoverEngine()
    local self = SurfaceEngine()

    return setmetatable(self, HoverEngine)
end