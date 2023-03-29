
-- spacesuit repair recipes
local function repair_recipe(partname)
	minetest.register_craft({
		type = "shapeless",
		output = partname,
		recipe = {
			"vacuum:air_bottle",
			partname
		},
		replacements = {
			{"vacuum:air_bottle", "vessels:steel_bottle"}
		}
	})
end

repair_recipe("spacesuit:helmet_base")
repair_recipe("spacesuit:chestplate_base")
repair_recipe("spacesuit:pants_base")
repair_recipe("spacesuit:boots_base")

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_craft({
		type = "filling",
		output = "spacesuit:helmet_base 1 1",
		items = {"spacesuit:helmet_base 1 60000"},
		width = 0,
	})
	unified_inventory.register_craft({
		type = "filling",
		output = "spacesuit:chestplate_base 1 1",
		items = {"spacesuit:chestplate_base 1 60000"},
		width = 0,
	})
	unified_inventory.register_craft({
		type = "filling",
		output = "spacesuit:pants_base 1 1",
		items = {"spacesuit:pants_base 1 60000"},
		width = 0,
	})
	unified_inventory.register_craft({
		type = "filling",
		output = "spacesuit:boots_base 1 1",
		items = {"spacesuit:boots_base 1 60000"},
		width = 0,
	})
end
