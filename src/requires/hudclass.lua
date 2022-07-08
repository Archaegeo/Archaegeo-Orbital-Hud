function HudClass(N, C, U, S, antigrav, warpdrive, gyro, shield, weapon)  -- Class that controls what shows up on screen

    local c = DUConstruct

    local Hud = {}

    local function initialize() -- Initial setup when class is defined (when you sit down)

        -- Parenting widget
        parentingPanelId = S.createWidgetPanel("Docking")
        parentingWidgetId = S.createWidget(parentingPanelId,"parenting")
        S.addDataToWidget(U.getWidgetDataId(),parentingWidgetId)

        -- Combat stress widget
        coreCombatStressPanelId = S.createWidgetPanel("Core combat stress")
        coreCombatStressgWidgetId = S.createWidget(coreCombatStressPanelId,"core_stress")
        S.addDataToWidget(C.getWidgetDataId(),coreCombatStressgWidgetId)

        -- element widgets
        -- For now we have to alternate between PVP and non-PVP widgets to have them on the same side.

        if weapon then 
            _autoconf.displayCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true) 
            WeaponPanelID = _autoconf.panels[_autoconf.panels_size] 
        end

        C.showWidget()
        _autoconf.displayCategoryPanel(radar, 1, "Periscope", "periscope")
        placeRadar = true
        if atmofueltank_size > 0 then
            _autoconf.displayCategoryPanel(atmofueltank, atmofueltank_size, "Atmo Fuel", "fuel_container")
            if placeRadar then
                _autoconf.displayCategoryPanel(radar, 1, "Radar", "radar")
                placeRadar = false
            end
        end
        if spacefueltank_size > 0 then
            _autoconf.displayCategoryPanel(spacefueltank, spacefueltank_size, "Space Fuel", "fuel_container")
            if placeRadar then
                _autoconf.displayCategoryPanel(radar, 1, "Radar", "radar")
                placeRadar = false
            end
        end
        _autoconf.displayCategoryPanel(rocketfueltank, rocketfueltank_size, "Rocket Fuel", "fuel_container")
        if placeRadar then -- We either have only rockets or no fuel tanks at all, uncommon for usual vessels
            _autoconf.displayCategoryPanel(radar, 1, "Radar", "radar")
            placeRadar = false
        end

        if antigrav ~= nil then antigrav.showWidget() end
        if warpdrive ~= nil then warpdrive.showWidget() end
        if gyro ~= nil then gyro.showWidget() end
        if shield ~= nil then shield.showWidget() end

    end

    if userHud then -- Extra user functions for hud not defined here
        for k,v in pairs(userHud) do Hud[k] = v end 
    end  

    initialize()

    return Hud
end
  
