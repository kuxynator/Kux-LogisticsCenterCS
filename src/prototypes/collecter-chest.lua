require('config')
local dataTools = require "dataTools"

local function make_prototype(name, icon, inventory_size, max_health, width, height, picture, ingredients)
    local h_width = width / 2
    local h_height = height / 2
    data:extend(
        {
			--TODO KUX MODIFICATION change to logistic-container passive-provider (not working > crash)
			-- workaround: add addition chest, see below
            {
				type = 'container',
				--logistic_mode = "passive-provider",
				--logistic_slots_count = 1,
				--render_not_in_network_icon = false,
                name = name,
                icon = icon,
                icon_size = 32,
                inventory_size = inventory_size,
                max_health = max_health,
                flags = {'placeable-neutral', 'placeable-player', 'player-creation'},
                minable = {hardness = 0.5, mining_time = 1, result = name},
                fast_replaceable_group = 'container',
                selection_box = {{-h_width, -h_height}, {h_width, h_height}},
                collision_box = {{-h_width + 0.1, -h_height + 0.1}, {h_width - 0.1, h_height - 0.1}},
                open_sound = {filename = '__base__/sound/metallic-chest-open.ogg'},
                close_sound = {filename = '__base__/sound/metallic-chest-close.ogg'},
                vehicle_impact_sound = {filename = '__base__/sound/car-metal-impact.ogg', volume = 0.5},
                picture = picture,
                circuit_wire_connection_point = {
                    shadow = {
                        red = {0.734375, 0.453125},
                        green = {0.609375, 0.515625}
                    },
                    wire = {
                        red = {0.40625, 0.21875},
                        green = {0.40625, 0.375}
                    }
                },
                circuit_wire_max_distance = 9,
                localised_description = {'item-description.ab-lc-collecter-chest'}
			}
		}
    )

    data:extend({
            {
                type = 'recipe',
                name = name,
                enabled = true,
                energy_required = 1,
                ingredients = ingredients,
                result = name
            }
        }
    )

    data:extend({
            {
                type = 'item',
                name = name,
                stack_size = 50,
                icon = icon,
                icon_size = 32,
                -- flags = {"goes-to-quickbar"},
                subgroup = 'logistics',
                order = 'l[a]',
                place_result = name
            }
        }
    )
end

-----------------------------------------------------------------------------------------------------------------

local icon_1_1 = LC_PATH .. '/graphics/icons/collecter-chest.png'
local picture_1_1 = {
    filename = LC_PATH .. '/graphics/entity/collecter-chest.png',
    priority = 'extra-high',
    width = 48,
    height = 34,
    shift = {0.1875, 0}
}
local ingredients_1_1 = {
    {'steel-plate', 10},
    {'copper-plate', 20}
}

-- name,icon,inventory_size,max_health,width,height,picture,ingredients
make_prototype(g_names.collecter_chest_1_1, icon_1_1, 48, 250, 1, 1, picture_1_1, ingredients_1_1)

if true then
	-- KUX MODIFICATION additional collector chest working also as passive-provider for bots
	local entity = table.deepcopy(data.raw["logistic-container"]["logistic-chest-passive-provider"])
	local recipe = table.deepcopy(data.raw.recipe["logistic-chest-passive-provider"])
	local item   = table.deepcopy(data.raw.item["logistic-chest-passive-provider"])
	item.name = g_names.collecter_chest_1_1.."-pp"
	item.icon = LC_PATH .. '/graphics/icons/logistic-chest-passive-provider.png'
	item.place_result = g_names.collecter_chest_1_1.."-pp"
	item.order = "l[a]"
	item.subgroup="logistics"
	recipe.name = g_names.collecter_chest_1_1.."-pp"
	recipe.result = g_names.collecter_chest_1_1.."-pp"
	entity.name = g_names.collecter_chest_1_1.."-pp"
	entity.animation.layers[1].filename=LC_PATH .. '/graphics/entity/hr-logistic-chest-passive-provider.png'
	entity.animation.layers[1].hr_version.filename=LC_PATH .. '/graphics/entity/hr-logistic-chest-passive-provider.png'
	entity.minable.result = g_names.collecter_chest_1_1.."-pp"
	entity.order = "z-l[a]"

	data:extend({entity,item,recipe})
	dataTools.technology.addEffect("logistic-robotics", {type  = "unlock-recipe", recipe = recipe.name})
