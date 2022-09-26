-- AtlasClass 


-- Planet Info - https://gitlab.com/JayleBreak/dualuniverse/-/tree/master/DUflightfiles/autoconf/custom with modifications to support HUD, vanilla JayleBreak will not work anymore
    function PlanetRef(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq)

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
        local utils = utils
        local vec3 = vec3
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
                local radius 
                if sizeCalculator then radius = sizeCalculator(body) else radius = self:sizeCalculator(body) end
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


    function Kinematics(Nav, c, u, s, msqrt, mabs) -- Part of Jaylebreak's flight files, modified slightly for hud

        local Kinematic = {} -- just a namespace
        local C = 100000000 / 3600
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

    function Keplers(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq) -- Part of Jaylebreak's flight files, modified slightly for hud
        local vec3 = vec3
        local PlanetRef = PlanetRef(Nav, c, u, s, stringf, uclamp, tonum, msqrt, float_eq)
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

-- ArchHUD AtlasOrdering
    function AtlasClass(Nav, c, u, s, dbHud_1, atlas, sysUpData, sysAddData, mfloor, tonum, msqrt, play, round) -- Atlas and Interplanetary functions including Update Autopilot Target

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
            
            local function findAtlasIndex(atlasList, findme)
                if not findme then findme = CustomTarget.name end
                for k, v in pairs(atlasList) do
                    if v.name and v.name == findme then
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
                        if autopilotEntry and 
                          ((autopilotEntry ~= nil and autopilotEntry.name == "Space") or 
                           (iphCondition == "Custom Only" and autopilotEntry.center) or
                           (iphCondition == "No Moons-Asteroids" and (string.find(autopilotEntry.name, "Moon") ~= nil or string.find(autopilotEntry.name, "Asteroid") ~= nil)))
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
                local function clearPosition(private)
                    local positions
                    if private then positions = privatelocations else positions = SavedLocations end
                    local index = -1
                    index = findAtlasIndex(atlas[0])
                    if index > -1 then
                        table.remove(atlas[0], index)
                    end
                    index = -1
                    index = findAtlasIndex(positions)
                    if index ~= -1 then
                        msgText = CustomTarget.name .. " saved location cleared"
                        table.remove(positions, index)
                    end
                    adjustAutopilotTargetIndex()
                    UpdateAtlasLocationsList()
                    return positions
                end
                if string.sub(AutopilotTargetName,1,1)=="*" then privatelocations=clearPosition(true) else SavedLocations=clearPosition(false) end
            end
            
            local function AddNewLocation(name, position, temp, safe)
                local function addPosition(private)
                    if private then positions = privatelocations else positions = SavedLocations end
                    if dbHud_1 or temp or private then
        
                        local p = getPlanet(position)
                        local newLocation = {
                            position = position,
                            name = name,
                            planetname = p.name,
                            gravity = c.getGravityIntensity(),
                            safe = safe, -- This indicates we can extreme land here, if this was a real positional waypoint
                        }
                        if not temp then 
                            positions[#positions + 1] = newLocation
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
                        return positions
                    else
                        msgText = "Databank must be installed to save permanent locations"
                    end
                end
                if string.sub(name,1,1)=="*" then privatelocations=addPosition(true) else SavedLocations=addPosition(false) end
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

        function Atlas.findAtlasIndex(atlasList, findme)
            return findAtlasIndex(atlasList, findme)
        end

        function Atlas.UpdatePosition(newName, saveHeading, saveAgg) -- Update a saved location with new position
            local function updatePosition(private)
                local positions
                if private then positions = privatelocations else positions = SavedLocations end
                local index = findAtlasIndex(positions)
                if index ~= -1 then
                    if newName ~= nil then
                        if private then newName = "*"..newName end
                        positions[index].name = newName
                        AutopilotTargetIndex = AutopilotTargetIndex - 1
                        adjustAutopilotTargetIndex()
                    elseif saveAgg ~= nil then
                        if saveAgg then
                            local alt = coreAltitude
                            if alt < 1000 then alt = 1000 end
                            positions[index].agg = round(alt,0)
                            msgText = positions[index].name .. " AGG Altitude:"..positions[index].agg.." saved ("..positions[index].planetname..")"
                            return
                        elseif saveAgg == false then 
                            positions[index].agg = nil 
                            msgText = positions[index].name .. " AGG Altitude cleared ("..positions[index].planetname..")"
                            return
                        end                        
                    else
                        local location = positions[index]
                        if saveHeading then 
                            location.heading = constructRight:cross(worldVertical)*5000 
                            msgText = positions[index].name .. " heading saved ("..positions[index].planetname..")"
                            return
                        elseif saveHeading == false then 
                            location.heading = nil 
                            msgText = positions[index].name .. " heading cleared ("..positions[index].planetname..")"
                            return
                        end
                        location.gravity = c.getGravityIntensity()
                        location.position = worldPos
                        location.safe = true
                    end
                    --UpdateAtlasLocationsList() -- Do we need these, if we only changed the name?  They are already done in AddNewLocation otherwise
                    msgText = positions[index].name .. " position updated ("..positions[index].planetname..")"
                    --UpdateAutopilotTarget()
                else
                    msgText = "Name Not Found"
                end
            end
            if string.sub(AutopilotTargetName,1,1)=="*" then updatePosition(true) else updatePosition(false) end
        end

        function Atlas.AddNewLocation(name, position, temp, safe)
            AddNewLocation(name, position, temp, safe)
        end

        function Atlas.ClearCurrentPosition()
            ClearCurrentPosition()
        end

        --Initial Setup
        for k, v in pairs(customlocations) do
            table.insert(atlas[0], v)
        end
        
        if userAtlas then 
            for k,v in pairs(userAtlas) do Atlas[k] = v end 
        end 

        UpdateAtlasLocationsList()
        if AutopilotTargetIndex > #AtlasOrdered then AutopilotTargetIndex=0 end
        Atlas.UpdateAutopilotTarget()

        return Atlas
    end