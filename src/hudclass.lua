function HudClass()
    -- REQUIRED DEFINES FROM HERE TILL NEXT REMARK - DO NOT REMOVE/CHANGE IF YOU DONT KNOW WHY
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

    local gravConstant = 9.80665

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
            
            local y1 = tankY
            local y2 = tankY+5
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
                        local backColor = stringf("rgb(%d,%d,%d)", uclamp(mfloor((255-colorMod)/2.55),50,100), uclamp(mfloor(colorMod/2.55),0,50), 50)
                        if BarFuelDisplay then
                            tankMessage = tankMessage..stringf([[
                                <g class="pdim">                        
                                <rect fill=%s class="bar" x="%d" y="%d" width="170" height="20"></rect></g>
                                <g class="bar txtstart">
                                <rect fill=%s width="%d" height="20" x="%d" y="%d"></rect>
                                <text class="txtstart" fill="white" x="%d" y="%d" style="font-family:Play;font-size:14px">%s %s%% %s</text>
                                </g>]], backColor, x, y2, color, mfloor(fuelPercentTable[i]*1.7+0.5), x, y2, x+5, y2+14,name, fuelPercentTable[i], fuelTimeDisplay
                            )
                            --tankMessage = tankMessage..svgText(x, y1, name, class.."txtstart pdim txtfuel") 
                            y1 = y1 - 22
                            y2 = y2 - 22
                        else
                            tankMessage = tankMessage..svgText(x, y1, name, class.."pdim txtfuel") 
                            tankMessage = tankMessage..svgText( x, y2, stringf("%d%% %s", fuelPercentTable[i], fuelTimeDisplay), "pdim txtfuel","fill:"..color)
                            y1 = y1 + 30
                            y2 = y2 + 30
                        end
                    end
                end
            end
            tankY = y1
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
            newContent[#newContent + 1] = [[<g style="clip-path: url(#headingClip);">]]
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
            for i = degRange+70, degRange, -5 do
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
                    newContent[#newContent + 1] = svgText(x,yawy+15, num, "txtmid bright" )
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
            newContent[#newContent + 1] = stringf([[<<polygon class="bright" points="%d,%d %d,%d %d,%d"/>]],
                yawx-5, yawy-20, yawx+5, yawy-20, yawx, yawy-10)
            if nearPlanet then bottomText = "HDG" end
            newContent[#newContent + 1] = svgText(ConvertResolutionX(960) , ConvertResolutionY(100), yawC.."°" , "dim txt txtmid size14", "")
            newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(85), bottomText, "dim txt txtmid size20","")
            newContent[#newContent + 1] = [[</g>]]
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
            local defaultStroke = "#222222"
            local onFill = "white"
            local defaultClass = "dimmer"
            local fillClass = "pbright"

            local brakeFill = "#110000"
            local brakeStroke = defaultStroke
            local brakeClass = defaultClass
            if BrakeIsOn then
                newContent[#newContent + 1] = svgText(warningX, brakeY, "Brake Engaged", "warnings")
                brakeFill = "#440000"
                brakeStroke = onFill
                brakeClass = fillClass
            elseif brakeInput2 > 0 then
                newContent[#newContent + 1] = svgText(warningX, brakeY, "Auto-Brake Engaged", "warnings", "opacity:"..brakeInput2)
            end
            local stallFill = "#110000"
            local stallStroke = defaultStroke
            local stallClass = defaultClass
            if inAtmo and stalling and abvGndDet == -1 then
                if not Autopilot and not VectorToTarget and not BrakeLanding and not antigravOn and not VertTakeOff and not AutoTakeoff then
                    newContent[#newContent + 1] = svgText(warningX, apY+50, "** STALL WARNING **", "warnings")
                    stallFill = "#ff0000"
                    stallStroke = onFill
                    stallClass = fillClass
                    play("stall","SW",2)
                end
            end
            if ReversalIsOn then
                newContent[#newContent + 1] = svgText(warningX, apY+90, "Flight Assist in Progress", "warnings")
            end

            if gyroIsOn then
                newContent[#newContent + 1] = svgText(warningX, gyroY, "Gyro Enabled", "warnings")
            end
            local gearFill = "#111100"
            local gearStroke = defaultStroke
            local gearClass = defaultClass
            if GearExtended then
                gearFill = "#775500"
                gearStroke = onFill
                gearClass = fillClass
                if hasGear then
                    newContent[#newContent + 1] = svgText(warningX, gearY, "Gear Extended", "warn")
                else
                    newContent[#newContent + 1] = svgText(warningX, gearY, "Landed (G: Takeoff)", "warnings")
                end
                local displayText = getDistanceDisplayString(Nav:getTargetGroundAltitude())
                newContent[#newContent + 1] = svgText(warningX, hoverY,"Hover Height: ".. displayText,"warn")
            end
            local rocketFill = "#000011"
            local rocketStroke = defaultStroke
            local rocketClass = defaultClass
            if isBoosting then
                rocketFill = "#0000DD"
                rocketStroke = onFill
                rocketClass = fillClass
                newContent[#newContent + 1] = svgText(warningX, ewarpY+20, "ROCKET BOOST ENABLED", "warn")
            end           
            local aggFill = "#001100"
            local aggStroke = defaultStroke      
            local aggClass = defaultClass
            if antigrav and not ExternalAGG and antigravOn and AntigravTargetAltitude ~= nil then
                aggFill = "#00DD00"
                aggStroke = onFill
                aggClass = fillClass
                if mabs(coreAltitude - antigrav.getBaseAltitude()) < 501 then
                    newContent[#newContent + 1] = svgText(warningX, apY+15, stringf("Target Altitude: %d Singularity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), "warn")
                else
                    newContent[#newContent + 1] = svgText( warningX, apY+15, stringf("Target Altitude: %d Singluarity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), "warnings")
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
            local collisionFill = "#110000"
            local collisionStroke = defaultStroke
            local collisionClass = defaultClass
            if collisionAlertStatus then
                collisionFill = "#FF0000"
                collisionStroke = onFill
                collisionClass = fillClass
                local type
                if string.find(collisionAlertStatus, "COLLISION") then type = "warnings" else type = "crit" end
                newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, collisionAlertStatus, type)
            elseif atmosDensity == 0 then
                local intersectBody, atmoDistance = checkLOS((constructVelocity):normalize())
                if atmoDistance ~= nil then
                    collisionClass = fillClass
                    collisionFill = "#FF0000"
                    collisionStroke = onFill
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
            local boardersFill = "#111100"
            local boardersStroke = defaultStroke
            local boardersClass = defaultClass
            if passengers and #passengers > 1 then
                boardersFill = "#DDDD00"
                boardersStroke = onFill
                boardersClass = fillClass
            end

            -- Removed because nobody liked these 'lights' at the bottom
            --newContent[#newContent + 1] = stringf([[
            --    <path class="linethick %s" style="fill:%s" d="M 730 940 l 100 0 l 50 50 l -200 0 l 50 -50 Z"/>
            --    <text class="txtmid size20" x=780 y=975 style="fill:%s">BOARDERS</text>
            --    <path class="linethick %s" style="fill:%s" d="M 1190 940 l -100 0 l -50 50 l 200 0 l -50 -50 Z"/>
            --    <text class="txtmid size20" x=1140 y=975 style="fill:%s">COLLISION</text>

            --    <path class="linethick %s" style="fill:%s" d="M 675 1000 l 100 0 l 50 50 l -200 0 l 50 -50 Z"/>
            --    <text class="txtmid size20" x=725 y=1030 style="fill:%s">BRAKE</text>
            --    <path class="linethick %s" style="fill:%s" d="M 790 1000 l 95 0 l 50 50 l -95 0 l -50 -50 Z"/>
            --    <text class="txtmid size20" x=860 y=1030 style="fill:%s">GEAR</text>

            --    <path class="linethick %s" style="fill:%s" d="M 1245 1000 l -100 0 l -50 50 l 200 0 l -50 -50 Z"/>
            --    <text class="txtmid size20" x=1195 y=1030 style="fill:%s">ROCKETS</text>
            --    <path class="linethick %s" style="fill:%s" d="M 1130 1000 l -95 0 l -50 50 l 95 0 l 50 -50 Z"/>
            --    <text class="txtmid size20" x=1055 y=1030 style="fill:%s">AGG</text>

            --    <path class="linethick %s" style="fill:%s" d="M 850 940 l 220 0 l -110 110 l -110 -110 Z"/>
            --    <text class="txtmid" x=960 y=980 style="font-size:32px;fill:%s">STALL</text>
            --]], boardersClass, boardersFill, boardersStroke, 
            --collisionClass, collisionFill, collisionStroke, 
            --brakeClass, brakeFill, brakeStroke, 
            --gearClass, gearFill, gearStroke, 
            --rocketClass, rocketFill, rocketStroke, 
            --aggClass, aggFill, aggStroke, 
            --stallClass, stallFill, stallStroke)
            local crx = ConvertResolutionX
            local cry = ConvertResolutionY

            local defaultClass = "topButton"
            local activeClass = "topButtonActive"
            local apClass = defaultClass
            if Autopilot or VectorToTarget or spaceLaunch or IntoOrbit then
                apClass = activeClass
            end
            local progradeClass = defaultClass
            if ProgradeIsOn then
                progradeClass = activeClass
            end
            local landClass = defaultClass
            if BrakeLanding or GearExtended then
                landClass = activeClass
            end
            local altHoldClass = defaultClass
            if AltitudeHold or VectorToTarget then
                altHoldClass = activeClass
            end
            local retroClass = defaultClass
            if RetrogradeIsOn then
                retroClass = activeClass
            end
            local orbitClass = defaultClass
            if IntoOrbit or (OrbitAchieved and Autopilot) then
                orbitClass = activeClass
            end

            local texty = cry(30)
            newContent[#newContent + 1] = stringf([[ 
                <g class="pdim txt txtmid">
                    <g class="%s">
                    <path d="M %f %f l 0 %f l %f 0 l %f %f Z"/>
                    ]], apClass, crx(960), cry(54), cry(-53), crx(-120), crx(25), cry(50))
            newContent[#newContent + 1] = svgText(crx(910),texty, "AUTOPILOT")
            newContent[#newContent + 1] = stringf([[
                    </g>

                    <g class="%s">
                    <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                    ]], progradeClass, crx(865), cry(51), crx(-25), cry(-50), crx(-110), crx(25), cry(46))
            newContent[#newContent + 1] = svgText(crx(800), texty, "PROGRADE")
            newContent[#newContent + 1] = stringf([[
                    </g>

                    <g class="%s">
                    <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                    ]], landClass, crx(755), cry(47), crx(-25), cry(-46), crx(-98), crx(44), cry(44))
            newContent[#newContent + 1] = svgText(crx(700), texty, "LAND")
            newContent[#newContent + 1] = stringf([[
                    </g>

                    <g class="%s">
                    <path d="M %f %f l 0 %f l %f 0 l %f %f Z"/>
                    ]], altHoldClass, crx(960), cry(54), cry(-53), crx(120), crx(-25), cry(50))
            newContent[#newContent + 1] = svgText(crx(1010), texty, "ALT HOLD")
            newContent[#newContent + 1] = stringf([[
                    </g>

                    <g class="%s">
                    <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                    ]], retroClass, crx(1055), cry(51), crx(25), cry(-50), crx(110), crx(-25), cry(46))
            newContent[#newContent + 1] = svgText(crx(1122), texty, "RETROGRADE")
            newContent[#newContent + 1] = stringf([[
                    </g>

                    <g class="%s">
                    <path d="M %f %f l %f %f l %f 0 l %f %f Z"/>
                    ]], orbitClass, crx(1165), cry(47), crx(25), cry(-46), crx(98), crx(-44), cry(44))
            newContent[#newContent + 1] = svgText(crx(1220), texty, "ORBIT")
            newContent[#newContent + 1] = [[
                    </g>
                </g>]]
        
            newContent[#newContent + 1] = "</g>"
            return newContent
        end

        local function getSpeedDisplayString(speed) -- TODO: Allow options, for now just do kph
            return mfloor(round(speed * 3.6, 0) + 0.5) .. " km/h" -- And generally it's not accurate enough to not twitch unless we round 0
        end

        local function DisplayHelp(newContent)
            local x = OrbitMapX+10
            local y = OrbitMapY+20
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
                newContent[#newContent + 1] = svgText( x, y, help[i], "pdim txtbig txtstart")
            end
        end
        
        local function DisplayOrbitScreen(newContent)
            local orbitMapX = ConvertResolutionX(OrbitMapX)
            local orbitMapY = ConvertResolutionY(OrbitMapY)
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

            local targetHeight = orbitMapSize*1.5
            if SelectedTab == "INFO" then
                targetHeight = 25*7
            end

            if SelectedTab ~= "HIDE" then
            newContent[#newContent + 1] = [[<g class="pbright txtorb txtmid">]]
            -- Draw a darkened box around it to keep it visible
            newContent[#newContent + 1] = stringf(
                                            '<rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" class="dimfill brightstroke" style="stroke-width:3;fill-opacity:0.3;" />',
                                            orbitMapSize*2, targetHeight, orbitMapX, orbitMapY)
            end


            if SelectedTab == "ORBIT" then
                -- If orbits are up, let's try drawing a mockup
                
                orbitMapY = orbitMapY + pad
                x = orbitMapX + orbitMapSize + pad
                y = orbitMapY + orbitMapSize*1.5 / 2 + 5 + pad
                rx = orbitMapSize / 4
                xOffset = 0
        
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
                                                    ellipseColor, orbitMapX + orbitMapSize + xOffset + pad,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, rx, ry)
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="%f" stroke="white" stroke-width="3" fill="blue" />',
                                                    orbitMapX + orbitMapSize + pad,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, planet.radius / scale)
                end
        
                if orbit.apoapsis ~= nil and orbit.apoapsis.speed < MaxGameVelocity and orbit.apoapsis.speed > 1 then
                    orbitInfo("Apoapsis")
                end
        
                y = orbitMapY + orbitMapSize*1.5 / 2 + 5 + pad
                x = orbitMapX - orbitMapX + 10 + pad
        
                if orbit.periapsis ~= nil and orbit.periapsis.speed < MaxGameVelocity and orbit.periapsis.speed > 1 then
                    orbitInfo("Periapsis")
                end
        
                -- Add a label for the planet
                newContent[#newContent + 1] = svgText(orbitMapX + orbitMapSize + pad, orbitMapY+20 + pad,planet.name, "txtorbbig")
        
                if orbit.period ~= nil and orbit.periapsis ~= nil and orbit.apoapsis ~= nil and orbit.apoapsis.speed > 1 then
                    local apsisRatio = (orbit.timeToApoapsis / orbit.period) * 2 * math.pi
                    -- x = xr * cos(t)
                    -- y = yr * sin(t)
                    local shipX = rx * math.cos(apsisRatio)
                    local shipY = ry * math.sin(apsisRatio)
        
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="5" stroke="white" stroke-width="3" fill="white" />',
                                                    orbitMapX + orbitMapSize + shipX + xOffset + pad,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + shipY + pad)
                end
        
                newContent[#newContent + 1] = [[</g>]]
                -- Once we have all that, we should probably rotate the entire thing so that the ship is always at the bottom so you can see AP and PE move?
                return newContent
            elseif SelectedTab == "INFO" then
                newContent = HUD.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
            elseif SelectedTab == "HELP" then
                newContent = DisplayHelp(newContent)
            else
                return newContent
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


    local Hud = {}
    local StaticPaths = nil

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
        rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.8 + 0.5) .. "," .. mfloor(PrimaryG * 0.8 + 0.5) .. "," ..   mfloor(PrimaryB * 0.8 + 0.5) .. [[)]]    
        local bright = rgb
        local dim = rgbdim
        local dimmer = [[rgb(]] .. mfloor(PrimaryR * 0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," ..   mfloor(PrimaryB * 0.3 + 0.5) .. [[)]]   
        local brightOrig = rgb
        local dimOrig = rgbdim
        if IsInFreeLook() and not brightHud then
            bright = [[rgb(]] .. mfloor(PrimaryR * 0.5 + 0.5) .. "," .. mfloor(PrimaryG * 0.5 + 0.5) .. "," ..
                        mfloor(PrimaryB * 0.5 + 0.5) .. [[)]]
            dim = [[rgb(]] .. mfloor(PrimaryR * 0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," ..
                    mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]
        end

        -- When applying styles, apply color first, then type (e.g. "bright line")
        -- so that "fill:none" gets applied
        local crx = ConvertResolutionX
        local cry = ConvertResolutionY
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
                    .line {stroke-width:2px;fill:none;stroke:%s}
                    .linethick {stroke-width:3px;fill:none}
                    .linethin {stroke-width:1px;fill:none}
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
                    .dimstroke {stroke:%s}
                    .brightstroke {stroke:%s}
                    .indicatorText {font-size:20px;fill:white}
                    .size14 {font-size:14px}
                    .size20 {font-size:20px}
                    .topButton {fill:%s;opacity:0.5;stroke-width:2;stroke:%s}
                    .topButtonActive {fill:url(#RadialGradientCenter);opacity:0.8;stroke-width:2;stroke:%s}
                    .topButton text {font-size:13px; fill: %s; opacity:1; stroke-width:20px}
                    .topButtonActive text {font-size:13px;fill:%s; stroke-width:0px; opacity:1}
                    .indicatorFont {font-size:20px;font-family:Bank}
                    .dimmer {stroke: %s;}
                    .dimfill {fill: %s;}
                </style>
            </head>
            <body>
                <svg height="100%%" width="100%%" viewBox="0 0 %d %d">
                    <defs>
                        <radialGradient id="RadialGradientCenterTop" cx="0.5" cy="0" r="1">
                            <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/>
                            <stop offset="100%%" stop-color="black" stop-opacity="0"/>
                        </radialGradient>
                        <radialGradient id="RadialGradientRightTop" cx="1" cy="0" r="1">
                            <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/>
                            <stop offset="200%%" stop-color="black" stop-opacity="0"/>
                        </radialGradient>
                        <radialGradient id="ThinRightTopGradient" cx="1" cy="0" r="1">
                            <stop offset="0%%" stop-color="%s" stop-opacity="0.2"/>
                            <stop offset="200%%" stop-color="black" stop-opacity="0"/>
                        </radialGradient>
                        <radialGradient id="RadialGradientLeftTop" cx="0" cy="0" r="1">
                            <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/>
                            <stop offset="200%%" stop-color="black" stop-opacity="0"/>
                        </radialGradient>
                        <radialGradient id="ThinLeftTopGradient" cx="0" cy="0" r="1">
                            <stop offset="0%%" stop-color="%s" stop-opacity="0.2"/>
                            <stop offset="200%%" stop-color="black" stop-opacity="0"/>
                        </radialGradient>
                        <radialGradient id="RadialGradientCenter" cx="0.5" cy="0.5" r="1">
                            <stop offset="0%%" stop-color="%s" stop-opacity="0.8"/>
                            <stop offset="100%%" stop-color="%s" stop-opacity="0.5"/>
                        </radialGradient>
                    </defs>
                    <g class="pdim txt txtend">
                    
                ]], bright, bright, bright, brightOrig, brightOrig, dim, dim, dimOrig, dimOrig,dim,bright,dimmer,dimOrig,bright,bright,dimmer,dimmer,dimmer, resolutionWidth, resolutionHeight, dim,dim,dim,dim,dim,brightOrig,dim)
        -- <path class="linethick dimstroke" style="fill:url(#ThinRightTopGradient);" d="M 1920 28 L 1920 800 L 1800 800 L 1750 750 L 1750 420 L 1700 370 L 1510 370 L 1460 320 L 1460 155 L 1410 105 L 1315 105 L 1403 28 Z"/>
        -- <path class="linethick dimstroke" style="fill:url(#ThinLeftTopGradient);" d="M 0 28 L 0 800 L 120 800 L 170 750 L 170 420 L 220 370 L 410 370 L 460 320 L 460 155 L 510 105 L 605 105 L 517 28 Z"/>
        
        -- These never change, set and store it on startup because that's a lot of calculations that we don't want to do every frame
        if not StaticPaths then
            StaticPaths = stringf([[<path class="linethick brightstroke" style="fill:url(#RadialGradientCenterTop);" d="M %f %f L %f %f L %f %f %f %f L %f %f"/>
            <path class="linethick brightstroke" style="fill:url(#RadialGradientRightTop);" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>
            
            <path class="linethick brightstroke" style="fill:url(#RadialGradientLeftTop);" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>
            
            <clipPath id="headingClip">
                <path class="linethick dimstroke" style="fill:black;fill-opacity:0.4;" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>
            </clipPath>
            <path class="linethick dimstroke" style="fill:black;fill-opacity:0.4;" d="M %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f L %f %f Z"/>]],
            crx(630), cry(0), crx(675), cry(45), crx(960), cry(55), crx(1245), cry(45), crx(1290), cry(0),
            crx(1000), cry(105), crx(1040), cry(59), crx(1250), cry(51), crx(1300), cry(0), crx(1920), cry(0), crx(1920), cry(20), crx(1400), cry(20), crx(1300), cry(105),
            crx(920), cry(105), crx(880), cry(59), crx(670), cry(51), crx(620), cry(0), crx(0), cry(0), crx(0), cry(20), crx(520), cry(20), crx(620), cry(105),
            crx(890), cry(59), crx(960), cry(62), crx(1030), cry(59), crx(985), cry (112), crx(1150), cry(112), crx(1100), cry(152), crx(820), cry(152), crx(780), cry(112), crx(935), cry(112),
            crx(890), cry(59), crx(960), cry(62), crx(1030), cry(59), crx(985), cry (112), crx(1150), cry(112), crx(1100), cry(152), crx(820), cry(152), crx(780), cry(112), crx(935), cry(112)
            )
        end
        newContent[#newContent+1] = StaticPaths
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
            -- Draw this in freelook now that it's less intrusive
            if nearPlanet then -- use real pitch, roll, and heading
                DrawRollLines (newContent, centerX, centerY, originalRoll, bottomText, nearPlanet)
            else -- use Relative Pitch and Relative Yaw
                DrawRollLines (newContent, centerX, centerY, roll, bottomText, nearPlanet)
            end
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
        local crx = ConvertResolutionX
        local cry = ConvertResolutionY

        local brakeValue = 0
        local flightStyle = GetFlightStyle()
        --if VertTakeOffEngine then flightStyle = flightStyle.."-VERTICAL" end
        --if CollisionSystem and not AutoTakeoff and not BrakeLanding and velMag > 20 then flightStyle = flightStyle.."-COLLISION ON" end
        --if UseExtra ~= "Off" then flightStyle = "("..UseExtra..")-"..flightStyle end
        --if TurnBurn then flightStyle = "TB-"..flightStyle end
        --if not stablized then flightStyle = flightStyle.."-DeCoupled" end

        local labelY1 = crx(99)
        local labelY2 = crx(80)
        local lineY = cry(85)
        local lineY2 = cry(31)
        local maxMass = 0
        local reqThrust = 0

        local mass = coreMass > 1000000 and round(coreMass / 1000000,2).."kT" or round(coreMass / 1000, 2).."T"
        if inAtmo then brakeValue = LastMaxBrakeInAtmo else brakeValue = LastMaxBrake end
        local brkDist, brkTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, brakeValue)
        if brkDist < 0 then brkDist = 0 end
        brakeValue = round((brakeValue / (coreMass * gravConstant)),2).."g"
        local maxThrust = Nav:maxForceForward()
        gravity = core.g()
        if gravity > 0.1 then
            reqThrust = coreMass * gravity
            reqThrust = round((reqThrust / (coreMass * gravConstant)),2).."g"
            maxMass = 0.5 * maxThrust / gravity
            maxMass = maxMass > 1000000 and round(maxMass / 1000000,2).."kT" or round(maxMass / 1000, 2).."T"
        end
        maxThrust = round((maxThrust / (coreMass * gravConstant)),2).."g"

        local accel = (vec3(core.getWorldAcceleration()):len() / 9.80665)
        gravity =  core.g()
        newContent[#newContent + 1] = [[<g class="dim txt txtend size14">]]
        if isRemote() == 1 and not RemoteHud then
            xg = ConvertResolutionX(1120)
            yg1 = ConvertResolutionY(55)
            yg2 = yg1+10
        elseif inAtmo then -- We only show atmo when not remote
            local atX = ConvertResolutionX(770)
            newContent[#newContent + 1] = svgText(crx(895), labelY1, "ATMO", "")
            newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke"  d="M %f %f l %f 0"/>]],crx(895),lineY,crx(-80))
            newContent[#newContent + 1] = svgText(crx(815), labelY2, stringf("%.1f%%", atmosDensity*100), "txtstart size20")
        end
        newContent[#newContent + 1] = svgText(crx(1025), labelY1, "GRAVITY", "txtstart")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(1025), lineY, crx(80))
        newContent[#newContent + 1] = svgText(crx(1105), labelY2, stringf("%.2fg", (gravity / 9.80665)), "size20")

        newContent[#newContent + 1] = svgText(crx(1125), labelY1, "ACCEL", "txtstart")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(1125), lineY, crx(80))
        newContent[#newContent + 1] = svgText(crx(1205), labelY2, stringf("%.2fg", accel), "size20") 

        newContent[#newContent + 1] = svgText(crx(695), labelY1, "BRK TIME", "")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(695),lineY, crx(-80))
        newContent[#newContent + 1] = svgText(crx(615), labelY2, stringf("%s", FormatTimeString(brkTime)), "txtstart size20") 
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(10), stringf("BrkTime: %s", FormatTimeString(brkTime)), "txtstart")
        newContent[#newContent + 1] = svgText(crx(635), cry(45), "TRIP", "")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(635),cry(31),crx(-90))
        if travelTime then
            newContent[#newContent + 1] = svgText(crx(532), cry(23), stringf("%s", FormatTimeString(travelTime)), "txtstart size20") 
        end
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(20), stringf("Trip: %.2f km", totalDistanceTrip), "txtstart") 
        --TODO: newContent[#newContent + 1] = svgText(ConvertResolutionX(700), ConvertResolutionY(30), stringf("Lifetime: %.2f kSU", (TotalDistanceTravelled / 200000)), "txtstart") 
        newContent[#newContent + 1] = svgText(crx(795), labelY1, "BRK DIST", "")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(795),lineY, crx(-80))
        newContent[#newContent + 1] = svgText(crx(715), labelY2, stringf("%s", getDistanceDisplayString(brkDist)), "txtstart size20") 
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(10), stringf("BrkDist: %s", getDistanceDisplayString(brkDist)) , "txtstart")
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(20), "Trip Time: "..FormatTimeString(flightTime), "txtstart") 
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(830), ConvertResolutionY(30), "Total Time: "..FormatTimeString(TotalFlightTime), "txtstart") 
        newContent[#newContent + 1] = svgText(crx(1285), cry(45), "MASS", "txtstart")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]],crx(1285), cry(31), crx(90))
        newContent[#newContent + 1] = svgText(crx(1388), cry(23), stringf("%s", mass), "size20") 
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(20), stringf("Mass: %s", mass), "txtstart") 
        --newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(10), stringf("Max Brake: %s",  brakeValue), "txtend") 
        newContent[#newContent + 1] = svgText(crx(1220), labelY1, "THRUST", "txtstart")
        newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]], crx(1220), lineY, crx(80))
        newContent[#newContent + 1] = svgText(crx(1300), labelY2, stringf("%s", maxThrust), "size20") 

        newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(175), flightStyle, "pbright txtbig txtmid size20")
        newContent[#newContent + 1] = "</g>"
    end

    function Hud.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
        if SelectedTab ~= "INFO" then return newContent end
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
        if isRemote() == 0 or RemoteHud then 
            local startX = ConvertResolutionX(OrbitMapX+10)
            local startY = ConvertResolutionY(OrbitMapY+20)
            local midX = ConvertResolutionX(OrbitMapX+10+OrbitMapSize/1.25)
            local height = 25
            newContent[#newContent + 1] = "<g class='txtstart size14 bright'>"
            newContent[#newContent + 1] = svgText(startX, startY, stringf("BrkTime: %s", FormatTimeString(brkTime)))
            newContent[#newContent + 1] = svgText(midX, startY, stringf("Trip: %.2f km", totalDistanceTrip)) 
            newContent[#newContent + 1] = svgText(startX, startY+height, stringf("Lifetime: %.2f kSU", (TotalDistanceTravelled / 200000))) 
            newContent[#newContent + 1] = svgText(midX, startY+ height, stringf("BrkDist: %s", getDistanceDisplayString(brkDist)))
            newContent[#newContent + 1] = svgText(startX, startY+height*2, "Trip Time: "..FormatTimeString(flightTime)) 
            newContent[#newContent + 1] = svgText(midX, startY+height*2, "Total Time: "..FormatTimeString(TotalFlightTime)) 
            newContent[#newContent + 1] = svgText(startX, startY+height*3, stringf("Mass: %s", mass)) 
            newContent[#newContent + 1] = svgText(midX, startY+height*3, stringf("Max Brake: %s",  brakeValue)) 
            newContent[#newContent + 1] = svgText(startX, startY+height*4, stringf("Max Thrust: %s", maxThrust)) 
            if gravity > 0.1 then
                newContent[#newContent + 1] = svgText(midX, startY+height*4, stringf("Max Thrust Mass: %s", (maxMass)))
                newContent[#newContent + 1] = svgText(startX, startY+height*5, stringf("Req Thrust: %s", reqThrust )) 
            else
                newContent[#newContent + 1] = svgText(midX, startY+height*5, "Max Mass: n/a") 
                newContent[#newContent + 1] = svgText(startX, startY+height*6, "Req Thrust: n/a") 
            end
        end
        newContent[#newContent + 1] = "</g></g>"
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
            tankY = fuelY
            DrawTank( fuelX, "Atmospheric ", "ATMO", atmoTanks, fuelTimeLeft, fuelPercent)
            DrawTank( fuelX, "Space Fuel T", "SPACE", spaceTanks, fuelTimeLeftS, fuelPercentS)
            DrawTank( fuelX, "Rocket Fuel ", "ROCKET", rocketTanks, fuelTimeLeftR, fuelPercentR)
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

    return Hud
end