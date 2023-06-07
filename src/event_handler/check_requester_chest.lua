local math_floor = math.floor
local math_min = math.min

local startup_settings = g_startup_settings

-- check all requester chests
function check_rcs_on_nth_tick(nth_tick_event)
    if global.lc_entities.count < 1 then
        return
    end

	-- print("check_rcs_on_nth_tick")
	-- print("  global.rc_entities.index:               "..global.rc_entities.index)
	-- print("  global.rc_entities.checked_index:   "..global.rc_entities.checked_index)
	-- print("  global.rc_entities.check_per_round: "..global.rc_entities.check_per_round)
    local crc_item_stack = {name = nil, count = 0}

    local index_begin = global.rc_entities.checked_index + 1
	if(index_begin > global.rc_entities.index -1) then index_begin = 0 end
    local index_end = math.min(index_begin + global.rc_entities.check_per_round, global.rc_entities.index -1)
	--print("check_rcs_on_nth_tick "..index_begin.."-"..index_end)

    for index = index_begin, index_end, 1 do
		global.rc_entities.checked_index = index
        -- ??? if index > global.rc_entities.index then index = index - global.rc_entities.index end

        local chest = global.rc_entities.entities[index] --[[@as RequestChest]]
        if chest == nil then goto next_chest end
        if not chest.entity.valid then print("request chest("..index..") is invalid");--[[Chests.remove_rc(index); ]] goto next_chest end
        if chest.nearest_lc == nil then goto next_chest end
		local eei = chest.nearest_lc.eei
		local power_consumption = chest.nearest_lc.power_consumption
		local inventory = chest.entity.get_output_inventory()
		if(inventory==nil) then goto next_chest end

		for i = 1, startup_settings.rc_logistic_slots_count do
			local name
			local count
			if chest.entity.name == g_names.requester_storage_chest_1_1 then
				if i > 1 then goto next_slot end
				name = chest.entity.get_filter(i--[[@as uint]])
				if name == nil then goto next_slot end
				count = 1 * game.item_prototypes[name].stack_size --TODO make configurable
			else
				local request_slot = chest.entity.get_request_slot(i--[[@as uint]])
				if request_slot == nil then goto next_slot end
				name = request_slot.name
				count = request_slot.count
			end

			-- stock.get_item(name)
			local item = global.items_stock.items[name]
			-- if item == nil then
			--     item = ITEM:add(name)  --- do not add signals requested
			-- end

			if item == nil then goto next_slot end
			-- calc shortage
			count = count - inventory.get_item_count(name)
			-- enough stock?
			count = math_min(count, item.stock)
			-- enough energy?
			count = math_min(count, math_floor(eei.energy / power_consumption))

			if count <= 0 then goto next_slot end
			crc_item_stack.name = name
			crc_item_stack.count = count
			-- in case the inventory is full
			local inserted_count = inventory.insert(crc_item_stack)
			item.stock = item.stock - inserted_count
			eei.energy = eei.energy - inserted_count * power_consumption
			--print(""..(- inserted_count * power_consumption).."("..eei.energy..")")
			LogisticsCenter.update_lc_signal(item, name)

			if eei.energy < power_consumption then break end
			::next_slot::
		end
		::next_chest::
    end

	if(global.rc_entities.checked_index == global.rc_entities.index-1) then
		global.rc_entities.checked_index = 0
	end

    -- -- calc checked_index
    -- if global.rc_entities.index ~= 0 then
    --     global.rc_entities.checked_index = index_end % global.rc_entities.index
    -- else
    --     global.rc_entities.checked_index = 0
    -- end
end
