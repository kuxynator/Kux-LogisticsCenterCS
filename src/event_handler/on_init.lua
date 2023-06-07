
local names = g_names
local startup_settings = g_startup_settings

local spaceShipInventory = {
	{"ab-lc-logistics-center", 1},
	{"ab-lc-collecter-chest-1_1", 50},
	{"ab-lc-requester-chest-1_1", 50},
	--{"ab-lc-collecter-chest-1_1-s", 50},  -- trash/storage chests
	--{"ab-lc-requester-chest-1_1-s", 50},  -- request/storage chests
}

local debrisItems = {
	{"ab-lc-collecter-chest-1_1", 5},
	{"ab-lc-requester-chest-1_1", 5}
}

local placeLogisticsCenter = function ()
	if true then return end -- temporary deactivated
	--can_place_entity{name=…, position=…, direction=…, force=…, build_check_type=…, forced=…} → boolean
	local entity = game.surfaces["nauvis"].create_entity{
		name = "ab-lc-logistics-center",
		position = {-2.5,-0.5}, --{-0.5,-2.5}
		force = game.forces["player"],
		--raise_built=true
	}
	LogisticsCenter.add(entity) -- WORKAROUND for on_build is not called
end

local setSpaceshipInventory = function ()
	--local existingLCs = game.surfaces["nauvis"].find_entities_filtered{
	--	area={{-500, -500}, {500, 500}}, name="ab-lc-logistics-center", limit=1}
	--if #existingLCs > 0 then return end

	placeLogisticsCenter()

	local created_items = remote.call("freeplay", "get_ship_items")
	for _,v in ipairs(spaceShipInventory) do
		created_items[v[1]] = (created_items[v[1]] or 0) + v[2]
	end
	remote.call("freeplay", "set_ship_items", created_items)
end

local setDebrisItems = function ()
	local created_items = remote.call("freeplay", "get_debris_items")
	for _,v in ipairs(debrisItems) do
		created_items[v[1]] = (created_items[v[1]] or 0) + v[2]
	end
	remote.call("freeplay", "set_debris_items", created_items)
end

local function insert_quick_start_items()
	if not remote.interfaces["freeplay"] then return end

	if(script.active_mods["space-exploration"]) then
		setSpaceshipInventory()
	else
		local quick_start = startup_settings.quick_start
		if quick_start == nil then quick_start = 1 end

		if quick_start > 0 then
			setSpaceshipInventory()
			if quick_start > 1 then -- place additionaly lcs into players inventory
				local created_items = remote.call("freeplay", "get_created_items")
				created_items["ab-lc-logistics-center"] = (created_items["ab-lc-logistics-center"] or 0) + quick_start-1
				remote.call("freeplay", "set_created_items", created_items)
			end
		end
	end
	setDebrisItems() --does not work?
end

function on_init()
	insert_quick_start_items()
end