--EXAMPLE CUSTOM HUD OVERRIDE FILE FOR DEFAULT HUDCLASS REQUIRE
-- Recommend backing up outside of the default DU path in case a DU update wipes the autoconf/custom directory
-- Any locals from the default require must be passed explicitly in the override function

local Hud = {}

--    local Hud = {}

    --[[ OVERRIDE FUNCTIONS GO HERE
    Functions must have same name as in the default require file.  Functions must include any local functions or variables.
    
    EXAMPLE 
    function Hud.TestFunction(str)  -- This would override a function named Hud.TestFunction in the default require file, bringing str as arguement
        p("OVERRIDE: "..str)
    end
    --]]


return Hud
