local names = g_names

local function on_research_finished(event)
    local research = event.research

    if string.match(research.name, names.tech_lc_capacity_pattern) ~= nil then
        Technology.research_lc_capacity(research)
    elseif string.match(research.name, names.tech_power_consumption_pattern) ~= nil then
        Technology.research_chest_power_consumption(research)
    end
end

script.on_event(defines.events.on_research_finished, on_research_finished)
