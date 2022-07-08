function ShieldClass(shield) -- Everything related to radar but draw data passed to HUD Class.
    local Shield = {}


    if userShield then 
        for k,v in pairs(userShield) do Shield[k] = v end 
    end  

    return Shield
end