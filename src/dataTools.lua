local dataTools = {
	technology = {}
}
local technology = dataTools.technology

technology.addEffect = function (technology, newEffect)
	local t = data.raw.technology[technology]
	if t.effects then table.insert(t.effects, newEffect) end
	if t.normal and t.normal.effects then table.insert(t.normal.effects, newEffect) end
	if t.expensive and t.expensive.effects then table.insert(t.expensive.effects, newEffect) end
end

return dataTools