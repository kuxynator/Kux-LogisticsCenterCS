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

-- tweak Krastorio 2 generator
local generator = data.raw["electric-energy-interface"]["kr-crash-site-generator"]
if generator then
	generator.energy_production               = "20MW" -- "240kW"
	generator.energy_source.buffer_capacity   = "20MJ" -- "240kJ"
	generator.energy_source.output_flow_limit = "20MW" -- "240kW"
end

local spaceship = data.raw["container"]["crash-site-spaceship"]
spaceship.inventory_size = spaceship.inventory_size + 4