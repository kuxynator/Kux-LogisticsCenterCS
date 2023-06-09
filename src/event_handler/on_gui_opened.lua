
local names = g_names

local function on_gui_opened(event)
    local entity = event.entity

    -- incase a nil value
    if entity == nil then return end
    
    if entity ~= nil then
        if entity.name == names.logistics_center then -- Logistics Center
            LogisticsCenter.update_lc_signals(entity)
        elseif entity.name == names.requester_chest_1_1 then -- Requester Chest
        -- game.players[event.player_index].gui.center.add {type = 'choose-elem-button', name = 'test_picker1', elem_type = 'item'}
        -- game.players[event.player_index].gui.top.add {type = 'choose-elem-button', name = 'test_picker2', elem_type = 'item'}
        -- game.players[event.player_index].gui.left.add {type = 'choose-elem-button', name = 'test_picker3', elem_type = 'item'}
        -- game.players[event.player_index].gui.goal.add {type = 'choose-elem-button', name = 'test_picker4', elem_type = 'item'}
        -- game.players[event.player_index].gui.screen.add {type = 'choose-elem-button', name = 'test_picker5', elem_type = 'item'}
        end
    end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)
