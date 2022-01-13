
script = {}  -- wrappable container for all the code. Different than normal DU Lua in that things are not seperated out.

-- function localizations for improved performance when used frequently or in loops.
local mabs = math.abs
local mfloor = math.floor
local stringf = string.format
local jdecode = json.decode
local jencode = json.encode
local eleMaxHp = c.getElementMaxHitPointsById
local atmosphere = u.getAtmosphereDensity
local eleMass = c.getElementMassById
local isRemote = Nav.control.isRemoteControlled
local atan = math.atan
local stringmatch = string.match
local systime = s.getTime
local uclamp = utils.clamp
local navCom = Nav.axisCommandManager
local sysDestWid = s.destroyWidgetPanel
local sysUpData = s.updateData
local sysAddData = s.addDataToWidget
local sysLockVw = s.lockView
local sysIsVwLock = s.isViewLocked
local msqrt = math.sqrt
local tonum = tonumber

local function round(num, numDecimalPlaces) -- rounds variable num to numDecimalPlaces
    local mult = 10 ^ (numDecimalPlaces or 0)
    return mfloor(num * mult + 0.5) / mult
end
-- Variables that we declare local outside script because they will be treated as global but get local effectiveness
time = systime()
clearAllCheck = systime()
local coreHalfDiag = 13
PrimaryR = SafeR
PrimaryB = SafeB
PrimaryG = SafeG
PlayerThrottle = 0
brakeInput2 = 0
ThrottleLimited = false
calculatedThrottle = 0
WasInCruise = false
apThrottleSet = false -- Do not save this, because when they re-enter, throttle won't be set anymore
minAutopilotSpeed = 55 -- Minimum speed for autopilot to maneuver in m/s.  Keep above 25m/s to prevent nosedives when boosters kick in
reentryMode = false
hasGear = false
pitchInput = 0
pitchInput2 = 0
yawInput2 = 0
rollInput = 0
yawInput = 0
brakeInput = 0
rollInput2 = 0
followMode = false 
holdingShift = false
msgText = "empty"

isBoosting = false -- Dodgin's Don't Die Rocket Govenor
brakeDistance = 0
brakeTime = 0
local maxBrakeDistance = 0
local maxBrakeTime = 0
autopilotTargetPlanet = nil
totalDistanceTrip = 0
flightTime = 0
upAmount = 0
simulatedX = 0
simulatedY = 0        
msgTimer = 3
distance = 0
lastOdometerOutput = ""
spaceLand = false
spaceLaunch = false
finalLand = false
abvGndDet = -1
local myAutopilotTarget=""
inAtmo = (atmosphere() > 0)
atmosDensity = atmosphere()
coreAltitude = c.getAltitude()
local elementsID = c.getElementIdList()
lastTravelTime = systime()
coreMass = c.getConstructMass()
mousePause = false
gyroIsOn = nil
rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) .. [[)]]
rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..   mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]
local markers = {}
damageMessage = ""

resolutionWidth = ResolutionX
resolutionHeight = ResolutionY
atmoTanks = {}
spaceTanks = {}
rocketTanks = {}
local eleTotalMaxHp = 0
repairArrows = false
local PlanetaryReference = nil
galaxyReference = nil
Kinematic = nil
maxKinematicUp = nil
Kep = nil
HUD = nil
ATLAS = nil
AP = nil
RADAR = nil
CONTROL = nil
Animating = false
Animated = false
autoRoll = autoRollPreference
local targetGroundAltitude = LandingGearGroundHeight -- So it can tell if one loaded or not
stalling = false
targetRoll = 0
adjustedAtmoSpeedLimit = AtmoSpeedLimit
VtPitch = 0
orbitMsg = nil
orbitalParams = { VectorToTarget = false } 
OrbitTargetOrbit = 0
OrbitAchieved = false
local SpaceEngineVertUp = false
SpaceEngineVertDn = false
SpaceEngines = false
constructUp = vec3(c.getConstructWorldOrientationUp())
constructForward = vec3(c.getConstructWorldOrientationForward())
constructRight = vec3(c.getConstructWorldOrientationRight())
coreVelocity = vec3(c.getVelocity())
constructVelocity = vec3(c.getWorldVelocity())
velMag = vec3(constructVelocity):len()
worldVertical = vec3(c.getWorldVertical())
vSpd = -worldVertical:dot(constructVelocity)
worldPos = vec3(c.getConstructWorldPos())
UpVertAtmoEngine = false
antigravOn = false
setCruiseSpeed = nil
throttleMode = true
adjustedPitch = 0
adjustedRoll = 0
AtlasOrdered = {}
notPvPZone = false
pvpDist = 50000
ReversalIsOn = nil
contacts = {}
nearPlanet = u.getClosestPlanetInfluence() > 0 or (coreAltitude > 0 and coreAltitude < 200000)
collisionAlertStatus = false
collisionTarget = nil

apButtonsHovered = false
apScrollIndex = 0
passengers = nil
ships = nil
planetAtlas = {}
scopeFOV = 90
oldShowHud = showHud

