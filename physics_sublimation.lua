function register_physics_sublimation(height)

    -- sublimate nodes in vacuum
    minetest.register_abm({
        label = "space vacuum sublimate",
        nodenames = {"group:snowy"},
        neighbors = {"vacuum:vacuum"},
        interval = 5,
        chance = 2, -- 1
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(500, function(pos, node)
            if not vacuum.is_pos_in_space(pos) then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.has_in_area(pos, "vacuum:vacuum", 1, 17) and not vacuum.near_powered_airpump(pos) then
                -- minetest.log("sublimate")
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            end
        end)
    })

    -- sublimate nodes in vacuum
    minetest.register_abm({
        label = "space vacuum sublimate",
        nodenames = {"group:leaves", "group:water"},
        neighbors = {"vacuum:vacuum"},
        interval = 3,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(750, function(pos, node)
            if not vacuum.is_pos_in_space(pos) then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.has_in_area(pos, "vacuum:vacuum", 1, 6) and not vacuum.near_powered_airpump(pos) then
                -- minetest.log("sublimate")
                if node.name == "default:water_source" then
                    minetest.set_node(pos, {
                        name = "default:snowblock"
                    })
                else
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                end
            end
        end)
    })

    minetest.register_abm({
        label = "space vacuum sublimate",
        nodenames = {"asteroid:atmos", "vacuum:atmos_thin"},
        neighbors = {"group:water"},
        interval = 3,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos)
            if not vacuum.is_pos_in_space(pos) or vacuum.near_powered_airpump(pos) then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.has_in_area(pos, "asteroid:atmos", 1, 3) then
                -- minetest.log("sublimate water")
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thick"
                })
            elseif vacuum.has_in_area(pos, "vacuum:atmos_thin", 1, 3) then
                -- minetest.log("sublimate water")
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thick"
                })
            end
        end)
    })

end
