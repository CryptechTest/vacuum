
-- this is vacuum of space
minetest.register_node("vacuum:vacuum", {
	description = "Vacuum",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drawtype = "airlike",
	--drawtype = "liquid",
	--drawtype = "glasslike",

	post_effect_color = {a = 17, r = 20, g = 30, b = 200},
	tiles = {"vacuum_texture.png^[colorize:#E0E0E033"},
	inventory_image = "vacuum_inv.png",
	wield_image = "vacuum_inv.png",
	use_texture_alpha = "blend",
	waving = 3,

	drowning = 1,
	groups = {not_in_creative_inventory=1, not_blocking_trains=1, cools_lava=1, vacuum = 1},
	paramtype = "light",
	drop = {},
})

-- this is the border between air and vacuum..
minetest.register_node("vacuum:atmos_thin", {
	description = "Atmosphere Air Thin",
	--drawtype = "glasslike",
	drawtype = "liquid",
	tiles = {"atmos_thin.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	use_texture_alpha = "blend",--true,
	inventory_image = "vacuum_inv.png",
	wield_image = "vacuum_inv.png",
	--post_effect_color = {a = 8, r = 55, g = 52, b = 88},
	post_effect_color = {a = 8, r = 20, g = 50, b = 200},
	groups = {not_in_creative_inventory = 1, atmosphere = 1},
	drowning = 1,
	waving = 3
})

-- this is just like air, but in space
minetest.register_node("vacuum:atmos_thick", {
	description = "Atmosphere Air Thick",
	--drawtype = "glasslike",
	--drawtype = "liquid",
	drawtype = "airlike",
	--tiles = {"asteroid_atmos3.png^[colorize:#E0E0E033"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	use_texture_alpha = "blend",--true,
	inventory_image = "vacuum_inv.png",
	wield_image = "vacuum_inv.png",
	--post_effect_color = {a = 28, r = 247, g = 255, b = 222},
	post_effect_color = {a = 20, r = 64, g = 60, b = 73},
	groups = {not_in_creative_inventory = 1, atmosphere = 2},
	waving = 3
})

-- this is atmosphere that is around the space asteroids
minetest.register_node(":asteroid:atmos", {
	description = "Atmosphere",
	--drawtype = "glasslike",
	drawtype = "liquid",
	--tiles = {"asteroid_atmos6.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	use_texture_alpha = "blend",--true,
	inventory_image = "vacuum_inv.png",
	wield_image = "vacuum_inv.png",
	post_effect_color = {a = 21, r = 241, g = 248, b = 255},
	groups = {not_in_creative_inventory = 1, atmosphere = 3},
	waving = 3
})