end

if true then
	-- KUX MODIFICATION additional collector chest working also as storage for bots
	local entity = table.deepcopy(data.raw["logistic-container"]["logistic-chest-storage"])
	local recipe = table.deepcopy(data.raw.recipe["logistic-chest-storage"])
	local item   = table.deepcopy(data.raw.item["logistic-chest-storage"])
	item.name = g_names.collecter_chest_1_1.."-s"
	item.icon = LC_PATH .. '/graphics/icons/logistic-chest-storage.png'
	item.place_result = g_names.collecter_chest_1_1.."-s"
	item.order = "l[a]"
	item.subgroup="logistics"
	recipe.name = g_names.collecter_chest_1_1.."-s"
	recipe.result = g_names.collecter_chest_1_1.."-s"
	entity.name = g_names.collecter_chest_1_1.."-s"
	entity.animation.layers[1].filename=LC_PATH .. '/graphics/entity/hr-logistic-chest-storage.png'
	entity.animation.layers[1].hr_version.filename=LC_PATH .. '/graphics/entity/hr-logistic-chest-storage.png'
	entity.minable.result = g_names.collecter_chest_1_1.."-s"
	entity.order = "z-l[a]"

	data:extend({entity,item,recipe})
	dataTools.technology.addEffect("logistic-robotics", {type  = "unlock-recipe", recipe = recipe.name})
end

-- logistic-system: active provider, requester, buffer


