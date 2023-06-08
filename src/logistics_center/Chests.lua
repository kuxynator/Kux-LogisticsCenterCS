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
---@field count uint Number of valid chests in entities
---@field empty_stack EmptyStack The stack for empty indices
---@field index uint Next free index
---@field entities Chest[]
---@field checked_index uint Index of last checked chest
--- {index, empty_stack, entities = {[index] = {entity, nearest_lc = {power_consumption, eei}}}}

local function show_flying_text(entity, nearest_lc)
    local text = {}
    local color = {r = 228 / 255, g = 236 / 255, b = 0}
    if nearest_lc and nearest_lc.eei then
        text = {
            g_names.locale_flying_text_when_build_chest,
            string.format('%.1f', calc_distance_between_two_points(entity.position, nearest_lc.eei.position))
        }
    else
        text = {g_names.locale_flying_text_when_build_chest_no_nearest_lc}
        color = {1,0.2,0.2,1}
    end
    entity.surface.create_entity {
        name = g_names.distance_flying_text,
        position = {x = entity.position.x, y = entity.position.y - 1},
        color = color,
        text = text
    }
end

--- Add to watch-list
---@param entity LuaEntity
function Chests.add_cc(entity)
    local index
    local empty_stack = global.cc_entities.empty_stack
    if empty_stack.count > 0 then
        index = empty_stack.data[empty_stack.count]
        empty_stack.count = empty_stack.count - 1
    else
        index = global.cc_entities.index
        global.cc_entities.index = global.cc_entities.index + 1
    end

    local nearest_lc = Chests.find_nearest_lc(entity, 1) -- TODO eei can be nil!
    global.cc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    -- show flying text
    show_flying_text(entity)

    global.cc_entities.count = global.cc_entities.count + 1

    -- recalc cpr
    global.cc_entities.check_per_round = math.ceil(global.cc_entities.count * g_startup_settings.check_cc_percentages)
end

---Add rerquest chest to watch-list
---@param entity LuaEntity
function Chests.add_rc(entity)
    -- local index
    -- local empty_stack = global.rc_entities.empty_stack
    -- if empty_stack.count > 0 then
    --     index = empty_stack.data[empty_stack.count]
    --     empty_stack.count = empty_stack.count - 1
    -- else
    --     index = global.rc_entities.index
    --     global.rc_entities.index = global.rc_entities.index + 1
    -- end

    local index = global.rc_entities.index;
    global.rc_entities.index = global.rc_entities.index +1
    local nearest_lc = Chests.find_nearest_lc(entity, 2)
    global.rc_entities.entities[index] = {entity = entity, nearest_lc = nearest_lc}

    -- show flying text
    show_flying_text(entity, nearest_lc)

    global.rc_entities.count = global.rc_entities.count + 1

    -- recalc cpr
    global.rc_entities.check_per_round = math.ceil(global.rc_entities.count * g_startup_settings.check_rc_percentages)
end

---comment
---@param t Chest[]
---@param entity LuaEntity
---@return integer #Index of the chest or 0
local function getIndex(t, entity)
    for index, v in pairs(t) do
        if(v.entity == entity) then return index end
    end
    return 0
end

---@deprecated
---Remove collector chast
---@param entityOrIndex integer|LuaEntity
function Chests.remove_cc(entityOrIndex) Chests.remove(entityOrIndex,1) end

---@deprecated
---Remove requester chest
---@param entityOrIndex integer|LuaEntity
function Chests.remove_rc(entityOrIndex) Chests.remove(entityOrIndex,2) end

