function ShieldClass(shield, stringmatch, mfloor) -- Everything related to shield but draw data passed to HUD Class.
    local Shield = {}
    local RCD = shield.getResistancesCooldown()

    local function checkShield()
        local shieldState = shield.isActive()
        if AutoShieldToggle then
            if not notPvPZone and shieldState == 0 and shield.isVenting() ~= 1 then
                shield.toggle()
            elseif notPvPZone and shieldState == 1 then
                shield.toggle()
            end
        end
    end

    local function updateResists()
        local sRR = shield.getStressRatioRaw()
        local tot = 0.5999
        if sRR[1] == 0.0 and sRR[2] == 0.0 and sRR[3] == 0.0 and sRR[4] == 0.0 then return end
        local setResist = shield.setResistances((tot*sRR[1]),(tot*sRR[2]),(tot*sRR[3]),(tot*sRR[4]))
        if setResist == 1 then msgText="Shield Resistances updated" else msgText = "Value Exceeded. Failed to update Shield Resistances" end
    end

    function Shield.shieldTick()
        shieldPercent = mfloor(0.5 + shield.getShieldHitpoints() * 100 / shield.getMaxShieldHitpoints())
        checkShield()
        RCD = shield.getResistancesCooldown()
        if RCD == 0 and shieldPercent < AutoShieldPercent then updateResists() end
    end

    function Shield.setResist(arguement)
        if not shield then
            msgText = "No shield found"
            return
        elseif arguement == nil or RCD>0 then
            msgText = "Usable once per min.  Usage: /resist 0.15, 0.15, 0.15, 0.15"
            return
        end
        local num  = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
        local posPattern = num .. ', ' .. num .. ', ' ..  num .. ', ' .. num    
        local antimatter, electromagnetic, kinetic, thermic = stringmatch(arguement, posPattern)
        if thermic == nil or (antimatter + electromagnetic+ kinetic + thermic) > 0.6 then msgText="Improperly formatted or total exceeds 0.6" return end
        if shield.setResistances(antimatter,electromagnetic,kinetic,thermic)==1 then msgText="Shield Resistances set" else msgText="Resistance setting failed." end
    end

    function Shield.ventShield()
        local vcd = shield.getVentingCooldown()
        if vcd > 0 then msgText="Cannot vent again for "..vcd.." seconds" return end
        if shield.getShieldHitpoints()<shield.getMaxShieldHitpoints() then shield.startVenting() msgText="Shields Venting Enabled - NO SHIELDS WHILE VENTING" else msgText="Shields already at max hitpoints" end
    end

    if userShield then 
        for k,v in pairs(userShield) do Shield[k] = v end 
    end  

    return Shield
end