function RadarClass(c, s, u, radar_1, radar_2, warpdrive,
    mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) -- Everything related to radar but draw data passed to HUD Class.
    local Radar = {}
    -- Radar Class locals

        local friendlies = {}
        local sizeMap = { XS = 13, S = 27, M = 55, L = 110, XL = 221}
        local cTypeString = {"Universe", "Planet", "Asteroid", "Static", "Dynamic", "Space", "Alien"}
        local knownContacts = {}
        local radarContacts = 0
        local target
        local numKnown
        local static = 0
        local activeRadar
        local radars = {activeRadar}
        local rType = "Atmo"
        local UpdateRadarCoroutine
        local perisPanelID
        local peris = 0
        local contacts = {}
        local radarData
        local lastPlay = 0
        local insert = table.insert
        local activeRadarState = -4
        local radarStatus = {
            [1] = "Operational",
            [0] = "broken",
            [-1] = "jammed",
            [-2] = "obstructed",
            [-3] = "in use"
          }
        local radarWidgetId, perisWidgetId
        local radarDataId, perisDataId
        local hasMatchingTransponder 
        local getConstructKind 
        local isConstructAbandoned 
        local getConstructName 
        local getDistance 
        local getSize 
        local conWorldPos 
    local function toggleRadarPanel()
        if radarPanelId ~= nil and peris == 0 then
            sysDestWid(radarPanelId)
            s.destroyWidget(radarWidgetId)
            s.destroyData(radarDataId)
            radarWidgetId, radarDataId, radarPanelId = nil, nil, nil
            if perisPanelID ~= nil then
                sysDestWid(perisPanelID)
                s.destroyWidget(perisWidgetId)
                s.destroyData(perisDataId)
                perisPanelID, perisWidgetId, perisDataId = nil, nil, nil
            end
        else
            -- If radar is installed but no weapon, don't show periscope
            if peris == 1 then
                --sysDestWid(radarPanelId)
                --radarPanelId = nil
                perisPanelID = s.createWidgetPanel("PeriWinkle")
                perisWidgetId = s.createWidget(perisPanelID, 'periscope')
                perisDataId = activeRadar.getWidgetDataId()
                s.addDataToWidget(perisDataId , perisWidgetId)
            end
            if radarPanelId == nil and radarContacts > 0 then
                radarPanelId = s.createWidgetPanel(rType)
                radarWidgetId = s.createWidget(radarPanelId, 'radar')
                radarDataId = activeRadar.getWidgetDataId()
                s.addDataToWidget(radarDataId , radarWidgetId)
            end
            peris = 0
        end
    end
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
                        construct.center = newPos
                        if construct.lastPos then
                            if (construct.lastPos - newPos):len() < 2 then
                                local dtt = (newPos - vec3(wp)):len()
                                if mabs(dtt - d) < 10 then
                                    construct.skipCalc = true
                                end
                            end
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
        if (activeRadar) then

            if #radarData > 0 then

                local count, count2 = 0, 0
                local radarDist = velMag * 10
                local nearPlanet = nearPlanet
                static, numKnown = 0, 0
                friendlies = {}
                for _,v in pairs(radarData) do
                    local distance = getDistance(v)
                    if distance > 0.0 then 
                        if hasMatchingTransponder(v) == 1 then
                            insert(friendlies,v)
                        end
                        if not notPvPZone and warpdrive and distance < EmergencyWarp and  warpdrive.getStatus() == 15 then 
                            msgText = "INITIATING WARP"
                            msgTimer = 7
                            warpdrive.initiate()
                        end
                        local abandoned = AbandonedRadar and isConstructAbandoned(v) == 1
                        if CollisionSystem or abandoned then
                            local size = getSize(v)
                            local sz = sizeMap[size]
                            local cType = getConstructKind(v)
                            if abandoned or (distance < radarDist and (sz > 27 or cType == 4 or cType == 6)) then
                                static = static + 1
                                local wp = {worldPos["x"],worldPos["y"],worldPos["z"]} 
                                local construct = contacts[v]
                                if construct == nil then
                                    sz = sz+coreHalfDiag
                                    contacts[v] = {pts = {}, ref = wp, name = getConstructName(v), i = 0, radius = sz, skipCalc = false}
                                    construct = contacts[v]
                                end
                                if not construct.skipCalc then
                                    if (abandoned or cType == 4 or cType == 6) then
                                        construct.center = vec3(conWorldPos(v))
                                        construct.skipCalc = true
                                    else
                                        updateVariables(construct, distance, wp)
                                        count2 = count2 + 1
                                    end                                        
                                    if abandoned and not construct.abandoned then
                                        local time = s.getArkTime()
                                        if lastPlay+5 < time then 
                                            lastPlay = time
                                            play("abRdr", "RD")
                                        end
                                        s.print("Abandoned Construct: "..construct.name.." ("..size.." ".. cTypeString[cType]..") at ::pos{0,0,"..construct.center.x..","..construct.center.y..","..construct.center.z.."}")
                                        msgText = "Abandoned Radar Contact ("..size.." ".. cTypeString[cType]..") detected"
                                        construct.abandoned = true
                                    end 
                                else
                                    insert(knownContacts, construct) 
                                end
                            end
                            count = count + 1
                            if count > 300 or count2 > 30 then
                                coroutine.yield()
                                count, count2 = 0, 0
                            end
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
                target = activeRadar.getTargetId()
            end
        end
    end
    local function pickType()
        if activeRadar then
            rType = "Atmo"
            if string.find(activeRadar.getName(),"Space") then 
                rType = "Space" 
            end
        end
    end
    function Radar.pickType()
        pickType()
    end

    function Radar.assignRadar()
        if radar_2 and activeRadarState ~= 1 then
            if activeRadarState == -1 then
                if activeRadar == radar_2 then 
                    activeRadar = radar_1
                else  
                    activeRadar = radar_2 
                end
            end
            radars = {activeRadar}
            hasMatchingTransponder = activeRadar.hasMatchingTransponder
            getConstructKind = activeRadar.getConstructKind
            isConstructAbandoned = activeRadar.isConstructAbandoned
            getConstructName = activeRadar.getConstructName
            getDistance = activeRadar.getConstructDistance
            getSize = activeRadar.getConstructCoreSize
            conWorldPos = activeRadar.getConstructWorldPos
            radarData = activeRadar.getConstructIds()
            pickType()
        else
            radarData = activeRadar.getConstructIds()
        end
        activeRadarState = activeRadar.getOperationalState()
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
        local radarMessage, msg
        local num = numKnown or 0 
        radarContacts = #radarData
        if radarContacts > 0 then 
            if CollisionSystem then 
                msg = num.."/"..static.." Known/InRange : "..radarContacts.." Total" 
            else
                msg = "Radar Contacts: "..radarContacts
            end
            radarMessage = svgText(radarX, radarY, msg, "pbright txtbig txtmid")
            if #friendlies > 0 then
                radarMessage = radarMessage..svgText( friendx, friendy, "Friendlies In Range", "pbright txtbig txtmid")
                for k, v in pairs(friendlies) do
                    friendy = friendy + 20
                    radarMessage = radarMessage..svgText(friendx, friendy, activeRadar.getConstructName(v), "pdim txtmid")
                end
            end
            local idNum = #activeRadar.getIdentifiedConstructIds()
            if perisPanelID == nil and idNum > 0 then
                peris = 1
                RADAR.ToggleRadarPanel()
            end
            if perisPanelID ~= nil and idNum == 0 then
                RADAR.ToggleRadarPanel()
            end
            if radarPanelId == nil then
                if showHud then RADAR.ToggleRadarPanel() end
            end
        else
            if activeRadarState ~= 1 then
                    radarMessage = svgText(radarX, radarY, rType.." Radar: "..radarStatus[activeRadarState] , "pbright txtbig txtmid")
            else
                radarMessage = svgText(radarX, radarY, "Radar: No "..rType.." Contacts", "pbright txtbig txtmid")
            end
            if radarPanelId ~= nil then
                peris = 0
                RADAR.ToggleRadarPanel()
            end
        end
        return radarMessage
    end

    function Radar.GetClosestName(name)
        if activeRadar then -- Just match the first one
                local closeName = activeRadar.getConstructName(activeRadar.getConstructIds()[1])
                if closeName then name = name .. " " .. closeName end
        end
        return name
    end

    function Radar.ToggleRadarPanel()
        toggleRadarPanel()
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
        if activeRadar and not inAtmo and not notPvPZone then 
            u.setTimer("contact",0.1) 
        end
    end

    function Radar.onLeave(id)
        if activeRadar and CollisionSystem then 
            if #contacts > 650 then 
                id = tostring(id)
                contacts[id] = nil 
            end
        end
    end

    local function setup()
        activeRadar=nil
        if radar_2 and radar_2.getOperationalState()==1 then
            activeRadar = radar_2
        else
            activeRadar = radar_1
        end
        activeRadarState=activeRadar.getOperationalState()
        hasMatchingTransponder = activeRadar.hasMatchingTransponder
        getConstructKind = activeRadar.getConstructKind
        isConstructAbandoned = activeRadar.isConstructAbandoned
        getConstructName = activeRadar.getConstructName
        getDistance = activeRadar.getConstructDistance
        getSize = activeRadar.getConstructCoreSize
        conWorldPos = activeRadar.getConstructWorldPos
        radars = {activeRadar}
        radarData = activeRadar.getConstructIds()
        pickType()
        UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)

        if userRadar then 
            for k,v in pairs(userRadar) do Radar[k] = v end 
        end   
    end
    setup()

    return Radar
end 