function AtlasClass(atlas, sysUpData, sysAddData, mfloor) -- Atlas and Interplanetary functions including Update Autopilot Target
	
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
