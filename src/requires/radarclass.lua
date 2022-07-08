function RadarClass(c, s, u, radar_1, radar_2, warpdrive,
    mabs, sysDestWid, msqrt, svgText, tonum, coreHalfDiag, play) -- Everything related to radar but draw data passed to HUD Class.
    local Radar = {}
    local activeRadar
    local activeRadarState
    radar = {}

    local function UpdateRadarRoutine()
        -- UpdateRadarRoutine Locals
        if radar_1 or radar_2 then RADAR.assignRadar() end
    end

    local function pickType()
        if activeRadar then
            rType = "Atmo"
            if radarData:find('worksInAtmosphere":false') then 
                rType = "Space" 
            end
        end
    end

    function Radar.pickType()
        pickType()
    end

    function Radar.assignRadar()
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
        end
        activeRadarState = activeRadar.getOperationalState()
    end

    function Radar.UpdateRadar()
        local cont = coroutine.status (UpdateRadarCoroutine)
        if cont == "suspended" then 
            local value, done = coroutine.resume(UpdateRadarCoroutine)
            if done then s.print("ERROR UPDATE RADAR: "..done) end
        elseif cont == "dead" then
            UpdateRadarCoroutine = coroutine.create(UpdateRadarRoutine)
            local value, done = coroutine.resume(UpdateRadarCoroutine)
        end
    end

    function Radar.onEnter(id)

    end

    function Radar.onLeave(id)

    end

    local function setup()
        activeRadar=nil
        if radar_2 and radar_2.getOperationalState()==1 then
            activeRadar = radar_2
        else
            activeRadar = radar_1
        end
        activeRadarState=activeRadar.getOperationalState()
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