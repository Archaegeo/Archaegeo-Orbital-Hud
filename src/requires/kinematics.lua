
-- Class Definitions to organize code
function Kinematics(mabs, msqrt) -- Part of Jaylebreak's flight files, modified slightly for hud

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
