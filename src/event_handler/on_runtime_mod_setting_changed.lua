
---Called when a runtime mod setting is changed by a player.
---@param event any
local function on_runtime_mod_setting_changed(event)
    if event.setting_type == 'runtime-global' then
        local setting = event.setting
        if setting == g_names.lc_animation then
            LogisticsCenter.on_lc_animation_setting_changed()
        elseif setting == g_names.re_scan_chests then
            -- local re_scan_chests = settings.global[g_names.re_scan_chests].value
            -- if re_scan_chests == true then
            Chests.rescan()
        -- end
        end
    -- else --- 'runtime-per-user'
    end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
