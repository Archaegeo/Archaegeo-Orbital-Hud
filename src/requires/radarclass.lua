function RadarClass(c, s, u, radar_1, radar_2, warpdrive, mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) -- Everything related to radar 
    local Radar = {}
    local activeRadar
    local activeRadarState
    local radarData
    local UpdateRadarCoroutine
    radar = {}

    local function UpdateRadarRoutine() -- Ensure current active radar is selected.
        -- UpdateRadarRoutine Locals
        if radar_1 or radar_2 then RADAR.assignRadar() end
    end

    local function pickType() -- Define the type of radar for use in HUD or other places
        if activeRadar then
            rType = "Atmo"
            if radarData:find('worksInAtmosphere":false') then 
                rType = "Space" 
            end
        end
    end

    function Radar.pickType()  -- Call the local function externally if needed after RADAR defined
        pickType()
    end

    function Radar.assignRadar() -- Assign the current active radar if possible
        if radar_2 and activeRadarState ~= 1 then
            if activeRadarState == -1 then
                if activeRadar == radar_2 then 
                    activeRadar = radar_1
                else  
                    activeRadar = radar_2 
                end
            end
            radar = {activeRadar}
            pickType()
            radarData = activeRadar.getWidgetData()
        else
            radarData = activeRadar.getWidgetData()
        end
        activeRadarState = activeRadar.getOperationalState()
    end

    function Radar.UpdateRadar() -- Sets up a coroutine to process the radar data if needed.
        local cont = coroutine.status (UpdateRadarCoroutine)
        if cont == "suspended" then 
            local value, done = coroutine.resume(UpdateRadarCoroutine)
            if done then s.print("ERROR UPDATE RADAR: "..done) end
        elseif cont == "dead" then
            UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
            local value, done = coroutine.resume(UpdateRadarCoroutine)
        end
    end

    function Radar.onEnter(id) -- Actions to take on a new radar contact
        --
    end

    function Radar.onLeave(id) -- Actions to take on a contact leaving radar range.
        --
    end

    local function setup() -- Action to take when RADAR class is first defined
        activeRadar=nil
        if radar_2 and radar_2.getOperationalState()==1 then
            activeRadar = radar_2
        else
            activeRadar = radar_1
        end
        activeRadarState=activeRadar.getOperationalState()
        radarData = activeRadar.getWidgetData()
        radar = {activeRadar}
        pickType()
        UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)

        if userRadar then 
            for k,v in pairs(userRadar) do Radar[k] = v end 
        end   
    end
    
    setup()

    return Radar
end 