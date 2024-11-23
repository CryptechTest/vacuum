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

function vacuum.register_physics_plants(height)

    -- plants in vacuum
    minetest.register_abm({
        label = "space vacuum plants",
        nodenames = {"group:sapling", "group:plant", "group:flora", "group:flower", "group:leafdecay",
                     "ethereal:banana", "ethereal:orange", "ethereal:strawberry"},
        neighbors = {"vacuum:vacuum", "asteroid:atmos"},
        interval = 2,
        chance = 3,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos)
            if vacuum.is_pos_in_spawn(pos) then
                return
            end
            minetest.set_node(pos, {
                name = "default:dry_shrub"
            })
        end)
    })

    -- leaves in vacuum
    minetest.register_abm({
        label = "space vacuum plants",
        nodenames = {"group:leaves"},
        neighbors = {"vacuum:vacuum", "asteroid:atmos"},
        interval = 2,
        chance = 3,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2000, function(pos)
            if vacuum.is_pos_in_spawn(pos) then
                return
            end
            if vacuum.near_vacuum(pos, 1, 4) then
                minetest.set_node(pos, {
                    name = "vacuum:dead_leaves"
                })
            end
        end)
    })

end
