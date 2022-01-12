
-- Planet Info - https://gitlab.com/JayleBreak/dualuniverse/-/tree/master/DUflightfiles/autoconf/custom with modifications to support HUD, vanilla JayleBreak will not work anymore
function PlanetRef()
	--[[                    START OF LOCAL IMPLEMENTATION DETAILS             ]]--
	-- Type checks
	local tonum = tonumber
    local msqrt = math.sqrt
	
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
