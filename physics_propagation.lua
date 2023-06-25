local has_monitoring = minetest.get_modpath("monitoring")

local metric_space_vacuum_abm

if has_monitoring then
    metric_space_vacuum_abm = monitoring.counter("vacuum_abm_count", "number of space vacuum abm calls")
end

-- ====================================================================================

function register_physics_propagation(height)

    -- thin atmos propagation
    minetest.register_abm({
        label = "vacuum -> thin atmos replacement",
        nodenames = {"vacuum:vacuum"},
        neighbors = {"vacuum:atmos_thick"},
        interval = 3,
        chance = 1, -- this need to be 1..
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos, node)
            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.is_pos_in_space(pos) then
                if vacuum.near_powered_airpump(pos, 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                elseif vacuum.has_in_area(pos, "vacuum:atmos_thick", 1, 4) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                end
            end
        end)
    })

    -- thin atmos propagation
    minetest.register_abm({
        label = "vacuum -> atmos_thin replacement",
        nodenames = {"vacuum:vacuum"},
        neighbors = {"vacuum:atmos_thin"},
        interval = 3,
        chance = 2, -- higher chance of thin appears
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos, node)
            -- update metrics 
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if (vacuum.is_pos_in_space(pos)) then
                if vacuum.near_powered_airpump(pos, 4) and vacuum.has_in_area(pos, "vacuum:atmos_thin", 2, 60) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                elseif vacuum.near_powered_airpump(pos, 5) and vacuum.has_in_area(pos, "vacuum:atmos_thin", 2, 100) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                end
            end
        end)
    })

    -- ====================================================================================

    -- thin atnos propagation
    minetest.register_abm({
        label = "thick atnos -> thin replacement",
        nodenames = {"vacuum:atmos_thick"},
        neighbors = {"vacuum:atmos_thin"},
        interval = 3,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos, node)
            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if not vacuum.is_pos_in_space(pos) then
                -- on earth
                minetest.set_node(pos, {
                    name = "air"
                })
                -- not near a powered airpump
            elseif not vacuum.near_powered_airpump(pos, 4) then
                if vacuum.has_in_area(pos, "vacuum:vacuum", 1, 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                elseif vacuum.has_in_area(pos, "vacuum:atmos_thin", 1, 10) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                end
            end
        end)
    })

    -- thin atmos propagation
    minetest.register_abm({
        label = "vacuum -> thin atmos replacement",
        nodenames = {"vacuum:atmos_thick"},
        neighbors = {"vacuum:vacuum"},
        interval = 2,
        chance = 1, -- 3 ???
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos, node)
            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.is_pos_in_space(pos) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            end
        end)
    })

    -- ====================================================================================

    -- thick atmos propagation
    minetest.register_abm({
        -- replace air and thin with thick..
        label = "aer -> thick atmos replacement",
        nodenames = {"vacuum:atmos_thin", "air", "technic:dummy_light_source"},
        neighbors = {"vacuum:atmos_thick"},
        interval = 3,
        chance = 2,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos, node)
            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.is_pos_in_space(pos) then
                if vacuum.near_powered_airpump(pos, 5) then -- 12
                    if vacuum.has_in_area(pos, "vacuum:atmos_thick", 1, 5) then
                        minetest.set_node(pos, {
                            name = "vacuum:atmos_thick"
                        })
                    elseif vacuum.has_in_area(pos, "vacuum:atmos_thin", 1, 1) and
                        not vacuum.has_in_area(pos, "vacuum:vacuum", 1, 3) then
                        minetest.set_node(pos, {
                            name = "vacuum:atmos_thick"
                        })
                    end
                end
                if node.name == "air" or node.name == "technic:dummy_light_source" then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thick"
                    })
                end
            end
        end)
    })

    -- thin atmos to vacuum
    minetest.register_abm({
        label = "thin atmos -> vacuum replacement",
        nodenames = {"vacuum:atmos_thin", "air"},
        neighbors = {"vacuum:vacuum"},
        interval = 2,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(1000, function(pos, node)
            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.is_pos_in_space(pos) then
                if not vacuum.near_powered_airpump(pos, 5) and vacuum.has_in_area(pos, "vacuum:vacuum", 1, 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:vacuum"
                    })
                elseif not vacuum.near_powered_airpump(pos, 4) and vacuum.has_in_area(pos, "vacuum:vacuum", 1, 10) then
                    minetest.set_node(pos, {
                        name = "vacuum:vacuum"
                    })
                    --[[elseif vacuum.has_in_area(pos, "vacuum:vacuum", 1, 25) then
                    minetest.set_node(pos, {
                        name = "vacuum:vacuum"
                    })--]]
                end
            end
        end)
    })

    -- ====================================================================================

    -- thick atmos propagation base
    -- seed propagation
    minetest.register_abm({
        label = "thin atmos + vacuum -> atmos replacement",
        nodenames = {"vacuum:atmos_thin", "vacuum:vacuum"},
        neighbors = {"vacuum:airpump", "vacuum:airpump_wait", "vacuum:airpump_active"},
        interval = 5,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(500, function(pos, node)
            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if vacuum.near_powered_airpump(pos, 4) and vacuum.has_in_area(pos, "vacuum:atmos_thin", 1, 5) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thick"
                })
            elseif vacuum.near_powered_airpump(pos, 2) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            end
        end)
    })

end
