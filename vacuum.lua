

minetest.register_node("vacuum:vacuum", {
	description = "Vacuum",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drawtype = "airlike",
	drowning = 1,
	use_texture_alpha = false,
	groups = {not_in_creative_inventory=1, not_blocking_trains=1, cools_lava=1},
	paramtype = "light",
	drop = {},
	sunlight_propagates = true
})
