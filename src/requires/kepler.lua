	
function Keplers(msqrt) -- Part of Jaylebreak's flight files, modified slightly for hud
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
