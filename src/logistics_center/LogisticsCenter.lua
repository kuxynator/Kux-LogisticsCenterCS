
---@class LogisticsCenter
LogisticsCenter = {}

---@deprecated
LC=LogisticsCenter

local names = g_names
local config = g_config
local startup_settings = g_startup_settings

local check_on_nth_tick = config.check_lc_animation_on_nth_tick
if check_on_nth_tick == config.check_energy_bar_on_nth_tick then
    check_on_nth_tick = check_on_nth_tick + 3
end
if check_on_nth_tick == g_startup_settings.check_cc_on_nth_tick then
    check_on_nth_tick = check_on_nth_tick + 1
end
if check_on_nth_tick == g_startup_settings.check_rc_on_nth_tick then
    check_on_nth_tick = check_on_nth_tick + 1
end

-- Check animation on nth-tick
local function check_animation(tick)
    local lcs = global.lc_entities
	for k, v in pairs(lcs.entities) do
        if v.eei.energy == 0 then
            if v.animation ~= nil then
                v.animation.destroy()
                v.animation = nil
            end
        else
            if v.animation == nil then
                v.animation =
                    v.lc.surface.create_entity {
                    name = names.logistics_center_animation,
                    -- position = {x = v.lc.position.x, y = v.lc.position.y + 0.5},
                    position = {x = v.lc.position.x, y = v.lc.position.y},
                    force = v.lc.force
                }
            end
        end
    end
end

function LogisticsCenter.register_check_animation_handler()
    local rg_lc_animation = settings.global[names.lc_animation].value
    if rg_lc_animation == true then
        script.on_nth_tick(check_on_nth_tick, check_animation)
    end
end

function LogisticsCenter.un_register_check_animation_handler()
    script.on_nth_tick(check_on_nth_tick, nil)
end

function LogisticsCenter.re_register_check_animation_handler()
    local rg_lc_animation = settings.global[names.lc_animation].value
    if rg_lc_animation == true then
        if global.lc_entities.count >= 1 then
            script.on_nth_tick(check_on_nth_tick, check_animation)
        end
    end
end

function LogisticsCenter.on_lc_animation_setting_changed()
    local rg_lc_animation = settings.global[names.lc_animation].value
    if rg_lc_animation == true then
        LogisticsCenter.re_register_check_animation_handler()
    else
        for k, v in pairs(global.lc_entities.entities) do
            if v.animation ~= nil then
                v.animation.destroy()
                v.animation = nil
            end
        end
        LogisticsCenter.un_register_check_animation_handler()
    end
end

-- Pack all the signals in items_stock
local function pack_signals()
    local signals = {}
    local i = 1
    for item_name, item in pairs(global.items_stock.items) do
        local signal = nil
        if item.enable == true then
            -- game.print(item_name)
            if item.index < startup_settings.lc_item_slot_count then
                signal = {signal = {type = 'item', name = item_name}, count = item.stock, index = item.index}
            end
        end
        signals[i] = signal
        i = i + 1
    end
    --local parameters = {parameters = signals} KUX removed

    return signals
end