--[[

{
  icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
  icon_mipmaps = 4,
  icon_size = 64,
  name = "ab-lc-collecter-chest-1_1-pp",
  order = "b[storage]-c[logistic-chest-passive-provider]",
  place_result = "ab-lc-collecter-chest-1_1-pp",
  stack_size = 50,
  subgroup = "logistic-network",
  type = "item"
}


{
  animation = {
    layers = {
      {
        filename = "__base__/graphics/entity/logistic-chest/logistic-chest-passive-provider.png",
        frame_count = 7,
        height = 38,
        hr_version = {
          filename = "__base__/graphics/entity/logistic-chest/hr-logistic-chest-passive-provider.png",
          frame_count = 7,
          height = 74,
          priority = "extra-high",
          scale = 0.5,
          shift = {
            0,
            -0.0625
          },
          width = 66
        },
        priority = "extra-high",
        shift = {
          0,
          -0.0625
        },
        width = 34
      },
      {
        draw_as_shadow = true,
        filename = "__base__/graphics/entity/logistic-chest/logistic-chest-shadow.png",
        height = 24,
        hr_version = {
          draw_as_shadow = true,
          filename = "__base__/graphics/entity/logistic-chest/hr-logistic-chest-shadow.png",
          height = 46,
          priority = "extra-high",
          repeat_count = 7,
          scale = 0.5,
          shift = {
            0.375,
            0.140625
          },
          width = 112
        },
        priority = "extra-high",
        repeat_count = 7,
        shift = {
          0.375,
          0.15625
        },
        width = 56
      }
    }
  },
  animation_sound = {
    {
      filename = "__base__/sound/passive-provider-chest-open-1.ogg",
      volume = 0.3
    },
    {
      filename = "__base__/sound/passive-provider-chest-open-2.ogg",
      volume = 0.3
    },
    {
      filename = "__base__/sound/passive-provider-chest-open-3.ogg",
      volume = 0.3
    },
    {
      filename = "__base__/sound/passive-provider-chest-open-4.ogg",
      volume = 0.3
    },
    {
      filename = "__base__/sound/passive-provider-chest-open-5.ogg",
      volume = 0.3
    }
  },
  circuit_connector_sprites = {
    blue_led_light_offset = {
      0.125,
      0.46875
    },
    connector_main = {
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04a-base-sequence.png",
      height = 50,
      priority = "low",
      scale = 0.5,
      shift = {
        0.09375,
        0.203125
      },
      width = 52,
      x = 104,
      y = 150
    },
    connector_shadow = {
      draw_as_shadow = true,
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04b-base-shadow-sequence.png",
      height = 46,
      priority = "low",
      scale = 0.5,
      shift = {
        0.3125,
        0.3125
      },
      width = 62,
      x = 124,
      y = 138
    },
    led_blue = {
      draw_as_glow = true,
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04e-blue-LED-on-sequence.png",
      height = 60,
      priority = "low",
      scale = 0.5,
      shift = {
        0.09375,
        0.171875
      },
      width = 60,
      x = 120,
      y = 180
    },
    led_blue_off = {
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04f-blue-LED-off-sequence.png",
      height = 44,
      priority = "low",
      scale = 0.5,
      shift = {
        0.09375,
        0.171875
      },
      width = 46,
      x = 92,
      y = 132
    },
    led_green = {
      draw_as_glow = true,
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04h-green-LED-sequence.png",
      height = 46,
      priority = "low",
      scale = 0.5,
      shift = {
        0.09375,
        0.171875
      },
      width = 48,
      x = 96,
      y = 138
    },
    led_light = {
      intensity = 0,
      size = 0.9
    },
    led_red = {
      draw_as_glow = true,
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04i-red-LED-sequence.png",
      height = 46,
      priority = "low",
      scale = 0.5,
      shift = {
        0.09375,
        0.171875
      },
      width = 48,
      x = 96,
      y = 138
    },
    red_green_led_light_offset = {
      0.109375,
      0.359375
    },
    wire_pins = {
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04c-wire-sequence.png",
      height = 58,
      priority = "low",
      scale = 0.5,
      shift = {
        0.09375,
        0.171875
      },
      width = 62,
      x = 124,
      y = 174
    },
    wire_pins_shadow = {
      draw_as_shadow = true,
      filename = "__base__/graphics/entity/circuit-connector/hr-ccm-universal-04d-wire-shadow-sequence.png",
      height = 54,
      priority = "low",
      scale = 0.5,
      shift = {
        0.25,
        0.296875
      },
      width = 70,
      x = 140,
      y = 162
    }
  },
  circuit_wire_connection_point = {
    shadow = {
      green = {
        0.671875,
        0.609375
      },
      red = {
        0.890625,
        0.5625
      }
    },
    wire = {
      green = {
        0.453125,
        0.453125
      },
      red = {
        0.390625,
        0.21875
      }
    }
  },
  circuit_wire_max_distance = 9,
  close_sound = {
    filename = "__base__/sound/metallic-chest-close.ogg",
    volume = 0.42999999999999998
  },
  collision_box = {
    {
      -0.35,
      -0.35
    },
    {
      0.35,
      0.35
    }
  },
  corpse = "passive-provider-chest-remnants",
  damaged_trigger_effect = {
    damage_type_filters = "fire",
    entity_name = "spark-explosion",
    offset_deviation = {
      {
        -0.5,
        -0.5
      },
      {
        0.5,
        0.5
      }
    },
    offsets = {
      {
        0,
        1
      }
    },
    type = "create-entity"
  },
  dying_explosion = "passive-provider-chest-explosion",
  fast_replaceable_group = "container",
  flags = {
    "placeable-player",
    "player-creation"
  },
  icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
  icon_mipmaps = 4,
  icon_size = 64,
  inventory_size = 48,
  logistic_mode = "passive-provider",
  max_health = 350,
  minable = {
    mining_time = 0.1,
    result = "logistic-chest-passive-provider"
  },
  name = "ab-lc-collecter-chest-1_1-pp",
  open_sound = {
    filename = "__base__/sound/metallic-chest-open.ogg",
    volume = 0.42999999999999998
  },
  opened_duration = 7,
  resistances = {
    {
      percent = 90,
      type = "fire"
    },
    {
      percent = 60,
      type = "impact"
    }
  },
  selection_box = {
    {
      -0.5,
      -0.5
    },
    {
      0.5,
      0.5
    }
  },
  type = "logistic-container",
  vehicle_impact_sound = {
    {
      filename = "__base__/sound/car-metal-impact-2.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/car-metal-impact-3.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/car-metal-impact-4.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/car-metal-impact-5.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/car-metal-impact-6.ogg",
      volume = 0.5
    }
  }
}
]]