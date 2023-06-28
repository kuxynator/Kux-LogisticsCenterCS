---@class Chests
Chests = {}

---@class Chest
---@field entity LuaEntity
---@field nearest_lc any
Chest = {}

---@class RequestChest : Chest
---@class CollectorChest : Chest

---@class Connection
---@field eei LuaEntity
---@field power_consumption number

---@class EmptyStack
---@field count uint
---@field data table

---Global chest stroage(global.cc_entities|global.rc_entities)
---@class ChestStorage
---@field count integer Number of valid chests in entities
---@field empty_stack EmptyStack The stack for empty indices
---@field index integer Next free index
---@field entities Chest[]
---@field checked_index integer Index of last checked chest
---@field x number
--- {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}}}}

local function show_flying_text(entity, nearest_lc)
    local text = {}
    local color = {0.2, 1, 0.2, 1}
    if nearest_lc and nearest_lc.eei then
        text = {
            g_names.locale_flying_text_when_build_chest,
            string.format('%.1f', calc_distance_between_two_points(entity.position, nearest_lc.eei.position))
        }
    else
        text = {g_names.locale_flying_text_when_build_chest_no_nearest_lc}
        color = {1, 0.2, 0.2, 1}
    end
    entity.surface.create_entity {
        name = g_names.distance_flying_text,
        position = {x = entity.position.x, y = entity.position.y - 1},
        color = color,
        text = text
    }
end

---Gets the chest type
---@param entity LuaEntity
---@return integer?
function Chests.getChestType(entity)
    if(not entity) then error("Entity must not be nil.") end
    local name = entity.name
    if name == g_names.collecter_chest_1_1 or
        -- if string.match(name,names.requester_chest_pattern) ~= nil then  --- this is not recommended
        -- name == names.collecter_chest_3_6 or
        -- name == names.collecter_chest_6_3
        name == g_names.collecter_chest_1_1.."-pp" or --TODO KUX
        name == g_names.collecter_chest_1_1.."-s"
    then
        return 1
    elseif name == g_names.requester_chest_1_1 or
        -- name == names.requester_chest_3_6 or
        -- name == names.requester_chest_6_3
        name == g_names.requester_chest_1_1.."b" or --TODO KUX
        name == g_names.requester_storage_chest_1_1
    then
        return 2
    else
        return nil
    end
end

---Gets the chest storage
---@param entity LuaEntity?
---@param chestType nil|1|2
---@return ChestStorage
function Chests.getChestStorage(entity, chestType)
    if(not chestType) then chestType = Chests.getChestType(entity) or error("Invalid chest type") end
    return switch(chestType,{global.cc_entities, global.rc_entities}) --[[@as ChestStorage]]
    --TODO get chest storage by surface.name
end

---Add a chest
---@param entity LuaEntity
---@param chest_type integer?
function Chests.add(entity, chest_type)
    if(not chest_type) then chest_type = Chests.getChestType(entity) or error("Invalid chest type") end
    local chestStorage = switch(chest_type,{global.cc_entities, global.rc_entities})
    local check_percentage = switch(chest_type,{g_startup_settings.check_cc_percentages,g_startup_settings.check_rc_percentages})

    -- local index
    -- local empty_stack = chestStorage.empty_stack
    -- if empty_stack.count > 0 then
    --     index = empty_stack.data[empty_stack.count]
    --     empty_stack.count = empty_stack.count - 1
    -- else
    --     index = chestStorage.index
    --     chestStorage.index = gchestStorage.index + 1
    -- end

    local index = chestStorage.index;
    chestStorage.index = chestStorage.index +1
    local nearest_lc = Chests.getConnection(entity, chest_type)
    chestStorage.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    show_flying_text(entity, nearest_lc)

    chestStorage.count = chestStorage.count + 1
    -- recalc cpr
    chestStorage.check_per_round = math.ceil(chestStorage.count * check_percentage)
    --[[
    print("add chest")
    prints("  type:"..switch(chest_type,{"collector","requester"})))
    print("  count: ".. chestStorage.count)
    print("  check_percentage: ".. check_percentage)
    print("  check_per_round: ".. chestStorage.check_per_round)
    --]]
