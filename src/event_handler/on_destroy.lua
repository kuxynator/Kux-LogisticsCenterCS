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

--[[
on_pre_player_mined_item 
entity          LuaEntity   The entity being mined
player_index    uint
name            uint        defines.events Identifier of the event
tick            uint        Tick the event was generated.

on_robot_pre_mined
robot           LuaEntity   The robot that's about to do the mining.
entity          uaEntity    The entity which is about to be mined.
name            uint        defines.events Identifier of the event
tick            uint        Tick the event was generated.

on_entity_died
entity          LuaEntity   The entity that died.
cause           LuaEntity?  The entity that did the killing if available.
loot            LuaInventory    The loot generated by this entity if any.
force           LuaForce?   The force that did the killing if any.
damage_type     LuaDamagePrototype? The damage type if any.
name            uint        defines.events Identifier of the event
tick            uint        Tick the event was generated.

script_raised_destroy
entity          LuaEntity   The entity that was destroyed.
name            uint        defines.events Identifier of the event
tick            uint        Tick the event was generated.

]]

local function on_destroy(event)
    local entity = event.entity
    if entity == nil then return end -- in case a nil value by script_raised_destroy by other mods
    print("on_destroy "..entity.name.."  "..event.tick)

    if string.match(entity.name, g_names.collecter_chest_pattern) then
        Chests.remove_cc(entity)
    elseif string.match(entity.name, g_names.requester_chest_pattern) then
        Chests.remove_rc(entity)
    elseif entity.name == g_names.logistics_center then
        LogisticsCenter.remove(entity)
    elseif entity.name == g_names.logistics_center_controller then
        LogisticsCenterController.remove(entity)
    else
        print("Unknwon entity '"..entity.name.."'")
    end
end

script.on_event(defines.events.on_pre_player_mined_item,on_destroy,item_filter)
script.on_event(defines.events.on_robot_pre_mined,on_destroy,item_filter)
script.on_event(defines.events.on_entity_died,on_destroy,item_filter)
script.on_event(defines.events.script_raised_destroy,on_destroy,item_filter)