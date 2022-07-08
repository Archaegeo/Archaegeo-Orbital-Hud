function HudClass(N, C, U, S, antigrav, warpdrive, gyro, shield)

    local c = DUConstruct

    local Hud = {}

    local function initialize()
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
        _autoconf.displayCategoryPanel(weapon, weapon_size, L_TEXT("ui_lua_widget_weapon", "Weapons"), "weapon", true)
        C.showWidget()
        _autoconf.displayCategoryPanel(radars, radar_size, L_TEXT("ui_lua_widget_periscope", "Periscope"), "periscope")
        placeRadar = true
        if atmofueltank_size > 0 then
            _autoconf.displayCategoryPanel(atmofueltank, atmofueltank_size, L_TEXT("ui_lua_widget_atmofuel", "Atmo Fuel"), "fuel_container")
            if placeRadar then
                _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
                placeRadar = false
            end
        end
        if spacefueltank_size > 0 then
            _autoconf.displayCategoryPanel(spacefueltank, spacefueltank_size, L_TEXT("ui_lua_widget_spacefuel", "Space Fuel"), "fuel_container")
            if placeRadar then
                _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
                placeRadar = false
            end
        end
        _autoconf.displayCategoryPanel(rocketfueltank, rocketfueltank_size, L_TEXT("ui_lua_widget_rocketfuel", "Rocket Fuel"), "fuel_container")
        if placeRadar then -- We either have only rockets or no fuel tanks at all, uncommon for usual vessels
            _autoconf.displayCategoryPanel(radar, radar_size, L_TEXT("ui_lua_widget_radar", "Radar"), "radar")
            placeRadar = false
        end

        if antigrav ~= nil then antigrav.showWidget() end
        if warpdrive ~= nil then warpdrive.showWidget() end
        if gyro ~= nil then gyro.showWidget() end
        if shield ~= nil then shield.showWidget() end

    end

    if userHud then 
        for k,v in pairs(userHud) do Hud[k] = v end 
    end  

    initialize()

    return Hud
end
  
