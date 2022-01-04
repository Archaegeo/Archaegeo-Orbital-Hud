function HudClass(Nav, core, unit, system, atlas, radar_1, radar_2, antigrav, hover, shield_1,
    mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, 
    navCom, sysDestWid, sysIsVwLock, msqrt, round, svgText)

-- Modify beyond here as you will
    local gravConstant = 9.80665
    local ControlButtons = {}
    local SettingButtons = {}


    --Local Huds Functions
        -- safezone() variables
            local safeWorldPos = vec3({13771471,7435803,-128971})
            local safeRadius = 18000000
            local szradius = 500000
            local distsz, distp = math.huge
            local szsafe 
        local function safeZone(WorldPos) -- Thanks to @SeM for the base code, modified to work with existing Atlas
            distsz = vec3(WorldPos):dist(safeWorldPos)
            if distsz < safeRadius then  
                return true, mabs(distsz - safeRadius)
            end 
            distp = vec3(WorldPos):dist(vec3(planet.center))
            if distp < szradius then szsafe = true else szsafe = false end
            if mabs(distp - szradius) < mabs(distsz - safeRadius) then 
                return szsafe, mabs(distp - szradius)
            else
                return szsafe, mabs(distsz - safeRadius)
            end
        end

        local function ConvertResolutionX (v)
            if resolutionWidth == 1920 then 
                return v
            else
                return round(resolutionWidth * v / 1920, 0)
            end
        end
    
        local function ConvertResolutionY (v)
            if resolutionHeight == 1080 then 
                return v
            else
                return round(resolutionHeight * v / 1080, 0)
            end
        end

        local function IsInFreeLook()
            return sysIsVwLock() == 0 and userControlScheme ~= "keyboard" and isRemote() == 0
        end

        local function GetFlightStyle()
            local flightStyle = "TRAVEL"
            if not throttleMode then
                flightStyle = "CRUISE"
            end
            if Autopilot then
                flightStyle = "AUTOPILOT"
            end
            return flightStyle
        end
        local radarMessage = ""
        local tankMessage = ""
        local shieldMessage = ""
        -- DrawTank variables
            local tankID = 1
            local tankName = 2
            local tankMaxVol = 3
            local tankMassEmpty = 4
            local tankLastMass = 5
            local tankLastTime = 6
            local slottedTankType = ""
            local slottedTanks = 0
            local fuelUpdateDelay = (mfloor(1 / apTickRate) * 2)*hudTickRate
            local fuelTimeLeftR = {}
            local fuelPercentR = {}
            local fuelTimeLeftS = {}
            local fuelPercentS = {}
            local fuelTimeLeft = {}
            local fuelPercent = {}
        
        local function DrawTank(x, nameSearchPrefix, nameReplacePrefix, tankTable, fuelTimeLeftTable,
            fuelPercentTable)
            
            local y1 = fuelY
            local y2 = fuelY+5
            if not BarFuelDisplay then y2=y2+5 end
            if isRemote() == 1 and not RemoteHud then
                y1 = y1 - 50
                y2 = y2 - 50
            end
        
            if nameReplacePrefix == "ATMO" then
                slottedTankType = "atmofueltank"
            elseif nameReplacePrefix == "SPACE" then
                slottedTankType = "spacefueltank"
            else
                slottedTankType = "rocketfueltank"
            end
            slottedTanks = _G[slottedTankType .. "_size"]
            if (#tankTable > 0) then
                for i = 1, #tankTable do
                    local name = string.sub(tankTable[i][tankName], 1, 12)
                    local slottedIndex = 0
                    for j = 1, slottedTanks do
                        if tankTable[i][tankName] == jdecode(unit[slottedTankType .. "_" .. j].getData()).name then
                            slottedIndex = j
                            break
                        end
                    end

                    local curTime = systime()

                    if fuelTimeLeftTable[i] == nil or fuelPercentTable[i] == nil or (curTime - tankTable[i][tankLastTime]) > fuelUpdateDelay then
                        
                        local fuelMassLast
                        local fuelMass = 0
                        if slottedIndex ~= 0 then
                            fuelPercentTable[i] = jdecode(unit[slottedTankType .. "_" .. slottedIndex].getData())
                                                    .percentage
                            fuelTimeLeftTable[i] = jdecode(unit[slottedTankType .. "_" .. slottedIndex].getData())
                                                    .timeLeft
                            if fuelTimeLeftTable[i] == "n/a" then
                                fuelTimeLeftTable[i] = 0
                            end
                        else
                            fuelMass = (eleMass(tankTable[i][tankID]) - tankTable[i][tankMassEmpty])
                            fuelPercentTable[i] = mfloor(0.5 + fuelMass * 100 / tankTable[i][tankMaxVol])
                            fuelMassLast = tankTable[i][tankLastMass]
                            if fuelMassLast <= fuelMass then
                                fuelTimeLeftTable[i] = 0
                            else
                                fuelTimeLeftTable[i] = mfloor(
                                                        0.5 + fuelMass /
                                                            ((fuelMassLast - fuelMass) / (curTime - tankTable[i][tankLastTime])))
                            end
                            tankTable[i][tankLastMass] = fuelMass
                            tankTable[i][tankLastTime] = curTime
                        end
                    end
                    if name == nameSearchPrefix then
                        name = stringf("%s %d", nameReplacePrefix, i)
                    end
                    if slottedIndex == 0 then
                        name = name .. " *"
                    end
                    local fuelTimeDisplay
                    if fuelTimeLeftTable[i] == 0 then
                        fuelTimeDisplay = ""
                    else
                        fuelTimeDisplay = FormatTimeString(fuelTimeLeftTable[i])
                    end
                    if fuelPercentTable[i] ~= nil then
                        local colorMod = mfloor(fuelPercentTable[i] * 2.55)
                        local color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                        local class = ""
                        if ((fuelTimeDisplay ~= "" and fuelTimeLeftTable[i] < 120) or fuelPercentTable[i] < 5) then
                            class = "red "
                        end
                        if BarFuelDisplay then
                            tankMessage = tankMessage..stringf([[
                                <g class="pdim">                        
                                <rect fill=grey class="bar" x="%d" y="%d" width="100" height="13"></rect></g>
                                <g class="bar txtstart">
                                <rect fill=%s width="%d" height="13" x="%d" y="%d"></rect>
                                <text fill=black x="%d" y="%d" style="stroke-width:0px;paint-order:normal;">%s%% %s</text>
                                </g>]], x, y2, color, fuelPercentTable[i], x, y2, x+2, y2+10, fuelPercentTable[i], fuelTimeDisplay
                            )
                            tankMessage = tankMessage..svgText(x, y1, name, class.."txtstart pdim txtfuel") 
                            y1 = y1 - 30
                            y2 = y2 - 30
                        else
                            tankMessage = tankMessage..svgText(x, y1, name, class.."pdim txtfuel") 
                            tankMessage = tankMessage..svgText( x, y2, stringf("%d%% %s", fuelPercentTable[i], fuelTimeDisplay), "pdim txtfuel","fill:"..color)
                            y1 = y1 + 30
                            y2 = y2 + 30
                        end
                    end
                end
            end
        end

        local function DrawVerticalSpeed(newContent, altitude) -- Draw vertical speed indicator - Code by lisa-lionheart
            if (altitude < 200000 and not inAtmo) or (altitude and inAtmo) then

                local angle = 0
                if mabs(vSpd) > 1 then
                    angle = 45 * math.log(mabs(vSpd), 10)
                    if vSpd < 0 then
                        angle = -angle
                    end
                end
                newContent[#newContent + 1] = stringf([[
                    <g class="pbright txt txtvspd" transform="translate(%d %d) scale(0.6)">
                            <text x="55" y="-41">1000</text>
                            <text x="10" y="-65">100</text>
                            <text x="-45" y="-45">10</text>
                            <text x="-73" y="3">O</text>
                            <text x="-45" y="52">-10</text>
                            <text x="10" y="72">-100</text>
                            <text x="55" y="50">-1000</text>
                            <text x="85" y="0" class="txtvspdval txtend">%d m/s</text>
                        <g class="linethick">
                            <path d="m-41 75 2.5-4.4m17 12 1.2-4.9m20 7.5v-10m-75-34 4.4-2.5m-12-17 4.9-1.2m17 40 7-7m-32-53h10m34-75 2.5 4.4m17-12 1.2 4.9m20-7.5v10m-75 34 4.4 2.5m-12 17 4.9 1.2m17-40 7 7m-32 53h10m116 75-2.5-4.4m-17 12-1.2-4.9m40-17-7-7m-12-128-2.5 4.4m-17-12-1.2 4.9m40 17-7 7"/>
                            <circle r="90" />
                        </g>
                        <path transform="rotate(%d)" d="m-0.094-7c-22 2.2-45 4.8-67 7 23 1.7 45 5.6 67 7 4.4-0.068 7.8-4.9 6.3-9.1-0.86-2.9-3.7-5-6.8-4.9z" />
                    </g>
                ]], vSpdMeterX, vSpdMeterY, mfloor(vSpd), mfloor(angle))
            end
            return newContent
        end

        local function getHeading(forward) -- code provided by tomisunlucky   
            local up = -worldVertical
            forward = forward - forward:project_on(up)
            local north = vec3(0, 0, 1)
            north = north - north:project_on(up)
            local east = north:cross(up)
            local angle = north:angle_between(forward) * constants.rad2deg
            if forward:dot(east) < 0 then
                angle = 360-angle
            end
            return angle
        end

        local function DrawRollLines (newContent, centerX, centerY, originalRoll, bottomText, nearPlanet)
            local horizonRadius = circleRad -- Aliased global
            local OFFSET = 20
            local rollC = mfloor(originalRoll)
            if nearPlanet then 
                for i = -45, 45, 5 do
                    local rot = i
                    newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,%d,%d)">]], rot, centerX, centerY)
                    len = 5
                    if (i % 15 == 0) then
                        len = 15
                    elseif (i % 10 == 0) then
                        len = 10
                    end
                    newContent[#newContent + 1] = stringf([[<line x1=%d y1=%d x2=%d y2="%d"/></g>]], centerX, centerY + horizonRadius + OFFSET - len, centerX, centerY + horizonRadius + OFFSET)
                end 
                newContent[#newContent + 1] = svgText(centerX, centerY+horizonRadius+OFFSET-35, bottomText, "pdim txt txtmid")
                newContent[#newContent + 1] = svgText(centerX, centerY+horizonRadius+OFFSET-25, rollC.." deg", "pdim txt txtmid")
                newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,%d,%d)">]], -originalRoll, centerX, centerY)
                newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/>]],
                    centerX-5, centerY+horizonRadius+OFFSET-20, centerX+5, centerY+horizonRadius+OFFSET-20, centerX, centerY+horizonRadius+OFFSET-15)
                newContent[#newContent +1] = "</g>"
            end
            local yaw = rollC
            if nearPlanet then yaw = getHeading(constructForward) end
            local range = 20
            local yawC = mfloor(yaw) 
            local yawlen = 0
            local yawy = (centerY + horizonRadius + OFFSET + 20)
            local yawx = centerX
            if bottomText ~= "YAW" then 
                yawy = ConvertResolutionY(130)
                yawx = ConvertResolutionX(960)
            end
            local tickerPath = [[<path class="txttick line" d="]]
            local degRange = mfloor(yawC - (range+10) - yawC % 5 + 0.5)
            for i = degRange+60, degRange, -5 do
                local x = yawx - (-i * 5 + yaw * 5)
                if (i % 10 == 0) then
                    yawlen = 10
                    local num = i
                    if num == 360 then 
                        num = 0
                    elseif num  > 360 then  
                        num = num - 360 
                    elseif num < 0 then
                        num = num + 360
                    end
                    newContent[#newContent + 1] = svgText(x+5,yawy-12, num )
                elseif (i % 5 == 0) then
                    yawlen = 5
                end
                if yawlen == 10 then
                    tickerPath = stringf([[%s M %f %f v %d]], tickerPath, x, yawy-5, yawlen)
                else
                    tickerPath = stringf([[%s M %f %f v %d]], tickerPath, x, yawy-2.5, yawlen)
                end
            end
            newContent[#newContent + 1] = tickerPath .. [["/>]]
            newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/>]],
                yawx-5, yawy+10, yawx+5, yawy+10, yawx, yawy+5)
            if nearPlanet then bottomText = "HDG" end
            newContent[#newContent + 1] = svgText(yawx, yawy+25, yawC.."deg" , "pdim txt txtmid", "")
            newContent[#newContent + 1] = svgText( yawx, yawy+35, bottomText, "pdim txt txtmid","")
        end

        local function DrawArtificialHorizon(newContent, originalPitch, originalRoll, centerX, centerY, nearPlanet, atmoYaw, speed)
            -- ** CIRCLE ALTIMETER  - Base Code from Discord @Rainsome = Youtube CaptainKilmar** 
            local horizonRadius = circleRad -- Aliased global
            local pitchX = mfloor(horizonRadius * 3 / 5)
            if horizonRadius > 0 then
                local pitchC = mfloor(originalPitch)
                local len = 0
                local tickerPath = stringf([[<path transform="rotate(%f,%d,%d)" class="dim line" d="]], (-1 * originalRoll), centerX, centerY)
                if not inAtmo then
                    tickerPath = stringf([[<path transform="rotate(0,%d,%d)" class="dim line" d="]], centerX, centerY)
                end
                newContent[#newContent + 1] = stringf([[<clipPath id="cut"><circle r="%f" cx="%d" cy="%d"/></clipPath>]],(horizonRadius - 1), centerX, centerY)
                newContent[#newContent + 1] = [[<g class="dim txttick" clip-path="url(#cut)">]]
                for i = mfloor(pitchC - 30 - pitchC % 5 + 0.5), mfloor(pitchC + 30 + pitchC % 5 + 0.5), 5 do
                    if (i % 10 == 0) then
                        len = 30
                    elseif (i % 5 == 0) then
                        len = 20
                    end
                    local y = centerY + (-i * 5 + originalPitch * 5)
                    if len == 30 then
                        tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX-pitchX-len, y, len)
                        if inAtmo then
                            newContent[#newContent + 1] = stringf([[<g path transform="rotate(%f,%d,%d)" class="pdim txt txtmid"><text x="%d" y="%f">%d</text></g>]],(-1 * originalRoll), centerX, centerY, centerX-pitchX+10, y+4, i)
                            newContent[#newContent + 1] = stringf([[<g path transform="rotate(%f,%d,%d)" class="pdim txt txtmid"><text x="%d" y="%f">%d</text></g>]],(-1 * originalRoll), centerX, centerY, centerX+pitchX-10, y+4, i)
                            if i == 0 or i == 180 or i == -180 then 
                                newContent[#newContent + 1] = stringf([[<path transform="rotate(%f,%d,%d)" d="m %d,%f %d,0" stroke-width="1" style="fill:none;stroke:#F5B800;" />]],
                                    (-1 * originalRoll), centerX, centerY, centerX-pitchX+20, y, pitchX*2-40)
                            end
                        else
                            newContent[#newContent + 1] = svgText(centerX-pitchX+10, y, i, "pdim txt txtmid")
                            newContent[#newContent + 1] = svgText(centerX+pitchX-10, y, i , "pdim txt txtmid")
                        end                            
                        tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX+pitchX, y, len)
                    else
                        tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX-pitchX-len, y, len)
                        tickerPath = stringf([[%s M %d %f h %d]], tickerPath, centerX+pitchX, y, len)
                    end
                end
                newContent[#newContent + 1] = tickerPath .. [["/>]]
                local pitchstring = "PITCH"                
                if not nearPlanet then 
                    pitchstring = "REL PITCH"
                end
                if originalPitch > 90 and not inAtmo then
                    originalPitch = 90 - (originalPitch - 90)
                elseif originalPitch < -90 and not inAtmo then
                    originalPitch = -90 - (originalPitch + 90)
                end
                if horizonRadius > 200 then
                    if inAtmo then
                        if speed > minAutopilotSpeed then
                            newContent[#newContent + 1] = svgText(centerX, centerY-15, "Yaw", "pdim txt txtmid")
                            newContent[#newContent + 1] = svgText(centerX, centerY+20, atmoYaw, "pdim txt txtmid")
                        end
                        newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,%d,%d)">]], -originalRoll, centerX, centerY)
                    else
                        newContent[#newContent + 1] = stringf([[<g transform="rotate(0,%d,%d)">]], centerX, centerY)
                    end
                    newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/> class="pdim txtend"><text x="%d" y="%f">%d</text>]],
                    centerX-pitchX+25, centerY-5, centerX-pitchX+20, centerY, centerX-pitchX+25, centerY+5, centerX-pitchX+50, centerY+4, pitchC)
                    newContent[#newContent + 1] = stringf([[<<polygon points="%d,%d %d,%d %d,%d"/> class="pdim txtend"><text x="%d" y="%f">%d</text>]],
                    centerX+pitchX-25, centerY-5, centerX+pitchX-20, centerY, centerX+pitchX-25, centerY+5, centerX+pitchX-30, centerY+4, pitchC)
                    newContent[#newContent +1] = "</g>"
                end
                local thirdHorizontal = mfloor(horizonRadius/3)
                newContent[#newContent + 1] = stringf([[<path d="m %d,%d %d,0" stroke-width="2" style="fill:none;stroke:#F5B800;" />]],
                    centerX-thirdHorizontal, centerY, horizonRadius-thirdHorizontal)
                if not inAtmo and nearPlanet then 
                    newContent[#newContent + 1] = stringf([[<path transform="rotate(%f,%d,%d)" d="m %d,%f %d,0" stroke-width="1" style="fill:none;stroke:#F5B800;" />]],
                        (-1 * originalRoll), centerX, centerY, centerX-pitchX+10, centerY, pitchX*2-20)
                end
                newContent[#newContent + 1] = "</g>"
                if horizonRadius < 200 then
                    if inAtmo and speed > minAutopilotSpeed then 
                        newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius, pitchstring, "pdim txt txtmid")
                        newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius+10, pitchC, "pdim txt txtmid")
                        newContent[#newContent + 1] = svgText(centerX, centerY-15, "Yaw", "pdim txt txtmid")
                        newContent[#newContent + 1] = svgText(centerX, centerY+20, atmoYaw, "pdim txt txtmid")
                    else
                        newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius, pitchstring, "pdim txt txtmid")
                        newContent[#newContent + 1] = svgText(centerX, centerY-horizonRadius+15, pitchC, "pdim txt txtmid")
                    end
                end
            end
        end

        local function DrawAltitudeDisplay(newContent, altitude, nearPlanet)
            local rectX = altMeterX
            local rectY = altMeterY
            local rectW = 78
            local rectH = 19
        
            local gndHeight = abvGndDet

            if abvGndDet ~= -1 then
                newContent[#newContent + 1] = svgText(rectX+rectW, rectY+rectH+20, stringf("AGL: %.1fm", abvGndDet), "pdim altsm txtend")
            end

            if nearPlanet and ((altitude < 200000 and not inAtmo) or (altitude and inAtmo)) then
                table.insert(newContent, stringf([[
                    <g class="pdim">                        
                        <rect class="line" x="%d" y="%d" width="%d" height="%d"/> 
                        <clipPath id="alt"><rect class="line" x="%d" y="%d" width="%d" height="%d"/></clipPath>
                        <g clip-path="url(#alt)">]], 
                        rectX - 1, rectY - 4, rectW + 2, rectH + 6,
                        rectX + 1, rectY - 1, rectW - 4, rectH))
                local index = 0
                local divisor = 1
                local forwardFract = 0
                local isNegative = altitude < 0

                local isLand = altitude < planet.surfaceMaxAltitude

                local rolloverDigit = 9
                if isNegative then
                    rolloverDigit = 0
                end

                local altitude = mabs(altitude)
                while index < 6 do
                    local glyphW = 11
                    local glyphH = 16
                    local glyphXOffset = 9
                    local glyphYOffset = 14
                    local class = "altsm"
        
                    if index > 2 then
                        glyphH = glyphH + 3
                        glyphW = glyphW + 2
                        glyphYOffset = glyphYOffset + 2
                        glyphXOffset = glyphXOffset - 6
                        class = "altbig"
                    end
        
                    if isNegative then  
                        class = class .. " red"
                    elseif isLand then
                        class = class .. " orange"
                    end
        
                    local digit = (altitude / divisor) % 10
                    local intDigit = mfloor(digit)
                    local fracDigit = mfloor((intDigit + 1) % 10)
        
                    local fract = forwardFract
                    if index == 0 then
                        fract = digit - intDigit
                        if isNegative then
                            fract = 1 - fract
                        end
                    end

                    if isNegative and (index == 0 or forwardFract ~= 0) then
                        local temp = fracDigit
                        fracDigit = intDigit
                        intDigit = temp
                    end
        
                    local topGlyphOffset = glyphH * (fract - 1) 
                    local botGlyphOffset = topGlyphOffset + glyphH
        
                    local x = rectX + glyphXOffset + (6 - index) * glyphW
                    local y = rectY + glyphYOffset
                    
                    newContent[#newContent + 1] = svgText(x, y + topGlyphOffset,fracDigit, class)
                    newContent[#newContent + 1] = svgText(x, y + botGlyphOffset,intDigit , class)

                    index = index + 1
                    divisor = divisor * 10
                    if intDigit == rolloverDigit then
                        forwardFract = fract
                    else
                        forwardFract = 0
                    end
                end
                table.insert(newContent, [[</g></g>]])
            end
        end

        local function getRelativePitch(velocity)
            local pitch = -math.deg(atan(velocity.y, velocity.z)) + 180
            -- This is 0-360 where 0 is straight up
            pitch = pitch - 90
            -- So now 0 is straight, but we can now get angles up to 420
            if pitch < 0 then
                pitch = 360 + pitch
            end
            -- Now, if it's greater than 180, say 190, make it go to like -170
            if pitch > 180 then
                pitch = -180 + (pitch - 180)
            end
            -- And it's backwards.  
            return -pitch
        end

        local function getRelativeYaw(velocity)
            local yaw = math.deg(atan(velocity.y, velocity.x)) - 90
            if yaw < -180 then
                yaw = 360 + yaw
            end
            return yaw
        end    

        local function DrawPrograde (newContent, velocity, speed, centerX, centerY)
            if (speed > 5 and not inAtmo) or (speed > minAutopilotSpeed) then
                local horizonRadius = circleRad -- Aliased global
                local pitchRange = 20
                local yawRange = 20
                local relativePitch = getRelativePitch(velocity)
                local relativeYaw = getRelativeYaw(velocity)
        
                local dotSize = 14
                local dotRadius = dotSize/2
                
                local dx = (-relativeYaw/yawRange)*horizonRadius -- Values from -1 to 1 indicating offset from the center
                local dy = (relativePitch/pitchRange)*horizonRadius
                local x = centerX + dx
                local y = centerY + dy
        
                local distance = msqrt((dx)^2 + (dy)^2)
        
                local progradeDot = [[<circle
                cx="]] .. x .. [["
                cy="]] .. y .. [["
                r="]] .. dotRadius/dotSize .. [["
                style="fill:#d7fe00;stroke:none;fill-opacity:1"/>
            <circle
                cx="]] .. x .. [["
                cy="]] .. y .. [["
                r="]] .. dotRadius .. [["
                style="stroke:#d7fe00;stroke-opacity:1;fill:none" />
            <path
                d="M ]] .. x-dotSize .. [[,]] .. y .. [[ h ]] .. dotRadius .. [["
                style="stroke:#d7fe00;stroke-opacity:1" />
            <path
                d="M ]] .. x+dotRadius .. [[,]] .. y .. [[ h ]] .. dotRadius .. [["
                style="stroke:#d7fe00;stroke-opacity:1" />
            <path
                d="M ]] .. x .. [[,]] .. y-dotSize .. [[ v ]] .. dotRadius .. [["
                style="stroke:#d7fe00;stroke-opacity:1" />]]
                    
                if distance < horizonRadius then
                    newContent[#newContent + 1] = progradeDot
                    -- Draw a dot or whatever at x,y, it's inside the AH
                else
                    -- x,y is outside the AH.  Figure out how to draw an arrow on the edge of the circle pointing to it.
                    -- First get the angle
                    -- tan(ang) = o/a, tan(ang) = x/y
                    -- atan(x/y) = ang (in radians)
                    -- This is a special overload for doing this on a circle and setting up the signs correctly for the quadrants
                    local angle = atan(dy,dx)
                    -- Project this onto the circle
                    -- These are backwards from what they're supposed to be.  Don't know why, that's just what makes it work apparently
                    local arrowSize = 4
                    local projectedX = centerX + (horizonRadius)*math.cos(angle) -- Needs to be converted to deg?  Probably not
                    local projectedY = centerY + (horizonRadius)*math.sin(angle)
                    -- Draw an arrow that we will rotate by angle
                    -- Convert angle to degrees
                    newContent[#newContent + 1] = stringf('<g transform="rotate(%f %f %f)"><rect x="%f" y="%f" width="%f" height="%f" stroke="#d7fe00" fill="#d7fe00" /><path d="M %f %f l %f %f l %f %f z" fill="#d7fe00" stroke="#d7fe00"></g>', angle*(180/math.pi), projectedX, projectedY, projectedX-arrowSize, projectedY-arrowSize/2, arrowSize*2, arrowSize,
                                                                                                                                                        projectedX+arrowSize, projectedY - arrowSize, arrowSize, arrowSize, -arrowSize, arrowSize)
        
                    --newContent[#newContent + 1] = stringf('<circle cx="%f" cy="%f" r="2" stroke="white" stroke-width="2" fill="white" />', projectedX, projectedY)
                end
        
                if(not inAtmo) then
                    local velo = vec3(velocity)
                    relativePitch = getRelativePitch(-velo)
                    relativeYaw = getRelativeYaw(-velo)
                    
                    dx = (-relativeYaw/yawRange)*horizonRadius -- Values from -1 to 1 indicating offset from the center
                    dy = (relativePitch/pitchRange)*horizonRadius
                    x = centerX + dx
                    y = centerY + dy
        
                    distance = msqrt((dx)^2 + (dy)^2)
                    -- Retrograde Dot
                    
                    if distance < horizonRadius then
                        local retrogradeDot = [[<circle
                        cx="]] .. x .. [["
                        cy="]] .. y .. [["
                        r="]] .. dotRadius .. [["
                        style="stroke:#d7fe00;stroke-opacity:1;fill:none" />
                    <path
                        d="M ]] .. x .. [[,]] .. y-dotSize .. [[ v ]] .. dotRadius .. [["
                        style="stroke:#d7fe00;stroke-opacity:1" id="l"/>
                    <use
                        xlink:href="#l"
                        transform="rotate(120,]] .. x .. [[,]] .. y .. [[)" />
                    <use
                        xlink:href="#l"
                        transform="rotate(-120,]] .. x .. [[,]] .. y .. [[)" />
                    <path
                        d="M ]] .. x-dotRadius .. [[,]] .. y .. [[ h ]] .. dotSize .. [["
                        style="stroke-width:0.5;stroke:#d7fe00;stroke-opacity:1"
                        transform="rotate(-45,]] .. x .. [[,]] .. y .. [[)" id="c"/>
                    <use
                        xlink:href="#c"
                        transform="rotate(-90,]] .. x .. [[,]] .. y .. [[)"/>]]
                        newContent[#newContent + 1] = retrogradeDot
                        -- Draw a dot or whatever at x,y, it's inside the AH
                    end -- Don't draw an arrow for this one, only prograde is that important
        
                end
            end
        end

        local function DrawThrottle(newContent, flightStyle, throt, flightValue)
            throt = mfloor(throt+0.5) -- Hard-round it to an int
            local y1 = throtPosY+10
            local y2 = throtPosY+20
            if isRemote() == 1 and not RemoteHud then
                y1 = 55
                y2 = 65
            end            
            local label = "CRUISE"
            local unit = "km/h"
            local value = flightValue
            if (flightStyle == "TRAVEL" or flightStyle == "AUTOPILOT") then
                label = "THROT"
                unit = "%"
                value = throt
                local throtclass = "dim"
                if throt < 0 then
                    throtclass = "red"
                end
                newContent[#newContent + 1] = stringf([[<g class="%s">
                    <path class="linethick" d="M %d %d L %d %d L %d %d L %d %d"/>
                    <g transform="translate(0 %.0f)">
                        <polygon points="%d,%d %d,%d %d,%d"/>
                    </g>]], throtclass, throtPosX-7, throtPosY-50, throtPosX, throtPosY-50, throtPosX, throtPosY+50, throtPosX-7, throtPosY+50, (1 - mabs(throt)), 
                    throtPosX-10, throtPosY+50, throtPosX-15, throtPosY+53, throtPosX-15, throtPosY+47)
            end
            newContent[#newContent + 1] = svgText(throtPosX+10, y1, label , "pbright txtstart")
            newContent[#newContent + 1] = svgText(throtPosX+10, y2, stringf("%.0f %s", value, unit), "pbright txtstart")
            if inAtmo and AtmoSpeedAssist and throttleMode and ThrottleLimited then
                -- Display a marker for where the AP throttle is putting it, calculatedThrottle
        
                throt = mfloor(calculatedThrottle*100+0.5)
                local throtclass = "red"
                if throt < 0 then
                    throtclass = "red" -- TODO
                end
                newContent[#newContent + 1] = stringf([[<g class="%s">
                    <g transform="translate(0 %d)">
                        <polygon points="%d,%d %d,%d %d,%d"/>
                    </g></g>]], throtclass, (1 - mabs(throt)), 
                    throtPosX-10, throtPosY+50, throtPosX-15, throtPosY+53, throtPosX-15, throtPosY+47)
                newContent[#newContent + 1] = svgText( throtPosX+10, y1+40, "LIMIT", "pbright txtstart")
                newContent[#newContent + 1] = svgText(throtPosX+10, y2+40, throt.."%", "pbright txtstart")
            end
            if (inAtmo and AtmoSpeedAssist) or Reentry then
                -- Display AtmoSpeedLimit above the throttle
                newContent[#newContent + 1] = svgText(throtPosX+10, y1-40, "LIMIT: ".. adjustedAtmoSpeedLimit .. " km/h", "dim txtstart")
            elseif not inAtmo and Autopilot then
                -- Display MaxGameVelocity above the throttle
                newContent[#newContent + 1] = svgText(throtPosX+10, y1-40, "LIMIT: ".. mfloor(MaxGameVelocity*3.6+0.5) .. " km/h", "dim txtstart")
            end
        end

        local function DrawSpeed(newContent, spd)
            local ys = throtPosY-10 
            local x1 = throtPosX + 10
            newContent[#newContent + 1] = svgText(0,0,"", "pdim txt txtend")
            if isRemote() == 1 and not RemoteHud then
                ys = 75
            end
            newContent[#newContent + 1] = svgText( x1, ys, mfloor(spd).." km/h" , "pbright txtbig txtstart")
        end

        local function DrawWarnings(newContent)

            newContent[#newContent + 1] = svgText(ConvertResolutionX(1900), ConvertResolutionY(1070), stringf("ARCH Hud Version: %.3f", VERSION_NUMBER), "hudver")
            newContent[#newContent + 1] = [[<g class="warnings">]]
            if unit.isMouseControlActivated() == 1 then
                newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(550), "Warning: Invalid Control Scheme Detected", "warnings")
                newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(600), "Keyboard Scheme must be selected", "warnings")
                newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(650), "Set your preferred scheme in Lua Parameters instead", "warnings")
            end
            local warningX = ConvertResolutionX(960)
            local brakeY = ConvertResolutionY(860)
            local gearY = ConvertResolutionY(880)
            local hoverY = ConvertResolutionY(900)
            local ewarpY = ConvertResolutionY(960)
            local apY = ConvertResolutionY(200)
            local turnBurnY = ConvertResolutionY(250)
            local gyroY = ConvertResolutionY(960)
            if isRemote() == 1 and not RemoteHud then
                brakeY = ConvertResolutionY(135)
                gearY = ConvertResolutionY(155)
                hoverY = ConvertResolutionY(175)
                apY = ConvertResolutionY(115)
                turnBurnY = ConvertResolutionY(95)
            end
            if BrakeIsOn then
                newContent[#newContent + 1] = svgText(warningX, brakeY, "Brake Engaged", "warnings")

            elseif brakeInput2 > 0 then
                newContent[#newContent + 1] = svgText(warningX, brakeY, "Auto-Brake Engaged", "warnings", "opacity:"..brakeInput2)
            end
            if inAtmo and stalling and abvGndDet == -1 then
                if not Autopilot and not VectorToTarget and not BrakeLanding and not antigravOn and not VertTakeOff and not AutoTakeoff then
                    newContent[#newContent + 1] = svgText(warningX, apY+50, "** STALL WARNING **", "warnings")
                    play("stall","SW",2)
                end
            end
            if ReversalIsOn then
                newContent[#newContent + 1] = svgText(warningX, apY+90, "Flight Assist in Progress", "warnings")
            end

            if gyroIsOn then
                newContent[#newContent + 1] = svgText(warningX, gyroY, "Gyro Enabled", "warnings")
            end
            if GearExtended then
                if hasGear then
                    newContent[#newContent + 1] = svgText(warningX, gearY, "Gear Extended", "warn")
                else
                    newContent[#newContent + 1] = svgText(warningX, gearY, "Landed (G: Takeoff)", "warnings")
                end
                local displayText = getDistanceDisplayString(Nav:getTargetGroundAltitude())
                newContent[#newContent + 1] = svgText(warningX, hoverY,"Hover Height: ".. displayText,"warn")
            end
            if isBoosting then
                newContent[#newContent + 1] = svgText(warningX, ewarpY+20, "ROCKET BOOST ENABLED", "warn")
            end                  
            if antigrav and not ExternalAGG and antigravOn and AntigravTargetAltitude ~= nil then
                if mabs(coreAltitude - antigrav.getBaseAltitude()) < 501 then
                    newContent[#newContent + 1] = svgText(warningX, apY+15, stringf("AGG On - Target Altitude: %d Singularity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), "warn")
                else
                    newContent[#newContent + 1] = svgText( warningX, apY+15, stringf("AGG On - Target Altitude: %d Singluarity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), "warnings")
                end
            elseif Autopilot and AutopilotTargetName ~= "None" then
                newContent[#newContent + 1] = svgText(warningX, apY+20,  "Autopilot "..AutopilotStatus, "warn")
            elseif LockPitch ~= nil then
                newContent[#newContent + 1] = svgText(warningX, apY+20, stringf("LockedPitch: %d", mfloor(LockPitch)), "warn")
            elseif followMode then
                newContent[#newContent + 1] = svgText(warningX, apY+20, "Follow Mode Engaged", "warn")
            elseif Reentry or finalLand then
                newContent[#newContent + 1] = svgText(warningX, apY+20, "Re-entry in Progress", "warn")
            end
            if AltitudeHold or VertTakeOff then
                local displayText = getDistanceDisplayString(HoldAltitude, 2)
                if VertTakeOff then
                    if antigravOn then
                        displayText = getDistanceDisplayString(antigrav.getBaseAltitude(),2).." AGG singularity height"
                    end
                    newContent[#newContent + 1] = svgText(warningX, apY, "VTO to "..displayText , "warn")
                elseif AutoTakeoff and not IntoOrbit then
                    if spaceLaunch then
                        newContent[#newContent + 1] = svgText(warningX, apY, "Takeoff to "..AutopilotTargetName, "warn")
                    else
                        newContent[#newContent + 1] = svgText(warningX, apY, "Takeoff to "..displayText, "warn")
                    end
                    if BrakeIsOn and not VertTakeOff then
                        newContent[#newContent + 1] = svgText( warningX, apY + 50,"Throttle Up and Disengage Brake For Takeoff", "crit")
                    end
                else
                    newContent[#newContent + 1] = svgText(warningX, apY, "Altitude Hold: ".. displayText, "warn")
                end
            end
            if VertTakeOff and (antigrav ~= nil and antigrav) then
                if atmosDensity > 0.1 then
                    newContent[#newContent + 1] = svgText(warningX, apY+20, "Beginning ascent", "warn")
                elseif atmosDensity < 0.09 and atmosDensity > 0.05 then
                    newContent[#newContent + 1] = svgText(warningX, apY+20,  "Aligning trajectory", "warn")
                elseif atmosDensity < 0.05 then
                    newContent[#newContent + 1] = svgText(warningX, apY+20,  "Leaving atmosphere", "warn")
                end
            end
            if IntoOrbit then
                if orbitMsg ~= nil then
                    newContent[#newContent + 1] = svgText(warningX, apY, orbitMsg, "warn")
                end
            end
            if BrakeLanding then
                if StrongBrakes then
                    newContent[#newContent + 1] = svgText(warningX, apY, "Brake-Landing", "warnings")
                else
                    newContent[#newContent + 1] = svgText(warningX, apY, "Coast-Landing", "warnings")
                end
            end
            if ProgradeIsOn then
                newContent[#newContent + 1] = svgText(warningX, apY, "Prograde Alignment", "crit")
            end
            if RetrogradeIsOn then
                newContent[#newContent + 1] = svgText(warningX, apY, "Retrograde Alignment", "crit")
            end
            if collisionAlertStatus then
                local type
                if string.find(collisionAlertStatus, "COLLISION") then type = "warnings" else type = "crit" end
                newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, collisionAlertStatus, type)
            elseif atmosDensity == 0 then
                local intersectBody, atmoDistance = checkLOS((constructVelocity):normalize())
                if atmoDistance ~= nil then
                    local displayText = getDistanceDisplayString(atmoDistance)
                    local travelTime = Kinematic.computeTravelTime(velMag, 0, atmoDistance)
                    local displayCollisionType = "Collision"
                    if intersectBody.noAtmosphericDensityAltitude > 0 then displayCollisionType = "Atmosphere" end
                    newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, intersectBody.name.." "..displayCollisionType.." "..FormatTimeString(travelTime).." In "..displayText, "crit")
                end
            end
            if VectorToTarget and not IntoOrbit then
                newContent[#newContent + 1] = svgText(warningX, apY+35, VectorStatus, "warn")
            end
        
            newContent[#newContent + 1] = "</g>"
            return newContent
        end

        local function getSpeedDisplayString(speed) -- TODO: Allow options, for now just do kph
            return mfloor(round(speed * 3.6, 0) + 0.5) .. " km/h" -- And generally it's not accurate enough to not twitch unless we round 0
        end
        
        local function DisplayOrbitScreen(newContent)
            local orbitMapX = OrbitMapX
            local orbitMapY = OrbitMapY
            local orbitMapSize = OrbitMapSize -- Always square
            local pad = 4

            local orbitInfoYOffset = 15
            local x = 0
            local y = 0
            local rx, ry, scale, xOffset

            local function orbitInfo(type)
                local alt, time, speed, line
                if type == "Periapsis" then
                    alt = orbit.periapsis.altitude
                    time = orbit.timeToPeriapsis
                    speed = orbit.periapsis.speed
                    line = 35
                else
                    alt = orbit.apoapsis.altitude
                    time = orbit.timeToApoapsis
                    speed = orbit.apoapsis.speed
                    line = -35
                end
                newContent[#newContent + 1] = stringf(
                    [[<line class="pdim op30 linethick" x1="%f" y1="%f" x2="%f" y2="%f"/>]],
                    x + line, y - 5, orbitMapX + orbitMapSize / 2 - rx + xOffset, y - 5)
                newContent[#newContent + 1] = svgText(x, y, type)
                y = y + orbitInfoYOffset
                local displayText = getDistanceDisplayString(alt)
                newContent[#newContent + 1] = svgText(x, y, displayText)
                y = y + orbitInfoYOffset
                newContent[#newContent + 1] = svgText(x, y, FormatTimeString(time))
                y = y + orbitInfoYOffset
                newContent[#newContent + 1] = svgText(x, y, getSpeedDisplayString(speed))
            end

            if orbit ~= nil and atmosDensity < 0.2 and planet ~= nil and orbit.apoapsis ~= nil and
                orbit.periapsis ~= nil and orbit.period ~= nil and orbit.apoapsis.speed > 5 and DisplayOrbit then
                -- If orbits are up, let's try drawing a mockup
                
                orbitMapY = orbitMapY + pad
                x = orbitMapX + orbitMapSize + orbitMapX / 2 + pad
                y = orbitMapY + orbitMapSize / 2 + 5 + pad
                rx = orbitMapSize / 4
                xOffset = 0
        
                newContent[#newContent + 1] = [[<g class="pbright txtorb txtmid">]]
                -- Draw a darkened box around it to keep it visible
                newContent[#newContent + 1] = stringf(
                                                '<rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" style="fill:rgb(0,0,100);stroke-width:4;stroke:white;fill-opacity:0.3;" />',
                                                orbitMapSize + orbitMapX * 2, orbitMapSize + orbitMapY, pad, pad)
        
                if orbit.periapsis ~= nil and orbit.apoapsis ~= nil then
                    scale = (orbit.apoapsis.altitude + orbit.periapsis.altitude + planet.radius * 2) / (rx * 2)
                    ry = (planet.radius + orbit.periapsis.altitude +
                            (orbit.apoapsis.altitude - orbit.periapsis.altitude) / 2) / scale *
                            (1 - orbit.eccentricity)
                    xOffset = rx - orbit.periapsis.altitude / scale - planet.radius / scale
        
                    local ellipseColor = ""
                    if orbit.periapsis.altitude <= 0 then
                        ellipseColor = 'redout'
                    end
                    newContent[#newContent + 1] = stringf(
                                                    [[<ellipse class="%s line" cx="%f" cy="%f" rx="%f" ry="%f"/>]],
                                                    ellipseColor, orbitMapX + orbitMapSize / 2 + xOffset + pad,
                                                    orbitMapY + orbitMapSize / 2 + pad, rx, ry)
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="%f" stroke="white" stroke-width="3" fill="blue" />',
                                                    orbitMapX + orbitMapSize / 2 + pad,
                                                    orbitMapY + orbitMapSize / 2 + pad, planet.radius / scale)
                end
        
                if orbit.apoapsis ~= nil and orbit.apoapsis.speed < MaxGameVelocity and orbit.apoapsis.speed > 1 then
                    orbitInfo("Apoapsis")
                end
        
                y = orbitMapY + orbitMapSize / 2 + 5 + pad
                x = orbitMapX - orbitMapX / 2 + 10 + pad
        
                if orbit.periapsis ~= nil and orbit.periapsis.speed < MaxGameVelocity and orbit.periapsis.speed > 1 then
                    orbitInfo("Periapsis")
                end
        
                -- Add a label for the planet
                newContent[#newContent + 1] = svgText(orbitMapX + orbitMapSize / 2 + pad, planet.name, 20 + pad, "txtorbbig")
        
                if orbit.period ~= nil and orbit.periapsis ~= nil and orbit.apoapsis ~= nil and orbit.apoapsis.speed > 1 then
                    local apsisRatio = (orbit.timeToApoapsis / orbit.period) * 2 * math.pi
                    -- x = xr * cos(t)
                    -- y = yr * sin(t)
                    local shipX = rx * math.cos(apsisRatio)
                    local shipY = ry * math.sin(apsisRatio)
        
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="5" stroke="white" stroke-width="3" fill="white" />',
                                                    orbitMapX + orbitMapSize / 2 + shipX + xOffset + pad,
                                                    orbitMapY + orbitMapSize / 2 + shipY + pad)
                end
        
                newContent[#newContent + 1] = [[</g>]]
                -- Once we have all that, we should probably rotate the entire thing so that the ship is always at the bottom so you can see AP and PE move?
                return newContent
            else
                return newContent
            end
        end
    
        local function DisplayHelp(newContent)
            local x = 30
            local y = 275
            local help = {}
            local helpAtmoGround = {"Alt-4: AutoTakeoff to Target"}
            local helpAtmoAir = { "Alt-6: Altitude hold at current altitude", "Alt-6-6: Altitude Hold at 11% atmosphere", 
                                "Alt-Q/E: Hard Bankroll left/right till released", "Alt-S: 180 deg bank turn"}
            local helpSpace = {"Alt-6: Orbit at current altitude", "Alt-6-6: Orbit at LowOrbitHeight over atmosphere"}
            local helpGeneral = {"", "------------------ALWAYS--------------------", "Alt-1: Increment Interplanetary Helper", "Alt-2: Decrement Interplanetary Helper", "Alt-3: Toggle Vanilla Widget view", 
                                "Alt-4: Autopilot to IPH target", "Alt-5: Lock Pitch at current pitch","Alt-7: Toggle Collision System on and off", "Alt-8: Toggle ground stabilization (underwater flight)",
                                "CTRL: Toggle Brakes on and off. Cancels active AP", "LAlt: Tap to shift freelook on and off", 
                                "Shift: Hold while not in freelook to see Buttons", "Type /commands or /help in lua chat to see text commands"}
            table.insert(help, "--------------DYNAMIC-----------------")
            if inAtmo then 
                if abvGndDet ~= -1 then
                    addTable(help, helpAtmoGround)
                    if autopilotTargetPlanet and planet and autopilotTargetPlanet.name == planet.name then
                        table.insert(help,"Alt-4-4: Low Orbit Autopilot to Target")
                    end
                    if antigrav or VertTakeOffEngine then 
                        if antigrav then
                            if antigravOn then
                                table.insert(help, "Alt-6: AGG is on, will takeoff to AGG Height")
                            else
                                table.insert(help,  "Turn on AGG to takeoff to AGG Height")
                            end
                        end
                        if VertTakeOffEngine then 
                            table.insert(help, "Alt-6: Begins Vertical AutoTakeoff.")
                        end
                    else
                        table.insert(help, "Alt-6: Autotakeoff to AutoTakeoffAltitude")
                        table.insert(help, "Alt-6-6: Autotakeoff to 11% atmosphere")
                    end
                    if GearExtended then
                        table.insert(help,"G: Takeoff to hover height, raise gear")
                    else
                        table.insert(help,"G: Lowergear and Land")
                    end
                else
                    addTable(help,helpAtmoAir)
                    table.insert(help,"G: Begin BrakeLanding or Land")
                end
                if VertTakeOff then
                    table.insert(help,"Hit Alt-6 before exiting Atmosphere during VTO to hold in level flight")
                end
            else
                addTable(help, helpSpace)
                if shield_1 then
                    table.insert(help,"Alt-Shift-5: Toggle shield off and on")
                    table.insert(help,"Alt-Shift-6: Vent shields")
                end
            end
            if gyro then
                table.insert(help,"Alt-9: Activate Gyroscope")
            end
            if ExtraLateralTags ~= "none" or ExtraLongitudeTags ~= "none" or ExtraVerticalTags ~= "none" then
                table.insert(help, "Alt-Shift-9: Cycles engines with Extra tags")
            end
            if AltitudeHold then 
                table.insert(help, "Alt-Spacebar/C will raise/lower target height")
                table.insert(help, "Alt+Shift+Spacebar/C will raise/lower target to preset values")
            end
            if AtmoSpeedAssist or not inAtmo then
                table.insert(help,"LALT+Mousewheel will lower/raise speed limit")
            end
            addTable(help, helpGeneral)
            for i = 1, #help do
                y=y+12
                newContent[#newContent + 1] = svgText( x, y, help[i], "pdim txttick txtstart")
            end
        end

        local function getPipeDistance(origCenter, destCenter)  -- Many thanks to Tiramon for the idea and functionality.
            local pipeDistance
            local pipe = (destCenter - origCenter):normalize()
            local r = (worldPos -origCenter):dot(pipe) / pipe:dot(pipe)
            if r <= 0. then
            return (worldPos-origCenter):len()
            elseif r >= (destCenter - origCenter):len() then
            return (worldPos-destCenter):len()
            end
            local L = origCenter + (r * pipe)
            pipeDistance =  (L - worldPos):len()
            return pipeDistance
        end

        local function getClosestPipe() -- Many thanks to Tiramon for the idea and functionality, thanks to Dimencia for the assist
            local pipeDistance
            local nearestDistance = nil
            local nearestPipePlanet = nil
            local pipeOriginPlanet = nil
            for k,nextPlanet in pairs(atlas[0]) do
                if nextPlanet.hasAtmosphere then -- Skip moons
                    local distance = getPipeDistance(planet.center, nextPlanet.center)
                    if nearestDistance == nil or distance < nearestDistance then
                        nearestPipePlanet = nextPlanet
                        nearestDistance = distance
                        pipeOriginPlanet = planet
                    end
                    if autopilotTargetPlanet and autopilotTargetPlanet.hasAtmosphere and autopilotTargetPlanet.name ~= planet.name then 
                        local distance2 = getPipeDistance(autopilotTargetPlanet.center, nextPlanet.center)
                        if distance2 < nearestDistance then
                            nearestPipePlanet = nextPlanet
                            nearestDistance = distance2
                            pipeOriginPlanet = autopilotTargetPlanet
                        end
                    end
                end
            end 
            local pipeX = ConvertResolutionX(1770)
            local pipeY = ConvertResolutionY(330)
            if nearestDistance then
                local txtadd = "txttick "
                local fudge = 500000
                if nearestDistance < nearestPipePlanet.radius+fudge or nearestDistance < pipeOriginPlanet.radius+fudge then 
                    if notPvPZone then txtadd = "txttick red " else txtadd = "txttick orange " end
                end
                pipeDistance = getDistanceDisplayString(nearestDistance,2)
                pipeMessage = svgText(pipeX, pipeY, "Pipe ("..pipeOriginPlanet.name.."--"..nearestPipePlanet.name.."): "..pipeDistance, txtadd.."pbright txtmid") 
            end
        end

        local function MakeButton(enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition, buttonList)
            local newButton = {
                enableName = enableName,
                disableName = disableName,
                width = width,
                height = height,
                x = x,
                y = y,
                toggleVar = toggleVar,
                toggleFunction = toggleFunction,
                drawCondition = drawCondition,
                hovered = false
            }
            if buttonList then 
                table.insert(SettingButtons, newButton)
            else
                table.insert(ControlButtons, newButton)
            end
            return newButton -- readonly, I don't think it will be saved if we change these?  Maybe.
            
        end

        local function ToggleShownSettings(whichVar)
            if not showSettings then
                showHandlingVariables = false
                showHudVariables = false
                showPhysicsVariables = false
                showHud = true
                return
            elseif whichVar == "handling" then
                showHandlingVariables = not showHandlingVariables
                showHudVariables = false
                showPhysicsVariables = false
            elseif whichVar == "hud" then 
                showHudVariables = not showHudVariables
                showHandlingVariables = false
                showPhysicsVariables = false
            elseif whichVar == "physics" then
                showPhysicsVariables = not showPhysicsVariables
                showHandlingVariables = false
                showHudVariables = false
            end
            if showPhysicsVariables or showHudVariables or showHandlingVariables then 
                settingsVariables = saveableVariables(whichVar)
                showHud = false 
            else
                settingsVariables = {}
                showHud = true
            end
        end

        local function ToggleButtons()
            showSettings = not showSettings 
            if showSettings then 
                Buttons = SettingButtons
                msgText = "Hold SHIFT to see Settings" 
                oldShowHud = showHud
            else
                Buttons = ControlButtons
                msgText = "Hold SHIFT to see Control Buttons"
                ToggleShownSettings()
                showHud = oldShowHud
            end
        end

        local function SettingsButtons()
            local function ToggleBoolean(v)

                _G[v] = not _G[v]
                if _G[v] then 
                    msgText = v.." set to true"
                else
                    msgText = v.." set to false"
                end
                if v == "showHud" then
                    oldShowHud = _G[v]
                elseif v == "BrakeToggleDefault" then 
                    BrakeToggleStatus = BrakeToggleDefault
                end
            end
            local buttonHeight = 50
            local buttonWidth = 340 -- Defaults
            local x = 500
            local y = resolutionHeight / 2 - 400
            local cnt = 0
            for k, v in pairs(saveableVariables("boolean")) do
                if type(_G[v]) == "boolean" then
                    MakeButton(v, v, buttonWidth, buttonHeight, x, y,
                        function() return _G[v] end, 
                        function() ToggleBoolean(v) end,
                        function() return true end, true) 
                    y = y + buttonHeight + 20
                    if cnt == 9 then 
                        x = x + buttonWidth + 20 
                        y = resolutionHeight / 2 - 400
                        cnt = 0
                    else
                        cnt = cnt + 1
                    end
                end
            end
            MakeButton("Control View", "Control View", buttonWidth, buttonHeight, 10, resolutionHeight / 2 - 500, function() return true end, 
                ToggleButtons, function() return true end, true)
            MakeButton("View Handling Settings", 'Hide Handling Settings', buttonWidth, buttonHeight, 10, resolutionHeight / 2 - (500 - buttonHeight), 
                function() return showHandlingVariables end, function() ToggleShownSettings("handling") end, 
                function() return true end, true)
            MakeButton("View Hud Settings", 'Hide Hud Settings', buttonWidth, buttonHeight, 10, resolutionHeight / 2 - (500 - buttonHeight*2), 
                function() return showHudVariables end, function() ToggleShownSettings("hud") end, 
                function() return true end, true)
            MakeButton("View Physics Settings", 'Hide Physics Settings', buttonWidth, buttonHeight, 10, resolutionHeight / 2 - (500 - buttonHeight*3), 
                function() return showPhysicsVariables end, function() ToggleShownSettings("physics") end, 
                function() return true end, true)
        end
        
        local function ControlsButtons()
            local function AddNewLocation()
                -- Add a new location to SavedLocations
                local position = worldPos
                local name = planet.name .. ". " .. #SavedLocations
                if radars[1] then -- Just match the first one
                    local id,_ = radars[1].getData():match('"constructId":"([0-9]*)","distance":([%d%.]*)')
                    if id ~= nil and id ~= "" then
                        name = name .. " " .. radars[1].getConstructName(id)
                    end
                end
                
                return ATLAS.AddNewLocation(name, position, false, true)
                
            end
            
            local function ToggleTurnBurn()
                TurnBurn = not TurnBurn
            end

            local function gradeToggle(pro)
                if pro == 1 then 
                    ProgradeIsOn = not ProgradeIsOn
                    RetrogradeIsOn = false
                else
                    RetrogradeIsOn = not RetrogradeIsOn
                    ProgradeIsOn = false
                end        
                Autopilot = false
                AltitudeHold = false
                followMode = false
                BrakeLanding = false
                LockPitch = nil
                Reentry = false
                AutoTakeoff = false
            end

            local function UpdatePosition()
                ATLAS.UpdatePosition()
            end
            local function ClearCurrentPosition()
                -- So AutopilotTargetIndex is special and not a real index.  We have to do this by hand.
                    ATLAS.ClearCurrentPosition()
            end

            local function getAPName(index)
                local name = AutopilotTargetName
                if index ~= nil and type(index) == "number" then 
                    if index == 0 then return "None" end
                    name = AtlasOrdered[index].name
                end
                if name == nil then
                    name = CustomTarget.name
                end
                if name == nil then
                    name = "None"
                end
                return name
            end
            
            local function getAPEnableName(index)
                return "Engage Autopilot: " .. getAPName(index)
            end

            local function getAPDisableName(index)
                return "Disable Autopilot: " .. getAPName(index)
            end   

            local function ToggleFollowMode() -- Toggle Follow Mode on and off
                if isRemote() == 1 then
                    followMode = not followMode
                    if followMode then
                        Autopilot = false
                        RetrogradeIsOn = false
                        ProgradeIsOn = false
                        AltitudeHold = false
                        Reentry = false
                        BrakeLanding = false
                        AutoTakeoff = false
                        OldGearExtended = GearExtended
                        GearExtended = false
                        Nav.control.retractLandingGears()
                        navCom:setTargetGroundAltitude(TargetHoverHeight)
                        play("folOn","F")
                    else
                        play("folOff","F")
                        BrakeIsOn = true
                        autoRoll = autoRollPreference
                        GearExtended = OldGearExtended
                        if GearExtended then
                            Nav.control.extendLandingGears()
                            navCom:setTargetGroundAltitude(LandingGearGroundHeight)
                        end
                    end
                else
                    msgText = "Follow Mode only works with Remote controller"
                    followMode = false
                end
            end
        
            -- BEGIN BUTTON DEFINITIONS
        
            -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
            
            local buttonHeight = 50
            local buttonWidth = 260 -- Defaults
            local brake = MakeButton("Enable Brake Toggle", "Disable Brake Toggle", buttonWidth, buttonHeight,
                                resolutionWidth / 2 - buttonWidth / 2, resolutionHeight / 2 + 350, function()
                    return BrakeToggleStatus
                end, function()
                    BrakeToggleStatus = not BrakeToggleStatus
                    if (BrakeToggleStatus) then
                        msgText = "Brakes in Toggle Mode"
                    else
                        msgText = "Brakes in Default Mode"
                    end
                end)
            MakeButton("Align Prograde", "Disable Prograde", buttonWidth, buttonHeight,
                resolutionWidth / 2 - buttonWidth / 2 - 50 - brake.width, resolutionHeight / 2 - buttonHeight + 380,
                function()
                    return ProgradeIsOn
                end, function() gradeToggle(1) end)
            MakeButton("Align Retrograde", "Disable Retrograde", buttonWidth, buttonHeight,
                resolutionWidth / 2 - buttonWidth / 2 + brake.width + 50, resolutionHeight / 2 - buttonHeight + 380,
                function()
                    return RetrogradeIsOn
                end, gradeToggle, function()
                    return atmosDensity == 0
                end) -- Hope this works
            apbutton = MakeButton(getAPEnableName, getAPDisableName, 600, 60, resolutionWidth / 2 - 600 / 2,
                                    resolutionHeight / 2 - 60 / 2 - 400, function()
                    return Autopilot or VectorToTarget or spaceLaunch or IntoOrbit
                end, function() end) -- No toggle function because we draw over this with things that do toggle
            -- Make 9 more buttons that only show when moused over the AP button
            local i
            local function getAtlasIndexFromAddition(add)
                local index = apScrollIndex + add
                if index > #AtlasOrdered then
                    index = index-#AtlasOrdered-1
                end
                if index < 0 then
                    index = #AtlasOrdered+index
                end
                
                return index
            end
            apExtraButtons = {}
            for i=0,10 do
                local button = MakeButton(function(b)
                    local index = getAtlasIndexFromAddition(b.apExtraIndex)
                    if Autopilot or VectorToTarget or spaceLaunch or IntoOrbit then
                        return "Redirect: " .. getAPName(index)
                    end
                    return getAPEnableName(index)
                end, function(b)
                    local index = getAtlasIndexFromAddition(b.apExtraIndex)
                    return getAPDisableName(index)
                end, 600, 60, resolutionWidth/2 - 600/2, 
                resolutionHeight/2 - 60/2 - 400 + 60*i, function(b)
                    local index = getAtlasIndexFromAddition(b.apExtraIndex)
                    return index == AutopilotTargetIndex and (Autopilot or VectorToTarget or spaceLaunch or IntoOrbit)
                end, function(b)
                    local index = getAtlasIndexFromAddition(b.apExtraIndex)
                    local disable = AutopilotTargetIndex == index
                    AutopilotTargetIndex = index
                    ATLAS.UpdateAutopilotTarget()
                    ToggleAutopilot()
                    -- Let buttons redirect AP, they're hard to do by accident
                    if not disable and not (Autopilot or VectorToTarget or spaceLaunch or IntoOrbit) then
                        ToggleAutopilot()
                    end
                end, function()
                    return apButtonsHovered
                end)
                button.apExtraIndex = i
                apExtraButtons[i] = button
            end


            MakeButton("Save Position", "Save Position", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y,
                function()
                    return false
                end, AddNewLocation, function()
                    return AutopilotTargetIndex == 0 or CustomTarget == nil
                end)
            MakeButton("Update Position", "Update Position", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y,
                function()
                    return false
                end, UpdatePosition, function()
                    return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                end)
            MakeButton("Clear Position", "Clear Position", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y,
                function()
                    return true
                end, ClearCurrentPosition, function()
                    return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                end)
            -- The rest are sort of standardized
            buttonHeight = 60
            buttonWidth = 300
            local x = 10
            local y = resolutionHeight / 2 - 500
            MakeButton("Show Help", "Hide Help", buttonWidth, buttonHeight, x, y, function() return showHelp end, function() showHelp = not showHelp end)
            y = y + buttonHeight + 20
            MakeButton("View Settings", "View Settings", buttonWidth, buttonHeight, x, y, function() return true end, ToggleButtons)
            local y = resolutionHeight / 2 - 300
            MakeButton("Enable Turn and Burn", "Disable Turn and Burn", buttonWidth, buttonHeight, x, y, function()
                return TurnBurn
            end, ToggleTurnBurn)
            MakeButton("Horizontal Takeoff Mode", "Vertical Takeoff Mode", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                function() return VertTakeOffEngine end, 
                function () 
                    VertTakeOffEngine = not VertTakeOffEngine 
                    if VertTakeOffEngine then 
                        msgText = "Vertical Takeoff Mode"
                    else
                        msgText = "Horizontal Takeoff Mode"
                    end
                end, function() return UpVertAtmoEngine end)
            y = y + buttonHeight + 20
            MakeButton("Show Orbit Display", "Hide Orbit Display", buttonWidth, buttonHeight, x, y,
                function()
                    return DisplayOrbit
                end, function()
                    DisplayOrbit = not DisplayOrbit
                    if (DisplayOrbit) then
                        msgText = "Orbit Display Enabled"
                    else
                        msgText = "Orbit Display Disabled"
                    end
                end)
            -- prevent this button from being an option until you're in atmosphere
            MakeButton("Engage Orbiting", "Cancel Orbiting", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                    function()
                        return IntoOrbit
                    end, ToggleIntoOrbit, function()
                        return (atmosDensity == 0 and nearPlanet)
                    end)
            y = y + buttonHeight + 20
            MakeButton("Glide Re-Entry", "Cancel Glide Re-Entry", buttonWidth, buttonHeight, x, y,
                function() return Reentry end, function() spaceLand = 1 gradeToggle(1) end, function() return (planet.hasAtmosphere and not inAtmo) end )
            MakeButton("Parachute Re-Entry", "Cancel Parachute Re-Entry", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                function() return Reentry end, BeginReentry, function() return (planet.hasAtmosphere and not inAtmo) end )
            y = y + buttonHeight + 20
            MakeButton("Engage Follow Mode", "Disable Follow Mode", buttonWidth, buttonHeight, x, y, function()
                return followMode
                end, ToggleFollowMode, function()
                    return isRemote() == 1
                end)
                MakeButton("Enable Repair Arrows", "Disable Repair Arrows", buttonWidth, buttonHeight, x + buttonWidth + 20, y, function()
                    return repairArrows
                end, function()
                    repairArrows = not repairArrows
                    if (repairArrows) then
                        msgText = "Repair Arrows Enabled"
                    else
                        msgText = "Repair Arrows Diabled"
                    end
                end, function()
                    return isRemote() == 1
                end)
            y = y + buttonHeight + 20
            if not ExternalAGG then
                MakeButton("Enable AGG", "Disable AGG", buttonWidth, buttonHeight, x, y, function()
                return antigravOn end, ToggleAntigrav, function()
                return antigrav ~= nil end)
            end
            MakeButton(function() return stringf("Switch IPH Mode - Current: %s", iphCondition)
            end, function()
                return stringf("IPH Mode: %s", iphCondition)
            end, buttonWidth * 2, buttonHeight, x, y, function()
                return false
            end, function()
                if iphCondition == "All" then
                    iphCondition = "Custom Only"
                elseif iphCondition == "Custom Only" then
                    iphCondition = "No Moons"
                else
                    iphCondition = "All"
                end
                msgText = "IPH Mode: "..iphCondition
            end)
            y = y + buttonHeight + 20
            MakeButton(function() return stringf("Toggle Control Scheme - Current: %s", userControlScheme)
                end, function()
                    return stringf("Control Scheme: %s", userControlScheme)
                end, buttonWidth * 2, buttonHeight, x, y, function()
                    return false
                end, function()
                    if userControlScheme == "keyboard" then
                        userControlScheme = "mouse"
                    elseif userControlScheme == "mouse" then
                        userControlScheme = "virtual joystick"
                    else
                        userControlScheme = "keyboard"
                    end
                    msgText = "New Control Scheme: "..userControlScheme
                end)
        end

    local Hud = {}

    function Hud.HUDPrologue(newContent)
        notPvPZone, pvpDist = safeZone(worldPos)
        if not notPvPZone then -- misnamed variable, fix later
            PrimaryR = PvPR
            PrimaryG = PvPG
            PrimaryB = PvPB
            if shield_1 and AutoShieldToggle and shield_1.getState() == 0 then
                shield_1.toggle()
            end
        else
            PrimaryR = SafeR
            PrimaryG = SafeG
            PrimaryB = SafeB
            if shield_1 and AutoShieldToggle and shield_1.getState() == 1 then
                shield_1.toggle()
            end
        end
        rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
        rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]    
        local bright = rgb
        local dim = rgbdim
        local brightOrig = rgb
        local dimOrig = rgbdim
        if IsInFreeLook() and not brightHud then
            bright = [[rgb(]] .. mfloor(PrimaryR * 0.4 + 0.5) .. "," .. mfloor(PrimaryG * 0.4 + 0.5) .. "," ..
                        mfloor(PrimaryB * 0.3 + 0.5) .. [[)]]
            dim = [[rgb(]] .. mfloor(PrimaryR * 0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," ..
                    mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]
        end
    
        -- When applying styles, apply color first, then type (e.g. "bright line")
        -- so that "fill:none" gets applied
    
        newContent[#newContent + 1] = stringf([[
            <head>
                <style>
                    body {margin: 0}
                    svg {position:absolute;top:0;left:0;font-family:Montserrat;} 
                    .txt {font-size:10px;font-weight:bold;}
                    .txttick {font-size:12px;font-weight:bold;}
                    .txtbig {font-size:14px;font-weight:bold;}
                    .altsm {font-size:16px;font-weight:normal;}
                    .altbig {font-size:21px;font-weight:normal;}
                    .line {stroke-width:2px;fill:none}
                    .linethick {stroke-width:3px;fill:none}
                    .warnings {font-size:26px;fill:red;text-anchor:middle;font-family:Bank;}
                    .warn {fill:orange; font-size:24px}
                    .crit {fill:darkred;font-size:28px}
                    .bright {fill:%s;stroke:%s}
                    text.bright {stroke:black; stroke-width:10px;paint-order:stroke;}
                    .pbright {fill:%s;stroke:%s}
                    text.pbright {stroke:black; stroke-width:10px;paint-order:stroke;}
                    .dim {fill:%s;stroke:%s}
                    text.dim {stroke:black; stroke-width:10px;paint-order:stroke;}
                    .pdim {fill:%s;stroke:%s}
                    text.pdim {stroke:black; stroke-width:10px;paint-order:stroke;}
                    .red {fill:red;stroke:red}
                    text.red {stroke:black; stroke-width:10px;paint-order:stroke;}
                    .orange {fill:orange;stroke:orange}
                    text.orange {stroke:black; stroke-width:10px;paint-order:stroke;}
                    .redout {fill:none;stroke:red}
                    .op30 {opacity:0.3}
                    .op10 {opacity:0.1}
                    .txtstart {text-anchor:start}
                    .txtend {text-anchor:end}
                    .txtmid {text-anchor:middle}
                    .txtvspd {font-family:sans-serif;font-weight:normal}
                    .txtvspdval {font-size:20px}
                    .txtfuel {font-size:11px;font-weight:bold}
                    .txtorb {font-size:12px}
                    .txtorbbig {font-size:18px}
                    .hudver {font-size:10px;font-weight:bold;fill:red;text-anchor:end;font-family:Bank}
                    .msg {font-size:40px;fill:red;text-anchor:middle;font-weight:normal}
                    .cursor {stroke:white}
                    text { stroke:black; stroke-width:10px;paint-order:stroke;}
                </style>
            </head>
            <body>
                <svg height="100%%" width="100%%" viewBox="0 0 %d %d">
                <defs>
                    <radialGradient id="RadialGradient1" cx="0.5" cy="0" r="1">
                        <stop offset="0%%" stop-color="black" stop-opacity="1"/>
                        <stop offset="100%%" stop-color="%s" stop-opacity="0.4"/>
                    </radialGradient>
                </defs>
                ]], bright, bright, brightOrig, brightOrig, dim, dim, dimOrig, dimOrig, resolutionWidth, resolutionHeight, dimOrig)
        return newContent
    end

    function Hud.DrawVerticalSpeed(newContent, altitude)
        DrawVerticalSpeed(newContent, altitude)
    end


    function Hud.UpdateHud(newContent)
        local pitch = adjustedPitch
        local roll = adjustedRoll
        local originalRoll = roll
        local originalPitch = pitch
        local throt = mfloor(unit.getThrottle())
        local spd = velMag * 3.6
        local flightValue = unit.getAxisCommandValue(0)
        local pvpBoundaryX = ConvertResolutionX(1770)
        local pvpBoundaryY = ConvertResolutionY(310)
        if AtmoSpeedAssist and throttleMode then
            flightValue = PlayerThrottle
            throt = PlayerThrottle*100
        end
    
        local flightStyle = GetFlightStyle()
        local bottomText = "ROLL"
        
        if throt == nil then throt = 0 end
    
        if (not nearPlanet) then
            if (velMag > 5) then
                pitch = getRelativePitch(coreVelocity)
                roll = getRelativeYaw(coreVelocity)
            else
                pitch = 0
                roll = 0
            end
            bottomText = "YAW"
        end
        
        if pvpDist > 50000 and not inAtmo then
            local dist
            dist = getDistanceDisplayString(pvpDist)
            newContent[#newContent + 1] = svgText(pvpBoundaryX, pvpBoundaryY, "PvP Boundary: "..dist, "pbright txtbig txtmid")
        end

        -- CRUISE/ODOMETER
    
        newContent[#newContent + 1] = lastOdometerOutput
    
        -- DAMAGE
    
        newContent[#newContent + 1] = damageMessage
    
        -- RADAR
    
        newContent[#newContent + 1] = radarMessage

        -- Pipe distance

        if pipeMessage ~= "" then newContent[#newContent +1] = pipeMessage end
    

        if tankMessage ~= "" then newContent[#newContent + 1] = tankMessage end
        if shieldMessage ~= "" then newContent[#newContent +1] = shieldMessage end
        -- PRIMARY FLIGHT INSTRUMENTS
    
        DrawVerticalSpeed(newContent, coreAltitude) -- Weird this is draw during remote control...?
    
    
        if isRemote() == 0 or RemoteHud then
            -- Don't even draw this in freelook
            if not IsInFreeLook() or brightHud then
                if nearPlanet then -- use real pitch, roll, and heading
                    DrawRollLines (newContent, centerX, centerY, originalRoll, bottomText, nearPlanet)
                    DrawArtificialHorizon(newContent, originalPitch, originalRoll, centerX, centerY, nearPlanet, mfloor(getRelativeYaw(coreVelocity)), velMag)
                else -- use Relative Pitch and Relative Yaw
                    DrawRollLines (newContent, centerX, centerY, roll, bottomText, nearPlanet)
                    DrawArtificialHorizon(newContent, pitch, roll, centerX, centerY, nearPlanet, mfloor(roll), velMag)
                end
                DrawAltitudeDisplay(newContent, coreAltitude, nearPlanet)
                DrawPrograde(newContent, coreVelocity, velMag, centerX, centerY)
            end
        end

        DrawThrottle(newContent, flightStyle, throt, flightValue)
    
        -- PRIMARY DATA DISPLAYS
    
        DrawSpeed(newContent, spd)
    
        DrawWarnings(newContent)
        DisplayOrbitScreen(newContent)

        if showHelp then DisplayHelp(newContent) end

        return newContent
    end

    function Hud.HUDEpilogue(newContent)
        newContent[#newContent + 1] = "</svg>"
        return newContent
    end

    function Hud.ExtraData(newContent)
        local xg = ConvertResolutionX(1240)
        local yg1 = ConvertResolutionY(55)
        local yg2 = yg1+10
        local gravity 

        local brakeValue = 0
        local flightStyle = GetFlightStyle()
        if VertTakeOffEngine then flightStyle = flightStyle.."-VERTICAL" end
        if CollisionSystem and not AutoTakeoff and not BrakeLanding and velMag > 20 then flightStyle = flightStyle.."-COLLISION ON" end
        if UseExtra ~= "Off" then flightStyle = "("..UseExtra..")-"..flightStyle end
        if TurnBurn then flightStyle = "TB-"..flightStyle end
        if not stablized then flightStyle = flightStyle.."-DeCoupled" end

        local accel = (vec3(core.getWorldAcceleration()):len() / 9.80665)
        gravity =  core.g()
        newContent[#newContent + 1] = [[<g class="pdim txt txtend">]]
        if isRemote() == 1 and not RemoteHud then
            xg = ConvertResolutionX(1120)
            yg1 = ConvertResolutionY(55)
            yg2 = yg1+10
        elseif inAtmo then -- We only show atmo when not remote
            local atX = ConvertResolutionX(770)
            newContent[#newContent + 1] = svgText(atX, yg1, "ATMOSPHERE", "pdim txt txtend")
            newContent[#newContent + 1] = svgText( atX, yg2, stringf("%.2f", atmosDensity), "pdim txt txtend","")
        end
        newContent[#newContent + 1] = svgText(xg, yg1, "GRAVITY", "pdim txt txtend")
        newContent[#newContent + 1] = svgText(xg, yg2, stringf("%.2f", (gravity / 9.80665)), "pdim txt txtend")
        newContent[#newContent + 1] = svgText(xg, yg1 + 20, "ACCEL", "pdim txt txtend")
        newContent[#newContent + 1] = svgText(xg, yg2 + 20, stringf("%.2f", accel), "pdim txt txtend") 
        newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(180), flightStyle, "txtbig txtmid")
    end

    function Hud.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
        local gravity 
        local maxMass = 0
        local reqThrust = 0
        local brakeValue = 0
        local mass = coreMass > 1000000 and round(coreMass / 1000000,2).." kTons" or round(coreMass / 1000, 2).." Tons"
        if inAtmo then brakeValue = LastMaxBrakeInAtmo else brakeValue = LastMaxBrake end
        local brkDist, brkTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, brakeValue)
        brakeValue = round((brakeValue / (coreMass * gravConstant)),2).." g"
        local maxThrust = Nav:maxForceForward()
        gravity = core.g()
        if gravity > 0.1 then
            reqThrust = coreMass * gravity
            reqThrust = round((reqThrust / (coreMass * gravConstant)),2).." g"
            maxMass = 0.5 * maxThrust / gravity
            maxMass = maxMass > 1000000 and round(maxMass / 1000000,2).." kTons" or round(maxMass / 1000, 2).." Tons"
        end
        maxThrust = round((maxThrust / (coreMass * gravConstant)),2).." g"
        newContent[#newContent + 1] = stringf([[
            <g class="pbright txt">
            <path class="linethick" style="fill:url(#RadialGradient1);" d="M %d 0 L %d %d Q %d %d %d %d L %d 0"/>]],
            ConvertResolutionX(660), ConvertResolutionX(700), ConvertResolutionY(35), ConvertResolutionX(960), ConvertResolutionY(55),
            ConvertResolutionX(1240), ConvertResolutionY(35), ConvertResolutionX(1280))
        if isRemote() == 0 or RemoteHud then 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(10), stringf("BrkTime: %s", FormatTimeString(brkTime)), "txtstart")
            newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(20), stringf("Trip: %.2f km", totalDistanceTrip), "txtstart") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(30), stringf("Lifetime: %.2f kSU", (TotalDistanceTravelled / 200000)), "txtstart") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(10), stringf("BrkDist: %s", getDistanceDisplayString(brkDist)) , "txtstart")
            newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(20), "Trip Time: "..FormatTimeString(flightTime), "txtstart") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(30), "Total Time: "..FormatTimeString(TotalFlightTime), "txtstart") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(20), stringf("Mass: %s", mass), "txtstart") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(10), stringf("Max Brake: %s",  brakeValue), "txtend") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(30), stringf("Max Thrust: %s", maxThrust), "txtend") 
            if gravity > 0.1 then
                newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(30), stringf("Max Thrust Mass: %s", (maxMass)), "txtstart")
                newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(20), stringf("Req Thrust: %s", reqThrust ), "txtend") 
            else
                newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(30), "Max Mass: n/a", "txtstart") 
                newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(20), "Req Thrust: n/a", "txtend") 
            end
        end
        newContent[#newContent + 1] = "</g>"
        return newContent
    end

    function Hud.DrawWarnings(newContent)
        return DrawWarnings(newContent)
    end

    function Hud.DisplayOrbitScreen(newContent)
        return DisplayOrbitScreen(newContent)
    end

    function Hud.DisplayMessage(newContent, displayText)
        if displayText ~= "empty" then
            local y = 310
            for str in string.gmatch(displayText, "([^\n]+)") do
                y = y + 35
                newContent[#newContent + 1] = svgText("50%", y, str, "msg")
            end
        end
        if msgTimer ~= 0 then
            unit.setTimer("msgTick", msgTimer)
            msgTimer = 0
        end
    end

    function Hud.DrawDeadZone(newContent)
        newContent[#newContent + 1] = stringf(
                                        [[<circle class="dim line" style="fill:none" cx="50%%" cy="50%%" r="%d"/>]],
                                        DeadZone)
    end

    function Hud.UpdatePipe() -- Many thanks to Tiramon for the idea and math part of the code.
        if inAtmo then 
            pipeMessage = "" 
            return 
        end
        getClosestPipe()           
    end
    
    function Hud.DrawSettings(newContent)
        if #settingsVariables > 0  then
            local x = ConvertResolutionX(640)
            local y = ConvertResolutionY(200)
            newContent[#newContent + 1] = [[<g class="pbright txtvspd txtstart">]]
            for k, v in pairs(settingsVariables) do
                newContent[#newContent + 1] = svgText(x, y, v..": ".._G[v])
                y = y + 20
                if k%12 == 0 then
                    x = x + ConvertResolutionX(350)
                    y = ConvertResolutionY(200)
                end
            end
            newContent[#newContent + 1] = svgText(ConvertResolutionX(640), ConvertResolutionY(200)+260, "To Change: In Lua Chat, enter /G VariableName Value")
            newContent[#newContent + 1] = "</g>"
        end
        return newContent
    end

        -- DrawRadarInfo() variables
        local perisPanelID
        local radarX = ConvertResolutionX(1770)
        local radarY = ConvertResolutionY(350)
        local friendy = ConvertResolutionY(15)
        local friendx = ConvertResolutionX(1370)
        local msg, where
        local peris = 0

    function Hud.DrawRadarInfo()
        local function ToggleRadarPanel()
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
                    _autoconf.displayCategoryPanel(radars, 1,  "Periscope",
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
        local target, data, radarContacts, numKnown, static, friendlies = RADAR.GetRadarHud()
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
                ToggleRadarPanel()
            end
            if target ~= nil and perisPanelID ~= nil then
                ToggleRadarPanel()
            end
            if radarPanelID == nil then
                ToggleRadarPanel()
            end
        else
            if data then
                radarMessage = svgText(radarX, radarY, rType.." Radar: Jammed", "pbright txtbig txtmid")
            else
                radarMessage = svgText(radarX, radarY, "Radar: No "..rType.." Contacts", "pbright txtbig txtmid")
            end
            if radarPanelID ~= nil then
                peris = 0
                ToggleRadarPanel()
            end
        end
    end

    function Hud.DrawTanks()
        -- FUEL TANKS
        if (fuelX ~= 0 and fuelY ~= 0) then
            tankMessage = svgText(fuelX, fuelY, "", "txtstart pdim txtfuel")
            DrawTank( fuelX, "Atmospheric ", "ATMO", atmoTanks, fuelTimeLeft, fuelPercent)
            DrawTank( fuelX+120, "Space fuel t", "SPACE", spaceTanks, fuelTimeLeftS, fuelPercentS)
            DrawTank( fuelX+240, "Rocket fuel ", "ROCKET", rocketTanks, fuelTimeLeftR, fuelPercentR)
        end

    end

    function Hud.DrawShield()
        local shieldState = (shield_1.getState() == 1) and "Shield Active" or "Shield Disabled"
        local pvpTime = core.getPvPTimer()
        local resistances = shield_1.getResistances()
        local resistString = "A: "..(10+resistances[1]*100).."% / E: "..(10+resistances[2]*100).."% / K:"..(10+resistances[3]*100).."% / T: "..(10+resistances[4]*100).."%"
        local x, y = shieldX -60, shieldY+30
        local shieldPercent = mfloor(0.5 + shield_1.getShieldHitpoints() * 100 / shield_1.getMaxShieldHitpoints())
        local colorMod = mfloor(shieldPercent * 2.55)
        local color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
        local class = ""
        shieldMessage = svgText(x, y, "", "txtmid pdim txtfuel")
        if shieldPercent < 10 and shieldState ~= "Shield Disabled" then
            class = "red "
        end
        pvpTime = pvpTime > 0 and "   PvPTime: "..FormatTimeString(pvpTime) or ""
        shieldMessage = shieldMessage..stringf([[
            <g class="pdim">                        
            <rect fill=grey class="bar" x="%d" y="%d" width="200" height="13"></rect></g>
            <g class="bar txtstart">
            <rect fill=%s width="%d" height="13" x="%d" y="%d"></rect>
            <text fill=black x="%d" y="%d">%s%%%s</text>
            </g>]], x, y, color, shieldPercent*2, x, y, x+2, y+10, shieldPercent, pvpTime)
        shieldMessage = shieldMessage..svgText(x, y-5, shieldState, class.."txtstart pbright txtbig") 
        shieldMessage = shieldMessage..svgText(x,y+30, resistString, class.."txtstart pbright txtsmall")
    end

    function Hud.hudtick()
        -- Local Functions for hudTick
            local function DrawCursorLine(newContent)
                local strokeColor = mfloor(uclamp((distance / (resolutionWidth / 4)) * 255, 0, 255))
                newContent[#newContent + 1] = stringf(
                                                "<line x1='0' y1='0' x2='%fpx' y2='%fpx' style='stroke:rgb(%d,%d,%d);stroke-width:2;transform:translate(50%%, 50%%)' />",
                                                simulatedX, simulatedY, mfloor(PrimaryR + 0.5) + strokeColor,
                                                mfloor(PrimaryG + 0.5) - strokeColor, mfloor(PrimaryB + 0.5) - strokeColor)
            end
            local function CheckButtons()
                for _, v in pairs(Buttons) do
                    if v.hovered then
                        if not v.drawCondition or v.drawCondition(v) then
                            v.toggleFunction(v)
                        end
                        v.hovered = false
                    end
                end
            end    
            local function SetButtonContains()

                local function Contains(mousex, mousey, x, y, width, height)
                    if mousex >= x and mousex <= (x + width) and mousey >= y and mousey <= (y + height) then
                        return true
                    else
                        return false
                    end
                end
                local x = simulatedX + resolutionWidth / 2
                local y = simulatedY + resolutionHeight / 2
                for _, v in pairs(Buttons) do
                    -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                    v.hovered = Contains(x, y, v.x, v.y, v.width, v.height)
                end

                if apButtonsHovered then -- Keep it hovered if any buttons are hovered
                    local hovered = false
                    for _,b in ipairs(apExtraButtons) do
                        if b.hovered then hovered = true break end
                    end
                    if apbutton.hovered then hovered = true end
                    apButtonsHovered = hovered
                else
                    apButtonsHovered = apbutton.hovered
                    if not apButtonsHovered then
                        apScrollIndex = AutopilotTargetIndex -- Reset when no longer hovering
                    end
                end
                
            end
            local function DrawButtons(newContent)

                local function DrawButton(newContent, toggle, hover, x, y, w, h, activeColor, inactiveColor, activeText, inactiveText, button)
                    if type(activeText) == "function" then
                        activeText = activeText(button)
                    end
                    if type(inactiveText) == "function" then
                        inactiveText = inactiveText(button)
                    end
                    newContent[#newContent + 1] = stringf("<rect x='%f' y='%f' width='%f' height='%f' fill='", x, y, w, h)
                    if toggle then
                        newContent[#newContent + 1] = stringf("%s'", activeColor)
                    else
                        newContent[#newContent + 1] = inactiveColor
                    end
                    if hover then
                        newContent[#newContent + 1] = stringf(" style='stroke:rgb(%d,%d,%d); stroke-width:2'",SafeR, SafeG, SafeB)
                    else
                        newContent[#newContent + 1] = stringf(" style='stroke:rgb(%d,%d,%d); stroke-width:1'",round(SafeR*0.5,0),round(SafeG*0.5,0),round(SafeB*0.5,0))
                    end
                    newContent[#newContent + 1] = " rx='5'></rect>"
                    newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='24' fill='", x + w / 2,
                                                    y + (h / 2) + 5)
                    if toggle then
                        newContent[#newContent + 1] = "black"
                    else
                        newContent[#newContent + 1] = "white"
                    end
                    newContent[#newContent + 1] = "' text-anchor='middle' font-family='Play' style='stroke-width:0px;'>"
                    if toggle then
                        newContent[#newContent + 1] = stringf("%s</text>", activeText)
                    else
                        newContent[#newContent + 1] = stringf("%s</text>", inactiveText)
                    end
                end    
                local defaultColor = stringf("rgb(%d,%d,%d)'",round(SafeR*0.1,0),round(SafeG*0.1,0),round(SafeB*0.1,0))
                local onColor = stringf("rgb(%d,%d,%d)",round(SafeR*0.8,0),round(SafeG*0.8,0),round(SafeB*0.8,0))
                local draw = DrawButton
                for _, v in pairs(Buttons) do
                    -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                    local disableName = v.disableName
                    local enableName = v.enableName
                    if type(disableName) == "function" then
                        disableName = disableName(v)
                    end
                    if type(enableName) == "function" then
                        enableName = enableName(v)
                    end
                    if not v.drawCondition or v.drawCondition(v) then -- If they gave us a nil condition
                        draw(newContent, v.toggleVar(v), v.hovered, v.x, v.y, v.width, v.height, onColor, defaultColor,
                            disableName, enableName, v)
                    end
                end
            end
        local halfResolutionX = round(ResolutionX / 2,0)
        local halfResolutionY = round(ResolutionY / 2,0)
        local newContent = {}
        --local t0 = system.getTime()
        HUD.HUDPrologue(newContent)
        if showHud then
            --local t0 = system.getTime()
            HUD.UpdateHud(newContent) -- sets up Content for us
            --_logCompute.addValue(system.getTime() - t0)
        else
            if AlwaysVSpd then HUD.DrawVerticalSpeed(newContent, coreAltitude) end
            HUD.DisplayOrbitScreen(newContent)
            HUD.DrawWarnings(newContent)
        end
        if showSettings and settingsVariables ~= {} then 
            HUD.DrawSettings(newContent) 
        end
        if radar_1 or radar_2 then RADAR.assignRadar() end
        if radars[1] then HUD.DrawRadarInfo() end
        HUD.HUDEpilogue(newContent)
        newContent[#newContent + 1] = stringf(
            [[<svg width="100%%" height="100%%" style="position:absolute;top:0;left:0"  viewBox="0 0 %d %d">]],
            resolutionWidth, resolutionHeight)   
        if msgText ~= "empty" then
            HUD.DisplayMessage(newContent, msgText)
        end
        if isRemote() == 0 and userControlScheme == "virtual joystick" then
            if DisplayDeadZone then HUD.DrawDeadZone(newContent) end
        end

        if sysIsVwLock() == 0 then
            if isRemote() == 1 and holdingShift then
                if not AltIsOn then
                    SetButtonContains()
                    DrawButtons(newContent)
                end
                -- If they're remote, it's kinda weird to be 'looking' everywhere while you use the mouse
                -- We need to add a body with a background color
                if not Animating and not Animated then
                    local collapsedContent = table.concat(newContent, "")
                    newContent = {}
                    newContent[#newContent + 1] = stringf("<style>@keyframes test { from { opacity: 0; } to { opacity: 1; } }  body { animation-name: test; animation-duration: 0.5s; }</style><body><svg width='100%%' height='100%%' position='absolute' top='0' left='0'><rect width='100%%' height='100%%' x='0' y='0' position='absolute' style='fill:rgb(6,5,26);'/></svg><svg width='50%%' height='50%%' style='position:absolute;top:30%%;left:25%%' viewbox='0 0 %d %d'>", resolutionWidth, resolutionHeight)
                    newContent[#newContent + 1] = collapsedContent
                    newContent[#newContent + 1] = "</body>"
                    Animating = true
                    newContent[#newContent + 1] = [[</svg></body>]] -- Uh what.. okay...
                    unit.setTimer("animateTick", 0.5)
                    local content = table.concat(newContent, "")
                    system.setScreen(content)
                elseif Animated then
                    local collapsedContent = table.concat(newContent, "")
                    newContent = {}
                    newContent[#newContent + 1] = stringf("<body style='background-color:rgb(6,5,26)'><svg width='50%%' height='50%%' style='position:absolute;top:30%%;left:25%%' viewbox='0 0 %d %d'>", resolutionWidth, resolutionHeight)
                    newContent[#newContent + 1] = collapsedContent
                    newContent[#newContent + 1] = "</body>"
                end

                if not Animating then
                    newContent[#newContent + 1] = stringf(
                                                    [[<g transform="translate(%d %d)"><circle class="cursor" cx="%fpx" cy="%fpx" r="5"/></g>]],
                                                    halfResolutionX, halfResolutionY, simulatedX, simulatedY)
                end
            else
                CheckButtons()
            end
        else
            if not holdingShift and isRemote() == 0 then -- Draw deadzone circle if it's navigating
                CheckButtons()
                if distance > DeadZone then -- Draw a line to the cursor from the screen center
                    -- Note that because SVG lines fucking suck, we have to do a translate and they can't use calc in their params
                    if DisplayDeadZone then DrawCursorLine(newContent) end
                end
            elseif not AltIsOn or holdingShift then
                SetButtonContains()
                DrawButtons(newContent)
            end
            -- Cursor always on top, draw it last
            newContent[#newContent + 1] = stringf(
                                            [[<g transform="translate(%d %d)"><circle class="cursor" cx="%fpx" cy="%fpx" r="5"/></g>]],
                                            halfResolutionX, halfResolutionY, simulatedX, simulatedY)
        end
        newContent = HUD.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime) 
        newContent[#newContent + 1] = [[</svg></body>]]
        content = table.concat(newContent, "")
    end

    function Hud.TenthTick()
        HUD.DrawTanks()
        if shield_1 then HUD.DrawShield() end
    end

    function Hud.OneSecond(newContent)
        local function updateDistance()
            local curTime = systime()
            local spd = velMag
            local elapsedTime = curTime - lastTravelTime
            if (spd > 1.38889) then
                spd = spd / 1000
                local newDistance = spd * (curTime - lastTravelTime)
                TotalDistanceTravelled = TotalDistanceTravelled + newDistance
                totalDistanceTrip = totalDistanceTrip + newDistance
            end
            flightTime = flightTime + elapsedTime
            TotalFlightTime = TotalFlightTime + elapsedTime
            lastTravelTime = curTime
        end

        updateDistance()
        HUD.UpdatePipe()
        HUD.ExtraData(newContent)
    end

    function Hud.ButtonSetup()
        SettingsButtons()
        ControlsButtons() -- Set up all the pushable buttons.
        Buttons = ControlButtons
    end

    return Hud
end 