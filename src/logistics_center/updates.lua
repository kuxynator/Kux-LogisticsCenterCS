require('config')
require('logistics_center.updates.16-old_version')
require('logistics_center.updates.17-add_center_position')
require('logistics_center.updates.18-re_create_lc_animations')
require('logistics_center.updates.19-add_lc_rc_count')

-- global data migrations
-- call only in script.on_configuration_changed()
function global_data_migrations()
    if global.global_data_version ~= nil then -- and global.global_data_version ~= g_config.global_data_version then
        if global.global_data_version == g_config.global_data_version then
            return
        end
    end
    game.print('ab_logisticscenter: global_data_version: ' .. global.global_data_version.." -> "..g_config.global_data_version)

    -- nil - 16
    update()

    -- 17
    add_center_position()

    -- 18
    re_create_lc_animations()

    -- 19
    add_lc_rc_count()


    -- 20
    -- move runtime_vars

    if global.global_data_version == nil or global.global_data_version < 20 then
        if(global.cc_entities.checked_index==nil) then global.cc_entities.checked_index = 0 end
        if(global.rc_entities.checked_index==nil) then global.rc_entities.checked_index = 0 end

        global.global_data_version = 20
    end
    


    -- global.global_data_version = g_config.global_data_version
end
