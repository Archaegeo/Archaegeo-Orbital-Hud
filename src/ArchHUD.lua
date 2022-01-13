require 'src.slots'
xpcall(function() require("autoconf/custom/archhud/globals")  end, function(err) require("Modules/globals")  end)

local s=system
local c=core
local u=unit

local Nav = Navigator.new(s, c, u)
local atlas = require("atlas")

xpcall(function() require("autoconf/custom/archhud/Modules/hudclass")  end, function(err) require("Modules/hudclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/apclass")  end, function(err) require("Modules/apclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/radarclass")  end, function(err) require("Modules/radarclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/controlclass")  end, function(err) require("Modules/controlclass")  end)

VERSION_NUMBER = 1.7061

xpcall(function() require("autoconf/custom/archhud/Modules/startup")  end, function(err) require("Modules/startup")  end)