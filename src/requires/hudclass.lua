function HudClass(Nav, c, u, s, atlas, antigrav, hover, shield, warpdrive, weapon,
    mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, 
    navCom, sysAddData, sysUpData, sysDestWid, sysIsVwLock, msqrt, round, svgText, play, addTable, saveableVariables,
    getDistanceDisplayString, FormatTimeString, elementsID, eleTotalMaxHp)

    local C = DUConstruct
    local gravConstant = 9.80665
    local Buttons = {}
    local ControlButtons = {}
    local SettingButtons = {}
    local TabButtons = {}
    local MapXRatio = nil
    local MapYRatio = nil
    local YouAreHere = nil
    local showSettings = false
    local settingsVariables = "none"
    local pipeMessage = ""
    local minAutopilotSpeed = 55 -- Minimum speed for autopilot to maneuver in m/s.  Keep above 25m/s to prevent nosedives when boosters kick in. Also used in apclass
    local maxBrakeDistance = 0
    local maxBrakeTime = 0
    local WeaponPanelID = nil
    local PrimaryR = SafeR
    local PrimaryG = SafeG
    local PrimaryB = SafeB
    local rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
    local rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]
    local totalDistanceTrip = 0
    local flightTime = 0
    local lastOdometerOutput = ""
    local lastTravelTime = systime()
    local repairArrows = false
    local showWarpWidget = false
    local activeRadar = false

    --Local Huds Functions

        local function ConvertResolutionX (v)
            if ResolutionX == 1920 then 
                return v
            else
                return round(ResolutionX * v / 1920, 0)
            end
        end
    
        local function ConvertResolutionY (v)
            if ResolutionY == 1080 then 
                return v
            else
                return round(ResolutionY * v / 1080, 0)
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
            local tankSlotIndex = 7
            local slottedTankType = ""
            local slottedTanks = 0        
            local fuelUpdateDelay = 90.0*hudTickRate
            local fuelTimeLeftR = {}
            local fuelPercentR = {}
            local fuelTimeLeftS = {}
            local fuelPercentS = {}
            local fuelTimeLeft = {}
            local fuelPercent = {}
            local fuelUsed = {}
            fuelUsed["atmofueltank"],fuelUsed["spacefueltank"],fuelUsed["rocketfueltank"] = 0,0,0

            local tankY = 0
        
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
                    local name = tankTable[i][tankName]
                    local slottedIndex = tankTable[i][tankSlotIndex]
                    for j = 1, slottedTanks do
                        if tankTable[i][tankName] == jdecode(u[slottedTankType .. "_" .. j].getWidgetData()).name then
                            slottedIndex = j
                            break
                        end
                    end

                    local curTime = systime()

                    if fuelTimeLeftTable[i] == nil or fuelPercentTable[i] == nil or (curTime - tankTable[i][tankLastTime]) > fuelUpdateDelay then
                        
                        local fuelMassLast
                        local fuelMass = 0

                        fuelMass = (eleMass(tankTable[i][tankID]) - tankTable[i][tankMassEmpty])
                        fuelMassLast = tankTable[i][tankLastMass]
                        local usedFuel = fuelMassLast > fuelMass or false
                        if usedFuel then 
                            fuelUsed[slottedTankType] = fuelUsed[slottedTankType]+(fuelMassLast - fuelMass) 
                        end

                        if slottedIndex ~= 0 then
                            local slotData = jdecode(u[slottedTankType .. "_" .. slottedIndex].getWidgetData())
                            fuelPercentTable[i] = slotData.percentage
                            fuelTimeLeftTable[i] = slotData.timeLeft
                            if fuelTimeLeftTable[i] == "n/a" then
                                fuelTimeLeftTable[i] = 0
                            end
                        else
                            fuelPercentTable[i] = mfloor(0.5 + fuelMass * 100 / tankTable[i][tankMaxVol])
                            if usedFuel then
                                fuelTimeLeftTable[i] = mfloor(
                                                        0.5 + fuelMass /
                                                            ((fuelMassLast - fuelMass) / (curTime - tankTable[i][tankLastTime])))
                            else
                                fuelTimeLeftTable[i] = 0 
                            end
                        end
                        tankTable[i][tankLastTime] = curTime
                        tankTable[i][tankLastMass] = fuelMass
                    end
                    if name == nameSearchPrefix then
                        name = stringf("%s %d", nameReplacePrefix, i)
                    end
                    if slottedIndex == 0 then
                        name = name .. " *"
                    end
                    local fuelTimeDisplay
                    fuelTimeDisplay = FormatTimeString(fuelTimeLeftTable[i])
                    if fuelTimeLeftTable[i] == 0 or fuelTimeDisplay == ">1y" then
                        fuelTimeDisplay = ""
                    end
                    if fuelPercentTable[i] ~= nil then
                        local colorMod = mfloor(fuelPercentTable[i] * 2.55)
                        local color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                        local class = ""
                        if ((fuelTimeDisplay ~= "" and fuelTimeLeftTable[i] < 120) or fuelPercentTable[i] < 5) then
                            class = "red "
                        end
                        local backColor = stringf("rgb(%d,%d,%d)", uclamp(mfloor((255-colorMod)/2.55),50,100), uclamp(mfloor(colorMod/2.55),0,50), 50)
                        local strokeColor = "rgb(196,0,255)"
                        if nameReplacePrefix == "ATMO" then
                            strokeColor = "rgb(0,188,255)"
                        elseif nameReplacePrefix == "SPACE" then
                            strokeColor = "rgb(239,255,0)"
                        end
                        local changed = false
                        if previous ~= strokeColor then
                            changed = true
                        end
                        previous = strokeColor
                        if BarFuelDisplay then
                            if changed then
                                y1 = y1 - 5
                                y2 = y2 - 5
                            end
                            tankMessage = tankMessage..stringf([[
                                <g class="pdim">                        
                                <rect fill=%s class="bar" stroke=%s x="%d" y="%d" width="170" height="20"></rect></g>
                                <g class="bar txtstart">
                                <rect fill=%s width="%d" height="18" x="%d" y="%d"></rect>
                                <text class="txtstart" fill="white" x="%d" y="%d" style="font-family:Play;font-size:14px">%s %s%%&nbsp;&nbsp;&nbsp;&nbsp;%s</text>
                                </g>]], backColor, strokeColor, x, y2, color, mfloor(fuelPercentTable[i]*1.7+0.5)-2, x+1, y2+1, x+5, y2+14, name, fuelPercentTable[i], fuelTimeDisplay
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
            if vSpdMeterX == 0 and vSpdMeterY == 0 then return end
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
            if circleRad == 0 then return end
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
            --if DisplayOdometer then 
                if nearPlanet then bottomText = "HDG" end
                newContent[#newContent + 1] = svgText(ConvertResolutionX(960) , ConvertResolutionY(100), yawC.."°" , "dim txt txtmid size14", "")
                newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(85), bottomText, "dim txt txtmid size20","")
            --end
            newContent[#newContent + 1] = [[</g>]]
        end

        local function DrawArtificialHorizon(newContent, originalPitch, originalRoll, centerX, centerY, nearPlanet, atmoYaw, speed)
            -- ** CIRCLE ALTIMETER  - Base Code from Discord @Rainsome = Youtube CaptainKilmar** 
            if circleRad == 0 then return end
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
            if rectX == 0 and rectY == 0 then return end
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
            if throtPosX == 0 and throtPosY == 0 then return end
            throt = mfloor(throt+0.5) -- Hard-round it to an int
            local y1 = throtPosY+10
            local y2 = throtPosY+20
            if isRemote() == 1 and not RemoteHud then
                y1 = 55
                y2 = 65
            end            
            local label = "CRUISE"
            local u = "km/h"
            local value = flightValue
            if (flightStyle == "TRAVEL" or flightStyle == "AUTOPILOT") then
                label = "THROT"
                u = "%"
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
            newContent[#newContent + 1] = svgText(throtPosX+10, y2, stringf("%.0f %s", value, u), "pbright txtstart")
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
            if throtPosX == 0 and throtPosY == 0 then return end
            local ys = throtPosY-10 
            local x1 = throtPosX + 10
            newContent[#newContent + 1] = svgText(0,0,"", "pdim txt txtend")
            if isRemote() == 1 and not RemoteHud then
                ys = 75
            end
            newContent[#newContent + 1] = svgText( x1, ys, mfloor(spd).." km/h" , "pbright txtbig txtstart")
        end
        local ecuBlink = 40
        local function DrawWarnings(newContent)

            newContent[#newContent + 1] = svgText(ConvertResolutionX(150), ConvertResolutionY(1070), stringf("ARCH Hud Version: %.3f", VERSION_NUMBER), "hudver")
            newContent[#newContent + 1] = [[<g class="warnings">]]
            if u.isMouseControlActivated() == 1 then
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
                local bkStr = ""
                if type(BrakeIsOn) == "string" then bkStr="-"..BrakeIsOn end
                newContent[#newContent + 1] = svgText(warningX, brakeY, "Brake Engaged"..bkStr, "warnings")
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

            if ECU then
                ecuBlink = ecuBlink -1
                if ecuBlink > 20 then 
                    newContent[#newContent + 1] = svgText(warningX, gyroY-20, "ECU Enabled", "warnings")
                elseif ecuBlink < 0 then 
                    ecuBlink = 40
                end
            end

            if GearExtended then

                if hasGear then
                    newContent[#newContent + 1] = svgText(warningX, gearY, "Gear Extended", "warn")
                else
                    newContent[#newContent + 1] = svgText(warningX, gearY, "Landed (G: Takeoff)", "warnings")
                end
            end
            if abvGndDet > -1 and (not antigravOn or coreAltitude < 100) then 
                local displayText = getDistanceDisplayString(Nav:getTargetGroundAltitude())
                newContent[#newContent + 1] = svgText(warningX, hoverY,"Hover Height: ".. displayText,"warn") 
            end

            if isBoosting then

                newContent[#newContent + 1] = svgText(warningX, ewarpY+20, "ROCKET BOOST ENABLED", "warn")
            end           

            if antigrav and not ExternalAGG and antigravOn and AntigravTargetAltitude ~= nil then

                local aggWarn = "warnings"
                if mabs(coreAltitude - antigrav.getBaseAltitude()) < 501 then aggWarn = "warn" end
                    newContent[#newContent + 1] = svgText(warningX, apY+40, stringf("Target Altitude: %d Singularity Altitude: %d", mfloor(AntigravTargetAltitude), mfloor(antigrav.getBaseAltitude())), aggWarn)
            end
            if Autopilot and AutopilotTargetName ~= "None" then
                newContent[#newContent + 1] = svgText(warningX, apY,  "Autopilot "..AutopilotStatus, "warn")
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
                        newContent[#newContent + 1] = svgText( warningX, apY + 80,"Throttle Up and Disengage Brake For Takeoff", "crit")
                    end
                else
                    newContent[#newContent + 1] = svgText(warningX, apY, "Altitude Hold: ".. stringf("%.1fm", HoldAltitude), "warn")
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
                    local str = "Brake Landing"
                    if alignHeading then str = str.."-Aligning" end
                    if apBrk then str = str.."-Drift Limited" end
                    newContent[#newContent + 1] = svgText(warningX, apY, str, "warnings")
                else
                    newContent[#newContent + 1] = svgText(warningX, apY, "Coast-Landing", "warnings")
                end
            end
            if ProgradeIsOn then
                newContent[#newContent + 1] = svgText(warningX, apY+20, "Prograde Alignment", "crit")
            end
            if RetrogradeIsOn then
                newContent[#newContent + 1] = svgText(warningX, apY, "Retrograde Alignment", "crit")
            end

            if collisionAlertStatus then

                local type
                if string.find(collisionAlertStatus, "COLLISION") then type = "warnings" else type = "crit" end
                newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, collisionAlertStatus, type)
            elseif atmosDensity == 0 then
                local intersectBody, atmoDistance = AP.checkLOS((constructVelocity):normalize())
                if atmoDistance ~= nil then

                    local displayText = getDistanceDisplayString(atmoDistance)
                    local travelTime = Kinematic.computeTravelTime(velMag, 0, atmoDistance)
                    local displayCollisionType = "Collision"
                    if intersectBody.noAtmosphericDensityAltitude > 0 then displayCollisionType = "Atmosphere" end
                    newContent[#newContent + 1] = svgText(warningX, turnBurnY+20, intersectBody.name.." "..displayCollisionType.." "..FormatTimeString(travelTime).." In "..displayText, "crit")
                end
            end
            if VectorToTarget and not IntoOrbit then
                newContent[#newContent + 1] = svgText(warningX, apY+60, VectorStatus, "warn")
            end

            if passengers and #passengers > 1 then

            end

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
            if showHud and DisplayOdometer then 
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
            end
            return newContent
        end

        local function getSpeedDisplayString(speed) -- TODO: Allow options, for now just do kph
            return mfloor(round(speed * 3.6, 0) + 0.5) .. " km/h" -- And generally it's not accurate enough to not twitch unless we round 0
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

        local function DisplayRoute(newContent)
            local checkRoute = AP.routeWP(true)
            if not checkRoute or #checkRoute==0 then return end
            local x = ConvertResolutionX(750)
            local y = ConvertResolutionY(360)
            if Autopilot or VectorToTarget then
                newContent[#newContent + 1] = svgText(x, y, "REMAINING ROUTE","pdim txtstart size20" )
            else
                newContent[#newContent + 1] = svgText(x, y, "LOADED ROUTE","pdim txtstart size20" )
            end
            for k,i in pairs(checkRoute) do
                y=y+20
                newContent[#newContent + 1] = svgText( x, y, k..". "..checkRoute[k], "pdim txtstart size20")
            end
        end

        local function DisplayHelp(newContent)
            local x = OrbitMapX+10
            local y = OrbitMapY+20
            local help = {}
            local helpAtmoGround = {"Alt-4: AutoTakeoff to Target"}
            local helpAtmoAir = { "Alt-6: Altitude hold at current altitude", "Alt-6-6: Altitude Hold at 11% atmosphere", 
                                "Alt-Q/E: Hard Bankroll left/right till released", "Alt-S: 180 deg bank turn"}
            local helpSpace = {"Alt-6: Orbit at current altitude", "Alt-6-6: Orbit at LowOrbitHeight over atmosphere","G: Raise or lower landing gear", "Alt-W: Toggle prograde align", "Alt-S: Toggle retrograde align / Turn&Burn (AP)"}
            local helpGeneral = {"", "------------------ALWAYS--------------------", "Alt-1: Increment Interplanetary Helper", "Alt-2: Decrement Interplanetary Helper", "Alt-Shift 1: Show passengers on board","Alt-Shift-2: Deboard passengers",
                                "Alt-3: Toggle Vanilla Widget view", "Alt-4: Autopilot to IPH target", "Alt-Shift-3: Show docked ships","Alt-Shift-4: Undock all ships",
                                "Alt-5: Lock Pitch at current pitch","Alt-Shift-5: Lock pitch at preset pitch","Alt-7: Toggle Collision System on and off", "Alt-8: Toggle ground stabilization (underwater flight)",
                                "B: Toggle rocket boost on/off","CTRL: Toggle Brakes on and off. Cancels active AP", "LAlt: Tap to shift freelook on and off", 
                                "Shift: Hold while not in freelook to see Buttons", "L: Toggle lights on and off", "Type /commands or /help in lua chat to see text commands"}
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
                if shield then
                    table.insert(help,"Alt-Shift-6: Vent shields")
                    if not AutoShieldToggle then table.insert(help,"Alt-Shift-7: Toggle shield off/on") end
                end
            end
            if CustomTarget ~= nil then
                table.insert(help, "Alt-Shift-8: Add current IPH target to Route")
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
            local orbitMapX = OrbitMapX
            local orbitMapY = OrbitMapY
            local orbitMapSize = OrbitMapSize -- Always square
            local pad = 4

            local orbitInfoYOffset = 15
            local x = 0
            local y = 0
            local rx, ry, scale, xOffset

            local tempOrbit

            local function orbitInfo(type)
                local alt, time, speed, line, class, textX
                if type == "Periapsis" then
                    alt = tempOrbit.periapsis.altitude
                    time = tempOrbit.timeToPeriapsis
                    speed = tempOrbit.periapsis.speed
                    class = "txtend"
                    line = 12
                    textX = math.min(x,orbitMapX + orbitMapSize - (planet.radius/scale) - pad*2)
                else
                    alt = tempOrbit.apoapsis.altitude
                    time = tempOrbit.timeToApoapsis
                    speed = tempOrbit.apoapsis.speed
                    line = -12
                    class = "txtstart"
                    textX = x
                end
                if velMag < 1 then time = 0 end
                newContent[#newContent + 1] = stringf(
                    [[<line class="pdim linethin" style="stroke:white" x1="%f" y1="%f" x2="%f" y2="%f"/>]],
                    textX + line, y - 5, x, y - 5)
                newContent[#newContent + 1] = stringf(
                    [[<line class="pdim linethin" x1="%f" y1="%f" x2="%f" y2="%f"/>]],
                    textX - line*4, y+2, x, y+2)
                newContent[#newContent + 1] = svgText(textX, y, type, class)
                x = textX - line*2
                y = y + orbitInfoYOffset
                local displayText = getDistanceDisplayString(alt)
                newContent[#newContent + 1] = svgText(x, y, displayText, class)
                y = y + orbitInfoYOffset
                newContent[#newContent + 1] = svgText(x, y, FormatTimeString(time), class)
                y = y + orbitInfoYOffset
                newContent[#newContent + 1] = svgText(x, y, getSpeedDisplayString(speed), class)
            end

            local targetHeight = orbitMapSize*1.5
            if SelectedTab == "INFO" then
                targetHeight = 25*10
            end
            if SelectedTab == "ORBIT" and coreAltitude < planet.spaceEngineMinAltitude then return newContent end
            if SelectedTab ~= "HIDE" then
                newContent[#newContent + 1] = [[<g class="pbright txtorb txtmid">]]
                -- Draw a darkened box around it to keep it visible
                newContent[#newContent + 1] = stringf(
                                                '<rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" class="dimfill brightstroke" style="stroke-width:3;fill-opacity:0.3;" />',
                                                orbitMapSize*2, targetHeight, orbitMapX, orbitMapY)
                -- And another inner box for clipping
                newContent[#newContent + 1] = stringf(
                                                [[<clippath id="orbitRect">
                                                <rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" class="dimfill brightstroke" style="stroke-width:3;fill-opacity:0.3;" />
                                                </clippath>]],
                                                orbitMapSize*2, targetHeight, orbitMapX, orbitMapY)
            end

            local orbitMapHeight = orbitMapSize*1.5
            local orbitMapWidth = orbitMapSize*2
            local orbitHalfHeight = orbitMapHeight/2
            local orbitHalfWidth = orbitMapSize -- Just to keep things consistent
            local orbitMidX = orbitMapX + orbitHalfWidth
            local orbitMidY = orbitMapY + orbitHalfHeight
            local orbitMaxX = orbitMapX + orbitMapWidth
            local orbitMaxY = orbitMapY + orbitMapHeight
            if SelectedTab == "ORBIT" then
                -- If orbits are up, let's try drawing a mockup
                
                orbitMapY = orbitMapY + pad
                rx = orbitMapSize / 2
                xOffset = 0
        
                tempOrbit = {}
                tempOrbit.periapsis = {}
                tempOrbit.apoapsis = {}
                if orbit ~= nil then -- Clone it so we don't edit it as we replace extreme values
                    if orbit.periapsis ~= nil then
                        tempOrbit.periapsis.altitude = orbit.periapsis.altitude
                        tempOrbit.periapsis.speed = orbit.periapsis.speed
                    end
                    if orbit.apoapsis ~= nil then
                        tempOrbit.apoapsis.altitude = orbit.apoapsis.altitude
                        tempOrbit.apoapsis.speed = orbit.apoapsis.speed
                    end
                    tempOrbit.period = orbit.period
                    tempOrbit.eccentricity = orbit.eccentricity
                    tempOrbit.timeToApoapsis = orbit.timeToApoapsis
                    tempOrbit.timeToPeriapsis = orbit.timeToPeriapsis
                    tempOrbit.eccentricAnomaly = orbit.eccentricAnomaly
                    tempOrbit.trueAnomaly = orbit.trueAnomaly
                end
                if tempOrbit.periapsis == nil then 
                    tempOrbit.periapsis = {}
                    tempOrbit.periapsis.altitude = -planet.radius
                    tempOrbit.periapsis.speed = MaxGameVelocity -- Don't show it
                end
                if tempOrbit.eccentricity == nil then
                    tempOrbit.eccentricity = 1
                end
                if tempOrbit.apoapsis == nil then
                    tempOrbit.apoapsis = {}
                    tempOrbit.apoapsis.altitude = coreAltitude
                    tempOrbit.apoapsis.speed = 0
                end
                if velMag < 1 then
                    tempOrbit.apoapsis.altitude = coreAltitude -- Prevent flicker when stopped
                    tempOrbit.apoapsis.speed = 0
                end

                
                if tempOrbit.apoapsis.altitude then
                
                    scale = (tempOrbit.apoapsis.altitude + tempOrbit.periapsis.altitude + (planet.radius) * 2) / (rx * 2)
                    ry = ((planet.radius) + tempOrbit.apoapsis.altitude) / scale *(1 - tempOrbit.eccentricity)
                    -- ry is a straight up distance from center multiplied by scale, then eccentricity
                    xOffset = rx - tempOrbit.periapsis.altitude / scale - (planet.radius) / scale

                    local apsisRatio = math.pi
                    if tempOrbit.period ~= nil and tempOrbit.period > 0 and tempOrbit.timeToApoapsis ~= nil then
                        --apsisRatio = (tempOrbit.timeToApoapsis / tempOrbit.period) * 2 * math.pi
                        -- So, this is kinda wrong.  Sorta.  It's a ratio representing where we are in the orbit
                        -- So that 0% and 100% are both at apoapsis, 50% is at periapsis
                        -- The problem is, when we're 25% through the orbit by time, we do not want to be 25% through the circle
                        -- Because speeds are slower near apoapsis and we spend more time near there if eccentric

                        -- I'm p sure one of the orbit params is an angle representing where we are on the circle
                        -- The true anomaly is the angle between the direction of periapsis and the current position
                        -- eccentricAnomaly already exists and is... the same thing... ?
                        apsisRatio = tempOrbit.eccentricAnomaly -- But it seems to be based on periapsis?
                        -- Ahhh weird.  It goes up to pi and back down to negative pi... 
                        -- Nope, it's 0 to pi... interesting... 
                        -- So we need to ... conditionally do something depending on which one it's going to
                        -- If periapsis is next, do 2pi-eccentric
                        if tempOrbit.timeToPeriapsis < tempOrbit.timeToApoapsis then
                            apsisRatio = (2*math.pi)-apsisRatio
                        end
                        
                        -- So, this describes a position on a non-eccentric orbit
                        -- The X value on that outer orbit is correct
                        -- But the angle itself is not correct for determining that on an ellipse... 
                    end
                    -- Handle nans and flickering at low speeds
                    if velMag < 1 or apsisRatio ~= apsisRatio then apsisRatio = math.pi end
                    -- x = xr * cos(t)
                    -- y = yr * sin(t)
                    local shipX = -rx * math.cos(apsisRatio) + orbitMapX + orbitHalfWidth + pad
                    local shipY = ry * math.sin(apsisRatio) + orbitMapY + orbitHalfHeight + pad
        
                    local ellipseColor = ""
                    --if orbit.periapsis.altitude <= 0 then
                    --    ellipseColor = 'redout'
                    --end
                    newContent[#newContent + 1] = '<g clip-path="url(#orbitRect)">'
                    newContent[#newContent + 1] = stringf(
                                                    [[<ellipse class="%s line" cx="%f" cy="%f" rx="%f" ry="%f"/>]],
                                                    ellipseColor, orbitMapX + orbitMapSize + pad,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, rx, ry)
                    if ry < 1 then
                        -- Draw a line instead, since the ellipse won't render
                        newContent[#newContent + 1] = stringf(
                                                    [[<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="red"/>]],
                                                    orbitMapX + orbitMapSize + pad - xOffset,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad,
                                                    shipX, shipY)
                    end
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="%f" stroke="white" stroke-width="1" fill="rgb(0,150,200)" opacity="0.5" />',
                                                    orbitMapX + orbitMapSize + pad - xOffset,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, (planet.radius+planet.noAtmosphericDensityAltitude) / scale)
                    newContent[#newContent + 1] = stringf(
                                                    '<clipPath id="planetClip"><circle cx="%f" cy="%f" r="%f" /></clipPath>',
                                                    orbitMapX + orbitMapSize + pad - xOffset,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, (planet.radius+planet.noAtmosphericDensityAltitude) / scale)
                    newContent[#newContent + 1] = stringf(
                                                    [[<ellipse class="%s line" cx="%f" cy="%f" rx="%f" ry="%f" clip-path="url(#planetClip)"/>]],
                                                    "redout", orbitMapX + orbitMapSize + pad,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, rx, ry)
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="%f" stroke="black" stroke-width="1" fill="rgb(0,100,150)" />',
                                                    orbitMapX + orbitMapSize + pad - xOffset,
                                                    orbitMapY + orbitMapSize*1.5 / 2 + pad, planet.radius / scale)
                    newContent[#newContent + 1] = '</g>' -- The rest doesn't really need clipping hopefully
                    local planetsize = math.floor(planet.radius / scale + 0.5)

                    x = orbitMapX + orbitMapSize + pad*4 + rx -- Aligning left makes us need more padding... for some reason... 
                    y = orbitMapY + orbitMapSize*1.5 / 2 + 5 + pad

                    if tempOrbit.apoapsis ~= nil and tempOrbit.apoapsis.speed < MaxGameVelocity then
                        orbitInfo("Apoapsis")
                    end
            
                    y = orbitMapY + orbitMapSize*1.5 / 2 + 5 + pad
                    x = orbitMapX + orbitMapSize - pad*2 - rx
            
                    if tempOrbit.periapsis ~= nil and tempOrbit.periapsis.speed < MaxGameVelocity and tempOrbit.periapsis.altitude > 0 then
                        orbitInfo("Periapsis")
                    end
            
                    -- Add a label for the planet
                    newContent[#newContent + 1] = svgText(orbitMapX + orbitMapSize + pad, orbitMapY+20 + pad,planet.name, "txtorbbig")
            
                    
                    newContent[#newContent + 1] = stringf(
                                                    '<circle cx="%f" cy="%f" r="2" stroke="black" stroke-width="1" fill="white" />',
                                                    shipX,
                                                    shipY)
                    
            
                    newContent[#newContent + 1] = [[</g>]]
                    -- Once we have all that, we should probably rotate the entire thing so that the ship is always at the bottom so you can see AP and PE move?
                    return newContent
                else
                    newContent[#newContent + 1] = '<g clip-path="url(#orbitRect)">'
                    -- There is no apoapsis, which means we're escaping (or approaching)
                    -- The planet should end up on the far left and we show a line indicating how close they will pass/are to the planet
                    -- Or, render the Galaxymap very small
                    local GalaxyMapHTML = "" -- No starting SVG tag so we can add it where we want it
                    -- Figure out our scale here... 
                    local xRatio = 1.2 * (maxAtlasX - minAtlasX) / (orbitMapSize*2) -- Add 10% for padding
                    local yRatio = 1.4 * (maxAtlasY - minAtlasY) / (orbitMapSize*1.5) -- Extra so we can get ion back in
                    for k, v in pairs(atlas[0]) do
                        if v.center then -- Only planets and stuff
                            -- Draw a circle at the scaled coordinates
                            local x = orbitMapX + orbitMapSize + (v.center.x / xRatio)
                            local y = orbitMapY + orbitMapSize*1.5/2 + (v.center.y / yRatio)
                            GalaxyMapHTML =
                                GalaxyMapHTML .. '<circle cx="' .. x .. '" cy="' .. y .. '" r="' .. (v.radius / xRatio) * 30 ..
                                    '" stroke="white" stroke-width="1" fill="blue" />'
                            if not string.match(v.name, "Moon") and not string.match(v.name, "Sanctuary") and not string.match (v.name, "Space") then
                                GalaxyMapHTML = GalaxyMapHTML .. "<text x='" .. x .. "' y='" .. y + (v.radius / xRatio) * 30 + 20 ..
                                                    "' font-size='12' fill=" .. rgb .. " text-anchor='middle' font-family='Montserrat'>" ..
                                                    v.name .. "</text>"
                            end
                        end
                    end
                    -- Draw a 'You Are Here' - face edition
                    local pos = vec3(C.getWorldPosition())
                    local x = orbitMapX + orbitMapSize + pos.x / xRatio
                    local y = orbitMapY + orbitMapSize*1.5/2 + pos.y / yRatio
                    GalaxyMapHTML = GalaxyMapHTML .. '<circle cx="' .. x .. '" cy="' .. y ..
                                        '" r="2" stroke="white" stroke-width="1" fill="red"/>'
                    GalaxyMapHTML = GalaxyMapHTML .. "<text x='" .. x .. "' y='" .. y - 10 ..
                                        "' font-size='14' fill='darkred' text-anchor='middle' font-family='Bank' font-weight='bold'>You Are Here</text>"
                    
                    MapXRatio = xRatio
                    MapYRatio = yRatio
                    -- And, if we can, draw a velocity line
                    -- We would need to project velocity on the plane of 0,0,1
                    -- Or the simplest, laziest way.  Project the point they'd be at after a while
                    local futurePoint = pos + constructVelocity*1000000
                    local x2 = orbitMapX + orbitMapSize + futurePoint.x / xRatio
                    local y2 = orbitMapY + orbitMapSize*1.5/2 + futurePoint.y / yRatio
                    GalaxyMapHTML = GalaxyMapHTML .. '<line x1="' .. x .. '" y1="' .. y ..
                                        '" x2="' .. x2 .. '" y2="' .. y2 .. '" stroke="purple" stroke-width="1"/>'
                    newContent[#newContent + 1] = GalaxyMapHTML
                    newContent[#newContent + 1] = '</g>'
                end
            elseif SelectedTab == "INFO" then
                newContent = HUD.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
            elseif SelectedTab == "HELP" then
                newContent = DisplayHelp(newContent)
            elseif SelectedTab == "SCOPE" then
                newContent[#newContent + 1] = '<g clip-path="url(#orbitRect)">'
                local fov = scopeFOV
                -- Sort the atlas by distance so closer planets draw on top
                
                -- If atmoDensity == 0, this already gets sorted in a hudTick
                if atmosDensity > 0 then
                    table.sort(planetAtlas, function(a1,b2) local a,b = a1.center,b2.center return (a.x-worldPos.x)^2+(a.y-worldPos.y)^2+(a.z-worldPos.z)^2 < (b.x-worldPos.x)^2+(b.y-worldPos.y)^2+(b.z-worldPos.z)^2  end)
                end

                local data = {} -- structure for text data which gets built first
                local ySorted = {} -- structure to sort by Y value to help prevent line overlaps
                local planetTextWidth = 120 -- Just an estimate, we calc later, but need this before we calc
                
                -- For finding the planet closest to the cursor
                local minCursorDistance = nil
                local minCursorData = nil

                -- Iterate backwards to build text, so nearest planets get priority on positioning
                -- It's already sorted backwards (nearest things are first)
                for i,v in ipairs(planetAtlas) do
                    

                    local target =  (v.center)-worldPos -- +v.radius*constructForward
                    local targetDistance = target:len()
                    local targetN = target:normalize()
                   
                    local horizontalRight = target:cross(constructForward):normalize()
                    local rollRad = math.acos(horizontalRight:dot(constructRight))
                    if rollRad ~= rollRad then rollRad = 0 end -- I don't know why this would fail but it does... so this fixes it... 
                    if horizontalRight:cross(constructRight):dot(constructForward) < 0 then rollRad = -rollRad end

                    local flatlen = target:project_on_plane(constructForward):len()
                    -- Triangle math is a bit more efficient than vector math, we just have a triangle with hypotenuse targetDistance
                    -- and the opposite leg is flatlen, so asin gets us the angle
                    -- We then sin it with rollRad to prevent janky square movement when rolling
                    local xAngle = math.sin(rollRad)*math.asin(flatlen/targetDistance)*constants.rad2deg
                    local yAngle = math.cos(rollRad)*math.asin(flatlen/targetDistance)*constants.rad2deg
                    -- These only output from 0 to 90 so we need to handle quadrants
                    if targetN:dot(constructForward) < 0 then
                        -- If it's in top or bottom quadrant, ie yAngle is 90 or -90ish, do this...
                        
                        yAngle = 90*math.cos(rollRad) + (90*math.cos(rollRad) - yAngle)
                        xAngle = 90*math.sin(rollRad) + (90*math.sin(rollRad) - xAngle)
                    end

                    local x = orbitMidX + (xAngle/fov)*orbitMapHeight
                    local y = orbitMidY + (yAngle/fov)*orbitMapHeight

                    local cursorDistance = ((x-orbitMidX)*(x-orbitMidX))+((y-orbitMidY)*(y-orbitMidY))
                    
                    -- Get the view angle from the center to the edge of a planet using trig
                    local topAngle = math.asin((v.radius+v.surfaceMaxAltitude)/targetDistance)*constants.rad2deg
                    if topAngle ~= topAngle then topAngle = fov end
                    local size = topAngle/fov*orbitMapHeight

                    local atmoAngle = math.asin((v.atmosphereRadius)/targetDistance)*constants.rad2deg
                    if atmoAngle ~= atmoAngle then atmoAngle = topAngle end -- hide atmo if inside it
                    local atmoSize = atmoAngle/fov*orbitMapHeight
                    --local nearestDistance = targetDistance - v.radius - math.max(v.surfaceMaxAltitude,v.noAtmosphericDensityAltitude)
                    --if nearestDistance < 0 then nearestDistance = targetDistance - v.radius - v.surfaceMaxAltitude end
                    --if nearestDistance < 0 then nearestDistance = targetDistance - v.radius end
                    --if v.name == "Teoma" then p(x .. "," .. y .. " - " .. xAngle .. ", " .. yAngle) end

                    -- Seems useful to give the distance to the atmo, land, etc instead of to the c
                    -- But it looks weird and I can't really label what it is, it'd take up too much space
                    local distance = getDistanceDisplayString(targetDistance,1)
                    local displayString = v.name
                    
                    -- Calculate whether or not we even display this planet.  In a really convoluted way.
                    local displayY = false
                    -- TODO: Simplify this somehow... 
                    if y > orbitMapY then
                        if y > orbitMaxY then
                            if y - atmoSize <= orbitMaxY then
                                displayY = true
                            end
                        else
                            displayY = true
                        end
                    else
                        if y+atmoSize >= orbitMapY then
                            displayY = true
                        end
                    end
                    local displayX = false
                    local tx = x
                    if v.systemId == 0 then
                        tx = x + planetTextWidth -- Don't stop showing til the text is offscreen
                    else
                        tx = x - planetTextWidth -- Still just an estimated max textWidth... we don't know yet how long it is
                    end
                    if tx+planetTextWidth > orbitMapX then
                        if tx+planetTextWidth > orbitMaxX then
                            if tx-atmoSize-planetTextWidth <= orbitMaxX then
                                displayX = true
                            end
                        else
                            displayX = true
                        end
                    else
                        if tx+atmoSize+planetTextWidth >= orbitMapX then
                            displayX = true
                        end
                    end

                    -- setup what we need for the distance line, because it draws even if the planet doesn't
                    local sortData = {}
                    sortData.x = x
                    sortData.y = y
                    sortData.planet = v
                    sortData.atmoSize = atmoSize

                    if not minCursorDistance or cursorDistance < minCursorDistance then
                        minCursorDistance = cursorDistance
                        minCursorData = sortData
                    end

                    if displayX and displayY then
                        local hoverSize = math.max(atmoSize,5) -- This 5px hoversize for small planets could probably go up a bit
                        if (cursorDistance) < hoverSize*hoverSize then
                        --if x-hoverSize <= orbitMidX and x+hoverSize >= orbitMidX and y-hoverSize <= orbitMidY and y+hoverSize >= orbitMidY then
                            displayString = displayString .. " - " .. distance
                        end
                        sortData.size = size
                        sortData.i = i
                        sortData.displayString = displayString
                        sortData.distance = distance
                        sortData.visible = true
                        ySorted[#ySorted+1] = sortData
                    else
                        sortData.visible = false
                    end
                end

                local anyHovered = false
                -- Setup text in y sort order
                table.sort(ySorted,function(a,b) return a.y<b.y end)
                -- Again, we draw the lowest Y first because it prevents the lines from crossing somehow
                -- And drawing them in this order makes sure that the upper-most planets get the upper-most labels
                for k,d in ipairs(ySorted) do
                    local v,size,i,atmoSize,x,y,displayString,distance = d.planet,d.size,d.i,d.atmoSize,d.x,d.y,d.displayString,d.distance

                    local textX, textY, textWidth, textHeight
                    local xMod = 15 -- Planet names are 15px right or left, for moons or planets respectively
                    local class = "pdim" -- Planet class is pdim
                    if v.systemId ~= 0 then -- This is moons
                        textWidth = ConvertResolutionX(string.len(displayString)*5) -- Smaller text
                        xMod = -(15+textWidth) -- Drawn left
                        textHeight = ConvertResolutionY(10) -- Smaller text
                        class = "pdimfill" -- Darker text
                    else
                        textWidth = ConvertResolutionX(string.len(displayString)*9)
                        textHeight = ConvertResolutionY(15)
                    end
                    -- Only clamp things that are large enough to matter (larger than the text)
                    if size*2 > textWidth then -- Size is a radius, so *2 for fitting text in it
                        -- and center text, if it's that big
                        -- Try to clamp it within the planet itself after clamping to screen
                        textX = uclamp(x,orbitMapX+textWidth/2,orbitMaxX-textWidth/2)
                        textY = uclamp(y,orbitMapY+textHeight,orbitMaxY-5)
                        textX = uclamp(textX, x-size+textWidth/2, x+size-textWidth/2)
                        textY = uclamp(textY, y-size+textHeight, y+size)
                    else
                        textX = x+xMod
                        textY = y
                    end
                    for tpi,d in pairs(data) do
                        local textPos = d.textPositions
                        local yDiff = textPos.y-textY
                        if tpi ~= i and mabs(yDiff) < textPos.height and textPos.x+textPos.width > textX and textPos.x < textX+textWidth then
                            if size > textWidth then
                                textY = uclamp(textY+textHeight,orbitMapY+15,orbitMaxY-5) -- These clamped values are meant to be on top
                            else
                                textY = textPos.y+textPos.height+1
                            end
                        end
                    end
                    local hovered = displayString ~= v.name or (textX <= orbitMidX and textX+textWidth >= orbitMidX and textY-textHeight <= orbitMidY and textY >= orbitMidY)
                    d.hovered = hovered
                    local opacityMult = 1
                    if hovered then
                        opacityMult=2
                        if size*2 < textWidth then opacityMult = 10 end -- If v small, make it v bright so you can see it
                        if displayString == v.name then -- If it's hovered and we don't have a distance in it yet, add one
                            displayString = displayString .. " - " .. distance
                        end
                        class = "pbright"
                        -- Sadly we need to redo the size here, I don't like that
                        -- But we need textX to be right to know if it's hovered
                        -- Then if it's hovered can change where textX is displayed
                        if v.systemId ~= 0 then
                            textWidth = ConvertResolutionX(string.len(displayString)*5)
                            xMod = -(15+textWidth)
                        else
                            textWidth = ConvertResolutionX(string.len(displayString)*7) -- When there are spaces, it's less long per char ... vs the *9 for just names
                        end
                        if size*2 > textWidth then -- Only clamp things that are large enough to matter (larger than the text)
                            textX = uclamp(x,orbitMapX+textWidth/2,orbitMaxX-textWidth/2)
                            textX = uclamp(textX, x-size+textWidth/2, x+size-textWidth/2) -- Center text if it can fit, no xMod
                        else
                            textX = x+xMod
                        end
                    end

                    data[i] = {}
                    data[i].textPositions = {} -- lua is very slow at inline declare so we do it outline
                    data[i].textPositions.y = textY
                    data[i].textPositions.x = textX
                    data[i].textPositions.width = textWidth
                    data[i].textPositions.height = textHeight
                    data[i].output = ""

                    if size*2 > textWidth then class = class .. " txtmid" else class = class .. " txtstart" end
                    
                    
                    if atmoSize-size > 2 then -- Only draw atmo if it's big enough to even show up
                        data[i].output = stringf('<circle cx="%f" cy="%f" r="%f" stroke-width="1" stroke="%s" stroke-opacity="%f" fill="url(#RadialAtmo)" />', -- fill-opacity="0.5"
                                                        x, y, atmoSize, rgbdim, 0.1*opacityMult)
                    end

                    data[i].output = data[i].output .. stringf('<circle cx="%f" cy="%f" r="%f" stroke="%s" stroke-width="1" stroke-opacity="%f" fill="url(#RadialPlanetCenter)" />',
                                                        x, y, size, rgbdim, 0.2*opacityMult)
                    
                     -- If it's centered text, don't bother with a line
                    if v.systemId == 0 then
                        data[i].output = data[i].output .. stringf([[<text x='%f' y='%f'
                                font-size='12' fill='%s' class='%s' font-family='Montserrat'>%s</text>]]
                                , textX, textY, rgb, class, displayString)
                        if size*2 <= textWidth then
                            data[i].output = data[i].output .. stringf("<path class='linethin dimstroke' d='M %f %f L %f %f L %f %f' />", 
                                                                    textX+textWidth, textY+2, textX, textY+2, x, y)
                        end
                    else
                        data[i].output = data[i].output .. stringf([[<text x='%f' y='%f'
                                font-size='8' fill='%s' class='%s' font-family='Montserrat'>%s</text>]]
                                , textX, textY, rgbdim, class, displayString)
                        if size*2 <= textWidth then
                            data[i].output = data[i].output .. stringf("<path class='linethin dimstroke' d='M %f %f L %f %f L %f %f' />", 
                            textX, textY+2, textX+textWidth, textY+2, x, y)
                        end
                    end
                    
                end

                -- draw everything.  Reverse order so furthest planets draw first
                for k=#planetAtlas,1,-1 do
                    if data[k] then
                        newContent[#newContent+1] = data[k].output
                    end
                end

                if minCursorData ~= nil and scopeFOV < 90 and not minCursorData.hovered then
                    -- If zoomed in, draw a line and distance label between the center and the nearest thing on screen
                    -- The distance is the orbital height if they were to go to that point
                    -- which is really minCursorDistance with some math to extrapolate it back out to a dist

                    -- But I'm a bit lazy.  How about we extrapolate out a scale for pixels to real distance
                    -- size should make that really easy
                    local scalar = minCursorData.planet.atmosphereRadius/minCursorData.atmoSize

                    local projAlt = msqrt(minCursorDistance)*scalar
                    local display = getDistanceDisplayString(projAlt,1)
                    local textWidth = ConvertResolutionX(math.max(string.len(display)*7,string.len(minCursorData.planet.name)*7))
                    local textHeight = ConvertResolutionY(12)

                    local textX = uclamp(minCursorData.x + (orbitMidX - minCursorData.x)/2,orbitMapX+textWidth/2,orbitMaxX-textWidth/2)
                    local textY = uclamp(minCursorData.y + (orbitMidY - minCursorData.y)/2,orbitMapY+textHeight*2,orbitMaxY-5)

                    newContent[#newContent + 1] = stringf("<path class='linethin dimstroke' stroke='white' d='M %f %f L %f %f' />", 
                            minCursorData.x, minCursorData.y, orbitMidX, orbitMidY)
                    --newContent[#newContent + 1] = stringf("<path class='linethin dimstroke' stroke='white' d='M %f %f L %f %f' />", 
                    --        textX+textWidth/2+1, textY-textHeight/2, orbitMidX, orbitMidY)
                    newContent[#newContent + 1] = stringf([[<text x='%f' y='%f'
                            font-size='12' fill='%s' class='txtmid' font-family='Montserrat'>%s</text>]]
                            , textX, textY, "white", display)
                    if not minCursorData.visible then
                        newContent[#newContent + 1] = stringf([[<text x='%f' y='%f'
                                font-size='12' fill='%s' class='txtmid' font-family='Montserrat'>%s</text>]]
                                , textX, textY-textHeight, "white", minCursorData.planet.name)
                    end
                end
                
                if velMag > 1 then
                    -- This does sorta work but, also draws retrograde and the arrow and also isn't scaled correctly 
                    --DrawPrograde(newContent, coreVelocity, velMag, orbitMidX, orbitMidY)
                    -- TODO: Rework DrawPrograde to be able to accept x,y values for the marker
                    local target = constructVelocity
                    local targetN = target:normalize()
                    local flatlen = target:project_on_plane(constructForward):len()
                    local horizontalRight = target:cross(constructForward):normalize()
                    local rollRad = math.acos(horizontalRight:dot(constructRight))
                    if rollRad ~= rollRad then rollRad = 0 end -- Again, idk how this could happen but it does
                    if horizontalRight:cross(constructRight):dot(constructForward) < 0 then rollRad = -rollRad end
                    local xAngle = math.sin(rollRad)*math.asin(flatlen/target:len())*constants.rad2deg
                    local yAngle = math.cos(rollRad)*math.asin(flatlen/target:len())*constants.rad2deg
                    
                    -- Fix quadrants
                    if targetN:dot(constructForward) < 0 then
                        -- If it's in top or bottom quadrant, ie yAngle is 90 or -90ish, do this...
                        
                        yAngle = 90*math.cos(rollRad) + (90*math.cos(rollRad) - yAngle)
                        xAngle = 90*math.sin(rollRad) + (90*math.sin(rollRad) - xAngle)
                    end

                    local x = orbitMidX + (xAngle/fov)*orbitMapHeight
                    local y = orbitMidY + (yAngle/fov)*orbitMapHeight
                    local dotSize = 14
                    local dotRadius = dotSize/2
                    -- TODO: stringf
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
                    newContent[#newContent + 1] = progradeDot
                end
                --Add a + to mark the center
                newContent[#newContent+1] = stringf("<line class='linethin dimstroke' x1='%f' y1='%f' x2='%f' y2='%f' />", 
                                                                            orbitMidX, orbitMidY-10, orbitMidX, orbitMidY+10)
                newContent[#newContent+1] = stringf("<line class='linethin dimstroke' x1='%f' y1='%f' x2='%f' y2='%f' />", 
                orbitMidX-10, orbitMidY, orbitMidX+10, orbitMidY)
                
                newContent[#newContent + 1] = '</g>'
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

        local function MakeTabButton(x, y, width, height, label)
            local newButton = {
                x = x, 
                y = y,
                width = width,
                height = height,
                label = label
            }
            TabButtons[label] = newButton
            return newButton
        end

        local function MakeButton(enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition, buttonList, class)
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
                hovered = false,
                class = class
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
                settingsVariables = "none"
                showHud = true
            end
        end

        local function ToggleButtons()
            showSettings = not showSettings 
            if showSettings then 
                Buttons = SettingButtons
                msgText = "Tap LMB to see Settings" 
                oldShowHud = showHud
            else
                Buttons = ControlButtons
                msgText = "Tap LMB to see Control Buttons"
                ToggleShownSettings()
                showHud = oldShowHud
            end
        end

        local function SettingsButtons()
            local function ToggleBoolean(v,k)

                v.set(not v.get())
                if v.get() then 
                    msgText = k.." set to true"
                else
                    msgText = k.." set to false"
                end
                if k == "showHud" then
                    oldShowHud = v.get()
                elseif k == "BrakeToggleDefault" then 
                    BrakeToggleStatus = BrakeToggleDefault
                end
            end
            local buttonHeight = 50
            local buttonWidth = 340 -- Defaults
            local x = 500
            local y = ResolutionY / 2 - 400
            local cnt = 0
            for k, v in pairs(saveableVariables("boolean")) do
                if type(v.get()) == "boolean" then
                    MakeButton(k, k, buttonWidth, buttonHeight, x, y,
                        function() return v.get() end, 
                        function() ToggleBoolean(v,k) end,
                        function() return true end, true) 
                    y = y + buttonHeight + 20
                    if cnt == 9 then 
                        x = x + buttonWidth + 20 
                        y = ResolutionY / 2 - 400
                        cnt = 0
                    else
                        cnt = cnt + 1
                    end
                end
            end
            MakeButton("Control View", "Control View", buttonWidth, buttonHeight, 10, ResolutionY / 2 - 500, function() return true end, 
                ToggleButtons, function() return true end, true)
            MakeButton("View Handling Settings", 'Hide Handling Settings', buttonWidth, buttonHeight, 10, ResolutionY / 2 - (500 - buttonHeight), 
                function() return showHandlingVariables end, function() ToggleShownSettings("handling") end, 
                function() return true end, true)
            MakeButton("View Hud Settings", 'Hide Hud Settings', buttonWidth, buttonHeight, 10, ResolutionY / 2 - (500 - buttonHeight*2), 
                function() return showHudVariables end, function() ToggleShownSettings("hud") end, 
                function() return true end, true)
            MakeButton("View Physics Settings", 'Hide Physics Settings', buttonWidth, buttonHeight, 10, ResolutionY / 2 - (500 - buttonHeight*3), 
                function() return showPhysicsVariables end, function() ToggleShownSettings("physics") end, 
                function() return true end, true)
        end
        
        local function ControlsButtons()
            local function AddNewLocation()
                -- Add a new location to SavedLocations
                local position = worldPos
                local name = planet.name .. ". " .. #SavedLocations
                if RADAR then name = RADAR.GetClosestName(name) end
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

            local function UpdatePosition(heading, saveAGG)
                ATLAS.UpdatePosition(nil, heading, saveAGG)
            end
            local function ClearCurrentPosition()
                -- So AutopilotTargetIndex is special and not a real index.  We have to do this by hand.
                    ATLAS.ClearCurrentPosition()
            end

           
            local function getAPEnableName(index)
                local checkRoute = AP.routeWP(true)
                if checkRoute and #checkRoute > 0 then return "Engage Route: "..checkRoute[1] end
                return "Engage Autopilot: " .. getAPName(index)
            end

            local function getAPDisableName(index)
                local checkRoute = AP.routeWP(true)
                if checkRoute and #checkRoute > 0 then return "Next Route Point: "..checkRoute[1] end
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
                        BrakeIsOn = "Follow Off"
                        autoRoll = autoRollPreference
                        GearExtended = OldGearExtended
                        if GearExtended then
                            Nav.control.deployLandingGears()
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
            -- TODO: This should use defined orbitMapHeight and Width vars but to move them out they'd have to be unlocal cuz we're out of locals
            -- But we know that height is orbitMapSize*1.5, width is orbitMapSize*2
            local orbitButtonSize = ConvertResolutionX(30)
            local orbitButtonX = OrbitMapX+OrbitMapSize*2+2
            local orbitButtonY = OrbitMapY+1
            MakeButton("+", "+", orbitButtonSize, orbitButtonSize, orbitButtonX, orbitButtonY+orbitButtonSize+1,
                                function() return false end, function() scopeFOV = scopeFOV/8 end, function() return SelectedTab == "SCOPE" end, nil, "ZoomButton")
            MakeButton("-", "-", orbitButtonSize, orbitButtonSize, orbitButtonX, orbitButtonY,
                                function() return false end, function() scopeFOV = math.min(scopeFOV*8,90) end, function() return SelectedTab == "SCOPE" end, nil, "ZoomButton")
            MakeButton("0", "0", orbitButtonSize, orbitButtonSize, orbitButtonX, orbitButtonY+orbitButtonSize*2+2,
                                function() return false end, function() scopeFOV = 90 end, function() return SelectedTab == "SCOPE" and scopeFOV ~= 90 end, nil, "ZoomButton")
            local brake = MakeButton("Enable Brake Toggle", "Disable Brake Toggle", buttonWidth, buttonHeight,
                                ResolutionX / 2 - buttonWidth / 2, ResolutionY / 2 + 350, function()
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
                ResolutionX / 2 - buttonWidth / 2 - 50 - brake.width, ResolutionY / 2 - buttonHeight + 380,
                function()
                    return ProgradeIsOn
                end, function() gradeToggle(1) end)
            MakeButton("Align Retrograde", "Disable Retrograde", buttonWidth, buttonHeight,
                ResolutionX / 2 - buttonWidth / 2 + brake.width + 50, ResolutionY / 2 - buttonHeight + 380,
                function()
                    return RetrogradeIsOn
                end, gradeToggle, function()
                    return atmosDensity == 0
                end) -- Hope this works
            apbutton = MakeButton(getAPEnableName, getAPDisableName, 600, 60, ResolutionX / 2 - 600 / 2,
                                    ResolutionY / 2 - 60 / 2 - 330, function()
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
                end, 600, 60, ResolutionX/2 - 600/2, 
                ResolutionY/2 - 60/2 - 330 + 60*i, function(b)
                    local index = getAtlasIndexFromAddition(b.apExtraIndex)
                    return index == AutopilotTargetIndex and (Autopilot or VectorToTarget or spaceLaunch or IntoOrbit)
                end, function(b)
                    local index = getAtlasIndexFromAddition(b.apExtraIndex)
                    local disable = AutopilotTargetIndex == index
                    AutopilotTargetIndex = index
                    ATLAS.UpdateAutopilotTarget()
                    AP.ToggleAutopilot()
                    -- Let buttons redirect AP, they're hard to do by accident
                    if not disable and not (Autopilot or VectorToTarget or spaceLaunch or IntoOrbit) then
                        AP.ToggleAutopilot()
                    end
                end, function()
                    return apButtonsHovered and (#AP.routeWP(true) == 0 or i==0)
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
                function() return false end, 
                function() UpdatePosition(nil) end, 
                function() return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                end)
            MakeButton("Save Heading", "Clear Heading", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y + apbutton.height + 20,
                function() return CustomTarget.heading ~= nil end, 
                function() if CustomTarget.heading ~= nil then UpdatePosition(false) else UpdatePosition(true) end end, 
                function() return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                end)
            MakeButton("Save AGG Alt", "Clear AGG Alt", 200, apbutton.height, apbutton.x + apbutton.width + 30, apbutton.y + apbutton.height*2 + 40,
                function() return CustomTarget.agg ~= nil end, 
                function() if CustomTarget.agg ~= nil then UpdatePosition(nil, false) else UpdatePosition(nil, true) end end, 
                function() return AutopilotTargetIndex > 0 and CustomTarget ~= nil and antigrav
                end)
            MakeButton("Clear Position", "Clear Position", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y,
                function()
                    return true
                end, ClearCurrentPosition, function()
                    return AutopilotTargetIndex > 0 and CustomTarget ~= nil
                end)
            MakeButton("Save Route", "Save Route", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y + apbutton.height*2 + 40, 
                function() return false end, function() AP.routeWP(false, false, 2) end, function() return #AP.routeWP(true) > 0 end)
            MakeButton("Load Route","Clear Route", 200, apbutton.height, apbutton.x - 200 - 30, apbutton.y + apbutton.height + 20,
                function()
                    return #AP.routeWP(true) > 0
                end, function() if #AP.routeWP(true) > 0 then AP.routeWP(false, true) elseif  Autopilot or VectorToTarget then 
                    msgText = "Disable Autopilot before loading route" return else AP.routeWP(false, false, 1) end end, function() return true end)   
            -- The rest are sort of standardized
            buttonHeight = 60
            buttonWidth = 300
            local x = 0
            local y = ResolutionY / 2 - 150
            MakeButton("Enable Check Damage", "Disable Check Damage", buttonWidth, buttonHeight, x, y - buttonHeight - 20, function()
                return ShouldCheckDamage
            end, function() ShouldCheckDamage = not ShouldCheckDamage end)
            MakeButton("View Settings", "View Settings", buttonWidth, buttonHeight, x, y, function() return true end, ToggleButtons)
            y = y + buttonHeight + 20
            MakeButton("Enable Turn and Burn", "Disable Turn and Burn", buttonWidth, buttonHeight, x, y, function()
                return TurnBurn
            end, ToggleTurnBurn)
            x = 10
            y = ResolutionY / 2 - 300
            MakeButton("Horizontal Takeoff Mode", "Vertical Takeoff Mode", buttonWidth, buttonHeight, ResolutionX/2-buttonWidth/2, y+20,
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
            -- prevent this button from being an option until you're in atmosphere
            MakeButton("Engage Orbiting", "Cancel Orbiting", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                    function()
                        return IntoOrbit
                    end, AP.ToggleIntoOrbit, function()
                        return (atmosDensity == 0 and nearPlanet)
                    end)
            y = ResolutionY / 2 - 150
            MakeButton("Glide Re-Entry", "Cancel Glide Re-Entry", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                function() return Reentry end, function() spaceLand = 1 gradeToggle(1) end, function() return (planet.hasAtmosphere and not inAtmo) end )
            y = y + buttonHeight + 20
            MakeButton("Parachute Re-Entry", "Cancel Parachute Re-Entry", buttonWidth, buttonHeight, x + buttonWidth + 20, y,
                function() return Reentry end, function() spaceLand = 2 gradeToggle(1) end, function() return (planet.hasAtmosphere and not inAtmo) end )
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
                return antigravOn end, AP.ToggleAntigrav, function()
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
                    iphCondition = "No Moons-Asteroids"
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


            -- Make tab buttons
            local tabHeight = ConvertResolutionY(20)
            local button = MakeTabButton(0, 0, ConvertResolutionX(70), tabHeight, "HELP")
            button = MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(80),tabHeight, "INFO")
            button = MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(70),tabHeight,"ORBIT")
            button = MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(70),tabHeight,"SCOPE")
            MakeTabButton(button.x + button.width,button.y,ConvertResolutionX(70),tabHeight,"HIDE")
        end


    local Hud = {}
    local StaticPaths = nil


    function Hud.HUDPrologue(newContent)
        if not notPvPZone then -- misnamed variable, fix later
            PrimaryR = PvPR
            PrimaryG = PvPG
            PrimaryB = PvPB
        else
            PrimaryR = SafeR
            PrimaryG = SafeG
            PrimaryB = SafeB
        end
        rgb = [[rgb(]] .. mfloor(PrimaryR + 0.6) .. "," .. mfloor(PrimaryG + 0.6) .. "," .. mfloor(PrimaryB + 0.6) .. [[)]]
        rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.8 + 0.5) .. "," .. mfloor(PrimaryG * 0.8 + 0.5) .. "," ..   mfloor(PrimaryB * 0.8 + 0.5) .. [[)]]    
        local bright = rgb
        local dim = rgbdim
        local dimmer = [[rgb(]] .. mfloor(PrimaryR * 0.4 + 0.5) .. "," .. mfloor(PrimaryG * 0.4 + 0.5) .. "," ..   mfloor(PrimaryB * 0.4 + 0.5) .. [[)]]   
        local brightOrig = rgb
        local dimOrig = rgbdim
        local dimmerOrig = dimmer
        if IsInFreeLook() and not brightHud then
            bright = [[rgb(]] .. mfloor(PrimaryR * 0.5 + 0.5) .. "," .. mfloor(PrimaryG * 0.5 + 0.5) .. "," ..
                        mfloor(PrimaryB * 0.5 + 0.5) .. [[)]]
            dim = [[rgb(]] .. mfloor(PrimaryR * 0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," ..
                    mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]
            dimmer = [[rgb(]] .. mfloor(PrimaryR * 0.2 + 0.5) .. "," .. mfloor(PrimaryG * 0.2 + 0.5) .. "," ..   mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]                        
        end

        -- When applying styles, apply color first, then type (e.g. "bright line")
        -- so that "fill:none" gets applied
        local crx = ConvertResolutionX
        local cry = ConvertResolutionY
            newContent[#newContent + 1] = stringf([[ <head> <style>body{margin: 0}svg{position:absolute;top:0;left:0;font-family:Montserrat;}.txt{font-size:10px;font-weight:bold;}.txttick{font-size:12px;font-weight:bold;}.txtbig{font-size:14px;font-weight:bold;}.altsm{font-size:16px;font-weight:normal;}.altbig{font-size:21px;font-weight:normal;}.line{stroke-width:2px;fill:none;stroke:%s}.linethick{stroke-width:3px;fill:none}.linethin{stroke-width:1px;fill:none}.warnings{font-size:26px;fill:red;text-anchor:middle;font-family:Bank;}.warn{fill:orange; font-size:24px}.crit{fill:darkred;font-size:28px}.bright{fill:%s;stroke:%s}text.bright{stroke:black; stroke-width:10px;paint-order:stroke;}.pbright{fill:%s;stroke:%s}text.pbright{stroke:black; stroke-width:10px;paint-order:stroke;}.dim{fill:%s;stroke:%s}text.dim{stroke:black; stroke-width:10px;paint-order:stroke;}.pdim{fill:%s;stroke:%s}text.pdim{stroke:black; stroke-width:10px;paint-order:stroke;}.red{fill:red;stroke:red}text.red{stroke:black; stroke-width:10px;paint-order:stroke;}.orange{fill:orange;stroke:orange}text.orange{stroke:black; stroke-width:10px;paint-order:stroke;}.redout{fill:none;stroke:red}.op30{opacity:0.3}.op10{opacity:0.1}.txtstart{text-anchor:start}.txtend{text-anchor:end}.txtmid{text-anchor:middle}.txtvspd{font-family:sans-serif;font-weight:normal}.txtvspdval{font-size:20px}.txtfuel{font-size:11px;font-weight:bold}.txtorb{font-size:12px}.txtorbbig{font-size:18px}.hudver{font-size:10px;font-weight:bold;fill:red;text-anchor:end;font-family:Bank}.msg{font-size:40px;fill:red;text-anchor:middle;font-weight:normal}.cursor{stroke:white}text{stroke:black; stroke-width:10px;paint-order:stroke;}.dimstroke{stroke:%s}.brightstroke{stroke:%s}.indicatorText{font-size:20px;fill:white}.size14{font-size:14px}.size20{font-size:20px}.topButton{fill:%s;opacity:0.5;stroke-width:2;stroke:%s}.topButtonActive{fill:url(#RadialGradientCenter);opacity:0.8;stroke-width:2;stroke:%s}.topButton text{font-size:13px; fill: %s; opacity:1; stroke-width:20px}.topButtonActive text{font-size:13px;fill:%s; stroke-width:0px; opacity:1}.indicatorFont{font-size:20px;font-family:Bank}.dimmer{stroke: %s;}.pdimfill{fill: %s;}.dimfill{fill: %s;}</style> </head> <body> <svg height="100%%" width="100%%" viewBox="0 0 %d %d"> <defs> <radialGradient id="RadialGradientCenterTop" cx="0.5" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/> <stop offset="100%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="RadialGradientRightTop" cx="1" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="ThinRightTopGradient" cx="1" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.2"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="RadialGradientLeftTop" cx="0" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.5"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="ThinLeftTopGradient" cx="0" cy="0" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.2"/> <stop offset="200%%" stop-color="black" stop-opacity="0"/> </radialGradient> <radialGradient id="RadialGradientCenter" cx="0.5" cy="0.5" r="1"> <stop offset="0%%" stop-color="%s" stop-opacity="0.8"/> <stop offset="100%%" stop-color="%s" stop-opacity="0.5"/> </radialGradient> <radialGradient id="RadialPlanetCenter" cx="0.5" cy="0.5" r="0.5"> <stop offset="0%%" stop-color="%s" stop-opacity="1"/> <stop offset="100%%" stop-color="%s" stop-opacity="1"/> </radialGradient> <radialGradient id="RadialAtmo" cx="0.5" cy="0.5" r="0.5"> <stop offset="0%%" stop-color="%s" stop-opacity="1"/> <stop offset="66%%" stop-color="%s" stop-opacity="1"/> <stop offset="100%%" stop-color="%s" stop-opacity="0.1"/> </radialGradient> </defs> <g class="pdim txt txtend">]], bright, bright, bright, brightOrig, brightOrig, dim, dim, dimOrig, dimOrig,dim,bright,dimmer,dimOrig,bright,bright,dimmer,dimmer, dimmerOrig,dimmer, ResolutionX, ResolutionY, dim,dim,dim,dim,dim,brightOrig,dim,dimOrig, dimmerOrig, dimOrig, dimOrig, dimmerOrig)

        
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
        if showHud and DisplayOdometer then 
            newContent[#newContent+1] = StaticPaths
        end
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
        local throt = mfloor(u.getThrottle())
        local spd = velMag * 3.6
        local flightValue = u.getAxisCommandValue(0)
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

        -- RADAR

        newContent[#newContent + 1] = radarMessage

        -- Pipe distance

        if pipeMessage ~= "" then newContent[#newContent +1] = pipeMessage end


        if tankMessage ~= "" then newContent[#newContent + 1] = tankMessage end
        if shieldMessage ~= "" then newContent[#newContent +1] = shieldMessage end
        -- PRIMARY FLIGHT INSTRUMENTS

        DrawVerticalSpeed(newContent, coreAltitude) -- Weird this is draw during remote control...?


        if isRemote() == 0 or RemoteHud then
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
        if not showSettings and holdingShift then DisplayRoute(newContent) end

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
        if VertTakeOffEngine then flightStyle = flightStyle.."-VERTICAL" end
        if CollisionSystem and activeRadar and not AutoTakeoff and not BrakeLanding and velMag > 20 then flightStyle = flightStyle.."-COLLISION ON" end
        if UseExtra ~= "Off" then flightStyle = "("..UseExtra..")-"..flightStyle end
        if TurnBurn then flightStyle = "TB-"..flightStyle end
        if HoverMode then flightStyle = "HOVERMODE-"..flightStyle end
        if not stablized then flightStyle = flightStyle.."-DeCoupled" end

        local labelY1 = cry(99)
        local labelY2 = cry(80)
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
        gravity = c.getGravityIntensity()
        if gravity > 0.1 then
            reqThrust = coreMass * gravity
            reqThrust = round((reqThrust / (coreMass * gravConstant)),2).."g"
            maxMass = 0.5 * maxThrust / gravity
            maxMass = maxMass > 1000000 and round(maxMass / 1000000,2).."kT" or round(maxMass / 1000, 2).."T"
        end
        maxThrust = round((maxThrust / (coreMass * gravConstant)),2).."g"

        local accel = (vec3(C.getWorldAcceleration()):len() / 9.80665)
        gravity =  c.getGravityIntensity()
        newContent[#newContent + 1] = [[<g class="dim txt txtend size14">]]
        if isRemote() == 1 and not RemoteHud then
            xg = ConvertResolutionX(1120)
            yg1 = ConvertResolutionY(55)
            yg2 = yg1+10
        elseif inAtmo and DisplayOdometer then -- We only show atmo when not remote
            local atX = ConvertResolutionX(770)
            newContent[#newContent + 1] = svgText(crx(895), labelY1, "ATMO", "")
            newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke"  d="M %f %f l %f 0"/>]],crx(895),lineY,crx(-80))
            newContent[#newContent + 1] = svgText(crx(815), labelY2, stringf("%.1f%%", atmosDensity*100), "txtstart size20")
        end
        if DisplayOdometer then 
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
                newContent[#newContent + 1] = svgText(crx(545), cry(26), stringf("%s", FormatTimeString(travelTime)), "txtstart size20")  
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
            newContent[#newContent + 1] = svgText(crx(1375), cry(26), stringf("%s", mass), "size20") 
            --newContent[#newContent + 1] = svgText(ConvertResolutionX(970), ConvertResolutionY(20), stringf("Mass: %s", mass), "txtstart") 
            --newContent[#newContent + 1] = svgText(ConvertResolutionX(1240), ConvertResolutionY(10), stringf("Max Brake: %s",  brakeValue), "txtend") 
            newContent[#newContent + 1] = svgText(crx(1220), labelY1, "THRUST", "txtstart")
            newContent[#newContent + 1] = stringf([[<path class="linethin dimstroke" d="M %f %f l %f 0"/>]], crx(1220), lineY, crx(80))
            newContent[#newContent + 1] = svgText(crx(1300), labelY2, stringf("%s", maxThrust), "size20") 
            newContent[#newContent + 1] = svgText(ConvertResolutionX(960), ConvertResolutionY(175), flightStyle, "pbright txtbig txtmid size20")
        end
        newContent[#newContent + 1] = "</g>"
    end
    
    local mod = 1 - (ContainerOptimization*0.05+FuelTankOptimization*0.05)
    function Hud.FuelUsed(fuelType)
        local used
        if fuelType == "atmofueltank" then 
            used = stringf("Atmo Fuel Used: %.1f L", fuelUsed[fuelType]/(4*mod))
        elseif fuelType == "spacefueltank" then
            used = stringf("Space Fuel Used: %.1f L", fuelUsed[fuelType]/(6*mod))
        else
            used = stringf("Rocket Fuel Used: %.1f L", fuelUsed[fuelType]/(0.8*mod))
        end
        return used
    end
    local fps, fpsAvg, fpsCount, fpsAvgTotal, fpsTotal = 0,0,0,{},0
    local safeAtmoMass = 0
    local safeSpaceMass = 0
    local safeHoverMass = 0

    function Hud.DrawOdometer(newContent, totalDistanceTrip, TotalDistanceTravelled, flightTime)
        if SelectedTab ~= "INFO" then return newContent end
        local gravity 
        local brakeValue = 0
        local reqThrust = 0
        local mass = coreMass > 1000000 and round(coreMass / 1000000,2).." kTons" or round(coreMass / 1000, 2).." Tons"
        if inAtmo then brakeValue = LastMaxBrakeInAtmo else brakeValue = LastMaxBrake end
        local brkDist, brkTime = Kinematic.computeDistanceAndTime(velMag, 0, coreMass, 0, 0, brakeValue)
        brakeValue = round((brakeValue / (coreMass * gravConstant)),2).." g"
        local maxThrust = Nav:maxForceForward()
        gravity = c.getGravityIntensity()
        if velMag < 5 then
            local axisCRefDirection = vec3(C.getOrientationForward())
            local maxKPAlongAxis = C.getMaxThrustAlongAxis('thrust analog longitudinal ', {axisCRefDirection:unpack()})
            safeAtmoMass = 0.5*maxKPAlongAxis[1]/gravity
            safeAtmoMass = safeAtmoMass > 1000000 and round(safeAtmoMass / 1000000,1).." kTons" or round(safeAtmoMass / 1000, 1).." Tons"
            safeSpaceMass = 0.5*maxKPAlongAxis[3]/gravity
            safeSpaceMass = safeSpaceMass > 1000000 and round(safeSpaceMass / 1000000,1).." kTons" or round(safeSpaceMass / 1000, 1).." Tons"
            axisCRefDirection = vec3(C.getOrientationUp())
            maxKPAlongAxis = C.getMaxThrustAlongAxis('hover_engine, booster_engine', {axisCRefDirection:unpack()})
            safeHoverMass = 0.5*maxKPAlongAxis[1]/gravity
            safeHoverMass = safeHoverMass > 1000000 and round(safeHoverMass / 1000000,1).." kTons" or round(safeHoverMass / 1000, 1).." Tons"
        end
        if gravity > 0.1 then
            reqThrust = coreMass * gravity
            reqThrust = round((reqThrust / (coreMass * gravConstant)),2).." g"
        else
            reqThrust = "n/a"
        end
        maxThrust = round((maxThrust / (coreMass * gravConstant)),2).." g"
        if isRemote() == 0 or RemoteHud then 
            local startX = ConvertResolutionX(OrbitMapX+10)
            local startY = ConvertResolutionY(OrbitMapY+20)
            local midX = ConvertResolutionX(OrbitMapX+10+OrbitMapSize/1.25)
            local height = 25
            local hudrate = mfloor(1/hudTickRate)
            if fpsCount < hudrate then
                fpsTotal = fpsTotal + s.getActionUpdateDeltaTime()
                fpsCount = fpsCount + 1
            else
                fps = 1/(fpsTotal / hudrate)
                table.insert(fpsAvgTotal, fps)
                fpsCount, fpsTotal = 0, 0
            end
            fpsAvg = 0
            for k,v in pairs(fpsAvgTotal) do
                fpsAvg = fpsAvg + v
            end
            if #fpsAvgTotal> 0 then fpsAvg = mfloor(fpsAvg/#fpsAvgTotal) end
            if #fpsAvgTotal > 29 then
                table.remove(fpsAvgTotal,1)
            end
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
            newContent[#newContent + 1] = svgText(midX, startY+height*4, stringf("Safe Atmo Mass: %s", (safeAtmoMass)))
            newContent[#newContent + 1] = svgText(startX, startY+height*5, stringf("Req Thrust: %s", reqThrust )) 
            newContent[#newContent + 1] = svgText(midX, startY+height*5, stringf("Safe Space Mass: %s", (safeSpaceMass)))
            newContent[#newContent + 1] = svgText(midX, startY+height*6, stringf("Safe Hover Mass: %s", (safeHoverMass)))
            newContent[#newContent +1] = svgText(startX, startY+height*7, stringf("Set Max Speed: %s", mfloor(MaxGameVelocity*3.6+0.5)))
            newContent[#newContent +1] = svgText(midX, startY+height*7, stringf("Actual Max Speed: %s", mfloor(MaxSpeed*3.6+0.5)))
            newContent[#newContent +1] = svgText(startX, startY+height*8, stringf("Friction Burn Speed: %s", mfloor(C.getFrictionBurnSpeed()*3.6)))
            newContent[#newContent +1] = svgText(midX, startY+height*8, stringf("FPS (Avg): %s (%s)", mfloor(fps),fpsAvg))
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
            u.setTimer("msgTick", msgTimer)
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
        local x = ConvertResolutionX(640)
        local y = ConvertResolutionY(200)
        newContent[#newContent + 1] = [[<g class="pbright txtvspd txtstart">]]
        local count=0
        for k, v in pairs(settingsVariables) do
            count=count+1
            newContent[#newContent + 1] = svgText(x, y, k..": "..v.get())
            y = y + 20
            if count%12 == 0 then
                x = x + ConvertResolutionX(350)
                y = ConvertResolutionY(200)
            end
        end
        newContent[#newContent + 1] = svgText(ConvertResolutionX(640), ConvertResolutionY(200)+260, "To Change: In Lua Chat, enter /G VariableName Value")
        newContent[#newContent + 1] = "</g>"
        return newContent
    end

        -- DrawRadarInfo() variables

        local friendy = ConvertResolutionY(125)
        local friendx = ConvertResolutionX(1225)

    function Hud.DrawRadarInfo()
        radarMessage = RADAR.GetRadarHud(friendx, friendy, radarX, radarY)
        if radarMessage then activeRadar = true end 
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
        local shieldState = (shield.isActive() == 1) and "Shield Active" or "Shield Disabled"
        local pvpTime = C.getPvPTimer()
        local resistances = shield.getResistances()
        local resistString = "A: "..(10+resistances[1]*100).."% / E: "..(10+resistances[2]*100).."% / K:"..(10+resistances[3]*100).."% / T: "..(10+resistances[4]*100).."%"
        local x, y = shieldX -60, shieldY+30
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
        if not planet then return end -- Avoid errors if APTick hasn't initialized before this is called

        -- Local Functions for hudTick
            local function DrawCursorLine(newContent)
                local strokeColor = mfloor(uclamp((mouseDistance / (ResolutionX / 4)) * 255, 0, 255))
                newContent[#newContent + 1] = stringf(
                                                "<line x1='0' y1='0' x2='%fpx' y2='%fpx' style='stroke:rgb(%d,%d,%d);stroke-width:2;transform:translate(50%%, 50%%)' />",
                                                simulatedX, simulatedY, mfloor(PrimaryR + 0.5) + strokeColor,
                                                mfloor(PrimaryG + 0.5) - strokeColor, mfloor(PrimaryB + 0.5) - strokeColor)
            end
            local function CheckButtons()
                if leftmouseclick then
                    for _, v in pairs(Buttons) do
                        if v.hovered then
                            if not v.drawCondition or v.drawCondition(v) then
                                v.toggleFunction(v)
                            end
                            v.hovered = false
                        end
                    end
                    for _, v in pairs(TabButtons) do
                        if v.hovered then
                            SelectedTab = v.label
                            v.hovered = false
                        end
                    end
                    leftmouseclick = false
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
                local x = simulatedX + ResolutionX / 2
                local y = simulatedY + ResolutionY / 2
                for _, v in pairs(Buttons) do
                    -- enableName, disableName, width, height, x, y, toggleVar, toggleFunction, drawCondition
                    v.hovered = Contains(x, y, v.x, v.y, v.width, v.height)
                end
                for _, v in pairs(TabButtons) do
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
            local function DrawTabButtons(newContent)
                if not SelectedTab or SelectedTab == "" then
                    SelectedTab = "HELP"
                end
                if showHud then 
                    for k,v in pairs(TabButtons) do
                        local class = "dim brightstroke"
                        local opacity = 0.2
                        if SelectedTab == k then
                            class = "pbright dimstroke"
                            opacity = 0.6
                        end
                        local extraStyle = ""
                        if v.hovered then
                            opacity = 0.8
                            extraStyle = ";stroke:white"
                        end
                        newContent[#newContent + 1] = stringf(
                                                            [[<rect width="%f" height="%d" x="%d" y="%d" clip-path="url(#round-corner)" class="%s" style="stroke-width:1;fill-opacity:%f;%s" />]],
                                                            v.width, v.height, v.x,v.y, class, opacity, extraStyle)
                        newContent[#newContent + 1] = svgText(v.x+v.width/2, v.y + v.height/2 + 5, v.label, "txt txtmid pdim")
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
        if userScreen then newContent[#newContent + 1] = userScreen end
        --local t0 = s.getArkTime()
        HUD.HUDPrologue(newContent)
        if showHud then
            --local t0 = s.getArkTime()
            HUD.UpdateHud(newContent) -- sets up Content for us
            --_logCompute.addValue(s.getArkTime() - t0)
        else
            if AlwaysVSpd then HUD.DrawVerticalSpeed(newContent, coreAltitude) end
            HUD.DrawWarnings(newContent)
        end
        if showSettings and settingsVariables ~= "none" then  
            HUD.DrawSettings(newContent) 
        end

        if RADAR then HUD.DrawRadarInfo() else radarMessage = "" end
        HUD.HUDEpilogue(newContent)
        newContent[#newContent + 1] = stringf(
            [[<svg width="100%%" height="100%%" style="position:absolute;top:0;left:0"  viewBox="0 0 %d %d">]],
            ResolutionX, ResolutionY)   
        if msgText ~= "empty" then
            HUD.DisplayMessage(newContent, msgText)
        end
        if isRemote() == 0 and userControlScheme == "virtual joystick" then
            if DisplayDeadZone then HUD.DrawDeadZone(newContent) end
        end

        DrawTabButtons(newContent)
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
                    newContent[#newContent + 1] = stringf("<style>@keyframes test { from { opacity: 0; } to { opacity: 1; } }  body { animation-name: test; animation-duration: 0.5s; }</style><body><svg width='100%%' height='100%%' position='absolute' top='0' left='0'><rect width='100%%' height='100%%' x='0' y='0' position='absolute' style='fill:rgb(6,5,26);'/></svg><svg width='50%%' height='50%%' style='position:absolute;top:30%%;left:25%%' viewbox='0 0 %d %d'>", ResolutionX, ResolutionY)
                    newContent[#newContent + 1] = collapsedContent
                    newContent[#newContent + 1] = "</body>"
                    Animating = true
                    newContent[#newContent + 1] = [[</svg></body>]] -- Uh what.. okay...
                    u.setTimer("animateTick", 0.5)
                elseif Animated then
                    local collapsedContent = table.concat(newContent, "")
                    newContent = {}
                    newContent[#newContent + 1] = stringf("<body style='background-color:rgb(6,5,26)'><svg width='50%%' height='50%%' style='position:absolute;top:30%%;left:25%%' viewbox='0 0 %d %d'>", ResolutionX, ResolutionY)
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
                if mouseDistance > DeadZone then -- Draw a line to the cursor from the screen center
                    -- Note that because SVG lines fucking suck, we have to do a translate and they can't use calc in their params
                    if DisplayDeadZone then DrawCursorLine(newContent) end
                end
            elseif holdingShift and (not AltIsOn or not freeLookToggle) then
                SetButtonContains()
                DrawButtons(newContent)
            end
            -- Cursor always on top, draw it last
            newContent[#newContent + 1] = stringf(
                                            [[<g transform="translate(%d %d)"><circle class="cursor" cx="%fpx" cy="%fpx" r="5"/></g>]],
                                            halfResolutionX, halfResolutionY, simulatedX, simulatedY)
        end
        newContent[#newContent + 1] = [[</svg></body>]]
        content = table.concat(newContent, "")
    end

    function Hud.TenthTick()
        -- Local Functions for tenthSecond
            local function SetupInterplanetaryPanel() -- Interplanetary helper
                local sysCrData = s.createData
                local sysCrWid = s.createWidget
                panelInterplanetary = s.createWidgetPanel("Interplanetary Helper")
            
                interplanetaryHeader = sysCrWid(panelInterplanetary, "value")
                interplanetaryHeaderText = sysCrData('{"label": "Target Planet", "value": "N/A", "unit":""}')
                sysAddData(interplanetaryHeaderText, interplanetaryHeader)
            
                widgetDistance = sysCrWid(panelInterplanetary, "value")
                widgetDistanceText = sysCrData('{"label": "distance", "value": "N/A", "unit":""}')
                sysAddData(widgetDistanceText, widgetDistance)
            
                widgetTravelTime = sysCrWid(panelInterplanetary, "value")
                widgetTravelTimeText = sysCrData('{"label": "Travel Time", "value": "N/A", "unit":""}')
                sysAddData(widgetTravelTimeText, widgetTravelTime)
            
                widgetMaxMass = sysCrWid(panelInterplanetary, "value")
                widgetMaxMassText = sysCrData('{"label": "Maximum Mass", "value": "N/A", "unit":""}')
                sysAddData(widgetMaxMassText, widgetMaxMass)
            
                widgetTargetOrbit = sysCrWid(panelInterplanetary, "value")
                widgetTargetOrbitText = sysCrData('{"label": "Target Altitude", "value": "N/A", "unit":""}')
                sysAddData(widgetTargetOrbitText, widgetTargetOrbit)
            
                widgetCurBrakeDistance = sysCrWid(panelInterplanetary, "value")
                widgetCurBrakeDistanceText = sysCrData('{"label": "Cur Brake distance", "value": "N/A", "unit":""}')
                widgetCurBrakeTime = sysCrWid(panelInterplanetary, "value")
                widgetCurBrakeTimeText = sysCrData('{"label": "Cur Brake Time", "value": "N/A", "unit":""}')
                widgetMaxBrakeDistance = sysCrWid(panelInterplanetary, "value")
                widgetMaxBrakeDistanceText = sysCrData('{"label": "Max Brake distance", "value": "N/A", "unit":""}')
                widgetMaxBrakeTime = sysCrWid(panelInterplanetary, "value")
                widgetMaxBrakeTimeText = sysCrData('{"label": "Max Brake Time", "value": "N/A", "unit":""}')
                widgetTrajectoryAltitude = sysCrWid(panelInterplanetary, "value")
                widgetTrajectoryAltitudeText = sysCrData('{"label": "Projected Altitude", "value": "N/A", "unit":""}')
                if not inAtmo then
                    sysAddData(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
                    sysAddData(widgetCurBrakeTimeText, widgetCurBrakeTime)
                    sysAddData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
                    sysAddData(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
                    sysAddData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
                end
            end                    
            local function HideInterplanetaryPanel()
                sysDestWid(panelInterplanetary)
                panelInterplanetary = nil
            end 

        HUD.DrawTanks()
        if shield then HUD.DrawShield() end
        if AutopilotTargetName ~= "None" then
            if panelInterplanetary == nil then
                SetupInterplanetaryPanel()
            end
            if AutopilotTargetName ~= nil then
                local targetDistance
                local customLocation = CustomTarget ~= nil
                local planetMaxMass = 0.5 * LastMaxBrakeInAtmo /
                    (autopilotTargetPlanet:getGravity(
                    autopilotTargetPlanet.center + (vec3(0, 0, 1) * autopilotTargetPlanet.radius))
                    :len())
                planetMaxMass = planetMaxMass > 1000000 and round(planetMaxMass / 1000000,2).." kTons" or round(planetMaxMass / 1000, 2).." Tons"
                sysUpData(interplanetaryHeaderText,
                    '{"label": "Target", "value": "' .. AutopilotTargetName .. '", "unit":""}')
                if customLocation and not Autopilot then -- If in autopilot, keep this displaying properly
                    targetDistance = (worldPos - CustomTarget.position):len()
                else
                    targetDistance = (AutopilotTargetCoords - worldPos):len() -- Don't show our weird variations
                end
                if not TurnBurn then
                    brakeDistance, brakeTime = AP.GetAutopilotBrakeDistanceAndTime(velMag)
                    maxBrakeDistance, maxBrakeTime = AP.GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
                else
                    brakeDistance, brakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(velMag)
                    maxBrakeDistance, maxBrakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
                end
                local displayText = getDistanceDisplayString(targetDistance)
                sysUpData(widgetDistanceText, '{"label": "distance", "value": "' .. displayText
                    .. '"}')
                sysUpData(widgetTravelTimeText, '{"label": "Travel Time", "value": "' ..
                    FormatTimeString(travelTime) .. '", "unit":""}')
                displayText = getDistanceDisplayString(brakeDistance)
                sysUpData(widgetCurBrakeDistanceText, '{"label": "Cur Brake distance", "value": "' ..
                    displayText.. '"}')
                sysUpData(widgetCurBrakeTimeText, '{"label": "Cur Brake Time", "value": "' ..
                    FormatTimeString(brakeTime) .. '", "unit":""}')
                displayText = getDistanceDisplayString(maxBrakeDistance)
                sysUpData(widgetMaxBrakeDistanceText, '{"label": "Max Brake distance", "value": "' ..
                    displayText.. '"}')
                sysUpData(widgetMaxBrakeTimeText, '{"label": "Max Brake Time", "value": "' ..
                    FormatTimeString(maxBrakeTime) .. '", "unit":""}')
                sysUpData(widgetMaxMassText, '{"label": "Max Brake Mass", "value": "' ..
                    stringf("%s", planetMaxMass ) .. '", "unit":""}')
                displayText = getDistanceDisplayString(AutopilotTargetOrbit)
                sysUpData(widgetTargetOrbitText, '{"label": "Target Orbit", "value": "' ..
                displayText .. '"}')
                if inAtmo and not WasInAtmo then
                    s.removeDataFromWidget(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
                    s.removeDataFromWidget(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
                    s.removeDataFromWidget(widgetCurBrakeTimeText, widgetCurBrakeTime)
                    s.removeDataFromWidget(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
                    s.removeDataFromWidget(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
                    WasInAtmo = true
                    if not throttleMode and AtmoSpeedAssist and (AltitudeHold or Reentry or finalLand) then
                        -- If they're reentering atmo from cruise, and have atmo speed Assist
                        -- Put them in throttle mode at 100%
                        AP.cmdThrottle(1)
                        BrakeIsOn = false
                        WasInCruise = false -- And override the thing that would reset it, in this case
                    end
                end
                if not inAtmo and WasInAtmo then
                    if sysUpData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) == 1 then
                        sysAddData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) end
                    if sysUpData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) == 1 then
                        sysAddData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) end
                    if sysUpData(widgetCurBrakeTimeText, widgetCurBrakeTime) == 1 then
                        sysAddData(widgetCurBrakeTimeText, widgetCurBrakeTime) end
                    if sysUpData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) == 1 then
                        sysAddData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) end
                    if sysUpData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) == 1 then
                        sysAddData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) end
                    WasInAtmo = false
                end
            end
        else
            HideInterplanetaryPanel()
        end
        if warpdrive ~= nil then
            local warpDriveData = jdecode(warpdrive.getWidgetData())
            if warpDriveData.destination ~= "Unknown" and warpDriveData.distance > 400000 then
                if not showWarpWidget then
                    warpdrive.showWidget()
                    showWarpWidget = true
                end
            elseif showWarpWidget then
                warpdrive.hideWidget()
                showWarpWidget = false
            end
        end
    end

    function Hud.OneSecondTick()
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
        local function CheckDamage(newContent)

            local percentDam = 0
            local maxShipHP = eleTotalMaxHp
            local curShipHP = 0
            local damagedElements = 0
            local disabledElements = 0
            local colorMod = 0
            local color = ""
            local eleHp = c.getElementHitPointsById
            local eleMaxHp = c.getElementMaxHitPointsById
            local markers = {}

            for k in pairs(elementsID) do
                local hp = 0
                local mhp = 0
                mhp = eleMaxHp(elementsID[k])
                hp = eleHp(elementsID[k])
                curShipHP = curShipHP + hp
                if (hp+1 < mhp) then
                    if (hp == 0) then
                        disabledElements = disabledElements + 1
                    else
                        damagedElements = damagedElements + 1
                    end
                    -- Thanks to Jerico for the help and code starter for arrow markers!
                    if repairArrows and #markers == 0 then
                        position = vec3(c.getElementPositionById(elementsID[k]))
                        local x = position.x 
                        local y = position.y 
                        local z = position.z 
                        table.insert(markers, c.spawnArrowSticker(x, y, z + 1, "down"))
                        table.insert(markers, c.spawnArrowSticker(x, y, z + 1, "down"))
                        c.rotateSticker(markers[2], 0, 0, 90)
                        table.insert(markers, c.spawnArrowSticker(x + 1, y, z, "north"))
                        table.insert(markers, c.spawnArrowSticker(x + 1, y, z, "north"))
                        c.rotateSticker(markers[4], 90, 90, 0)
                        table.insert(markers, c.spawnArrowSticker(x - 1, y, z, "south"))
                        table.insert(markers, c.spawnArrowSticker(x - 1, y, z, "south"))
                        c.rotateSticker(markers[6], 90, -90, 0)
                        table.insert(markers, c.spawnArrowSticker(x, y - 1, z, "east"))
                        table.insert(markers, c.spawnArrowSticker(x, y - 1, z, "east"))
                        c.rotateSticker(markers[8], 90, 0, 90)
                        table.insert(markers, c.spawnArrowSticker(x, y + 1, z, "west"))
                        table.insert(markers, c.spawnArrowSticker(x, y + 1, z, "west"))
                        c.rotateSticker(markers[10], -90, 0, 90)
                        table.insert(markers, elementsID[k])
                    end
                elseif repairArrows and #markers > 0 and markers[11] == elementsID[k] then
                    for j in pairs(markers) do
                        c.deleteSticker(markers[j])
                    end
                    markers = {}
                end
            end
            percentDam = round((curShipHP / maxShipHP)*100,2)
            if disabledElements > 0 or damagedElements > 0 then
                newContent[#newContent + 1] = svgText(0,0,"", "pbright txt")
                colorMod = mfloor(percentDam * 2.55)
                color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                newContent[#newContent + 1] = svgText("50%", 1035, "Elemental Integrity: "..percentDam.."%", "txtbig txtmid","fill:"..color )
                if (disabledElements > 0) then
                    newContent[#newContent + 1] = svgText("50%",1055, "Disabled Modules: "..disabledElements.." Damaged Modules: "..damagedElements, "txtbig txtmid","fill:"..color)
                elseif damagedElements > 0 then
                    newContent[#newContent + 1] = svgText("50%", 1055, "Damaged Modules: "..damagedElements, "txtbig txtmid", "fill:" .. color)
                end
            end
        end
        local function updateWeapons()
            if weapon then
                if  WeaponPanelID==nil and (radarPanelId ~= nil or GearExtended)  then
                    _autoconf.displayCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true)
                    WeaponPanelID = _autoconf.panels[_autoconf.panels_size]
                elseif WeaponPanelID ~= nil and radarPanelId == nil and not GearExtended then
                    sysDestWid(WeaponPanelID)
                    WeaponPanelID = nil
                end
            end
        end

 
        local newContent = {}
        updateDistance()
        if ShouldCheckDamage then
            CheckDamage(newContent)
        end
        updateWeapons()
        HUD.UpdatePipe()
        HUD.ExtraData(newContent)
        lastOdometerOutput = table.concat(newContent, "")
    end

    function Hud.AnimateTick()
        Animated = true
        Animating = false
        simulatedX = 0
        simulatedY = 0
        u.stopTimer("animateTick")
    end

    function Hud.MsgTick()
        -- This is used to clear a message on screen after a short period of time and then stop itself
        local newContent = {}
        HUD.DisplayMessage(newContent, "empty")
        msgText = "empty"
        u.stopTimer("msgTick")
        msgTimer = 3
    end
    function Hud.ButtonSetup()
        SettingsButtons()
        ControlsButtons() -- Set up all the pushable buttons.
        Buttons = ControlButtons
    end

    if userHud then 
        for k,v in pairs(userHud) do Hud[k] = v end 
    end  

    return Hud
end
  
