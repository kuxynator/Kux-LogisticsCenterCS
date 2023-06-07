local names = g_names
local startup_settings = g_startup_settings

---Called when mod configuration changes.
---@param data ConfigurationChangedData
---This is called when the game version or any mod version changed, when any mod was added or removed, 
---when a startup setting has changed, when any prototypes have been added or removed, or when a migration was applied. 
---It allows the mod to make any changes it deems appropriate to both the data structures in its global table or to the 
---game state through LuaGameScript.
function on_configuration_changed(data)
    --log("on_configuration_changed")
    global_data_migrations()

    -- in case global tables were altered in global_data_migrations()
    -- and cc/rc counts may change after migrations
    global.cc_entities.check_per_round = math.ceil(global.cc_entities.count * startup_settings.check_cc_percentages)
    global.rc_entities.check_per_round = math.ceil(global.rc_entities.count * startup_settings.check_rc_percentages)

    -- recalc power consumption if configuration changed
    local default_power_consumption_changed = false

    if
        global.technologies.cc_power_consumption ~= math.ceil(startup_settings.default_cc_power_consumption * global.technologies.power_consumption_percentage) or
            global.technologies.rc_power_consumption ~= math.ceil(startup_settings.default_rc_power_consumption * global.technologies.power_consumption_percentage)
     then
        default_power_consumption_changed = true
    end

    global.technologies.cc_power_consumption = math.ceil(startup_settings.default_cc_power_consumption * global.technologies.power_consumption_percentage)
    global.technologies.rc_power_consumption = math.ceil(startup_settings.default_rc_power_consumption * global.technologies.power_consumption_percentage)

    if default_power_consumption_changed == true then
        game.print(
            {
                names.locale_print_after_power_consumption_configuration_changed,
                global.technologies.cc_power_consumption,
                global.technologies.rc_power_consumption
            }
        )
    end

    -- check if item were removed
    for k, v in pairs(global.items_stock.items) do
        if game.item_prototypes[k] ~= nil then
            v.enable = true
        else
            v.enable = false
        end
    end

    if(data.mod_changes[mod.name]) then
        local changes = data.mod_changes[mod.name] --[[@as ModChangeData]]
        if(Version.compare(changes.old_version,"2.4.0") < 0) then
            print("update chests from old version: "..changes.old_version)
            Chests.rescan()
        end
    end
end