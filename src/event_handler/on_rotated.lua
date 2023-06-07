
local names = g_names
local config = g_config

function on_rotated(event)
    local entity = event.entity
    
    -- incase a nil value
    if entity == nil then return end
    
    if entity.name == names.logistics_center then -- Logistics center
        LogisticsCenter.create_energy_bar(entity)
    end
end
