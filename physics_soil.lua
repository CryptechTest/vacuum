function register_physics_soil(height)

    -- various dirts in vacuum
    minetest.register_abm({
        label = "space vacuum soil dry",
        nodenames = {"default:dirt", "default:dirt_with_grass", "default:dirt_with_snow", "default:dirt_with_dry_grass",
                     "default:dirt_with_grass_footsteps", "default:dirt_with_rainforest_litter",
                     "default:dirt_with_coniferous_litter", "default:dry_dirt", "default:dry_dirt_with_dry_grass",
                     "woodsoils:dirt_with_leaves_1", "woodsoils:dirt_with_leaves_2"},
        neighbors = {"vacuum:vacuum"},
        interval = 2,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(100, function(pos)
            if vacuum.is_pos_in_spawn(pos) then
                return
            end
            minetest.set_node(pos, {
                name = "default:gravel"
            })
        end)
    })

end
