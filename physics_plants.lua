-- plants
minetest.register_node("vacuum:dead_leaves", {
    description = "Dead Leaves",
    drawtype = "plantlike",
    waving = 1,
    tiles = {"default_dry_shrub.png^dead_leaves.png"},
    inventory_image = "default_dry_shrub.png^dead_leaves.png",
    wield_image = "default_dry_shrub.png^dead_leaves.png",
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 4,
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {
        snappy = 3,
        flammable = 3,
        attached_node = 1
    },
    sounds = default.node_sound_leaves_defaults(),
    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 4 / 16, 6 / 16}
    }
})

-- plants in vacuum
minetest.register_abm({
    label = "space vacuum plants",
    nodenames = {"group:sapling", "group:plant", "group:flora", "group:flower", "group:leafdecay", "ethereal:banana", -- ethereal compat
                 "ethereal:orange", "ethereal:strawberry"},
    neighbors = {"vacuum:vacuum"},
    interval = 2,
    chance = 1,
    action = vacuum.throttle(100, function(pos)
        minetest.set_node(pos, {
            name = "default:dry_shrub"
        })
    end)
})

-- leaves in vacuum
minetest.register_abm({
    label = "space vacuum plants",
    nodenames = {"group:leaves"},
    neighbors = {"vacuum:vacuum"},
    interval = 3,
    chance = 2,
    action = vacuum.throttle(200, function(pos)
        minetest.set_node(pos, {
            name = "vacuum:dead_leaves"
        })
    end)
})
