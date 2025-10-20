minetest.register_craftitem("vacuum:air_bottle", {
    description = "Air Bottle",
    inventory_image = vacuum.air_bottle_image
})

if minetest.get_modpath("unified_inventory") then
    unified_inventory.register_craft_type("filling", {
        description = "Filling",
        icon = "vacuum_airpump_front.png",
        width = 1,
        height = 1
    })
    unified_inventory.register_craft({
        type = "filling",
        output = "vacuum:air_bottle",
        items = {"vessels:steel_bottle"},
        width = 0
    })
end

minetest.register_node("vacuum:air_bottle", {
	description = "Air Bottle",
	drawtype = "plantlike",
	tiles = {vacuum.air_bottle_image},
	inventory_image = vacuum.air_bottle_image,
	wield_image = vacuum.air_bottle_image,
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_water_defaults(),
    drop = "",
})
