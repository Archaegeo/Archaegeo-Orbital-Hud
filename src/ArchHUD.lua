require 'src.slots'
VERSION_NUMBER = 1.7061
xpcall(function() require("autoconf/custom/archhud/Modules/globals")  end, function(err) require("Modules/globals")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/hudclass")  end, function(err) require("Modules/hudclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/apclass")  end, function(err) require("Modules/apclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/radarclass")  end, function(err) require("Modules/radarclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/controlclass")  end, function(err) require("Modules/controlclass")  end)
xpcall(function() require("autoconf/custom/archhud/Modules/startup")  end, function(err) require("Modules/startup")  end)