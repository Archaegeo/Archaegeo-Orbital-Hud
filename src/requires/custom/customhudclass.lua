--EXAMPLE CUSTOM HUD OVERRIDE FILE FOR DEFAULT HUDCLASS REQUIRE
-- Recommend backing up outside of the default DU path in case a DU update wipes the autoconf/custom directory

local Hud = {}
    -- REQUIRED DEFINES FROM HERE TILL NEXT REMARK - THESE CAN BE REMOVED IN THIS CUSTOM REQUIRE IF NOT USED
    local Nav = navGlobal
    local core = coreGlobal
    local unit = unitGlobal
    local system = systemGlobal
    local atlas = atlasGlobal
    local radar_1 = radar_1Global
    local radar_2 = radar_2Global
    local antigrav = antigravGlobal
    local hover = hoverGlobal
    local shield_1 = shield_1Global
    
    -- END OF REQUIRED DEFINES


--    local Hud = {}

    --[[ OVERRIDE FUNCTIONS GO HERE
    Functions must have same name as in the default require file.  Functions must include any local functions or variables.
    
    EXAMPLE 
    function Hud.TestFunction(str)  -- This would override a function named Hud.TestFunction in the default require file.
        p("OVERRIDE: "..str)
    end
    --]]


return Hud
