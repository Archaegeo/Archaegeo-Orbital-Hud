-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Engines
-----------------------------------------------------------------------------------

require("element")

---@class Engine
Engine = {}
Engine.__index = Engine
function Engine()
    local self = Element()

    --- Returns the obstruction ratio of the engine exhaust by Elements and Voxels.
    --- The more obstructed the engine is, the less properly it will work. Try to fix your design if this is the case
    ---@return number
    function self.getObstructionFactor() end

    --- Returns the tags of the engine
    ---@return string
    function self.getTags() end
    
    --- Set the tags of the engine
    ---@param tags string The CSV string of the tags
    ---@param ignore boolean: True to ignore the default engine tags
    function self.setTags(tags,ignore) end
    
    --- Checks if the engine is ignoring default tags
    ---@return integer 1 if the engine ignores default engine tags
    function self.isIgnoringTags() end

    return setmetatable(self, Engine)
end