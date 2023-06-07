local math_floor = math.floor
local math_min = math.min

-- check all collector chests, all items
function check_ccs_on_nth_tick_all(event)
    if global.lc_entities.count < 1 then return end

    local crc_item_stack = {name = nil, count = 0}

    local index_begin = global.cc_entities.checked_index + 1
    if(index_begin > global.rc_entities.index -1) then index_begin = 0 end
    local index_end = math.min(index_begin + global.cc_entities.check_per_round, global.cc_entities.index-1)
    --print("check_ccs_on_nth_tick_all "..index_begin.."-"..index_end)
    for iChest = index_begin, index_end, 1 do
        -- ??? if index > global.cc_entities.index then index = index - global.cc_entities.index end
        global.cc_entities.checked_index = iChest
        local chest = global.cc_entities.entities[iChest]
        if chest == nil then --[[print("cc("..index..") nil");]] goto next_chest end
        if not chest.entity.valid then print("cc("..iChest..") entity invalid"); --[[CHEST:remove_cc(iChest);]] goto next_chest end
        if chest.nearest_lc == nil then --[[print("cc nearest_lc nil");]] goto next_chest end
        local inventory = chest.entity.get_output_inventory()
        if(inventory==nil) then goto next_chest end
        if inventory.is_empty() then goto next_chest end

        local eei = chest.nearest_lc.eei --> LuaEntity name="ab-lc-electric-energy-interface"
        local power_consumption = chest.nearest_lc.power_consumption
        local contents = inventory.get_contents()
        for name, count in pairs(contents) do
            local item = global.items_stock.items[name]
            if item == nil then
                item = Items.add(name)
            end
            -- enough energy?
            count = math_min(count, math_floor(eei.energy / power_consumption))
            -- calc max_control
            count = math_min(count, item.max_control - item.stock)

            if count > 0 then
                crc_item_stack.name = name
                crc_item_stack.count = count
                count = inventory.remove(crc_item_stack)
                item.stock = item.stock + count
                eei.energy = eei.energy - count * power_consumption
                --print(count.." items ".. (count * power_consumption).." ("..eei.energy..")")
                LogisticsCenter.update_lc_signal(item, name)
                if eei.energy < power_consumption then break end
            end
            ::next_slot::
        end
		::next_chest::
    end

    if(global.cc_entities.checked_index == global.cc_entities.index-1) then
        global.cc_entities.checked_index = 0
    end

    -- -- calc checked_index
    -- if global.cc_entities.index ~= 0 then
    --     global.cc_entities.checked_index = index_end % global.cc_entities.index
    -- else
    --     global.cc_entities.checked_index = 0
    -- end
end

-- check all collector chests, ores only
function check_ccs_on_nth_tick_ores_only(event)
    if global.lc_entities.count < 1 then
        return
    end

    local crc_item_stack = {name = nil, count = 0}
    local ore_entity

    local index_begin = global.cc_entities.checked_index + 1
    local index_end = index_begin + global.cc_entities.check_per_round

    -- check(index_begin,index_end)
    for index = index_begin, index_end, 1 do
        -- game.print("cc:"..index_begin.." "..index_end)
        -- local index = idx
        if index > global.cc_entities.index then
            index = index - global.cc_entities.index
        end
        local chest = global.cc_entities.entities[index]
        if chest ~= nil then
            if chest.entity.valid then
                if chest.nearest_lc ~= nil then
                    local inventory = chest.entity.get_output_inventory()
                    if not inventory.is_empty() then
                        local eei = chest.nearest_lc.eei
                        local power_consumption = chest.nearest_lc.power_consumption
                        local contents = inventory.get_contents()

                        for name, count in pairs(contents) do
                            ore_entity = game.entity_prototypes[name]
                            if ore_entity ~= nil and ore_entity.type == 'resource' then -- game.item_prototypes[name] ~= nil?
                                -- stock.get_item(name)
                                local item = global.items_stock.items[name]
                                if item == nil then
                                    item = Items.add(name)
                                end

                                -- enough energy?
                                count = math_min(count, math_floor(eei.energy / power_consumption))
                                -- calc max_control
                                count = math_min(count, item.max_control - item.stock)

                                if count > 0 then
                                    crc_item_stack.name = name
                                    crc_item_stack.count = count
                                    count = inventory.remove(crc_item_stack)
                                    item.stock = item.stock + count
                                    eei.energy = eei.energy - count * power_consumption
                                    LogisticsCenter.update_lc_signal(item, name)

                                    if eei.energy < power_consumption then
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            else
                Chests:remove_cc(index)
            end
        end
    end

    -- calc checked_index
    if global.cc_entities.index ~= 0 then
        global.cc_entities.checked_index = index_end % global.cc_entities.index
    else
        global.cc_entities.checked_index = 0
    end
end

-- check all collector chests, except ores
function check_ccs_on_nth_tick_except_ores(event)
    if global.lc_entities.count < 1 then
        return
    end

    local crc_item_stack = {name = nil, count = 0}
    local ore_entity

    local index_begin = global.cc_entities.checked_index + 1
    local index_end = index_begin + global.cc_entities.check_per_round

    -- check(index_begin,index_end)
    for index = index_begin, index_end, 1 do
        -- game.print("cc:"..index_begin.." "..index_end)
        -- local index = idx
        if index > global.cc_entities.index then
            index = index - global.cc_entities.index
        end
        local chest = global.cc_entities.entities[index]
        if chest ~= nil then
            if chest.entity.valid then
                if chest.nearest_lc ~= nil then
                    local inventory = chest.entity.get_output_inventory()
                    if not inventory.is_empty() then
                        local eei = chest.nearest_lc.eei
                        local power_consumption = chest.nearest_lc.power_consumption
                        local contents = inventory.get_contents()

                        for name, count in pairs(contents) do
                            ore_entity = game.entity_prototypes[name]
                            if ore_entity == nil or game.entity_prototypes[name].type ~= 'resource' then
                                -- stock.get_item(name)
                                local item = global.items_stock.items[name]
                                if item == nil then
                                    item = Items.add(name)
                                end

                                -- enough energy?
                                count = math_min(count, math_floor(eei.energy / power_consumption))
                                -- calc max_control
                                count = math_min(count, item.max_control - item.stock)

                                if count > 0 then
                                    crc_item_stack.name = name
                                    crc_item_stack.count = count
                                    count = inventory.remove(crc_item_stack)
                                    item.stock = item.stock + count
                                    eei.energy = eei.energy - count * power_consumption
                                    LogisticsCenter.update_lc_signal(item, name)

                                    if eei.energy < power_consumption then
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            else
                Chests:remove_cc(index)
            end
        end
    end

    -- calc checked_index
    if global.cc_entities.index ~= 0 then
        global.cc_entities.checked_index = index_end % global.cc_entities.index
    else
        global.cc_entities.checked_index = 0
    end
end
