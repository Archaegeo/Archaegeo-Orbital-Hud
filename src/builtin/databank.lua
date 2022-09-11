-- ################################################################################
-- #                  Copyright 2014-2022 Novaquark SAS                           #
-- ################################################################################

-----------------------------------------------------------------------------------
-- Databank
--
-- Stores key/value pairs in a persistent way.
-----------------------------------------------------------------------------------

require("element")

--- Stores key/value pairs in a persistent way.
---@class Databank
Databank = {}
Databank.__index = Databank
function Databank()
    local self = Element()

    --- Clear the Databank
    function self.clear() end

    --- Returns the number of keys that are stored inside the Databank
    ---@return integer
    function self.getNbKeys() end

    --- Returns all the keys in the Databank
    ---@return table value The key list, as a list of string
    function self.getKeyList() end
    ---@deprecated Databank.getKeys() is deprecated, use Databank.getKeyList().
    function self.getKeys() error("Databank.getKeys() is deprecated, use Databank.getKeyList().") end

    --- Returns 1 if the key is present in the Databank, 0 otherwise
    ---@param key string The key used to store a value
    ---@return integer value 1 if the key exists and 0 otherwise
    function self.hasKey(key) end

    --- Remove the given key if the key is present in the Databank
    ---@param key string The key used to store a value
    ---@return integer value 1 if the key has been successfully removed, 0 otherwise
    function self.clearValue(key) end

    --- Stores a string value at the given key
    ---@param key string The key used to store the value
    ---@param val string The value, as a string
    function self.setStringValue(key,val) end

    --- Returns value stored in the given key as a string
    ---@param key string The key used to retrieve the value
    ---@return string value The value as a string
    function self.getStringValue(key) end

    --- Stores an integer value at the given key
    ---@param key string The key used to store the value
    ---@param val integer The value, as an integer
    function self.setIntValue(key,val) end

    --- Returns value stored in the given key as an integer
    ---@param key string The key used to retrieve the value
    ---@return integer value The value as an integer
    function self.getIntValue(key) end

    --- Stores a floating number value at the given key
    ---@param key string The key used to store the value
    ---@param val number The value, as a floating number
    function self.setFloatValue(key,val) end

    --- Returns value stored in the given key as a floating number
    ---@param key string The key used to retrieve the value
    ---@return number value The value as a floating number
    function self.getFloatValue(key) end


    return setmetatable(self, Databank)
end
