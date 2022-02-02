function ShieldClass(shield_1, stringmatch, mfloor) -- Everything related to radar but draw data passed to HUD Class.
    local Shield = {}
    local RCD = shield_1.getResistancesCooldown()

    local function checkShield()
        local shieldState = shield_1.getState()
        if AutoShieldToggle then
            if not notPvPZone and shieldState == 0 then
                shield_1.toggle()
            elseif notPvPZone and shieldState == 1 then
                shield_1.toggle()
            end
        end
    end

    local function updateResists()
        local sRR = shield_1.getStressRatioRaw()
        if sRR[1] == 0.0 and sRR[2] == 0.0 and sRR[3] == 0.0 and sRR[4] == 0.0 then return end
        local setResist = shield_1.setResistances(0.6*sRR[1],0.6*sRR[2],0.6*sRR[3],0.6*sRR[4])
        if setResist == 1 then msgText="Shield Resistances updated" else msgText = "Failed to update Shield Resistances" end
    end

    function Shield.shieldTick()
        shieldPercent = mfloor(0.5 + shield_1.getShieldHitpoints() * 100 / shield_1.getMaxShieldHitpoints())
        checkShield()
        RCD = shield_1.getResistancesCooldown()
        if RCD == 0 and shieldPercent < AutoShieldPercent then updateResists() end
    end

    function Shield.setResist(arguement)
        if not shield_1 then
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
        if shield_1.setResistances(antimatter,electromagnetic,kinetic,thermic)==1 then msgText="Shield Resistances set" else msgText="Resistance setting failed." end
    end

    function Shield.ventShield()
        local vcd = shield_1.getVentingCooldown()
        if vcd > 0 then msgText="Cannot vent again for "..vcd.." seconds" return end
        if shield_1.getShieldHitpoints()<shield_1.getMaxShieldHitpoints() then shield_1.startVenting() msgText="Shields Venting Enabled - NO SHIELDS WHILE VENTING" else msgText="Shields already at max hitpoints" end
    end

    return Shield
end