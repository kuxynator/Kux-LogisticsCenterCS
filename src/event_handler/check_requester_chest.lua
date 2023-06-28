local math_floor = math.floor
local math_min = math.min

local startup_settings = g_startup_settings

-- check all requester chests
function check_rcs_on_nth_tick(nth_tick_event)
    if global.lc_entities.count < 1 then return end
	local chestStorage = global.rc_entities;

	-- print("check_rcs_on_nth_tick")
	-- print("  chestStorage.index:               "..chestStorage.index)
	-- print("  chestStorage.checked_index:   "..chestStorage.checked_index)
	-- print("  chestStorage.check_per_round: "..chestStorage.check_per_round)
    local crc_item_stack = {name = nil, count = 0}

    local index_begin = chestStorage.checked_index + 1
	if(index_begin > chestStorage.index -1) then index_begin = 1 end
    local index_end = math.min(index_begin + chestStorage.check_per_round -1, chestStorage.index -1)
	--print("check_rcs_on_nth_tick "..index_begin.."-"..index_end)

    for index = index_begin, index_end, 1 do
		chestStorage.checked_index = index
        -- ??? if index > chestStorage.index then index = index - chestStorage.index end

        local chest = chestStorage.entities[index] --[[@as RequestChest]]
        if chest == nil then goto next_chest end
        if not chest.entity.valid then print("request chest("..index..") is invalid");--[[Chests.remove_rc(index); ]] goto next_chest end
        if chest.nearest_lc == nil then goto next_chest end
		local eei = chest.nearest_lc.eei
		if(eei==nil) then goto next_chest end
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

    -- -- calc checked_index
    -- if chestStorage.index ~= 0 then
    --     chestStorage.checked_index = index_end % chestStorage.index
    -- else
    --     chestStorage.checked_index = 0
    -- end
end
