function RadarClass(c, s, u, library, radar_1, radar_2, 
    mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) -- Everything related to radar but draw data passed to HUD Class.
    local Radar = {}
    -- Radar Class locals

        local friendlies = {}
        local sizeMap = { XS = 13, S = 27, M = 55, L = 110, XL = 221}
        local knownContacts = {}
        local radarContacts
        local target
        local data
        local numKnown
        local static
        local radars = {}
        local rType = "Atmo"
        local UpdateRadarCoroutine
        local perisPanelID
        local peris = 0
        local contacts = {}

    local function UpdateRadarRoutine()
        -- UpdateRadarRoutine Locals
            local function trilaterate (r1, p1, r2, p2, r3, p3, r4, p4 )-- Thanks to Wolfe's DU math library and Eastern Gamer advice
                p1,p2,p3,p4 = vec3(p1),vec3(p2),vec3(p3),vec3(p4)
                local r1s, r2s, r3s = r1*r1, r2*r2, r3*r3
                local v2 = p2 - p1
                local ax = v2:normalize()
                local U = v2:len()
                local v3 = p3 - p1
                local ay = (v3 - v3:project_on(ax)):normalize()
                local v3x, v3y = v3:dot(ax), v3:dot(ay)
                local vs = v3x*v3x + v3y*v3y
                local az = ax:cross(ay)  
                local x = (r1s - r2s + U*U) / (2*U) 
                local y = (r1s - r3s + vs - 2*v3x*x)/(2*v3y)
                local m = r1s - (x^2) - (y^2) 
                local z = msqrt(m)
                local t1 = p1 + ax*x + ay*y + az*z
                local t2 = p1 + ax*x + ay*y - az*z
            
                if mabs((p4 - t1):len() - r4) < mabs((p4 - t2):len() - r4) then
                return t1
                else
                return t2
                end
            end

            local function getTrueWorldPos()
                local function getLocalToWorldConverter()
                    local v1 = c.getConstructWorldOrientationRight()
                    local v2 = c.getConstructWorldOrientationForward()
                    local v3 = c.getConstructWorldOrientationUp()
                    local v1t = library.systemResolution3(v1, v2, v3, {1,0,0})
                    local v2t = library.systemResolution3(v1, v2, v3, {0,1,0})
                    local v3t = library.systemResolution3(v1, v2, v3, {0,0,1})
                    return function(cref)
                        return library.systemResolution3(v1t, v2t, v3t, cref)
                    end
                end
                local cal = getLocalToWorldConverter()
                local cWorldPos = c.getConstructWorldPos()
                local pos = c.getElementPositionById(1)
                local offsetPosition = {pos[1] , pos[2] , pos[3] }
                local adj = cal(offsetPosition)
                local adjPos = {cWorldPos[1] - adj[1], cWorldPos[2] - adj[2], cWorldPos[3] - adj[3]}
                return adjPos
            end
            
            local function updateVariables(construct, d, wp) -- Thanks to EasternGamer and Dimencia
                local pts = construct.pts
                local index = #pts
                local ref = construct.ref
                if index > 3 then
                    local in1, in2, in3, in4 = pts[index], pts[index-1], pts[index-2], pts[index-3]
                    construct.ref = wp
                    local pos = trilaterate(in1[1], in1[2], in2[1], in2[2], in3[1], in3[2], in4[1], in4[2])
                    local x,y,z = pos.x, pos.y, pos.z
                    if x == x and y == y and z == z then
                        x = x + ref[1]
                        y = y + ref[2]
                        z = z + ref[3]
                        local newPos = vec3(x,y,z)
                        if not construct.lastPos then
                            construct.center = newPos
                        elseif (construct.lastPos - newPos):len() < 2 then
                            construct.center = newPos
                            construct.skipCalc = true
                        end
                        construct.lastPos = newPos
                    end
                    construct.pts = {}
                else
                    local offset = {wp[1]-ref[1],wp[2]-ref[2],wp[3]-ref[3]}
                    pts[index+1] = {d,offset}
                end
            end

        if radar_1 or radar_2 then RADAR.assignRadar() end
        if (radars[1]) then
            radarContacts = #radars[1].getConstructIds()
            local radarData = radars[1].getData()
            local contactData = radarData:gmatch('{"constructId[^}]*}[^}]*}') 
         
            if radarContacts > 0 then
                local wp = getTrueWorldPos()
                local count, count2 = 0, 0
                static, numKnown = 0, 0
                for v in contactData do
                    local id,distance,size = v:match([[{"constructId":"([%d%.]*)","distance":([%d%.]*).-"size":"(%a+)"]])
                    local sz = sizeMap[size]
                    distance = tonum(distance)
                    if radars[1].hasMatchingTransponder(id) == 1 then
                        table.insert(friendlies,id)
                    end

                    local cType = radars[1].getConstructType(id)
                    if CollisionSystem then
                        if (sz > 27 or AbandonedRadar) or cType == "static" or cType == "space" then
                            static = static + 1
                            local name = radars[1].getConstructName(id)
                            local construct = contacts[id]
                            if construct == nil then
                                sz = sz+coreHalfDiag
                                contacts[id] = {pts = {}, ref = wp, name = name, i = 0, radius = sz, skipCalc = false}
                                construct = contacts[id]
                            end
                            if not construct.skipCalc then 
                                updateVariables(construct, distance, wp) 
                                count2 = count2 + 1
                            end
                            if construct.center then 
                                if AbandonedRadar and radars[1].isConstructAbandoned(id) == 1 and not construct.abandoned then
                                    play("abRdr", "RD")
                                    s.print("Abandoned Construct: "..name.." ("..cType..") ::pos{0,0,"..construct.center.x..","..construct.center.y..","..construct.center.z.."}")
                                    msgText = "Abandoned Radar Contact ("..cType..") detected"
                                    construct.abandoned = true
                                end
                                table.insert(knownContacts, construct) 
                            end
                        end
                        count = count + 1
                        if (nearPlanet and count > 700 or count2 > 70) or (not nearPlanet and count > 300 or count2 > 30) then
                            coroutine.yield()
                            count, count2 = 0, 0
                        end
                    end
                end
                numKnown = #knownContacts
                if numKnown > 0 and (velMag > 20 or BrakeLanding) then 
                    local body, far, near, vect
                    local innerCount = 0
                    local galxRef = galaxyReference:getPlanetarySystem(0)
                    vect = constructVelocity:normalize()
                    while innerCount < numKnown do
                        coroutine.yield()
                        local innerList = { table.unpack(knownContacts, innerCount, math.min(innerCount + 75, numKnown)) }
                        body, far, near = galxRef:castIntersections(worldPos, vect, nil, nil, innerList, true)
                        if body and near then 
                            collisionTarget = {body, far, near} 
                            break 
                        end
                        innerCount = innerCount + 75
                    end
                    if not body then collisionTarget = nil end
                else
                    collisionTarget = nil
                end
                knownContacts = {}
                target = radarData:find('identifiedConstructs":%[%]')
            else
                data = radarData:find('worksInEnvironment":false')
            end
        end
    end
    local function pickType()
        if radars[1] then
            rType = "Atmo"
            if radars[1].getData():find('worksInAtmosphere":false') then 
                rType = "Space" 
            end
        end
    end
    function Radar.pickType()
        pickType()
    end

    function Radar.assignRadar()
        if radar_1 and radars[1]==radar_1 and radar_1.isOperational() ~= 1 then
            if radar_2 and radar_2.isOperational() == 1 then 
                radars[1] = radar_2
            end
            if radars[1] == radar_2 then pickType() end
        elseif radar_2 and radars[1]==radar_2 and radar_2.isOperational() ~= 1 then
            if radar_1 and radar_1.isOperational() == 1 then 
                radars[1] = radar_1
            end
            if radars[1] == radar_1 then pickType() end
        end
    end

    function Radar.UpdateRadar()
        local cont = coroutine.status (UpdateRadarCoroutine)
        if cont == "suspended" then 
            local value, done = coroutine.resume(UpdateRadarCoroutine)
            if done then s.print("ERROR UPDATE RADAR: "..done) end
        elseif cont == "dead" then
            UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
            local value, done = coroutine.resume(UpdateRadarCoroutine)
        end
    end

    function Radar.GetRadarHud(friendx, friendy, radarX, radarY)
        local friends = friendlies
        local radarMessage, msg
        friendlies = {}
        local num = numKnown or 0 
        if radarContacts > 0 then 
            if CollisionSystem then 
                msg = num.."/"..static.." Plotted : "..(radarContacts-static).." Ignored" 
            else
                msg = "Radar Contacts: "..radarContacts
            end
            radarMessage = svgText(radarX, radarY, msg, "pbright txtbig txtmid")
            if #friendlies > 0 then
                radarMessage = radarMessage..svgText( friendx, friendy, "Friendlies In Range", "pbright txtbig txtmid")
                for k, v in pairs(friendlies) do
                    friendy = friendy + 20
                    radarMessage = radarMessage..svgText(friendx, friendy, radars[1].getConstructName(v), "pdim txtmid")
                end
            end

            if target == nil and perisPanelID == nil then
                peris = 1
                RADAR.ToggleRadarPanel()
            end
            if target ~= nil and perisPanelID ~= nil then
                RADAR.ToggleRadarPanel()
            end
            if radarPanelID == nil then
                RADAR.ToggleRadarPanel()
            end
        else
            if data then
                radarMessage = svgText(radarX, radarY, rType.." Radar: Jammed", "pbright txtbig txtmid")
            else
                radarMessage = svgText(radarX, radarY, "Radar: No "..rType.." Contacts", "pbright txtbig txtmid")
            end
            if radarPanelID ~= nil then
                peris = 0
                RADAR.ToggleRadarPanel()
            end
        end
        return radarMessage
    end

    function Radar.GetClosestName(name)
        if radars[1] then -- Just match the first one
            local id,_ = radars[1].getData():match('"constructId":"([0-9]*)","distance":([%d%.]*)')
            if id ~= nil and id ~= "" then
                name = name .. " " .. radars[1].getConstructName(id)
            end
        end
        return name
    end
    function Radar.ToggleRadarPanel()
        if radarPanelID ~= nil and peris == 0 then
            sysDestWid(radarPanelID)
            radarPanelID = nil
            if perisPanelID ~= nil then
                sysDestWid(perisPanelID)
                perisPanelID = nil
            end
        else
            -- If radar is installed but no weapon, don't show periscope
            if peris == 1 then
                sysDestWid(radarPanelID)
                radarPanelID = nil
                _autoconf.displayCategoryPanel(radars, 1, "Periscope",
                    "periscope")
                perisPanelID = _autoconf.panels[_autoconf.panels_size]
            end
            if radarPanelID == nil then
                _autoconf.displayCategoryPanel(radars, 1, "Radar", "radar")
                radarPanelID = _autoconf.panels[_autoconf.panels_size]
            end
            peris = 0
        end
    end

    function Radar.ContactTick()
        if not contactTimer then contactTimer = 0 end
        if time > contactTimer+10 then
            msgText = "Radar Contact" 
            play("rdrCon","RC")
            contactTimer = time
        end
        u.stopTimer("contact")
    end

    function Radar.onEnter(id)
        if radar_1 and not inAtmo and not notPvPZone then 
            u.setTimer("contact",0.1) 
        end
    end

    function Radar.onLeave(id)
        if radar_1 and CollisionSystem then 
            if #contacts > 650 then 
                id = tostring(id)
                contacts[id] = nil 
            end
        end
    end

    radars[1]=nil
    if radar_1 then
        radars[1] = radar_1
        pickType()
    end
    UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)

    -- TO ACTIVATE A CUSTOM OVERRIDE FILE TO OVERRIDE SPECIFIC FUNCTIONS THE FOLLOWING FILE MUST BE PRESENT
    local _, radarOverride = pcall(require, "autoconf/custom/archhud/custom/customradarclass")
    if type(radarOverride) == "table" then
        for k,v in pairs(radarOverride) do Radar[k] = v end 
    end    
    return Radar
end 