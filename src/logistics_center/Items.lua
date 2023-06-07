---@class Items
Items = {}

local startup_settings = g_startup_settings

-- Add item
function Items.add(name)
    -- find the smallest index not in use
    local index_s = {}
    for k, v in pairs(global.items_stock.items) do
        index_s[v.index] = 1
    end

    -- default index = config.lc_item_slot_count + 1
    local index = startup_settings.lc_item_slot_count + 1
    for i = 1, startup_settings.lc_item_slot_count do
        if index_s[i] == nil then
            index = i
            break
        end
    end

    -- add item
    --local item = {index = index, stock = 0, enable = true, max_control = global.technologies.lc_capacity}
    local item = {index = index, stock = 0, enable = true, max_control = 100} --TODO KUX Modification default number of max items
    global.items_stock.items[name] = item
    global.items_stock.index = global.items_stock.index + 1

    return item
end

-- Del item
function Items.remove(name)
    global.items_stock.items[name] = nil
end

return Items
