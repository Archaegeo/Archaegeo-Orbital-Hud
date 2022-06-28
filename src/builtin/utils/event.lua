-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Event Library
--
-- The library contains all object definitions for Lua event handling.
--  - action
--  - event
-----------------------------------------------------------------------------------

local getTime = getTime or DUSystem.getUtcTime()

local function isCallable(call)
    if type(call) == "table" then
        if type(getmetatable(call)["__call"]) == "function" then
            return true
        end
    elseif type(call) == "function" then
        return true
    elseif type(call) == "thread" then
        if coroutine.status(call) ~= "dead" then
            return true
        end
    end

    return false
end


---@class action
---@field id string This is an ID which we can use later to refer to this action.
---@field call any Triggered when the event is trigger.
---@field enabled boolean This boolean indicates whether or not the action is enabled.
---@field limit integer This property represents the number of times events can invoke this action.
---@field nbCall integer This property keeps track of how many times events have invoked this action.
---@field interval number This property allows to limit the minimum time between two calls.
---@field lastCall number This property helps track the time of when we last called this action.
local action = {}
action.__index = action

--- Create a new action event
---@param call any
---@param enabled boolean
---@param limit integer
---@param interval number
---@return action
function action:new(call, enabled, limit, interval)
    local self = {}

    assert(isCallable(call))
    self.id = tostring(call)
    self.call = call
    self.enabled = enabled ~= false
    self.limit = limit or -1
    self.nbCall = 0
    self.interval = interval or 0
    self.keep = true
    self.lastCall = getTime()

    ---Compare two actions for equality
    ---@param a1 action
    ---@param a2 action
    ---@return boolean result
    function self.__eq(a1, a2)
        if getmetatable(a1) ~= action or getmetatable(a2) ~= action then
            return false
        end
        return a1.id == a2.id
    end

    return setmetatable(self,action)
end


---@class Event
---@field actions table
local event = {}
event.__index = event
function Event:new()
    local self = {}
    self.actions = {}

    ---Invoke an action with arguments
    ---@param act action
    ---@return boolean keep
    local function invoke(act, ...)
        if act.enabled == false then return true end
        if act.nbCall > 0 and getTime() - act.lastCall < act.interval then return true end
    
        if type(act.call) == "thread" then
            coroutine.resume(act.call, ...)
            if coroutine.status(act.call) == "dead" then
                act.keep = false
            end
        else
            act.call(...)
        end
        act.nbCall = act.nbCall + 1

        if act.limit >= 0 and act.nbCall >= act.limit then
            act.keep = false
        end
    end

    ---Compare two events for equality
    ---@param e1 Event
    ---@param e2 Event
    ---@return boolean result
    function self:__eq(e1,e2)
        if getmetatable(e1) ~= event or getmetatable(e2) ~= event then
            return false
        end
    
        if #e1.actions ~= #e2.actions then return false end
    
        local found = false
        for _,a1 in pairs(e1.actions) do
            for _,a2 in pairs(e2.actions) do
                if a1 == a2 then
                    found = true
                    break
                end
            end
        end
        return found
    end

    local function _call(act, ...)
        invoke(act, ...)
        act.lastCall = getTime()
    end

    ---Emit the event
    function self:emit(...)
        if #self.actions == 0 then return end

        for _,a in pairs(self.actions) do
            if a.enabled then
                if a.interval > 0 and a.nbCall > 0 then
                    if (getTime() - a.lastCall) >= a.interval then
                        _call(a, ...)
                    end
                else
                    _call(a, ...)
                end
            end
        end
        
        self:cleanActions()
    end

    ---Find a specific action associated with this event
    ---@param act any
    ---@return boolean success
    ---@return integer index
    function self:findAction(act)
        local key
        if type(act) == "string" then
            key = "id"
        elseif isCallable(act) then
            key = "call"
        else
            error("Invalid action parameter: " .. tostring(act))
        end
    
        for i,a in pairs(self.actions) do
            if a[key] == act then
                return true, i
            end
        end
        return false, nil
    end

    function self:getAction(id)
        local found, index = self:findAction(id)
        if found then
            return self.actions[index]
        else
            return nil
        end
    end

    ---Add an action to the event
    ---@param call any
    ---@param enabled? boolean
    ---@param limit? integer
    ---@param interval? number
    ---@return string actionId
    function self:addAction(call, enabled, limit, interval)
        assert(isCallable(call))

        if self:findAction(call) then return end

        local act = action:new(call, enabled, limit, interval)
        self.actions[#self.actions+1] = act

        return act.id
    end

    ---Remove an action associated with the event
    ---@param act any
    function self:removeAction(act)
        local exists = self:findAction(act)
        if exists then act.keep = false end
        self:cleanActions()
    end

    function self:cleanActions()
        local i = 1
        for k=1,#self.actions do
            local a = self.actions[k]
            if a.keep then
                if k~=i then
                    self.actions[i] = a
                    self.actions[k] = nil
                end
                i = i+1
            else
                self.actions[i] = nil
            end
        end
    end

    return setmetatable(self,event)
end

return event