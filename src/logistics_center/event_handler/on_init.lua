require('config')

local names = g_names
local startup_settings = g_startup_settings

local function insert_quick_start_items()
	if not remote.interfaces["freeplay"] then return end
    local quick_start = startup_settings.quick_start
    if quick_start == nil then
        quick_start = 1
    end

	if quick_start > 0 then
		local items = {
			[names.logistics_center] = quick_start,
			[names.collecter_chest_1_1] = 50,
			[names.requester_chest_1_1] = 50
		}
		-- Add items
		local created_items = remote.call("freeplay", "get_created_items")
		for k,v in pairs(items) do
			created_items[k] = (created_items[k] or 0) + v
		end	
		remote.call("freeplay", "set_created_items", created_items)
    end
end

function on_init()
    insert_quick_start_items()
end