---Remove chest
---@param entityOrIndex any
function Chests.remove(entityOrIndex, chestType)
    print("Chests.remove (type:"..chestType..")")
    local entities = switch(chestType,{global.cc_entities, global.rc_entities}) --[[@as ChestStorage]]

    local index = 0
    if(type(entityOrIndex)=="number") then index = entityOrIndex;
    else index = getIndex(entities.entities, entityOrIndex) end
    if(index==0) then return end

    -- entities[index] = nil
    -- -- push the index to the stack
    -- local empty_stack = entities.empty_stack
    -- empty_stack.count = empty_stack.count + 1
    -- empty_stack.data[empty_stack.count] = index

    table.remove(entities.entities, index)
    entities.count = entities.count -1
    entities.index = entities.index -1

    assert(entities.count == #entities.entities, entities.count ..":"..#entities.entities)

    print(switch(chestType,{"collectot","requester"}).." chest "..index.." removed")

    -- recalc cpr
    if(index<entities.checked_index) then entities.checked_index= math.max(entities.checked_index-1,0) end
    if(entities.checked_index >= entities.index) then entities.checked_index = 0 end

    if(chestType==1) then
        global.cc_entities.check_per_round = math.ceil(entities.count * g_startup_settings.check_cc_percentages)
    else
        global.rc_entities.check_per_round = math.ceil(global.rc_entities.count * g_startup_settings.check_rc_percentages)
    end
    print("entities.checked_index: "..entities.checked_index)
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

---comment
---@param distance number Distance between logistcs center and chest
---@param eei LuaEntity The energy interface entity
---@param chest_type uint
---@return Connection
function Chests.getConnection(distance, eei, chest_type)
    return {
        eei = eei,
        power_consumption = Chests.calc_power_consumption(distance, eei, chest_type)
    }
end

--- Find nearest lc and return the connection.
---@param entity LuaEntity The chest entity
---@param chest_type any
---@return Connection?
function Chests.find_nearest_lc(entity, chest_type)
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

    return Chests.getConnection(nearest_distance, eei, chest_type)
end

-- Add to watch-list
local function re_scan_add_cc(entity)
    global.cc_entities.entities[global.cc_entities.index] = {
        entity = entity, 
        nearest_lc = Chests.find_nearest_lc(entity, 1)
    }
    global.cc_entities.index = global.cc_entities.index + 1
    global.cc_entities.count = global.cc_entities.count + 1
end

-- Add to watch-list
local function re_scan_add_rc(entity)
    global.rc_entities.entities[global.rc_entities.index] = {
        entity = entity, 
        nearest_lc = Chests.find_nearest_lc(entity, 2)
    }
    global.rc_entities.index = global.rc_entities.index + 1
    global.rc_entities.count = global.rc_entities.count + 1
end

function Chests.rescan()
    log("Chests.rescan()")
    global.cc_entities = {
        index = 1,
        empty_stack = {count = 0, data = {}},
        entities = {},
        count = 0,
        checked_index=0
    }
    global.cc_entities.checked_index=0

    global.rc_entities = {
        index = 1,
        empty_stack = {count = 0, data = {}},
        entities = {},
        count = 0,
        checked_index=0
    }
    global.rc_entities.checked_index=0

    local total_ccs = 0
    local total_rcs = 0

    print(g_names.collecter_chest_1_1)
    print(g_names.requester_chest_1_1)

    for _, surface in pairs(game.surfaces) do
        -- re-scan collector chests
        local ccs = surface.find_entities_filtered {name = g_names.collecter_chest_1_1}
        for _, v in pairs(ccs) do re_scan_add_cc(v) end
		local ccspp = surface.find_entities_filtered {name = g_names.collecter_chest_1_1.."-pp"} --TODO KUX MODIFICATION
        for _, v in pairs(ccspp) do re_scan_add_cc(v) end
		local ccss = surface.find_entities_filtered {name = g_names.collecter_chest_1_1.."-s"} --TODO KUX MODIFICATION
        for _, v in pairs(ccss) do re_scan_add_cc(v) end
		total_ccs = total_ccs + #ccs + #ccspp + #ccss

        -- re-scan requester chests
        local rcs = surface.find_entities_filtered {name = g_names.requester_chest_1_1}
        for _, v in pairs(rcs) do re_scan_add_rc(v) end
		local rcsb = surface.find_entities_filtered {name = g_names.requester_chest_1_1.."b"} --TODO KUX MODIFICATION
        for _, v in pairs(rcsb) do re_scan_add_rc(v) end
		local rcss = surface.find_entities_filtered {name = g_names.requester_chest_1_1.."-s"} --TODO KUX MODIFICATION
        for _, v in pairs(rcss) do re_scan_add_rc(v) end
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