end


---Gets the index of the chest
---@param chestStorage ChestStorage
---@param entity LuaEntity
---@return integer #Index of the chest or 0
local function getIndex(chestStorage, entity)
    for index, v in pairs(chestStorage.entities) do
        if(v.entity == entity) then return index end
    end
    return 0
end

---Remove chest
---@param entityOrIndex any
function Chests.remove(entityOrIndex, chestType)
    print("Chests.remove (type:"..chestType..")")
    local chestStorage = switch(chestType,{global.cc_entities, global.rc_entities}) --[[@as ChestStorage]]

    local index = 0
    if(type(entityOrIndex)=="number") then index = entityOrIndex;
    else index = getIndex(chestStorage, entityOrIndex) end
    if(index==0) then return end

    -- entities[index] = nil
    -- -- push the index to the stack
    -- local empty_stack = entities.empty_stack
    -- empty_stack.count = empty_stack.count + 1
    -- empty_stack.data[empty_stack.count] = index

    table.remove(chestStorage.entities, index)
    chestStorage.count = chestStorage.count -1
    chestStorage.index = chestStorage.index -1

    assert(chestStorage.count == #chestStorage.entities, chestStorage.count ..":"..#chestStorage.entities)

    print(switch(chestType,{"collectot","requester"}).." chest "..index.." removed")

    -- recalc cpr
    if(index<chestStorage.checked_index) then chestStorage.checked_index= math.max(chestStorage.checked_index-1,0) end
    if(chestStorage.checked_index >= chestStorage.index) then chestStorage.checked_index = 0 end

    if(chestType==1) then
        global.cc_entities.check_per_round = math.ceil(chestStorage.count * g_startup_settings.check_cc_percentages)
    else
        global.rc_entities.check_per_round = math.ceil(global.rc_entities.count * g_startup_settings.check_rc_percentages)
    end
    print("entities.checked_index: "..chestStorage.checked_index)
end

---Calkulates the power consumption 
---@param distance number Distance between logistcs center and chest
---@param eei LuaEntity The energy interface entity
---@param chest_type integer
---@return number
function Chests.calc_power_consumption(distance, eei, chest_type)
    if eei == nil then return 0 end -- game.print("[ab_logisticscenter]: error, didn't find@find_nearest_lc")

    -- calc multiplier
    local dis = calc_distance_between_two_points2(eei.position.x, eei.position.y, global.lc_entities.center_pos_x, global.lc_entities.center_pos_y)
    local multiplier
    if dis < 500 then
        multiplier = 1
    else
        -- game.print('multiplier: ' .. multiplier)
        multiplier = 1 + (dis / 500 * 0.1)
    end

    -- if string.match(entity.name,names.collecter_chest_pattern) ~= nil then this is not recommended
    if chest_type == 1 then
       return math.ceil(distance * global.technologies.cc_power_consumption * multiplier)
    else
        return math.ceil(distance * global.technologies.rc_power_consumption * multiplier)
    end
end

---Create a new connection
---@param distance number Distance between logistcs center and chest
---@param eei LuaEntity The energy interface entity
---@param chest_type uint
---@return Connection
function Chests.newConnection(distance, eei, chest_type)
    return {
        eei = eei,
        power_consumption = Chests.calc_power_consumption(distance, eei, chest_type)
    }
end

--- Find nearest lc and return the connection.
---@param entity LuaEntity The chest entity
---@param chest_type 1|2
---@return Connection?
function Chests.getConnection(entity, chest_type)
    if global.lc_entities.count == 0 then return nil end

    local eei = nil
    local nearest_distance = 1000000000 -- should big enough
    for _, v in pairs(global.lc_entities.entities) do
        if entity.surface.index ~= v.lc.surface.index then goto next end
        local distance = calc_distance_between_two_points(entity.position, v.lc.position)
        if distance < nearest_distance then
            nearest_distance = distance
            eei = v.eei
        end
        ::next::
    end

    return Chests.newConnection(nearest_distance, eei, chest_type)
end

---Add to chest watch-list
---@param entity LuaEntity
---@param chestType any
local function rescan_addChest(entity, chestType)
    local chestStorage = Chests.getChestStorage(entity, chestType)
    chestStorage.entities[chestStorage.index] = {
        entity = entity, 
        nearest_lc = Chests.getConnection(entity, chestType)
    }
    chestStorage.index = chestStorage.index + 1
    chestStorage.count = chestStorage.count + 1
end

function Chests.newChestStorage(chestType,surface)
    return {
        index = 1,
        empty_stack = {count = 0, data = {}},
        entities = {},
        count = 0,
        checked_index = 0
    }
end

function Chests.rescan()
    log("Chests.rescan()")

    --TODO use surfaces storage

    global.cc_entities = Chests.newChestStorage(1,nil)
    global.rc_entities = Chests.newChestStorage(2,nil)

    local total_ccs = 0
    local total_rcs = 0

    for _, surface in pairs(game.surfaces) do
        -- re-scan collector chests
        local ccs = surface.find_entities_filtered {name = g_names.collecter_chest_1_1}
        for _, v in pairs(ccs) do rescan_addChest(v,1) end
		local ccspp = surface.find_entities_filtered {name = g_names.collecter_chest_1_1.."-pp"} --TODO KUX MODIFICATION
        for _, v in pairs(ccspp) do rescan_addChest(v,1) end
		local ccss = surface.find_entities_filtered {name = g_names.collecter_chest_1_1.."-s"} --TODO KUX MODIFICATION
        for _, v in pairs(ccss) do rescan_addChest(v,1) end
		total_ccs = total_ccs + #ccs + #ccspp + #ccss

        -- re-scan requester chests
        local rcs = surface.find_entities_filtered {name = g_names.requester_chest_1_1}
        for _, v in pairs(rcs) do rescan_addChest(v,2) end
		local rcsb = surface.find_entities_filtered {name = g_names.requester_chest_1_1.."b"} --TODO KUX MODIFICATION
        for _, v in pairs(rcsb) do rescan_addChest(v,2) end
		local rcss = surface.find_entities_filtered {name = g_names.requester_chest_1_1.."-s"} --TODO KUX MODIFICATION
        for _, v in pairs(rcss) do rescan_addChest(v,2) end
        total_rcs = total_rcs + #rcs + #rcsb + #rcss
    end

    assert(global.cc_entities.count == total_ccs, global.cc_entities.count .."<>",total_ccs)
    assert(global.rc_entities.count == total_rcs, global.rc_entities.count .."<>"..total_rcs)

    game.print('Logistics Center rescan chests done.\n".."requester chests: ' .. total_rcs .. '  collector chests: ' .. total_ccs)
    print("number requester chests: "..total_rcs)
    print("number collector chests: "..total_ccs)

    -- recalc cpr
    global.rc_entities.check_per_round = math.ceil(total_rcs * g_startup_settings.check_rc_percentages)
    global.cc_entities.check_per_round = math.ceil(total_ccs * g_startup_settings.check_cc_percentages)
    print("rc_check_per_round: "..global.rc_entities.check_per_round)
    print("cc_check_per_round: "..global.cc_entities.check_per_round)
    local rc_check_per_second = (global.rc_entities.check_per_round) / (g_startup_settings.check_rc_on_nth_tick) * (60)
    local cc_check_per_second = (global.cc_entities.check_per_round) / (g_startup_settings.check_cc_on_nth_tick) * (60)
    print("rc_check_per_second: "..rc_check_per_second)
    print("cc_check_per_second: "..cc_check_per_second)
    print("rc_seconds_per_complete_check: "..total_rcs/rc_check_per_second)
    print("cc_seconds_per_complete_check: "..total_ccs/cc_check_per_second)
end

return Chests
