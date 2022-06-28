-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Counter
--
-- Cycle its output signal over a set of n-plugs, incrementing the activate plug by one step at each impulse received on its IN plug
-----------------------------------------------------------------------------------

require("element")

--- Cycle its output signal over a set of n-plugs, incrementing the activate plug by one step at each impulse received on its IN plug
---@class Counter
Counter = {}
Counter.__index = Counter
function Counter()
    local self = Element()

    --- Returns the index of the current active output plug
    ---@return integer
    function self.getIndex() end
    ---@deprecated Counter.getCounterState() is deprecated, use Counter.getIndex() instead.
    function self.getCounterState() error("Counter.getCounterState() is deprecated, use Counter.getIndex() instead.") end

    --- Returns the maximum index of the counter
    ---@return integer
    function self.getMaxIndex() end

    --- Moves the next counter index
    function self.nextIndex() end
    ---@deprecated Counter.next() is deprecated, use Counter.nextIndex() instead.
    function self.next() error("Counter.next() is deprecated, use Counter.nextIndex() instead.") end

    --- Sets the counter index
    ---@param index integer The index of the plug to activate
    function self.setIndex(index) end

    return setmetatable(self, Counter)
end