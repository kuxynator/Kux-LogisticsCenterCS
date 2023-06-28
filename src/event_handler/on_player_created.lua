
local function on_player_created(event)
    local player = game.players[event.player_index]
    player.print(
        {
            g_names.locale_print_when_first_init,
            g_startup_settings.lc_buffer_capacity
        }
    )
end

script.on_event(defines.events.on_player_created, on_player_created)