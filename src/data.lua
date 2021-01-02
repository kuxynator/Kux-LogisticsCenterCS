-- entity/item/recipe
require('prototypes.logistics-center')
require('prototypes.collecter-chest')
require('prototypes.requester-chest')
require('prototypes.logistics-center-controller')
-- technology
require('prototypes.tech-logistics-center-capacity')
require('prototypes.tech-power-consumption')
-- else
require('prototypes.electric-energy-interface')
require("prototypes.logistics-center-animation")
require('prototypes.distance-flying-text')
require('prototypes.energy_bars')

if mods then
	data.raw["container"]["crash-site-spaceship"].inventory_size = 30

	if mods["Krastorio2"] then
		print("increase generator output")
		local generator = data.raw["electric-energy-interface"]["kr-crash-site-generator"]
		generator.energy_production               = "20MW" -- "240kW"
		generator.energy_source.buffer_capacity   = "20MJ" -- "240kJ"
		generator.energy_source.output_flow_limit = "20MW" -- "240kW"
	end
end