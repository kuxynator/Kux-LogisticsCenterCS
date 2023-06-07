if script.active_mods["gvv"] then require("__gvv__.gvv")() end
require("mod")

require('config')

require('logistics_center.helper')
require('logistics_center.init_globals')
require('logistics_center.Chests')
require('logistics_center.Items')
require('logistics_center.LogisticsCenter')
require('logistics_center.LogisticsCenterController')
require('logistics_center.EnergyBar')
require('logistics_center.updates')
require('logistics_center.Technology')

require('event_handler.check_collector_chest')
-- require('event_handler.check_player_request')
require('event_handler.check_requester_chest')
require('event_handler.on_built')
require('event_handler.on_configuration_changed')
require('event_handler.on_gui_closed')
require('event_handler.on_gui_opened')
require('event_handler.on_load')
require('event_handler.on_destroy')
require('event_handler.on_player_created')
require('event_handler.on_init')
require('event_handler.on_research_finished')
require('event_handler.on_rotated')
require('event_handler.on_runtime_mod_setting_changed')

script.on_init(function ()
	init_globals()
	on_init()
end)

-- will be called on every save and load
script.on_load(on_load)

-- on configuration changed
script.on_configuration_changed(on_configuration_changed)

local item_filter = {
    {filter="name", name=g_names.collecter_chest_1_1},
    {filter="name", name=g_names.collecter_chest_1_1.."-pp"},
    {filter="name", name=g_names.collecter_chest_1_1.."-s"},

    {filter="name", name=g_names.requester_chest_1_1},
    {filter="name", name=g_names.requester_chest_1_1.."b"},
    {filter="name", name=g_names.requester_chest_1_1.."-s"},

    {filter="name", name=g_names.logistics_center},
    {filter="name", name=g_names.logistics_center_controller},
}

-- on built
script.on_event(defines.events.on_built_entity,on_built,item_filter)
script.on_event(defines.events.on_robot_built_entity,on_built,item_filter)
script.on_event(defines.events.script_raised_built,on_built,item_filter)
script.on_event(defines.events.script_raised_revive,on_built,item_filter)

-- check all collector chests
local check_ccs_on_nth_tick = check_ccs_on_nth_tick_all
if g_startup_settings.item_type_limitation == 'ores only' then
    check_ccs_on_nth_tick= check_ccs_on_nth_tick_ores_only
elseif g_startup_settings.item_type_limitation == 'except ores' then
    check_ccs_on_nth_tick = check_ccs_on_nth_tick_except_ores
end
if(g_startup_settings.check_cc_on_nth_tick == g_startup_settings.check_rc_on_nth_tick) then
    script.on_nth_tick(g_startup_settings.check_cc_on_nth_tick, function (event)
        check_ccs_on_nth_tick(event)
        check_rcs_on_nth_tick(event)
    end)
else
    script.on_nth_tick(g_startup_settings.check_cc_on_nth_tick, check_ccs_on_nth_tick)
    script.on_nth_tick(g_startup_settings.check_rc_on_nth_tick, check_rcs_on_nth_tick)
end

script.on_event(defines.events.on_player_rotated_entity, on_rotated)

-- on opened the logistics center
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)

script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)

-- commands.add_command("abc()",{"update all signals"},function(event)
--     update_all_signals()
-- end)

-- on player created
script.on_event(defines.events.on_player_created, on_player_created)

-- on research finished
script.on_event(defines.events.on_research_finished, on_research_finished)