-- Add to watch-list
function LogisticsCenter.add(entity)
    local lcs = global.lc_entities

    local p_str = surface_and_position_to_string(entity)
    -- in case duplicated event
    if lcs.entities[p_str] ~= nil then
        return
    end

    lcs.count = lcs.count + 1

    if lcs.count == 1 then
        lcs.center_pos_x = entity.position.x
        lcs.center_pos_y = entity.position.y
    else
        -- disable signal output of the lc on default except the very first one
        -- [RESOLVED] this will cause a problem that signals don't show up immediately after control-behavior enabled
        entity.get_or_create_control_behavior().enabled = false

        local dx = entity.position.x - lcs.center_pos_x
        local dy = entity.position.y - lcs.center_pos_y
        local p = 1 / lcs.count
        lcs.center_pos_x = lcs.center_pos_x + dx * p
        lcs.center_pos_y = lcs.center_pos_y + dy * p
    end

    local dis = calc_distance_between_two_points2(entity.position.x, entity.position.y, lcs.center_pos_x, lcs.center_pos_y)

    entity.surface.create_entity {
        name = names.distance_flying_text,
        position = {x = entity.position.x, y = entity.position.y - 1},
        color = {r = 255, g = 0, b = 0},
        text = {
            names.locale_flying_text_when_build_lc,
            string.format('%.1f', dis)
        }
    }

    -- game.print('center pos: ' .. lcs.center_pos_x .. ',' .. lcs.center_pos_y)

    -- [RESOLVED] will conflict when entity on different surfaces?
    -- global.lc_entities.entities[position_to_string(entity.position)] = {
    local pack = {
        lc = entity,
        -- create the electric energy interface
        eei = entity.surface.create_entity {
            name = names.electric_energy_interface,
            position = entity.position,
            force = entity.force
        }
        -- animation = entity.surface.create_entity {
        --     name = names.logistics_center_animation,
        --     position = entity.position,
        --     force = entity.force
        -- }
    }

    -- add energy bar for the first logistics center
    if lcs.count == 1 then
        EnergyBar.add(pack)
        LogisticsCenter.register_check_animation_handler()
    end

    -- pack.animation.active = false
    -- pack.eei.active = false
    lcs.entities[p_str] = pack

    -- game.print('on-built:' .. p_str)

    -- recalc distance
    LogisticsCenter.recalc_distance_when_add_lc(entity, pack.eei)
end

-- Remove from watch list
function LogisticsCenter.remove(entity)
    local lcs = global.lc_entities

    local p_str = surface_and_position_to_string(entity)
    local pack = lcs.entities[p_str]
    if pack == nil then return end --< in case duplicated event

    -- game.print('pre-mined:' .. p_str)

    lcs.count = lcs.count - 1

    -- recalc center position
    local dx = entity.position.x - lcs.center_pos_x
    local dy = entity.position.y - lcs.center_pos_y
    local p
    if lcs.count > 1 then
        p = 1 / lcs.count
    else
        p = 1
    end
    lcs.center_pos_x = lcs.center_pos_x - dx * p
    lcs.center_pos_y = lcs.center_pos_y - dy * p
    -- game.print('center pos: ' .. lcs.center_pos_x .. ',' .. lcs.center_pos_y)

    local old_eei = pack.eei

    -- destroy the energy bar
    EnergyBar.remove(pack)

    -- should remove lc first and then recalc distance, destroy eei last

    lcs.entities[p_str] = nil

    -- recalc distance
    LogisticsCenter.recalc_distance_when_remove_lc(entity, old_eei)

    -- destroy the electric energy interface and animation
    pack.eei.destroy()
    if pack.animation ~= nil then
        pack.animation.destroy()
    end

    if lcs.count == 0 then
        LogisticsCenter.un_register_check_animation_handler()
    end
end

-- Call on lc rotated
function LogisticsCenter.create_energy_bar(entity)
    -- Create or destroy energy bar for the rotated logistics center

    local p_str = surface_and_position_to_string(entity)
    local pack = global.lc_entities.entities[p_str]

    if pack.energy_bar_index == nil then
        EnergyBar.add(pack)
    else
        EnergyBar.remove(pack)
    end
end

-- Update single lc signal
function LogisticsCenter.update_lc_signal(item, item_name)
    -- pack the signal
    local signal = nil
    -- local item = global.items_stock.items[item_name]
    if item.index < startup_settings.lc_item_slot_count then
        signal = {signal = {type = 'item', name = item_name}, count = item.stock}
    end

    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signal to the lc(s) which control_behavior are enabled
    for _, v in pairs(global.lc_entities.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.set_signal(item.index, signal)
        end
    end
end

-- Update all signals of one lc
function LogisticsCenter.update_lc_signals(entity)
	local control_behavior = entity.get_or_create_control_behavior()
    if control_behavior.enabled then
        control_behavior.parameters = pack_signals()
	else
        control_behavior.parameters = nil
    end
end

-- Update signals of all lcs
function LogisticsCenter.update_all_lc_signals()
    -- TODO if item.index > startup_settings.lc_item_slot_count
    -- set the signals to the lc(s) which control_behavior are enabled
    local parameters = pack_signals()
    for _, v in pairs(global.lc_entities.entities) do
		local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            control_behavior.parameters = parameters
        else
            control_behavior.parameters = nil
        end
    end
end

function LogisticsCenter.recalc_distance_when_power_consumption_changed()
    local function recalc(chestStorage, chest_type)
        for _, v in pairs(chestStorage.entities) do
            if v.entity.valid and v.nearest_lc and v.nearest_lc.eei then
                local distance = calc_distance_between_two_points(v.entity.position, v.nearest_lc.eei.position)
                v.nearest_lc = Chests.newConnection(distance, v.nearest_lc.eei, chest_type)
            end
        end
    end
    recalc(global.cc_entities, 1)
    recalc(global.rc_entities, 2)
end

function LogisticsCenter.recalc_distance_when_add_lc(entity, eei)
    local function recalc(chestStorage, chest_type)
        local invalidEntities={}
        for i, v in pairs(chestStorage.entities) do
            if not v.entity.valid then table.insert(invalidEntities, i); goto next; end
            if v.nearest_lc == nil then
                v.nearest_lc = Chests.getConnection(v.entity, chest_type)
            else
                local new_dis = calc_distance_between_two_points(v.entity.position, entity.position)
                if(not v.nearest_lc.eei) then
                    v.nearest_lc = Chests.newConnection(new_dis, eei, chest_type)
                else
                    local old_dis = calc_distance_between_two_points(v.entity.position, v.nearest_lc.eei.position)
                    if new_dis <= old_dis then
                        v.nearest_lc = Chests.newConnection(new_dis, eei, chest_type)
                    end
                end
            end
            ::next::
        end

        for i = #invalidEntities, 1, -1 do
            --Chests.remove_cc(i) 
        end
    end

    recalc(global.cc_entities, 1)
    recalc(global.rc_entities, 2)
    LogisticsCenter.recalc_distance_when_power_consumption_changed()
end

function LogisticsCenter.recalc_distance_when_remove_lc(entity, eei)
    local function recalc(chestStorage, chest_type)
        local invalidEntities={}
        for i,v in pairs(chestStorage.entities) do
            if not v.entity.valid then table.insert(invalidEntities, i); goto next; end
            if v.nearest_lc ~= nil and v.nearest_lc.eei == eei then
                v.nearest_lc = Chests.getConnection(v.entity, chest_type)
            end
            ::next::
        end

        for i = #invalidEntities, 1, -1 do
            --Chests.remove_cc(i) 
        end
    end

    recalc(global.cc_entities, 1)
    recalc(global.rc_entities, 2)
    LogisticsCenter.recalc_distance_when_power_consumption_changed()
end

return LogisticsCenter
