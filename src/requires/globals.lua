-- Auto Variable declarations that store status of ship on databank. Do not edit directly here unless you know what you are doing, these change as ship flies.
    -- NOTE: autoVariables below must contain any variable that needs to be saved/loaded from databank system
    BrakeToggleStatus = BrakeToggleDefault  -- Example, not use in base templace
    autoVariables = {BrakeToggleStatus={set=function (i)BrakeToggleStatus=i end,get=function() return BrakeToggleStatus end}}

-- Unsaved Globals that are needed across classes but are not saved to databank.
    function globalDeclare() -- globals used in more than 1 spot
        planetAtlas = {}
    end