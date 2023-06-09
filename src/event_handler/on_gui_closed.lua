
local names = g_names

local function on_gui_closed(event)
    local entity = event.entity

    -- incase a nil value
    if entity == nil then return end

    if entity ~= nil then
        if entity ~= nil and entity.name == names.logistics_center then -- Logistics Center
            LogisticsCenter.update_lc_signals(entity)
        elseif entity.name == names.logistics_center_controller then -- Logistics Center Controller
            LogisticsCenterController.update(entity)
        elseif entity.name == names.requester_chest_1_1 then -- Requester Chest
        -- game.players[event.player_index].gui.center.clear()
        -- game.players[event.player_index].gui.top.clear()
        -- game.players[event.player_index].gui.left.clear()
        -- game.players[event.player_index].gui.goal.clear()
        -- game.players[event.player_index].gui.screen.clear()
        end
    end
end

script.on_event(defines.events.on_gui_closed, on_gui_closed)
