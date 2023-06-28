
local names = g_names
local config = g_config

local function on_rotated(event)
    local entity = event.entity

    if entity == nil then return end

    if entity.name == names.logistics_center then -- Logistics center
        LogisticsCenter.create_energy_bar(entity)
    end
end

script.on_event(defines.events.on_player_rotated_entity, on_rotated)