--EXAMPLE CUSTOM HUD OVERRIDE FILE FOR DEFAULT HUDCLASS REQUIRE
-- Recommend backing up outside of the default DU path in case a DU update wipes the autoconf/custom directory

local ap = {}
    -- REQUIRED DEFINES FROM HERE TILL NEXT REMARK - THESE CAN BE REMOVED IN THIS CUSTOM REQUIRE IF NOT USED
        local Nav = navGlobal
        local core = coreGlobal
        local unit = unitGlobal
        local system = systemGlobal
        local atlas = atlasGlobal
        local vBooster = vBoosterGlobal
        local hover = hoverGlobal
        local telemeter_1 = telmeter_1Global
        local antigrav = antigravGlobal
        
    -- END OF REQUIRED DEFINES

    --[[ OVERRIDE FUNCTIONS GO HERE
    Functions must have same name as in the default require file.  Functions must include any local functions or variables.
    --]]

return ap