-- Function Definitions that are used in more than one areause 
--[[    -- EliasVilld Log Code - To use uncomment all Elias sections and put the two lines below around code to be measured.
        -- local t0 = s.getTime()
        -- <code to be checked>
        -- _logCompute.addValue(s.getTime() - t0)
    function Log(name,ty)
        local self={}
        self.Name = name or 'Log'
        self.Value = (ty == 'number' and 0) or {}
        self.Type = ty or 'mean'

        function self.Update(v)
            if self.Type == 'number' then
                self.Value = v
            else
                self.Value[#self.Value] = v
            end
        end

        function self.getString()
            if self.Type == 'number' then
                return tostring(self.Value)
            elseif self.Type == 'time' then
                return utils.round(self.getMean()*1000,0.0001) .. 'ms ('..#self.Value..")"
            elseif self.Type == 'mean' then
                return tostring(utils.round(self.getMean(),0.01));
            end
        end
        
        function self.getValue()
            if self.Type == 'number' then
                return self.value
            else
                return self.getMean()
            end
        end
            
        function self.addValue(v)
            if self.Type == 'number' then return end
            
            table.insert(self.Value,1,v)
            if #self.Value > 1000 then self.Value[1001] = nil end
        end
        
        function self.getMean()
            local m = 0;
            for i=1,#self.Value do
                m = m + self.Value[i]
            end
            return m/#self.Value;
        end

        return self
    end
    function Logger()
        local self={}
        self.Logs={}

        function self.CreateLog(name,type)
            local log = Log(name,type)
            Register(log)
            return log;
        end
        
        function self.getLogs()
            local logs = {}
            for _,l in pairs(self.Logs) do
                logs[#logs+1] = l.Name .. ': ' .. l.getString()
            end
            return logs
        end
        
        function Register(log)
            self.Logs[#self.Logs+1] = log;
        end
        return self
    end
--]]
--
function p(msg)
    s.print(time..": "..msg)
end
--]]

function play(sound, ID, type)
    if (type == nil and not voices) or (type ~= nil and not alerts) or soundFolder == "archHUD" then return end
    if type ~= nil then
        if type == 2 then
            s.logInfo("sound_loop|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
        else
            s.logInfo("sound_notification|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
        end
    else
        s.logInfo("sound_q|audiopacks/"..soundFolder.."/"..sound.."|"..ID.."|"..soundVolume)
    end
end

function addTable(table1, table2) -- Function to add two tables together
    for k,v in pairs(table2) do
        if type(k)=="string" then
            table1[k] = v
        else
            table1[#table1 + 1 ] = table2[k]
        end
    end
    return table1
end

function saveableVariables(subset) -- returns saveable variables by catagory
    local returnSet = {}
        -- Complete list of user variables above, must be in saveableVariables to be stored on databank

    if not subset then
        addTable(returnSet, saveableVariablesBoolean)
        addTable(returnSet, savableVariablesHandling)
        addTable(returnSet, savableVariablesHud)
        addTable(returnSet, savableVariablesPhysics)
        return returnSet
    elseif subset == "boolean" then
        return saveableVariablesBoolean
    elseif subset == "handling" then
        return savableVariablesHandling
    elseif subset == "hud" then
        return savableVariablesHud
    elseif subset == "physics" then
        return savableVariablesPhysics
    end            
end

local function svgText(x, y, text, class, style) -- processes a svg text string, saves code lines by doing it this way
    if class == nil then class = "" end
    if style == nil then style = "" end
    return stringf([[<text class="%s" x=%s y=%s style="%s">%s</text>]], class,x, y, style, text)
end

function float_eq(a, b) -- float equation
    if a == 0 then
        return mabs(b) < 1e-09
    end
    if b == 0 then
        return mabs(a) < 1e-09
    end
    return mabs(a - b) < math.max(mabs(a), mabs(b)) * epsilon
end

function getDistanceDisplayString(distance, places) -- Turn a distance into a string to a number of places
    local su = distance > 100000
    if places == nil then places = 1 end
    if su then
        -- Convert to SU
        return round(distance / 1000 / 200, places).."SU"
    elseif distance < 1000 then
        return round(distance, places).."M"
    else
        -- Convert to KM
        return round(distance / 1000, places).."KM"
    end
end



function FormatTimeString(seconds) -- Format a time string for display
    local minutes = 0
    local hours = 0
    local days = 0
    if seconds < 60 then
        seconds = mfloor(seconds)
    elseif seconds < 3600 then
        minutes = mfloor(seconds / 60)
        seconds = mfloor(seconds % 60) 
    elseif seconds < 86400 then
        hours = mfloor(seconds / 3600)
        minutes = mfloor( (seconds % 3600) / 60)
    else
        days = mfloor ( seconds / 86400)
        hours = mfloor ( (seconds % 86400) / 3600)
    end
    if days > 0 then 
        return days .. "d " .. hours .."h "
    elseif hours > 0 then
        return hours .. "h " .. minutes .. "m "
    elseif minutes > 0 then
        return minutes .. "m " .. seconds .. "s"
    elseif seconds > 0 then 
        return seconds .. "s"
    else
        return "0s"
    end
end

function SaveDataBank(copy) -- Save values to the databank.
    local function writeData(dataList)
        for k, v in pairs(dataList) do
            dbHud_1.setStringValue(k, jencode(v.get()))
            if copy and dbHud_2 then
                dbHud_2.setStringValue(k, jencode(v.get()))
            end
        end
    end
    if dbHud_1 then
        writeData(autoVariables) 
        writeData(saveableVariables())
        s.print("Saved Variables to Datacore")
        if copy and dbHud_2 then
            msgText = "Databank copied.  Remove copy when ready."
        end
    end
end

-- Planet Info - https://gitlab.com/JayleBreak/dualuniverse/-/tree/master/DUflightfiles/autoconf/custom with modifications to support HUD, vanilla JayleBreak will not work anymore

local function PlanetRef()
    --[[                    START OF LOCAL IMPLEMENTATION DETAILS             ]]--
    -- Type checks
    local function isNumber(n)
        return type(n) == 'number'
    end
    local function isSNumber(n)
        return type(tonum(n)) == 'number'
    end
    local function isTable(t)
        return type(t) == 'table'
    end
    local function isString(s)
        return type(s) == 'string'
    end
    local function isVector(v)
        return isTable(v) and isNumber(v.x and v.y and v.z)
    end
    local function isMapPosition(m)
        return isTable(m) and isNumber(m.latitude and m.longitude and m.altitude and m.id and m.systemId)
    end
    -- Constants
    local deg2rad = math.pi / 180
    local rad2deg = 180 / math.pi
    local epsilon = 1e-10
    local num = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
    local posPattern = '::pos{' .. num .. ',' .. num .. ',' .. num .. ',' .. num .. ',' .. num .. '}'
    -- Utilities
    local utils = require('cpml.utils')
    local vec3 = require('cpml.vec3')
    local function formatNumber(n)
        local result = string.gsub(string.reverse(stringf('%.4f', n)), '^0*%.?', '')
        return result == '' and '0' or string.reverse(result)
    end
    local function formatValue(obj)
        if isVector(obj) then
            return stringf('{x=%.3f,y=%.3f,z=%.3f}', obj.x, obj.y, obj.z)
        end
        if isTable(obj) and not getmetatable(obj) then
            local list = {}
            local nxt = next(obj)
            if type(nxt) == 'nil' or nxt == 1 then -- assume this is an array
                list = obj
            else
                for k, v in pairs(obj) do
                    local value = formatValue(v)
                    if type(k) == 'number' then
                        table.insert(list, stringf('[%s]=%s', k, value))
                    else
                        table.insert(list, stringf('%s=%s', k, value))
                    end
                end
            end
            return stringf('{%s}', table.concat(list, ','))
        end
        if isString(obj) then
            return stringf("'%s'", obj:gsub("'", [[\']]))
        end
        return tostring(obj)
    end
    -- CLASSES
    -- BodyParameters: Attributes of planetary bodies (planets and moons)
    local BodyParameters = {}
    BodyParameters.__index = BodyParameters
    BodyParameters.__tostring = function(obj, indent)
        local keys = {}
        for k in pairs(obj) do
            table.insert(keys, k)
        end
        table.sort(keys)
        local list = {}
        for _, k in ipairs(keys) do
            local value = formatValue(obj[k])
            if type(k) == 'number' then
                table.insert(list, stringf('[%s]=%s', k, value))
            else
                table.insert(list, stringf('%s=%s', k, value))
            end
        end
        if indent then
            return stringf('%s%s', indent, table.concat(list, ',\n' .. indent))
        end
        return stringf('{%s}', table.concat(list, ','))
    end
    BodyParameters.__eq = function(lhs, rhs)
        return lhs.systemId == rhs.systemId and lhs.id == rhs.id and
                float_eq(lhs.radius, rhs.radius) and float_eq(lhs.center.x, rhs.center.x) and
                float_eq(lhs.center.y, rhs.center.y) and float_eq(lhs.center.z, rhs.center.z) and
                float_eq(lhs.GM, rhs.GM)
    end
    local function mkBodyParameters(systemId, id, radius, worldCoordinates, GM)
        -- 'worldCoordinates' can be either table or vec3
        assert(isSNumber(systemId), 'Argument 1 (systemId) must be a number:' .. type(systemId))
        assert(isSNumber(id), 'Argument 2 (id) must be a number:' .. type(id))
        assert(isSNumber(radius), 'Argument 3 (radius) must be a number:' .. type(radius))
        assert(isTable(worldCoordinates),
            'Argument 4 (worldCoordinates) must be a array or vec3.' .. type(worldCoordinates))
        assert(isSNumber(GM), 'Argument 5 (GM) must be a number:' .. type(GM))
        return setmetatable({
            systemId = tonum(systemId),
            id = tonum(id),
            radius = tonum(radius),
            center = vec3(worldCoordinates),
            GM = tonum(GM)
        }, BodyParameters)
    end
    -- MapPosition: Geographical coordinates of a point on a planetary body.
    local MapPosition = {}
    MapPosition.__index = MapPosition
    MapPosition.__tostring = function(p)
        return stringf('::pos{%d,%d,%s,%s,%s}', p.systemId, p.id, formatNumber(p.latitude * rad2deg),
                formatNumber(p.longitude * rad2deg), formatNumber(p.altitude))
    end
    MapPosition.__eq = function(lhs, rhs)
        return lhs.id == rhs.id and lhs.systemId == rhs.systemId and
                float_eq(lhs.latitude, rhs.latitude) and float_eq(lhs.altitude, rhs.altitude) and
                (float_eq(lhs.longitude, rhs.longitude) or float_eq(lhs.latitude, math.pi / 2) or
                    float_eq(lhs.latitude, -math.pi / 2))
    end
    -- latitude and longitude are in degrees while altitude is in meters
    local function mkMapPosition(overload, id, latitude, longitude, altitude)
        local systemId = overload -- Id or '::pos{...}' string
        
        if isString(overload) and not longitude and not altitude and not id and not latitude then
            systemId, id, latitude, longitude, altitude = stringmatch(overload, posPattern)
            assert(systemId, 'Argument 1 (position string) is malformed.')
        else
            assert(isSNumber(systemId), 'Argument 1 (systemId) must be a number:' .. type(systemId))
            assert(isSNumber(id), 'Argument 2 (id) must be a number:' .. type(id))
            assert(isSNumber(latitude), 'Argument 3 (latitude) must be in degrees:' .. type(latitude))
            assert(isSNumber(longitude), 'Argument 4 (longitude) must be in degrees:' .. type(longitude))
            assert(isSNumber(altitude), 'Argument 5 (altitude) must be in meters:' .. type(altitude))
        end
        systemId = tonum(systemId)
        id = tonum(id)
        latitude = tonum(latitude)
        longitude = tonum(longitude)
        altitude = tonum(altitude)
        if id == 0 then -- this is a hack to represent points in space
            return setmetatable({
                latitude = latitude,
                longitude = longitude,
                altitude = altitude,
                id = id,
                systemId = systemId
            }, MapPosition)
        end
        return setmetatable({
            latitude = deg2rad * uclamp(latitude, -90, 90),
            longitude = deg2rad * (longitude % 360),
            altitude = altitude,
            id = id,
            systemId = systemId
        }, MapPosition)
    end
    -- PlanetarySystem - map body IDs to BodyParameters
    local PlanetarySystem = {}
    PlanetarySystem.__index = PlanetarySystem
    PlanetarySystem.__tostring = function(obj, indent)
        local sep = indent and (indent .. '  ')
        local bdylist = {}
        local keys = {}
        for k in pairs(obj) do
            table.insert(keys, k)
        end
        table.sort(keys)
        for _, bi in ipairs(keys) do
            bdy = obj[bi]
            local bdys = BodyParameters.__tostring(bdy, sep)
            if indent then
                table.insert(bdylist, stringf('[%s]={\n%s\n%s}', bi, bdys, indent))
            else
                table.insert(bdylist, stringf('  [%s]=%s', bi, bdys))
            end
        end
        if indent then
            return stringf('\n%s%s%s', indent, table.concat(bdylist, ',\n' .. indent), indent)
        end
        return stringf('{\n%s\n}', table.concat(bdylist, ',\n'))
    end

    local function mkPlanetarySystem(referenceTable)
        local atlas = {}
        local pid
        for _, v in pairs(referenceTable) do
            local id = v.planetarySystemId
            if type(id) ~= 'number' then
                error('Invalid planetary s ID: ' .. tostring(id))
            elseif pid and id ~= pid then
                error('Mistringmatch planetary s IDs: ' .. id .. ' and ' .. pid)
            end
            local bid = v.bodyId
            if type(bid) ~= 'number' then
                error('Invalid body ID: ' .. tostring(bid))
            elseif atlas[bid] then
                error('Duplicate body ID: ' .. tostring(bid))
            end
            setmetatable(v.center, getmetatable(vec3.unit_x))
            atlas[bid] = setmetatable(v, BodyParameters)
            pid = id
        end
        return setmetatable(atlas, PlanetarySystem)
    end

    -- PlanetaryReference - map planetary s ID to PlanetarySystem
    PlanetaryReference = {}
    local function mkPlanetaryReference(referenceTable)
        return setmetatable({
            galaxyAtlas = referenceTable or {}
        }, PlanetaryReference)
    end
    PlanetaryReference.__index = function(t, i)
        if type(i) == 'number' then
            local s = t.galaxyAtlas[i]
            return mkPlanetarySystem(s)
        end
        return rawget(PlanetaryReference, i)
    end
    PlanetaryReference.__pairs = function(obj)
        return function(t, k)
            local nk, nv = next(t, k)
            return nk, nv and mkPlanetarySystem(nv)
        end, obj.galaxyAtlas, nil
    end
    PlanetaryReference.__tostring = function(obj)
        local pslist = {}
        for _, ps in pairs(obj or {}) do
            local psi = ps:getPlanetarySystemId()
            local pss = PlanetarySystem.__tostring(ps, '    ')
            table.insert(pslist, stringf('  [%s]={%s\n  }', psi, pss))
        end
        return stringf('{\n%s\n}\n', table.concat(pslist, ',\n'))
    end
    PlanetaryReference.BodyParameters = mkBodyParameters
    PlanetaryReference.MapPosition = mkMapPosition
    PlanetaryReference.PlanetarySystem = mkPlanetarySystem
    function PlanetaryReference.createBodyParameters(systemId, id, surfaceArea, aPosition,
        verticalAtPosition, altitudeAtPosition, gravityAtPosition)
        assert(isSNumber(systemId),
            'Argument 1 (systemId) must be a number:' .. type(systemId))
        assert(isSNumber(id), 'Argument 2 (id) must be a number:' .. type(id))
        assert(isSNumber(surfaceArea), 'Argument 3 (surfaceArea) must be a number:' .. type(surfaceArea))
        assert(isTable(aPosition), 'Argument 4 (aPosition) must be an array or vec3:' .. type(aPosition))
        assert(isTable(verticalAtPosition),
            'Argument 5 (verticalAtPosition) must be an array or vec3:' .. type(verticalAtPosition))
        assert(isSNumber(altitudeAtPosition),
            'Argument 6 (altitude) must be in meters:' .. type(altitudeAtPosition))
        assert(isSNumber(gravityAtPosition),
            'Argument 7 (gravityAtPosition) must be number:' .. type(gravityAtPosition))
        local radius = msqrt(surfaceArea / 4 / math.pi)
        local distance = radius + altitudeAtPosition
        local center = vec3(aPosition) + distance * vec3(verticalAtPosition)
        local GM = gravityAtPosition * distance * distance
        return mkBodyParameters(systemId, id, radius, center, GM)
    end

    PlanetaryReference.isMapPosition = isMapPosition
    function PlanetaryReference:getPlanetarySystem(overload)
        -- if galaxyAtlas then
        if i == nil then i = 0 end
        if nv == nil then nv = 0 end
        local systemId = overload
        if isMapPosition(overload) then
            systemId = overload.systemId
        end
        if type(systemId) == 'number' then
            local s = self.galaxyAtlas[i]
            if s then
                if getmetatable(nv) ~= PlanetarySystem then
                    s = mkPlanetarySystem(s)
                end
                return s
            end
        end
        -- end
        -- return nil
    end

    function PlanetarySystem:sizeCalculator(body)
        return 1.05*body.radius
        end
        
        function PlanetarySystem:castIntersections(origin, direction, sizeCalculator, bodyIds, collection, sorted)
        local candidates = {}
        if collection then
            -- Since we don't use bodyIds anywhere, got rid of them
            -- It was two tables doing basically the same thing

            -- Changed this to insert the body to candidates
            for _, body in pairs(collection) do
                table.insert(candidates, body)
            end
        else
            candidates = planetAtlas -- Already-built and probably already sorted
        end
        -- Added this because, your knownContacts list is already sorted, can skip an expensive re-sort
        if not sorted then
            table.sort(candidates, function (a1, b2)
                local a = a1.center
                local b = b2.center
                return (a.x-origin.x)^2+(a.y-origin.y)^2+(a.z-origin.z)^2 < (b.x-origin.x)^2+(b.y-origin.y)^2+(b.z-origin.z)^2
            end)
        end
        local dir = direction:normalize()
        -- Use the body directly from the for loop instead of getting it with i
        for _, body in ipairs(candidates) do
            local c_oV3 = body.center - origin
            -- Changed to the new method.  IDK if this is how self works but I think so
            local radius = self:sizeCalculator(body)
            local dot = c_oV3:dot(dir)
            local desc = dot ^ 2 - (c_oV3:len2() - radius ^ 2)
            if desc >= 0 then
                local root = msqrt(desc)
                local farSide = dot + root
                local nearSide = dot - root
                if nearSide > 0 then
                    return body, farSide, nearSide
                elseif farSide > 0 then
                    return body, farSide, nil
                end
            end
        end
        return nil, nil, nil
    end

    function PlanetarySystem:closestBody(coordinates)
        assert(type(coordinates) == 'table', 'Invalid coordinates.')
        local minDistance2, body
        local coord = vec3(coordinates)
        for _, params in pairs(self) do
            local distance2 = (params.center - coord):len2()
            if (not body or distance2 < minDistance2) and params.name ~= "Space" then -- Never return space.  
                body = params
                minDistance2 = distance2
            end
        end
        return body
    end

    function PlanetarySystem:convertToBodyIdAndWorldCoordinates(overload)
        local mapPosition = overload
        if isString(overload) then
            mapPosition = mkMapPosition(overload)
        end
        if mapPosition.id == 0 then
            return 0, vec3(mapPosition.latitude, mapPosition.longitude, mapPosition.altitude)
        end
        local params = self:getBodyParameters(mapPosition)
        if params then
            return mapPosition.id, params:convertToWorldCoordinates(mapPosition)
        end
    end

    function PlanetarySystem:getBodyParameters(overload)
        local id = overload
        if isMapPosition(overload) then
            id = overload.id
        end
        assert(isSNumber(id), 'Argument 1 (id) must be a number:' .. type(id))
        return self[id]
    end

    function PlanetarySystem:getPlanetarySystemId()
        local _, v = next(self)
        return v and v.systemId
    end

    function BodyParameters:convertToMapPosition(worldCoordinates)
        assert(isTable(worldCoordinates),
            'Argument 1 (worldCoordinates) must be an array or vec3:' .. type(worldCoordinates))
        local worldVec = vec3(worldCoordinates)
        if self.id == 0 then
            return setmetatable({
                latitude = worldVec.x,
                longitude = worldVec.y,
                altitude = worldVec.z,
                id = 0,
                systemId = self.systemId
            }, MapPosition)
        end
        local coords = worldVec - self.center
        local distance = coords:len()
        local altitude = distance - self.radius
        local latitude = 0
        local longitude = 0
        if not float_eq(distance, 0) then
            local phi = atan(coords.y, coords.x)
            longitude = phi >= 0 and phi or (2 * math.pi + phi)
            latitude = math.pi / 2 - math.acos(coords.z / distance)
        end
        return setmetatable({
            latitude = latitude,
            longitude = longitude,
            altitude = altitude,
            id = self.id,
            systemId = self.systemId
        }, MapPosition)
    end

    function BodyParameters:convertToWorldCoordinates(overload)
        local mapPosition = isString(overload) and mkMapPosition(overload) or overload
        if mapPosition.id == 0 then -- support deep space map position
            return vec3(mapPosition.latitude, mapPosition.longitude, mapPosition.altitude)
        end
        assert(isMapPosition(mapPosition), 'Argument 1 (mapPosition) is not an instance of "MapPosition".')
        assert(mapPosition.systemId == self.systemId,
            'Argument 1 (mapPosition) has a different planetary s ID.')
        assert(mapPosition.id == self.id, 'Argument 1 (mapPosition) has a different planetary body ID.')
        local xproj = math.cos(mapPosition.latitude)
        return self.center + (self.radius + mapPosition.altitude) *
                vec3(xproj * math.cos(mapPosition.longitude), xproj * math.sin(mapPosition.longitude),
                    math.sin(mapPosition.latitude))
    end

    function BodyParameters:getAltitude(worldCoordinates)
        return (vec3(worldCoordinates) - self.center):len() - self.radius
    end

    function BodyParameters:getDistance(worldCoordinates)
        return (vec3(worldCoordinates) - self.center):len()
    end

    function BodyParameters:getGravity(worldCoordinates)
        local radial = self.center - vec3(worldCoordinates) -- directed towards body
        local len2 = radial:len2()
        return (self.GM / len2) * radial / msqrt(len2)
    end
    -- end of module
    return setmetatable(PlanetaryReference, {
        __call = function(_, ...)
            return mkPlanetaryReference(...)
        end
    })
end

-- Class Definitions to organize code
local function Kinematics() -- Part of Jaylebreak's flight files, modified slightly for hud

    local Kinematic = {} -- just a namespace
    local C = 30000000 / 3600
    local C2 = C * C
    local ITERATIONS = 100 -- iterations over engine "warm-up" period

    function Kinematic.computeAccelerationTime(initial, acceleration, final)
        -- The low speed limit of following is: t=(vf-vi)/a (from: vf=vi+at)
        local k1 = C * math.asin(initial / C)
        return (C * math.asin(final / C) - k1) / acceleration
    end

    function Kinematic.computeDistanceAndTime(initial, final, restMass, thrust, t50, brakeThrust)

        t50 = t50 or 0
        brakeThrust = brakeThrust or 0 -- usually zero when accelerating
        local speedUp = initial <= final
        local a0 = thrust * (speedUp and 1 or -1) / restMass
        local b0 = -brakeThrust / restMass
        local totA = a0 + b0
        if speedUp and totA <= 0 or not speedUp and totA >= 0 then
            return -1, -1 -- no solution
        end
        local distanceToMax, timeToMax = 0, 0

        if a0 ~= 0 and t50 > 0 then

            local k1 = math.asin(initial / C)
            local c1 = math.pi * (a0 / 2 + b0)
            local c2 = a0 * t50
            local c3 = C * math.pi
            local v = function(t)
                local w = (c1 * t - c2 * math.sin(math.pi * t / 2 / t50) + c3 * k1) / c3
                local tan = math.tan(w)
                return C * tan / msqrt(tan * tan + 1)
            end
            local speedchk = speedUp and function(s)
                return s >= final
            end or function(s)
                return s <= final
            end
            timeToMax = 2 * t50
            if speedchk(v(timeToMax)) then
                local lasttime = 0
                while mabs(timeToMax - lasttime) > 0.5 do
                    local t = (timeToMax + lasttime) / 2
                    if speedchk(v(t)) then
                        timeToMax = t
                    else
                        lasttime = t
                    end
                end
            end
            -- There is no closed form solution for distance in this case.
            -- Numerically integrate for time t=0 to t=2*T50 (or less)
            local lastv = initial
            local tinc = timeToMax / ITERATIONS
            for step = 1, ITERATIONS do
                local speed = v(step * tinc)
                distanceToMax = distanceToMax + (speed + lastv) * tinc / 2
                lastv = speed
            end
            if timeToMax < 2 * t50 then
                return distanceToMax, timeToMax
            end
            initial = lastv
        end

        local k1 = C * math.asin(initial / C)
        local time = (C * math.asin(final / C) - k1) / totA
        local k2 = C2 * math.cos(k1 / C) / totA
        local distance = k2 - C2 * math.cos((totA * time + k1) / C) / totA
        return distance + distanceToMax, time + timeToMax
    end

    function Kinematic.computeTravelTime(initial, acceleration, distance)
        -- The low speed limit of following is: t=(sqrt(2ad+v^2)-v)/a
        -- (from: d=vt+at^2/2)
        if distance == 0 then
            return 0
        end
        -- So then what's with all the weird ass sines and cosines?
        if acceleration > 0 then
            local k1 = C * math.asin(initial / C)
            local k2 = C2 * math.cos(k1 / C) / acceleration
            return (C * math.acos(acceleration * (k2 - distance) / C2) - k1) / acceleration
        end
        if initial == 0 then
            return -1 -- IDK something like that should make sure we never hit the assert yelling at us
        end
        assert(initial > 0, 'Acceleration and initial speed are both zero.')
        return distance / initial
    end

    return Kinematic
end
local function Keplers() -- Part of Jaylebreak's flight files, modified slightly for hud
    local vec3 = require('cpml.vec3')
    local PlanetRef = PlanetRef()
    local function isString(s)
        return type(s) == 'string'
    end
    local function isTable(t)
        return type(t) == 'table'
    end
    Kepler = {}
    Kepler.__index = Kepler

    function Kepler:escapeAndOrbitalSpeed(altitude)
        assert(self.body)
        -- P = -GMm/r and KE = mv^2/2 (no lorentz factor used)
        -- mv^2/2 = GMm/r
        -- v^2 = 2GM/r
        -- v = sqrt(2GM/r1)
        local distance = altitude + self.body.radius
        if not float_eq(distance, 0) then
            local orbit = msqrt(self.body.GM / distance)
            return msqrt(2) * orbit, orbit
        end
        return nil, nil
    end

    function Kepler:orbitalParameters(overload, velocity)
        assert(self.body)
        assert(isTable(overload) or isString(overload))
        assert(isTable(velocity))
        local pos = (isString(overload) or PlanetRef.isMapPosition(overload)) and
                        self.body:convertToWorldCoordinates(overload) or vec3(overload)
        local v = vec3(velocity)
        local r = pos - self.body.center
        local v2 = v:len2()
        local d = r:len()
        local mu = self.body.GM
        local e = ((v2 - mu / d) * r - r:dot(v) * v) / mu
        local a = mu / (2 * mu / d - v2)
        local ecc = e:len()
        local dir = e:normalize()
        local pd = a * (1 - ecc)
        local ad = a * (1 + ecc)
        local per = pd * dir + self.body.center
        local apo = ecc <= 1 and -ad * dir + self.body.center or nil
        local trm = msqrt(a * mu * (1 - ecc * ecc))
        local Period = apo and 2 * math.pi * msqrt(a ^ 3 / mu)
        -- These are great and all, but, I need more.
        local trueAnomaly = math.acos((e:dot(r)) / (ecc * d))
        if r:dot(v) < 0 then
            trueAnomaly = -(trueAnomaly - 2 * math.pi)
        end
        -- Apparently... cos(EccentricAnomaly) = (cos(trueAnomaly) + eccentricity)/(1 + eccentricity * cos(trueAnomaly))
        local EccentricAnomaly = math.acos((math.cos(trueAnomaly) + ecc) / (1 + ecc * math.cos(trueAnomaly)))
        -- Then.... apparently if this is below 0, we should add 2pi to it
        -- I think also if it's below 0, we're past the apoapsis?
        local timeTau = EccentricAnomaly
        if timeTau < 0 then
            timeTau = timeTau + 2 * math.pi
        end
        -- So... time since periapsis...
        -- Is apparently easy if you get mean anomly.  t = M/n where n is mean motion, = 2*pi/Period
        local MeanAnomaly = timeTau - ecc * math.sin(timeTau)
        local TimeSincePeriapsis = 0
        local TimeToPeriapsis = 0
        local TimeToApoapsis = 0
        if Period ~= nil then
            TimeSincePeriapsis = MeanAnomaly / (2 * math.pi / Period)
            -- Mean anom is 0 at periapsis, positive before it... and positive after it.
            -- I guess this is why I needed to use timeTau and not EccentricAnomaly here

            TimeToPeriapsis = Period - TimeSincePeriapsis
            TimeToApoapsis = TimeToPeriapsis + Period / 2
            if trueAnomaly - math.pi > 0 then -- TBH I think something's wrong in my formulas because I needed this.
                TimeToPeriapsis = TimeSincePeriapsis
                TimeToApoapsis = TimeToPeriapsis + Period / 2
            end
            if TimeToApoapsis > Period then
                TimeToApoapsis = TimeToApoapsis - Period
            end
        end
        return {
            periapsis = {
                position = per,
                speed = trm / pd,
                circularOrbitSpeed = msqrt(mu / pd),
                altitude = pd - self.body.radius
            },
            apoapsis = apo and {
                position = apo,
                speed = trm / ad,
                circularOrbitSpeed = msqrt(mu / ad),
                altitude = ad - self.body.radius
            },
            currentVelocity = v,
            currentPosition = pos,
            eccentricity = ecc,
            period = Period,
            eccentricAnomaly = EccentricAnomaly,
            meanAnomaly = MeanAnomaly,
            timeToPeriapsis = TimeToPeriapsis,
            timeToApoapsis = TimeToApoapsis,
            trueAnomaly = trueAnomaly
        }
    end
    local function new(bodyParameters)
        local params = PlanetRef.BodyParameters(bodyParameters.systemId, bodyParameters.id,
                        bodyParameters.radius, bodyParameters.center, bodyParameters.GM)
        return setmetatable({
            body = params
        }, Kepler)
    end
    return setmetatable(Kepler, {
        __call = function(_, ...)
            return new(...)
        end
    })
end   

local function AtlasClass() -- Atlas and Interplanetary functions including Update Autopilot Target

    -- Atlas functions
        local function getPlanet(position)
            local p = sys:closestBody(position)
            if (position-p.center):len() > p.radius + p.noAtmosphericDensityAltitude then
                p = atlas[0][0]
            end
            return p
        end

        local function UpdateAtlasLocationsList()
            local function atlasCmp (left, right)
                return left.name < right.name
            end        
            AtlasOrdered = {}
            for k, v in pairs(atlas[0]) do
                AtlasOrdered[#AtlasOrdered + 1] = { name = v.name, index = k}
            end

            table.sort(AtlasOrdered, atlasCmp)
        end
        
        local function findAtlasIndex(atlasList)
            for k, v in pairs(atlasList) do
                if v.name and v.name == CustomTarget.name then
                    return k
                end
            end
            return -1
        end

        local function UpdateAutopilotTarget()
            apScrollIndex = AutopilotTargetIndex
            -- So the indices are weird.  I think we need to do a pairs
            if AutopilotTargetIndex == 0 then
                AutopilotTargetName = "None"
                autopilotTargetPlanet = nil
                CustomTarget = nil
                return true
            end
            local atlasIndex = AtlasOrdered[AutopilotTargetIndex].index
            local autopilotEntry = atlas[0][atlasIndex]
            if autopilotEntry.center then -- Is a real atlas entry
                AutopilotTargetName = autopilotEntry.name
                autopilotTargetPlanet = galaxyReference[0][atlasIndex]
                if CustomTarget ~= nil then
                    if atmosDensity == 0 then
                        if sysUpData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) ~= 1 then
                            sysAddData(widgetMaxBrakeTimeText, widgetMaxBrakeTime) end
                        if sysUpData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) ~= 1 then
                            sysAddData(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) end
                        if sysUpData(widgetCurBrakeTimeText, widgetCurBrakeTime) ~= 1 then
                            sysAddData(widgetCurBrakeTimeText, widgetCurBrakeTime) end
                        if sysUpData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) ~= 1 then
                            sysAddData(widgetCurBrakeDistanceText, widgetCurBrakeDistance) end
                        if sysUpData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) ~= 1 then
                            sysAddData(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) end
                    end
                    if sysUpData(widgetMaxMassText, widgetMaxMass) ~= 1 then
                        sysAddData(widgetMaxMassText, widgetMaxMass) end
                    if sysUpData(widgetTravelTimeText, widgetTravelTime) ~= 1 then
                        sysAddData(widgetTravelTimeText, widgetTravelTime) end
                    if sysUpData(widgetTargetOrbitText, widgetTargetOrbit) ~= 1 then
                        sysAddData(widgetTargetOrbitText, widgetTargetOrbit) end
                end
                CustomTarget = nil
            else
                CustomTarget = autopilotEntry
                for _, v in pairs(galaxyReference[0]) do
                    if v.name == CustomTarget.planetname then
                        autopilotTargetPlanet = v
                        AutopilotTargetName = CustomTarget.name
                        break
                    end
                end
                if sysUpData(widgetMaxMassText, widgetMaxMass) ~= 1 then
                    sysAddData(widgetMaxMassText, widgetMaxMass) end
                if sysUpData(widgetTravelTimeText, widgetTravelTime) ~= 1 then
                    sysAddData(widgetTravelTimeText, widgetTravelTime) end
            end
            if CustomTarget == nil then
                AutopilotTargetCoords = vec3(autopilotTargetPlanet.center) -- Aim center until we align
            else
                AutopilotTargetCoords = CustomTarget.position
            end
            -- Determine the end speed
            if autopilotTargetPlanet.planetname ~= "Space" then
                if autopilotTargetPlanet.hasAtmosphere then 
                    AutopilotTargetOrbit = mfloor(autopilotTargetPlanet.radius*(TargetOrbitRadius-1) + autopilotTargetPlanet.noAtmosphericDensityAltitude)
                else
                    AutopilotTargetOrbit = mfloor(autopilotTargetPlanet.radius*(TargetOrbitRadius-1) + autopilotTargetPlanet.surfaceMaxAltitude)
                end
            else
                AutopilotTargetOrbit = AutopilotSpaceDistance
            end
            if CustomTarget ~= nil and CustomTarget.planetname == "Space" then 
                AutopilotEndSpeed = 0
            else
                _, AutopilotEndSpeed = Kep(autopilotTargetPlanet):escapeAndOrbitalSpeed(AutopilotTargetOrbit)
            end
            AutopilotPlanetGravity = 0 -- This is inaccurate unless we integrate and we're not doing that.  
            AutopilotAccelerating = false
            AutopilotBraking = false
            AutopilotCruising = false
            Autopilot = false
            AutopilotRealigned = false
            AutopilotStatus = "Aligning"
            return true

        end

        local function adjustAutopilotTargetIndex(up)
            if not Autopilot and not VectorToTarget and not spaceLaunch and not IntoOrbit and not Reentry and not finalLand then -- added to prevent crash when index == 0
                if up == nil then 
                    AutopilotTargetIndex = AutopilotTargetIndex + 1
                    if AutopilotTargetIndex > #AtlasOrdered then
                        AutopilotTargetIndex = 0
                    end
                else
                    AutopilotTargetIndex = AutopilotTargetIndex - 1
                    if AutopilotTargetIndex < 0 then
                        AutopilotTargetIndex = #AtlasOrdered
                    end  
                end
                if AutopilotTargetIndex == 0 then
                    UpdateAutopilotTarget()
                else
                    local atlasIndex = AtlasOrdered[AutopilotTargetIndex].index
                    local autopilotEntry = atlas[0][atlasIndex]
                    if autopilotEntry ~= nil and autopilotEntry.name == "Space" or 
                        (iphCondition == "Custom Only" and autopilotEntry.center) or
                        (iphCondition == "No Moons" and string.find(autopilotEntry.name, "Moon") ~= nil)
                    then 
                        if up == nil then 
                            adjustAutopilotTargetIndex()
                        else
                            adjustAutopilotTargetIndex(1)
                        end
                    else
                        UpdateAutopilotTarget()
                    end
                end        
            else
                msgText = "Disengage autopilot before changing Interplanetary Helper"
                play("iph","AP")
            end
        end

        local function ClearCurrentPosition()
            local index = -1
            index = findAtlasIndex(atlas[0])
            if index > -1 then
                table.remove(atlas[0], index)
            end
            -- And SavedLocations
            index = -1
            index = findAtlasIndex(SavedLocations)
            if index ~= -1 then
                msgText = CustomTarget.name .. " saved location cleared"
                table.remove(SavedLocations, index)
            end
            adjustAutopilotTargetIndex()
            UpdateAtlasLocationsList()
        end
        
        local function AddNewLocation(name, position, temp, safe)
            if dbHud_1 or temp then
    
                local p = getPlanet(position)
                local gravity = p.gravity
                if safe then
                    gravity = u.getClosestPlanetInfluence()
                end
                local newLocation = {
                    position = position,
                    name = name,
                    planetname = p.name,
                    gravity = gravity,
                    safe = safe, -- This indicates we can extreme land here, if this was a real positional waypoint
                }
                if not temp then 
                    SavedLocations[#SavedLocations + 1] = newLocation
                else
                    for k, v in pairs(atlas[0]) do
                        if v.name and name == v.name then
                            table.remove(atlas[0], k)
                        end
                    end
                end
                -- Nearest planet, gravity also important - if it's 0, we don't autopilot to the target planet, the target isn't near a planet.                      
                table.insert(atlas[0], newLocation)
                UpdateAtlasLocationsList()
                UpdateAutopilotTarget() -- This is safe and necessary to do right?
                -- Store atmosphere so we know whether the location is in space or not
                msgText = "Location saved as " .. name.."("..p.name..")"
            else
                msgText = "Databank must be installed to save permanent locations"
            end
        end

    local Atlas = {}

    function Atlas.UpdateAtlasLocationsList()
        UpdateAtlasLocationsList()
    end
    
    function Atlas.UpdateAutopilotTarget()
        UpdateAutopilotTarget()
    end

    function Atlas.adjustAutopilotTargetIndex(up)
        adjustAutopilotTargetIndex(up)
    end 

    function Atlas.findAtlasIndex(atlasList)
        findAtlasIndex(atlasList)
    end

    function Atlas.UpdatePosition(newName) -- Update a saved location with new position
        local index = findAtlasIndex(SavedLocations)
        if index ~= -1 then
            if newName ~= nil then
                SavedLocations[index].name = newName
                AutopilotTargetIndex = AutopilotTargetIndex - 1
                adjustAutopilotTargetIndex()
            else
                local location = SavedLocations[index]
                location.gravity = u.getClosestPlanetInfluence()
                location.position = worldPos
                location.safe = true
            end
            --UpdateAtlasLocationsList() -- Do we need these, if we only changed the name?  They are already done in AddNewLocation otherwise
            msgText = SavedLocations[index].name .. " position updated ("..SavedLocations[index].planetname..")"
            --UpdateAutopilotTarget()
        else
            msgText = "Name Not Found"
        end
    end

    function Atlas.AddNewLocation(name, position, temp, safe)
        AddNewLocation(name, position, temp, safe)
    end

    function Atlas.ClearCurrentPosition()
        ClearCurrentPosition()
    end

    --Initial Setup
    for k, v in pairs(SavedLocations) do
        table.insert(atlas[0], v)
    end

    UpdateAtlasLocationsList()
    if AutopilotTargetIndex > #AtlasOrdered then AutopilotTargetIndex=0 end
    Atlas.UpdateAutopilotTarget()
    return Atlas
end

-- DU Events written for wrap and minimization. Written by Dimencia and Archaegeo. Optimization and Automation of scripting by ChronosWS  Linked sources where appropriate, most have been modified.
function script.onStart()
    -- Local functions for onStart

        local valuesAreSet = false
        local function LoadVariables()

            local function processVariableList(varList)
                local hasKey = dbHud_1.hasKey
                for k, v in pairs(varList) do
                    if hasKey(k) then
                        local result = jdecode(dbHud_1.getStringValue(k))
                        if result ~= nil then
                            v.set(result)
                            valuesAreSet = true
                        end
                    end
                end
            end

            if dbHud_1 then
                if not useTheseSettings then 
                    processVariableList(saveableVariables())
                    coroutine.yield()
                    processVariableList(autoVariables)
                else
                    processVariableList(autoVariables)
                    msgText = "Updated user preferences used.  Will be saved when you exit seat.\nToggle off useTheseSettings to use saved values"
                    msgTimer = 5
                    valuesAreSet = false
                end
                coroutine.yield()
                if valuesAreSet then
                    msgText = "Loaded Saved Variables"
                    resolutionWidth = ResolutionX
                    resolutionHeight = ResolutionY
                    BrakeToggleStatus = BrakeToggleDefault
                    userControlScheme = string.lower(userControlScheme)
                    autoRoll = autoRollPreference
                    adjustedAtmoSpeedLimit = AtmoSpeedLimit
                    rgb = [[rgb(]] .. mfloor(PrimaryR + 0.5) .. "," .. mfloor(PrimaryG + 0.5) .. "," .. mfloor(PrimaryB + 0.5) ..
                    [[)]]
                    rgbdim = [[rgb(]] .. mfloor(PrimaryR * 0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," ..
                    mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]  
                elseif not useTheseSettings then
                    msgText = "No Saved Variables Found - Exit HUD to save settings"
                end
                if LastVersionUpdate < 1.500 then
                    if LowOrbitHeight < 2000 then
                        msgText = "Updating LowOrbitHeight to new minimum default of 2000."
                        LowOrbitHeight = 2000
                    end
                end
                LastVersionUpdate = VERSION_NUMBER
            else
                msgText = "No databank found. Attach one to control u and rerun \nthe autoconfigure to save preferences and locations"
            end
        
            if (LastStartTime + 180) < time then -- Variables to reset if out of seat (and not on hud) for more than 3 min
                LastMaxBrakeInAtmo = 0
            end
            LastStartTime = time
            userControlScheme = string.lower(userControlScheme)
            if string.find("keyboard virtual joystick mouse",  userControlScheme) == nil then 
                msgText = "Invalid User Control Scheme selected.\nChange userControlScheme in Lua Parameters to keyboard, mouse, or virtual joystick\nOr use shift and button in screen"
                msgTimer = 7
            end
        
            if antigrav and not ExternalAGG then
                if AntigravTargetAltitude == nil then 
                    AntigravTargetAltitude = coreAltitude
                end
                antigrav.setBaseAltitude(AntigravTargetAltitude)
            end

            VectorStatus = "Proceeding to Waypoint"
        end

        local function ProcessElements()
            
            local function CalculateFuelVolume(curMass, vanillaMaxVolume)
                if curMass > vanillaMaxVolume then
                    vanillaMaxVolume = curMass
                end
                local f1, f2 = 0, 0
                if ContainerOptimization > 0 then 
                    f1 = ContainerOptimization * 0.05
                end
                if FuelTankOptimization > 0 then 
                    f2 = FuelTankOptimization * 0.05
                end
                vanillaMaxVolume = vanillaMaxVolume * (1 - (f1 + f2))
                return vanillaMaxVolume            
            end

            local eleName = c.getElementNameById
            local checkTanks = (fuelX ~= 0 and fuelY ~= 0)
            for k in pairs(elementsID) do --Look for space engines, landing gear, fuel tanks if not slotted and c size
                local type = c.getElementTypeById(elementsID[k])
                if stringmatch(type, '^.*Atmospheric Engine$') then
                    if stringmatch(tostring(c.getElementTagsById(elementsID[k])), '^.*vertical.*$') and c.getElementForwardById(elementsID[k])[3]>0 then
                        UpVertAtmoEngine = true
                    end
                end

                if stringmatch(type, '^.*Space Engine$') then
                    SpaceEngines = true
                    if stringmatch(tostring(c.getElementTagsById(elementsID[k])), '^.*vertical.*$') then
                        local enrot = c.getElementForwardById(elementsID[k])
                        if enrot[3] < 0 then
                            SpaceEngineVertUp = true
                        else
                            SpaceEngineVertDn = true
                        end
                    end
                end
                if (type == "Landing Gear") then
                    hasGear = true
                end
                if (type == "Dynamic Core Unit") then
                    local hp = eleMaxHp(elementsID[k])
                    if hp > 10000 then
                        coreHalfDiag = 110
                    elseif hp > 1000 then
                        coreHalfDiag = 55
                    elseif hp > 150 then
                        coreHalfDiag = 27
                    end
                end
                eleTotalMaxHp = eleTotalMaxHp + eleMaxHp(elementsID[k])
                if checkTanks and (type == "Atmospheric Fuel Tank" or type == "Space Fuel Tank" or type == "Rocket Fuel Tank") then
                    local hp = eleMaxHp(elementsID[k])
                    local mass = eleMass(elementsID[k])
                    local curMass = 0
                    local curTime = systime()
                    if (type == "Atmospheric Fuel Tank") then
                        local vanillaMaxVolume = 400
                        local massEmpty = 35.03
                        if hp > 10000 then
                            vanillaMaxVolume = 51200 -- volume in kg of L tank
                            massEmpty = 5480
                        elseif hp > 1300 then
                            vanillaMaxVolume = 6400 -- volume in kg of M
                            massEmpty = 988.67
                        elseif hp > 150 then
                            vanillaMaxVolume = 1600 --- volume in kg small
                            massEmpty = 182.67
                        end
                        curMass = mass - massEmpty
                        if fuelTankHandlingAtmo > 0 then
                            vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingAtmo * 0.2))
                        end
                        vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                        atmoTanks[#atmoTanks + 1] = {elementsID[k], eleName(elementsID[k]),
                                                    vanillaMaxVolume, massEmpty, curMass, curTime}
                    end
                    if (type == "Rocket Fuel Tank") then
                        local vanillaMaxVolume = 320
                        local massEmpty = 173.42
                        if hp > 65000 then
                            vanillaMaxVolume = 40000 -- volume in kg of L tank
                            massEmpty = 25740
                        elseif hp > 6000 then
                            vanillaMaxVolume = 5120 -- volume in kg of M
                            massEmpty = 4720
                        elseif hp > 700 then
                            vanillaMaxVolume = 640 --- volume in kg small
                            massEmpty = 886.72
                        end
                        curMass = mass - massEmpty
                        if fuelTankHandlingRocket > 0 then
                            vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingRocket * 0.1))
                        end
                        vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                        rocketTanks[#rocketTanks + 1] = {elementsID[k], eleName(elementsID[k]),
                                                        vanillaMaxVolume, massEmpty, curMass, curTime}
                    end
                    if (type == "Space Fuel Tank") then
                        local vanillaMaxVolume = 600
                        local massEmpty = 35.03
                        if hp > 10000 then
                            vanillaMaxVolume = 76800 -- volume in kg of L tank
                            massEmpty = 5480
                        elseif hp > 1300 then
                            vanillaMaxVolume = 9600 -- volume in kg of M
                            massEmpty = 988.67
                        elseif hp > 150 then
                            vanillaMaxVolume = 2400 -- volume in kg of S
                            massEmpty = 182.67                                
                        end
                        curMass = mass - massEmpty
                        if fuelTankHandlingSpace > 0 then
                            vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume * (fuelTankHandlingSpace * 0.2))
                        end
                        vanillaMaxVolume =  CalculateFuelVolume(curMass, vanillaMaxVolume)
                        spaceTanks[#spaceTanks + 1] = {elementsID[k], eleName(elementsID[k]),
                                                    vanillaMaxVolume, massEmpty, curMass, curTime}
                    end
                end
            end
            if not UpVertAtmoEngine then
                VertTakeOff, VertTakeOffEngine = false, false
            end
        end
        
        local function SetupChecks()
            
            if gyro ~= nil then
                gyroIsOn = gyro.getState() == 1
            end
            if not stablized then 
                navCom:deactivateGroundEngineAltitudeStabilization()
            end
            if userControlScheme ~= "keyboard" then
                sysLockVw(1)
            else
                sysLockVw(0)
            end
            -- Close door and retract ramp if available
            if door and (inAtmo or (not inAtmo and coreAltitude < 10000)) then
                for _, v in pairs(door) do
                    v.toggle()
                end
            end
            if switch then 
                for _, v in pairs(switch) do
                    v.toggle()
                end
            end    
            if forcefield and (inAtmo or (not inAtmo == 0 and coreAltitude < 10000)) then
                for _, v in pairs(forcefield) do
                    v.toggle()
                end
            end
            if antigrav then
                antigravOn = (antigrav.getState() == 1)
                if antigravOn and not ExternalAGG then antigrav.show() end
            end
            -- unfreeze the player if he is remote controlling the construct
            if isRemote() == 1 and RemoteFreeze then
                s.freeze(1)
            else
                s.freeze(0)
            end
            if hasGear then
                GearExtended = (Nav.control.isAnyLandingGearExtended() == 1)
                if GearExtended then
                    Nav.control.extendLandingGears()
                else
                    Nav.control.retractLandingGears()
                end
            end

            -- Engage brake and extend Gear if either a hover detects something, or they're in space and moving very slowly
            if abvGndDet ~= -1 or (not inAtmo and coreVelocity:len() < 50) then
                BrakeIsOn = true
                GearExtended = true
                if hasGear then
                    Nav.control.extendLandingGears()
                end
            else
                BrakeIsOn = false
            end
        
            navCom:setTargetGroundAltitude(targetGroundAltitude)
        
            -- Store their max kinematic parameters in ship-up direction for use in brake-landing
            if inAtmo and abvGndDet ~= -1 then 
                maxKinematicUp = c.getMaxKinematicsParametersAlongAxis("ground", c.getConstructOrientationUp())[1]
            end
        
            WasInAtmo = inAtmo
        end

        local function atlasSetup()
            local atlasCopy = {}
            
            local function getSpaceEntry()
                return {
                            id = 0,
                            name = { "Space", "Space", "Space"},
                            type = {},
                            biosphere = {},
                            classification = {},
                            habitability = {},
                            description = {},
                            iconPath = "",
                            hasAtmosphere = false,
                            isSanctuary = false,
                            isInSafeZone = true,
                            systemId = 0,
                            positionInSystem = 0,
                            satellites = {},
                            center = { 0, 0, 0 },
                            gravity = 0,
                            radius = 0,
                            atmosphereThickness = 0,
                            atmosphereRadius = 0,
                            surfaceArea = 0,
                            surfaceAverageAltitude = 0,
                            surfaceMaxAltitude = 0,
                            surfaceMinAltitude = 0,
                            GM = 0,
                            ores = {},
                            territories = 0,
                            noAtmosphericDensityAltitude = 0,
                            spaceEngineMinAltitude = 0,
                        }
            end

            local altTable = { [1]=4480, [6]=4480, [7]=6270} -- Alternate altitudes for madis, sinnen, sicari
            for galaxyId,galaxy in pairs(atlas) do
                -- Create a copy of Space with the appropriate SystemId for each galaxy
                atlas[galaxyId][0] = getSpaceEntry()
                atlas[galaxyId][0].systemId = galaxyId
                atlasCopy[galaxyId] = {} -- Prepare a copy galaxy

                for planetId,planet in pairs(atlas[galaxyId]) do
                    planet.gravity = planet.gravity/9.8
                    planet.center = vec3(planet.center)
                    planet.name = planet.name[1]
            
                    planet.noAtmosphericDensityAltitude = planet.atmosphereThickness or (planet.atmosphereRadius-planet.radius)
                    planet.spaceEngineMinAltitude = altTable[planet.id] or 0.68377*(planet.atmosphereThickness or (planet.atmosphereRadius-planet.radius))
                            
                    planet.planetarySystemId = galaxyId
                    planet.bodyId = planet.id
                    atlasCopy[galaxyId][planetId] = planet
                    if minAtlasX == nil or planet.center.x < minAtlasX then
                        minAtlasX = planet.center.x
                    end
                    if maxAtlasX == nil or planet.center.x > maxAtlasX then
                        maxAtlasX = planet.center.x
                    end
                    if minAtlasY == nil or planet.center.y < minAtlasY then
                        minAtlasY = planet.center.y
                    end
                    if maxAtlasY == nil or planet.center.y > maxAtlasY then
                        maxAtlasY = planet.center.y
                    end
                    if planet.center and planet.name ~= "Space" then
                        planetAtlas[#planetAtlas + 1] = planet
                    end
                end
            end
            PlanetaryReference = PlanetRef()
            galaxyReference = PlanetaryReference(atlasCopy)
            -- Setup Modular Classes
            Kinematic = Kinematics()
            Kep = Keplers()

            ATLAS = AtlasClass()
        end
    
    SetupComplete = false

    beginSetup = coroutine.create(function()
        
        --[[ --EliasVilld Log Code setup material.
        Logs = Logger()
        _logCompute = Logs.CreateLog("Computation", "time")
        --]]

        navCom:setupCustomTargetSpeedRanges(axisCommandId.longitudinal,
            {1000, 5000, 10000, 20000, 30000})

        -- Load Saved Variables

        LoadVariables()
        coroutine.yield() -- Give it some time to breathe before we do the rest

        -- Find elements we care about
        ProcessElements()
        coroutine.yield() -- Give it some time to breathe before we do the rest

        AP = APClass(Nav, c, u, s, atlas, vBooster, hover, telemeter_1, antigrav,
            mabs, mfloor, atmosphere, isRemote, atan, systime, uclamp, 
            navCom, sysUpData, sysIsVwLock, msqrt, round)
        SetupChecks() -- All the if-thens to set up for particular ship.  Specifically override these with the saved variables if available
        
        coroutine.yield() -- Just to make sure

        atlasSetup()
        RADAR = RadarClass(c, s, library, radar_1, radar_2, 
            mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag)
        HUD = HudClass(Nav, c, u, s, atlas, radar_1, radar_2, antigrav, hover, shield_1,
            mabs, mfloor, stringf, jdecode, atmosphere, eleMass, isRemote, atan, systime, uclamp, 
            navCom, sysDestWid, sysIsVwLock, msqrt, round, svgText)
        HUD.ButtonSetup()
        CONTROL = ControlClass(Nav, c, u, s, atlas, vBooster, hover, antigrav, shield_1, dbHud_2,
            isRemote, navCom, sysIsVwLock, sysLockVw, sysDestWid, round, stringmatch, tonum, uclamp)
        coroutine.yield()

        u.hide()
        s.showScreen(1)
        s.showHelper(0)
        -- That was a lot of work with dirty strings and json.  Clean up
        collectgarbage("collect")
        -- Start timers
        coroutine.yield()

        u.setTimer("apTick", apTickRate)
        u.setTimer("radarTick", apTickRate)
        u.setTimer("hudTick", hudTickRate)
        u.setTimer("oneSecond", 1)
        u.setTimer("tenthSecond", 1/10)
        u.setTimer("fiveSecond", 5) 
        play("start","SU")
    end)
    coroutine.resume(beginSetup)
end

function script.onStop()
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
    play("stop","SU")
    --[[ --EliasVilld Log Code for printing timing checks.
    for _,s in pairs(Logs.getLogs()) do
        s.print(s)
    end
    --]]
end

function script.onTick(timerId)
    local lastMaxBrakeAtG = nil
    -- Various tick timers
    if timerId == "contact" then
        if not contactTimer then contactTimer = 0 end
        if time > contactTimer+10 then
            msgText = "Radar Contact" 
            play("rdrCon","RC")
            contactTimer = time
        end
        u.stopTimer("contact")
    elseif timerId == "tenthSecond" then -- Timer executed ever tenth of a second
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
            local function GetAutopilotTravelTime()
                if not Autopilot then
                    if CustomTarget == nil or CustomTarget.planetname ~= planet.name then
                        AutopilotDistance = (autopilotTargetPlanet.center - worldPos):len() -- This updates elsewhere if we're already piloting
                    else
                        AutopilotDistance = (CustomTarget.position - worldPos):len()
                    end
                end
                local speed = velMag
                local throttle = u.getThrottle()/100
                if AtmoSpeedAssist then throttle = PlayerThrottle end
                local accelDistance, accelTime =
                    Kinematic.computeDistanceAndTime(velMag, MaxGameVelocity, -- From currently velocity to max
                        coreMass, Nav:maxForceForward()*throttle, warmup, -- T50?  Assume none, negligible for this
                        0) -- Brake thrust, none for this
                -- accelDistance now has the amount of distance for which we will be accelerating
                -- Then we need the distance we'd brake from full speed
                -- Note that for some nearby moons etc, it may never reach full speed though.
                local brakeDistance, brakeTime
                if not TurnBurn then
                    brakeDistance, brakeTime = AP.GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
                else
                    brakeDistance, brakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
                end
                local _, curBrakeTime
                if not TurnBurn and speed > 0 then -- Will this cause problems?  Was spamming something in here was giving 0 speed and 0 accel
                    _, curBrakeTime = AP.GetAutopilotBrakeDistanceAndTime(speed)
                else
                    _, curBrakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(speed)
                end
                local cruiseDistance = 0
                local cruiseTime = 0
                -- So, time is in seconds
                -- If cruising or braking, use real cruise/brake values
                if AutopilotCruising or (not Autopilot and speed > 5) then -- If already cruising, use current speed
                    cruiseTime = Kinematic.computeTravelTime(speed, 0, AutopilotDistance)
                elseif brakeDistance + accelDistance < AutopilotDistance then
                    -- Add any remaining distance
                    cruiseDistance = AutopilotDistance - (brakeDistance + accelDistance)
                    cruiseTime = Kinematic.computeTravelTime(8333.0556, 0, cruiseDistance)
                else
                    local accelRatio = (AutopilotDistance - brakeDistance) / accelDistance
                    accelDistance = AutopilotDistance - brakeDistance -- Accel until we brake
                    
                    accelTime = accelTime * accelRatio
                end
                if CustomTarget ~= nil and CustomTarget.planetname == planet.name and not Autopilot then
                    return cruiseTime
                elseif AutopilotBraking then
                    return curBrakeTime
                elseif AutopilotCruising then
                    return cruiseTime + curBrakeTime
                else -- If not cruising or braking, assume we'll get to max speed
                    return accelTime + brakeTime + cruiseTime
                end
            end
            local function RefreshLastMaxBrake(gravity, force)
                if gravity == nil then
                    gravity = c.g()
                end
                gravity = round(gravity, 5) -- round to avoid insignificant updates
                if (force ~= nil and force) or (lastMaxBrakeAtG == nil or lastMaxBrakeAtG ~= gravity) then
                    local speed = coreVelocity:len()
                    local maxBrake = jdecode(u.getData()).maxBrake 
                    if maxBrake ~= nil and maxBrake > 0 and inAtmo then 
                        maxBrake = maxBrake / uclamp(speed/100, 0.1, 1)
                        maxBrake = maxBrake / atmosDensity
                        if atmosDensity > 0.10 then 
                            if LastMaxBrakeInAtmo then
                                LastMaxBrakeInAtmo = (LastMaxBrakeInAtmo + maxBrake) / 2
                            else
                                LastMaxBrakeInAtmo = maxBrake 
                            end
                        end -- Now that we're calculating actual brake values, we want this updated
                    end
                    if maxBrake ~= nil and maxBrake > 0 then
                        LastMaxBrake = maxBrake
                    end
                    lastMaxBrakeAtG = gravity
                end
            end
        RefreshLastMaxBrake(nil, true) -- force refresh, in case we took damage
        if setCruiseSpeed ~= nil then
            if navCom:getAxisCommandType(0) ~= axisCommandType.byTargetSpeed or navCom:getTargetSpeed(axisCommandId.longitudinal) ~= setCruiseSpeed then
                AP.cmdCruise(setCruiseSpeed)
            else
                setCruiseSpeed = nil
            end
        end
        if AutopilotTargetName ~= "None" then
            if panelInterplanetary == nil then
                SetupInterplanetaryPanel()
            end
            if AutopilotTargetName ~= nil then
                local customLocation = CustomTarget ~= nil
                local planetMaxMass = 0.5 * LastMaxBrakeInAtmo /
                    (autopilotTargetPlanet:getGravity(
                    autopilotTargetPlanet.center + (vec3(0, 0, 1) * autopilotTargetPlanet.radius))
                    :len())
                planetMaxMass = planetMaxMass > 1000000 and round(planetMaxMass / 1000000,2).." kTons" or round(planetMaxMass / 1000, 2).." Tons"
                sysUpData(interplanetaryHeaderText,
                    '{"label": "Target", "value": "' .. AutopilotTargetName .. '", "unit":""}')
                travelTime = GetAutopilotTravelTime() -- This also sets AutopilotDistance so we don't have to calc it again
                if customLocation and not Autopilot then -- If in autopilot, keep this displaying properly
                    distance = (worldPos - CustomTarget.position):len()
                else
                    distance = (AutopilotTargetCoords - worldPos):len() -- Don't show our weird variations
                end
                if not TurnBurn then
                    brakeDistance, brakeTime = AP.GetAutopilotBrakeDistanceAndTime(velMag)
                    maxBrakeDistance, maxBrakeTime = AP.GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
                else
                    brakeDistance, brakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(velMag)
                    maxBrakeDistance, maxBrakeTime = AP.GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
                end
                local displayText = getDistanceDisplayString(distance)
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
                if atmosDensity > 0 and not WasInAtmo then
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
                if atmosDensity == 0 and WasInAtmo then
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
            if jdecode(warpdrive.getData()).destination ~= "Unknown" and jdecode(warpdrive.getData()).distance > 400000 then
                warpdrive.show()
                showWarpWidget = true
            else
                warpdrive.hide()
                showWarpWidget = false
            end
        end
        HUD.TenthTick()

    elseif timerId == "oneSecond" then -- Timer for evaluation every 1 second
        -- Local Functions for oneSecond

            local function CheckDamage(newContent)

                local percentDam = 0
                damageMessage = ""
                local maxShipHP = eleTotalMaxHp
                local curShipHP = 0
                local damagedElements = 0
                local disabledElements = 0
                local colorMod = 0
                local color = ""
                local eleHp = c.getElementHitPointsById

                for k in pairs(elementsID) do
                    local hp = 0
                    local mhp = 0
                    mhp = eleMaxHp(elementsID[k])
                    hp = eleHp(elementsID[k])
                    curShipHP = curShipHP + hp
                    if (hp < mhp) then
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
                percentDam = mfloor((curShipHP / maxShipHP)*100)
                if percentDam < 100 then
                    newContent[#newContent + 1] = svgText(0,0,"", "pbright txt")
                    colorMod = mfloor(percentDam * 2.55)
                    color = stringf("rgb(%d,%d,%d)", 255 - colorMod, colorMod, 0)
                    if percentDam < 100 then
                        newContent[#newContent + 1] = svgText("50%", 1035, "Elemental Integrity: "..percentDam.."%", "txtbig txtmid","fill:"..color )
                        if (disabledElements > 0) then
                            newContent[#newContent + 1] = svgText("50%",1055, "Disabled Modules: "..disabledElements.." Damaged Modules: "..damagedElements, "txtbig txtmid","fill:"..color)
                        elseif damagedElements > 0 then
                            newContent[#newContent + 1] = svgText("50%", 1055, "Damaged Modules: "..damagedElements, "txtbig txtmid", "fill:" .. color)
                        end
                    end
                end
            end
            local function updateWeapons()
                if weapon then
                    if  WeaponPanelID==nil and (radarPanelID ~= nil or GearExtended)  then
                        _autoconf.displayCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true)
                        WeaponPanelID = _autoconf.panels[_autoconf.panels_size]
                    elseif WeaponPanelID ~= nil and radarPanelID == nil and not GearExtended then
                        sysDestWid(WeaponPanelID)
                        WeaponPanelID = nil
                    end
                end
            end    
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

        passengers = c.getPlayersOnBoard()
        ships = c.getDockedConstructs()
        updateWeapons()
        -- Update odometer output string
        local newContent = {}
        HUD.OneSecond(newContent)

        if ShouldCheckDamage then
            CheckDamage(newContent)
        end
        lastOdometerOutput = table.concat(newContent, "")
        collectgarbage("collect")
    elseif timerId == "fiveSecond" then -- Timer executed every 5 seconds (SatNav only stuff for now)
        if not UseSatNav then return end
        -- Support for SatNav by Trog
        myAutopilotTarget = dbHud_1.getStringValue("SPBAutopilotTargetName")
        if myAutopilotTarget ~= nil and myAutopilotTarget ~= "" and myAutopilotTarget ~= "SatNavNotChanged" then
            local result = jdecode(dbHud_1.getStringValue("SavedLocations"))
            if result ~= nil then
                SavedLocations = result        
                local index = -1        
                local newLocation        
                for k, v in pairs(SavedLocations) do        
                    if v.name and v.name == "SatNav Location" then                   
                        index = k                
                        break                
                    end            
                end        
                if index ~= -1 then       
                    newLocation = SavedLocations[index]            
                    index = -1            
                    for k, v in pairs(atlas[0]) do           
                        if v.name and v.name == "SatNav Location" then               
                            index = k                    
                            break                  
                        end                
                    end            
                    if index > -1 then           
                        atlas[0][index] = newLocation                
                    end            
                    ATLAS.UpdateAtlasLocationsList()           
                    msgText = newLocation.name .. " position updated"            
                end       
            end

            for i=1,#AtlasOrdered do    
                if AtlasOrdered[i].name == myAutopilotTarget then
                    AutopilotTargetIndex = i
                    s.print("Index = "..AutopilotTargetIndex.." "..AtlasOrdered[i].name)          
                    ATLAS.UpdateAutopilotTarget()
                    dbHud_1.setStringValue("SPBAutopilotTargetName", "SatNavNotChanged")
                    break            
                end     
            end
        end
    elseif timerId == "msgTick" then -- Timer executed whenever msgText is applied somwehere
        -- This is used to clear a message on screen after a short period of time and then stop itself
        local newContent = {}
        HUD.DisplayMessage(newContent, "empty")
        msgText = "empty"
        u.stopTimer("msgTick")
        msgTimer = 3
    elseif timerId == "animateTick" then -- Timer for animation
        Animated = true
        Animating = false
        simulatedX = 0
        simulatedY = 0
        u.stopTimer("animateTick")
    elseif timerId == "hudTick" then -- Timer for all hud updates not called elsewhere
        HUD.hudtick()
    elseif timerId == "apTick" then -- Timer for all autopilot functions
        AP.APTick()
    elseif timerId == "radarTick" then
        RADAR.UpdateRadar()
    elseif timerId == "tagTick" then
        if UseExtra == "Off" then UseExtra = "All"
        elseif UseExtra == "All" then UseExtra = "Longitude"
        elseif UseExtra == "Longitude" then UseExtra = "Lateral"
        elseif UseExtra == "Lateral" then UseExtra = "Vertical"
        else UseExtra = "Off"
        end
        msgText = "Extra Engine Tags: "..UseExtra 
        u.stopTimer("tagTick")
    end
end

function script.onFlush()
    -- Local functions for onFlush
        local function composeAxisAccelerationFromTargetSpeedV(commandAxis, targetSpeed)

            local axisCRefDirection = vec3()
            local axisWorldDirection = vec3()
        
            if (commandAxis == axisCommandId.longitudinal) then
                axisCRefDirection = vec3(c.getConstructOrientationForward())
                axisWorldDirection = constructForward
            elseif (commandAxis == axisCommandId.vertical) then
                axisCRefDirection = vec3(c.getConstructOrientationUp())
                axisWorldDirection = constructUp
            elseif (commandAxis == axisCommandId.lateral) then
                axisCRefDirection = vec3(c.getConstructOrientationRight())
                axisWorldDirection = constructRight
            else
                return vec3()
            end
        
            local gravityAcceleration = vec3(c.getWorldGravity())
            local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
        
            local airResistanceAcceleration = vec3(c.getWorldAirFrictionAcceleration())
            local airResistanceAccelerationCommand = airResistanceAcceleration:dot(axisWorldDirection)
        

            local currentAxisSpeedMS = coreVelocity:dot(axisCRefDirection)
        
            local targetAxisSpeedMS = targetSpeed * constants.kph2m
        
            if targetSpeedPID2 == nil then -- CHanged first param from 1 to 10...
                targetSpeedPID2 = pid.new(10, 0, 10.0) -- The PID used to compute acceleration to reach target speed
            end
        
            targetSpeedPID2:inject(targetAxisSpeedMS - currentAxisSpeedMS) -- update PID
        
            local accelerationCommand = targetSpeedPID2:get()
        
            local finalAcceleration = (accelerationCommand - airResistanceAccelerationCommand - gravityAccelerationCommand) * axisWorldDirection  -- Try to compensate air friction
        
            -- The hell are these? Uncommented recently just in case they were important
            --s.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
            --s.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())
        
            return finalAcceleration
        end

        local function composeAxisAccelerationFromTargetSpeed(commandAxis, targetSpeed)

            local axisCRefDirection = vec3()
            local axisWorldDirection = vec3()
        
            if (commandAxis == axisCommandId.longitudinal) then
                axisCRefDirection = vec3(c.getConstructOrientationForward())
                axisWorldDirection = constructForward
            elseif (commandAxis == axisCommandId.vertical) then
                axisCRefDirection = vec3(c.getConstructOrientationUp())
                axisWorldDirection = constructUp
            elseif (commandAxis == axisCommandId.lateral) then
                axisCRefDirection = vec3(c.getConstructOrientationRight())
                axisWorldDirection = constructRight
            else
                return vec3()
            end
        
            local gravityAcceleration = vec3(c.getWorldGravity())
            local gravityAccelerationCommand = gravityAcceleration:dot(axisWorldDirection)
        
            local airResistanceAcceleration = vec3(c.getWorldAirFrictionAcceleration())
            local airResistanceAccelerationCommand = airResistanceAcceleration:dot(axisWorldDirection)
        
            local currentAxisSpeedMS = coreVelocity:dot(axisCRefDirection)
        
            local targetAxisSpeedMS = targetSpeed * constants.kph2m
        
            if targetSpeedPID == nil then -- CHanged first param from 1 to 10...
                targetSpeedPID = pid.new(10, 0, 10.0) -- The PID used to compute acceleration to reach target speed
            end
        
            targetSpeedPID:inject(targetAxisSpeedMS - currentAxisSpeedMS) -- update PID
        
            local accelerationCommand = targetSpeedPID:get()
        
            local finalAcceleration = (accelerationCommand - airResistanceAccelerationCommand - gravityAccelerationCommand) * axisWorldDirection  -- Try to compensate air friction
        
            -- The hell are these? Uncommented recently just in case they were important
            --s.addMeasure("dynamic", "acceleration", "command", accelerationCommand)
            --s.addMeasure("dynamic", "acceleration", "intensity", finalAcceleration:len())
        
            return finalAcceleration
        end

        local function getPitch(gravityDirection, forward, right)
        
            local horizontalForward = gravityDirection:cross(right):normalize_inplace() -- Cross forward?
            local pitch = math.acos(uclamp(horizontalForward:dot(-forward), -1, 1)) * constants.rad2deg -- acos?
            
            if horizontalForward:cross(-forward):dot(right) < 0 then
                pitch = -pitch
            end -- Cross right dot forward?
            return pitch
        end

    if antigrav and not ExternalAGG then
        if not antigravOn and antigrav.getBaseAltitude() ~= AntigravTargetAltitude then 
            antigrav.setBaseAltitude(AntigravTargetAltitude) 
        end
    end

    throttleMode = (navCom:getAxisCommandType(0) == axisCommandType.byThrottle)

    if throttleMode and WasInCruise then
        -- Not in cruise, but was last tick
        AP.cmdThrottle(0)
        WasInCruise = false
    elseif not throttleMode and not WasInCruise then
        -- Is in cruise, but wasn't last tick
        PlayerThrottle = 0 -- Reset this here too, because, why not
        WasInCruise = true
    end

    -- validate params
    pitchSpeedFactor = math.max(pitchSpeedFactor, 0.01)
    yawSpeedFactor = math.max(yawSpeedFactor, 0.01)
    rollSpeedFactor = math.max(rollSpeedFactor, 0.01)
    torqueFactor = math.max(torqueFactor, 0.01)
    brakeSpeedFactor = math.max(brakeSpeedFactor, 0.01)
    brakeFlatFactor = math.max(brakeFlatFactor, 0.01)
    autoRollFactor = math.max(autoRollFactor, 0.01)
    -- final inputs
    local finalPitchInput = uclamp(pitchInput + pitchInput2 + s.getControlDeviceForwardInput(),-1,1)
    local finalRollInput = uclamp(rollInput + rollInput2 + s.getControlDeviceYawInput(),-1,1)
    local finalYawInput = uclamp((yawInput + yawInput2) - s.getControlDeviceLeftRightInput(),-1,1)
    local finalBrakeInput = brakeInput

    -- Axis
    worldVertical = vec3(c.getWorldVertical()) -- along gravity
    if worldVertical == nil or worldVertical:len() == 0 then
        worldVertical = (planet.center - worldPos):normalize() -- I think also along gravity hopefully?
    end

    constructUp = vec3(c.getConstructWorldOrientationUp())
    constructForward = vec3(c.getConstructWorldOrientationForward())
    constructRight = vec3(c.getConstructWorldOrientationRight())
    constructVelocity = vec3(c.getWorldVelocity())
    coreVelocity = vec3(c.getVelocity())
    worldPos = vec3(c.getConstructWorldPos())
    coreMass =  c.getConstructMass()
    velMag = vec3(constructVelocity):len()
    vSpd = -worldVertical:dot(constructVelocity)
    adjustedRoll = getRoll(worldVertical, constructForward, constructRight) 
    local radianRoll = (adjustedRoll / 180) * math.pi
    local corrX = math.cos(radianRoll)
    local corrY = math.sin(radianRoll)
    adjustedPitch = getPitch(worldVertical, constructForward, (constructRight * corrX) + (constructUp * corrY)) 

    local constructVelocityDir = constructVelocity:normalize()
    local currentRollDegAbs = mabs(adjustedRoll)
    local currentRollDegSign = utils.sign(adjustedRoll)

    -- Rotation
    local constructAngularVelocity = vec3(c.getWorldAngularVelocity())
    local targetAngularVelocity =
        finalPitchInput * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward +
            finalYawInput * yawSpeedFactor * constructUp

    if autoRoll == true and worldVertical:len() > 0.01 then
        -- autoRoll on AND adjustedRoll is big enough AND player is not rolling
        local currentRollDelta = mabs(targetRoll-adjustedRoll)
        if ((( ProgradeIsOn or Reentry or BrakeLanding or spaceLand or AltitudeHold or IntoOrbit) and currentRollDelta > 0) or
            (atmosDensity > 0.0 and currentRollDelta < autoRollRollThreshold and autoRollPreference))  
            and finalRollInput == 0 and mabs(adjustedPitch) < 85 then
            local targetRollDeg = targetRoll
            local rollFactor = autoRollFactor
            if atmosDensity == 0 then
                rollFactor = rollFactor/4 -- Better or worse, you think?
                targetRoll = 0 -- Always roll to 0 out of atmo
                targetRollDeg = 0
            end
            if (rollPID == nil) then
                rollPID = pid.new(rollFactor * 0.01, 0, rollFactor * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
            end
            rollPID:inject(targetRollDeg - adjustedRoll)
            local autoRollInput = rollPID:get()
            targetAngularVelocity = targetAngularVelocity + autoRollInput * constructForward
        end
    end


    -- Engine commands
    local keepCollinearity = 1 -- for easier reading
    local dontKeepCollinearity = 0 -- for easier reading
    local tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities
    local wheel = s.getMouseWheel()

    if wheel > 0 then
        AP.changeSpd()
    elseif wheel < 0 then
        AP.changeSpd(true)
    else
        mousePause = true
    end

    brakeInput2 = 0


    if inAtmo and AtmoSpeedAssist and throttleMode then
        -- This is meant to replace cruise
        -- Uses AtmoSpeedLimit as the desired speed in which to 'cruise'
        -- In atmo, if throttle is 100%, it applies a PID to throttle to try to achieve AtmoSpeedLimit
        -- Since throttle is already 100% this means nothing except, it should slow them as it approaches it, throttling down
            -- Note - Beware reentry.  It will throttle them down due to high fall speeds, but they need that throttle
            -- We could instead only throttle down when the velMag in the direction of ShipFront exceeds AtmoSpeedLimt.  
        -- We also need to do braking if the speed is high enough above the desired limit.  
        -- Braking should happen immediately if the speed is not mostly forward

        -- .. Maybe as a whole we just, also PID brakeForce to keep speed under that limit, so if we barely go over it'll only tap them and throttle down

        -- We're going to want a param, PlayerThrottle, which we always keep (not between loads).  We set it in SpeedUp and SpeedDown
        -- So we only control throttle if their last throttle input was 100%

        -- Well, no.  Even better, do it all the time.  We would show their throttle on the HUD, then a red line separating it from our adjusted throttle
        -- Along with a message like, "Atmospheric Speed Limit Reached - Press Something to Disable Temporarily"
        -- But of course, don't throttle up for them.  Only down. 


        

        if (throttlePID == nil) then
            throttlePID = pid.new(0.5, 0, 1) -- First param, higher means less range in which to PID to a proper value
            -- IE 1 there means it tries to get within 1m/s of target, 0.5 there means it tries to get within 5m/s of target
            -- The smaller the value, the further the end-speed is from the target, but also the sooner it starts reducing throttle
            -- It is also the same as taking the result * (firstParam), it's a direct scalar

            -- Second value makes it change constantly over time.  This doesn't work in this case, it just builds up forever while they're not at max

            -- And third value affects how hard it tries to fix it.  Higher values mean it will very quickly go to negative values as you approach target
            -- Lower values means it steps down slower

            -- 0.5, 0, 20 works pretty great
            -- And I think it was, 0.5, 0, 0.001 is smooth, but gets some braking early
            -- 0.5, 0, 1 is v good.  One early braking bit then stabilizes easily .  10 as the last is way too much, it's bouncy.  Even 2.  1 will do
        end
        -- Add in vertical speed as well as the front speed, to help with ships that have very bad brakes
        throttlePID:inject(adjustedAtmoSpeedLimit/3.6 - constructVelocity:dot(constructForward))
        local pidGet = throttlePID:get()
        calculatedThrottle = uclamp(pidGet,-1,1)
        if calculatedThrottle < PlayerThrottle and (atmosDensity > 0.005) then -- We can limit throttle all the way to 0.05% probably
            ThrottleLimited = true
            navCom:setThrottleCommand(axisCommandId.longitudinal, uclamp(calculatedThrottle,0.01,1))
        else
            ThrottleLimited = false
            navCom:setThrottleCommand(axisCommandId.longitudinal, PlayerThrottle)
        end

        
        -- Then additionally
        if (brakePID == nil) then
            brakePID = pid.new(1 * 0.01, 0, 1 * 0.1)
        end
        brakePID:inject(constructVelocity:len() - (adjustedAtmoSpeedLimit/3.6)) 
        local calculatedBrake = uclamp(brakePID:get(),0,1)
        if (atmosDensity > 0 and vSpd < -80) or atmosDensity > 0.005 then -- Don't brake-limit them at <5% atmo if going up (or mostly up), it's mostly safe up there and displays 0% so people would be mad
            brakeInput2 = calculatedBrake
        end
        --if calculatedThrottle < 0 then
        --    brakeInput2 = brakeInput2 + mabs(calculatedThrottle)
        --end
        if brakeInput2 > 0 then
            if ThrottleLimited and calculatedThrottle == 0.01 then
                navCom:setThrottleCommand(axisCommandId.longitudinal, 0) -- We clamped it to >0 before but, if braking and it was at that clamp, 0 is good.
            end
        else -- For display purposes, keep calculatedThrottle positive in this case
            calculatedThrottle = uclamp(calculatedThrottle,0.01,1)
        end

        -- And finally, do what cruise does for angling wings toward the nose

        local autoNavigationEngineTags = ''
        local autoNavigationAcceleration = vec3()
        

        local verticalStrafeAcceleration = composeAxisAccelerationFromTargetSpeedV(axisCommandId.vertical,upAmount*1000)
        Nav:setEngineForceCommand("vertical airfoil , vertical ground ", verticalStrafeAcceleration, dontKeepCollinearity)
        --autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. "vertical airfoil , vertical ground "
        --autoNavigationAcceleration = autoNavigationAcceleration + verticalStrafeAcceleration

        local longitudinalEngineTags = 'thrust analog longitudinal '
        if (UseExtra=="All" or UseExtra=="Longitude") then longitudinalEngineTags = longitudinalEngineTags..ExtraLongitudeTags end
        local longitudinalCommandType = navCom:getAxisCommandType(axisCommandId.longitudinal)
        local longitudinalAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                longitudinalEngineTags, axisCommandId.longitudinal)

        local lateralAcceleration = composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral, LeftAmount*1000)
        autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. "lateral airfoil , lateral ground " -- We handle the rest later
        autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration

        -- Auto Navigation (Cruise Control)
        if (autoNavigationAcceleration:len() > constants.epsilon) then
            Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '',
                '', tolerancePercentToSkipOtherPriorities)
        end
        -- And let throttle do its thing separately
        Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)

        local verticalStrafeEngineTags = 'thrust analog vertical fueled '
        local lateralStrafeEngineTags = 'thrust analog lateral fueled '

        if (UseExtra=="All" or UseExtra=="Lateral")then lateralStrafeEngineTags = lateralStrafeEngineTags..ExtraLateralTags end
        if (UseExtra=="All" or UseExtra=="Vertical") then verticalStrafeEngineTags = verticalStrafeEngineTags..ExtraVerticalTags end

        -- Vertical also handles the non-airfoils separately
        if upAmount ~= 0 or (BrakeLanding and BrakeIsOn) or (not GearExtended and not stablized) then
            Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity)
        else
            Nav:setEngineForceCommand(verticalStrafeEngineTags, vec3(), keepCollinearity) -- Reset vertical engines but not airfoils or ground
        end

        if LeftAmount ~= 0 then
            Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralAcceleration, keepCollinearity)
        else
            Nav:setEngineForceCommand(lateralStrafeEngineTags, vec3(), keepCollinearity) -- Reset vertical engines but not airfoils or ground
        end

        if finalBrakeInput == 0 then -- If player isn't braking, use cruise assist braking
            finalBrakeInput = brakeInput2
        end

        -- Brakes
        local brakeAcceleration = -finalBrakeInput *
        (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
        Nav:setEngineForceCommand('brake', brakeAcceleration)

    else
        --PlayerThrottle = 0
        if AtmoSpeedAssist then
            navCom:setThrottleCommand(axisCommandId.longitudinal, PlayerThrottle) -- Use PlayerThrottle always.
        end

        local targetSpeed = u.getAxisCommandValue(0)

        if not throttleMode then -- Use a PID to brake past targetSpeed
            if (brakePID == nil) then
                brakePID = pid.new(1 * 0.01, 0, 1 * 0.1)
            end
            brakePID:inject(constructVelocity:len() - (targetSpeed/3.6)) 
            local calculatedBrake = uclamp(brakePID:get(),0,1)
            finalBrakeInput = uclamp(finalBrakeInput + calculatedBrake,0,1)
        end

        -- Brakes - Do these first so Cruise can override it
        local brakeAcceleration = -finalBrakeInput *
        (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
        Nav:setEngineForceCommand('brake', brakeAcceleration)

        -- AutoNavigation regroups all the axis command by 'TargetSpeed'
        local autoNavigationEngineTags = ''
        local autoNavigationAcceleration = vec3()
        local autoNavigationUseBrake = false

        -- Longitudinal Translation
        local longitudinalEngineTags = 'thrust analog longitudinal '
        if (UseExtra=="All" or UseExtra=="Longitude") then longitudinalEngineTags = longitudinalEngineTags..ExtraLongitudeTags end
        local longitudinalCommandType = navCom:getAxisCommandType(axisCommandId.longitudinal)
        if (longitudinalCommandType == axisCommandType.byThrottle) then
            local longitudinalAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                longitudinalEngineTags, axisCommandId.longitudinal)
            Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)
        elseif (longitudinalCommandType == axisCommandType.byTargetSpeed) then
            local longitudinalAcceleration = navCom:composeAxisAccelerationFromTargetSpeed(
                                                axisCommandId.longitudinal)
            autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. longitudinalEngineTags
            autoNavigationAcceleration = autoNavigationAcceleration + longitudinalAcceleration
            if (navCom:getTargetSpeed(axisCommandId.longitudinal) == 0 or -- we want to stop
                navCom:getCurrentToTargetDeltaSpeed(axisCommandId.longitudinal) <
                -navCom:getTargetSpeedCurrentStep(axisCommandId.longitudinal) * 0.5) -- if the longitudinal velocity would need some braking
            then
                autoNavigationUseBrake = true
            end

        end

        -- Lateral Translation
        local lateralStrafeEngineTags = 'thrust analog lateral '
        if (UseExtra=="All" or UseExtra=="Lateral") then lateralStrafeEngineTags = lateralStrafeEngineTags..ExtraLateralTags end
        local lateralCommandType = navCom:getAxisCommandType(axisCommandId.lateral)
        if (lateralCommandType == axisCommandType.byThrottle) then
            local lateralStrafeAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                lateralStrafeEngineTags, axisCommandId.lateral)
            Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralStrafeAcceleration, keepCollinearity)
        elseif (lateralCommandType == axisCommandType.byTargetSpeed) then
            local lateralAcceleration = navCom:composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral)
            autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. lateralStrafeEngineTags
            autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration
        end

        -- Vertical Translation
        local verticalStrafeEngineTags = 'thrust analog vertical '
        if (UseExtra=="All" or UseExtra=="Vertical") then verticalStrafeEngineTags = verticalStrafeEngineTags..ExtraVerticalTags end
        local verticalCommandType = navCom:getAxisCommandType(axisCommandId.vertical)
        if (verticalCommandType == axisCommandType.byThrottle)  then
            local verticalStrafeAcceleration = navCom:composeAxisAccelerationFromThrottle(
                                                verticalStrafeEngineTags, axisCommandId.vertical)
            if upAmount ~= 0 or (BrakeLanding and BrakeIsOn) then
                Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity, 'airfoil',
                    'ground', '', tolerancePercentToSkipOtherPriorities)
            else
                Nav:setEngineForceCommand(verticalStrafeEngineTags, vec3(), keepCollinearity) -- Reset vertical engines but not airfoils or ground
                Nav:setEngineForceCommand('airfoil vertical', verticalStrafeAcceleration, keepCollinearity, 'airfoil',
                '', '', tolerancePercentToSkipOtherPriorities)
                Nav:setEngineForceCommand('ground vertical', verticalStrafeAcceleration, keepCollinearity, 'ground',
                '', '', tolerancePercentToSkipOtherPriorities)
            end
        elseif (verticalCommandType == axisCommandType.byTargetSpeed) then
            if upAmount < 0 then 
                Nav:setEngineForceCommand('hover', vec3(), keepCollinearity) 
            end
            local verticalAcceleration = navCom:composeAxisAccelerationFromTargetSpeed(
                                            axisCommandId.vertical)
            autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. verticalStrafeEngineTags
            autoNavigationAcceleration = autoNavigationAcceleration + verticalAcceleration
        end

        -- Auto Navigation (Cruise Control)
        if (autoNavigationAcceleration:len() > constants.epsilon) then -- This means it's in cruise
            if (brakeInput ~= 0 or autoNavigationUseBrake or mabs(constructVelocityDir:dot(constructForward)) < 0.5)
            then
                autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
            end
            Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '',
                '', tolerancePercentToSkipOtherPriorities)
        end
    end

    -- Rotation
    local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
    local airAcceleration = vec3(c.getWorldAirFrictionAngularAcceleration())
    angularAcceleration = angularAcceleration - airAcceleration -- Try to compensate air friction
    
    Nav:setEngineTorqueCommand('torque', angularAcceleration, keepCollinearity, 'airfoil', '', '',
        tolerancePercentToSkipOtherPriorities)

    -- Rockets
    Nav:setBoosterCommand('rocket_engine')
    -- Dodgin's Don't Die Rocket Govenor - Cruise Control Edition
    if isBoosting and not VanillaRockets then 
        local speed = coreVelocity:len()
        local maxSpeedLag = 0.15
        if not throttleMode then -- Cruise control rocket boost assist, Dodgin's modified.
            local cc_speed = navCom:getTargetSpeed(axisCommandId.longitudinal)
            if speed * 3.6 > (cc_speed * (1 - maxSpeedLag)) and IsRocketOn then
                IsRocketOn = false
                Nav:toggleBoosters()
            elseif speed * 3.6 < (cc_speed * (1 - maxSpeedLag)) and not IsRocketOn then
                IsRocketOn = true
                Nav:toggleBoosters()
            end
        else -- Atmosphere Rocket Boost Assist Not in Cruise Control by Azraeil
            local throttle = u.getThrottle()
            if AtmoSpeedAssist then throttle = PlayerThrottle*100 end
            local targetSpeed = (throttle/100)
            if atmosphere == 0 then
                targetSpeed = targetSpeed * MaxGameVelocity
                if speed >= (targetSpeed * (1- maxSpeedLag)) and IsRocketOn then
                    IsRocketOn = false
                    Nav:toggleBoosters()
                elseif speed < (targetSpeed * (1- maxSpeedLag)) and not IsRocketOn then
                    IsRocketOn = true
                    Nav:toggleBoosters()
                end
            else
                local ReentrySpeed = mfloor(adjustedAtmoSpeedLimit)
                targetSpeed = targetSpeed * ReentrySpeed / 3.6 -- 1100km/hr being max safe speed in atmo for most ships
                if speed >= (targetSpeed * (1- maxSpeedLag)) and IsRocketOn then
                    IsRocketOn = false
                    Nav:toggleBoosters()
                elseif speed < (targetSpeed * (1- maxSpeedLag)) and not IsRocketOn then 
                    IsRocketOn = true
                    Nav:toggleBoosters()
                end
            end
        end
    end
end

function script.onUpdate()
    if not SetupComplete then
        local cont = coroutine.status (beginSetup)
        if cont == "suspended" then 
            local value, done = coroutine.resume(beginSetup)
            if done then s.print("ERROR STARTUP: "..done) end
        elseif cont == "dead" then
            SetupComplete = true
        end
    end
    if SetupComplete then
        Nav:update()
        if not Animating and content ~= LastContent then
            s.setScreen(content) 
        end
        LastContent = content
    end
end

function script.onActionStart(action)
    CONTROL.startControl(action)
end

function script.onActionStop(action)
    CONTROL.stopControl(action)
end

function script.onActionLoop(action)
    CONTROL.loopControl(action)
end

function script.onInputText(text)
    CONTROL.inputTextControl(text)
end

function script.onEnter(id)
    if radar_1 and not inAtmo and not notPvPZone then 
        u.setTimer("contact",0.1) 
    end
end

function script.onLeave(id)
    if radar_1 and CollisionSystem then 
        if #contacts > 650 then 
            id = tostring(id)
            contacts[id] = nil 
        end
    end
end

-- Execute Script
script.onStart() 