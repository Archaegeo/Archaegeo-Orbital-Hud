--[[
    Below here is used to add new functions or override functions in the various require files in the hud 

    To override a function, it must have the same .Name as the existing function but have the table userName shown here

    For example, in baseclass.lua, the stop function is called program.onStop.  
    To override or add to it here, you would name it function userBase.onStop (see example below).  You would need to copy the base
    function to keep all functionality.  Then you could add code before, after, or changed.

    This require file is looked for and loaded after all other require classes.
--]]

-- IMPORTANT NOTE: If a global variable named userScreen is set anywhere, it is added to the svg displayed by the main hud's setScreen call without needing to change other hudclass functions.
    userScreen = nil -- If userScreen is set anywhere, it is added to the svg displayed by the main hud's setScreen call without needing to change other hudclass functions.

    userBase = {} -- baseclass.lua override
    userRadar = {} -- radarclass.lua override
    userAP = {} -- apclass.lua override
    userAtlas = {} -- atlasclass.lua override
    userControl = {} -- controlclass.lua override
    userHud = {} -- hudclass.lua override
    userShield = {} -- shieldclass.lua override

-- ADDON FUNCTIONALITY FOR THE FOUR MAIN EVENTS, CALLED AT END OF EVENT
    function userBase.ExtraOnStart()
        -- Code you want executed at end of Startup
    end
    function userBase.ExtraOnStop()
        -- Code you want executed at end of Shutdown
    end
    function userBase.ExtraOnUpdate()
        -- Code you want executed at end of Update
    end
    function userBase.ExtraOnFlush()
        -- Code you want executed at end of Flush
    end

-- EXAMPLES OF OVERRIDE FUNCTIONALITY
    --[[
        -- This is an an example of how modify an existing function (onStop from baseclass.lua).  First you copy the entire function, then you modify it as desired.
            function userBase.onStop()
                _autoconf.hideCategoryPanels()
                if antigrav ~= nil  and not ExternalAGG then
                    antigrav.hide()
                end
                if warpdrive ~= nil then
                    warpdrive.hide()
                end
                c.hide()
                Nav.control.switchOffHeadlights()
                -- Open door and extend ramp if available
                if door and (atmosDensity > 0 or (atmosDensity == 0 and coreAltitude < 10000)) then
                    for _, v in pairs(door) do
                        v.toggle()
                    end
                end
                if switch then
                    for _, v in pairs(switch) do
                        v.toggle()
                    end
                end
                if forcefield and (atmosDensity > 0 or (atmosDensity == 0 and coreAltitude < 10000)) then
                    for _, v in pairs(forcefield) do
                        v.toggle()
                    end
                end
                showHud = oldShowHud
                SaveDataBank()
                if button then
                    button.activate()
                end
                if SetWaypointOnExit then AP.showWayPoint(planet, worldPos) end
                s.print(HUD.FuelUsed("atmofueltank")..", "..HUD.FuelUsed("spacefueltank")..", "..HUD.FuelUsed("rocketfueltank"))
                if userBase then PROGRAM.ExtraOnStop() end
                play("stop","SU")
            end
    --]]

    --[[
        function userRadar.onEnter(id) -- This example completely replaces the existing Radar.onEnter function in radarclass.lua and also calls a newly created function (Special()).
            p("Hello: "..id)
            RADAR.Special()
        end
        function userRadar.Special() -- Would add a new function to the radar class called special that is called by the above overriden onEnter
            p("Working")
        end
    --]]




