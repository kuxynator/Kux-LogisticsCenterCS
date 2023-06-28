local names = g_names

-- script.on_event(defines.events.on_built_entity,on_built,item_filter)
-- script.on_event(defines.events.on_robot_built_entity,on_built,item_filter)
-- script.on_event(defines.events.script_raised_built,on_build_adapter,item_filter)
-- script.on_event(defines.events.script_raised_revive,on_build_adapter,item_filter)

---Handles some build events
---@param event Event_on_built_entity|Event_on_robot_built_entity|Event_script_raised_built|Event_script_raised_revive
local function on_built(event)
	local entity = (event.created_entity or event.entity) --[[@as LuaEntity]]
    if entity == nil then return end -- in case a nil value by script_raised_built by other mods
    local name = entity.name
    --print("on_built "..name)

    -- if string.match(name,names.collecter_chest_pattern) ~= nil then  --- this is not recommended
    if name == names.collecter_chest_1_1 or
        -- if string.match(name,names.requester_chest_pattern) ~= nil then  --- this is not recommended
        -- name == names.collecter_chest_3_6 or
		-- name == names.collecter_chest_6_3
		name == names.collecter_chest_1_1.."-pp" or --TODO KUX
		name == names.collecter_chest_1_1.."-s"
	then
        Chests.add(entity, 1)
    elseif name == names.requester_chest_1_1 or
        -- name == names.requester_chest_3_6 or
		-- name == names.requester_chest_6_3
		name == names.requester_chest_1_1.."b" or --TODO KUX
		name == names.requester_storage_chest_1_1
	then
        Chests.add(entity, 2)
    elseif name == names.logistics_center then
        LogisticsCenter.add(entity)
    elseif name == names.logistics_center_controller then
        LogisticsCenterController.add(entity)
    end
end

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

local function register()
    script.on_event(defines.events.on_built_entity,       on_built, item_filter)
    script.on_event(defines.events.on_robot_built_entity, on_built, item_filter)
    script.on_event(defines.events.script_raised_built,   on_built, item_filter)
    script.on_event(defines.events.script_raised_revive,  on_built, item_filter)
end

register()