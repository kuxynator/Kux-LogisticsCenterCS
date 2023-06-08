local names = g_names

-- script.on_event(defines.events.on_built_entity,on_built,item_filter)
-- script.on_event(defines.events.on_robot_built_entity,on_built,item_filter)
-- script.on_event(defines.events.script_raised_built,on_build_adapter,item_filter)
-- script.on_event(defines.events.script_raised_revive,on_build_adapter,item_filter)
--[[
on_built_entity Called when player builds something. Can be filtered using LuaPlayerBuiltEntityEventFilter.
created_entity	:: LuaEntity
player_index	:: uint
stack	:: LuaItemStack
item	:: LuaItemPrototype?    The item prototype used to build the entity. Note this won't exist in some situations (built from blueprint, undo, etc).
tags	:: Tags?    The tags associated with this entity if any.
name	:: defines.events   Identifier of the event
tick	:: uint Tick the event was generated.

on_robot_built_entity Called when a construction robot builds an entity. Can be filtered using LuaRobotBuiltEntityEventFilter.
robot	:: LuaEntity    The robot that did the building.
created_entity	:: LuaEntity    The entity built.
stack	:: LuaItemStack The item used to do the building.
tags	:: Tags?    The tags associated with this entity if any.
name	:: defines.events   Identifier of the event
tick	:: uint Tick the event was generated.

script_raised_built
entity	:: LuaEntity    The entity that has been built.
name	:: defines.events   Identifier of the event
tick	:: uint Tick the event was generated.

script_raised_revive
entity	:: LuaEntity    The entity that was revived.
tags	:: Tags?    The tags associated with this entity, if any.
name	:: defines.events   Identifier of the event
tick	:: uint Tick the event was generated.

]]

---Handles some build events
---@param event Event_on_built_entity|Event_on_robot_built_entity|Event_script_raised_built|Event_script_raised_revive
function on_built(event)
	local entity = (event.created_entity or event.entity) --[[@as LuaEntity]]    
    if entity == nil then return end -- in case a nil value by script_raised_built by other mods
    local name = entity.name
    print("on_built "..name)

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
