-- These values are a default set for 1920x1080 ResolutionX and Y settings. 

-- Auto Variable declarations that store status of ship on databank. Do not edit directly here unless you know what you are doing, these change as ship flies.
    -- NOTE: autoVariables below must contain any variable that needs to be saved/loaded from databank system
    BrakeToggleStatus = BrakeToggleDefault
    autoVariables = {BrakeToggleStatus={set=function (i)BrakeToggleStatus=i end,get=function() return BrakeToggleStatus end}}

-- Unsaved Globals
    function globalDeclare(c, u) -- # is how many classes variable is in
        local s = DUSystem
        local C = DUConstruct
    end