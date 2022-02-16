--EXAMPLE CUSTOM CONTROL OVERRIDE FILE FOR DEFAULT CONTROL REQUIRE
-- Recommend backing up outside of the default DU path in case a DU update wipes the autoconf/custom directory
-- Any locals from the default require must be passed explicitly in the override function

    local Control = {}

    --[[ OVERRIDE FUNCTIONS GO HERE
    Functions must have same name as in the default require file.  Functions must include any local functions or variables.
    --]]

return Control