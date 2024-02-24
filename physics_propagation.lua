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
        neighbors = {"air"},
        interval = 5,
        chance = 1, -- this need to be 1..
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_space(pos) then
                if vacuum.near_powered_airpump(pos, 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                elseif vacuum.has_in_area(pos, "air", 1, 4) then
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
        interval = 2,
        chance = 1, -- higher chance of thin appears
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics 
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if (vacuum.is_pos_in_space(pos)) then
                if vacuum.near_powered_airpump(pos, 5) and vacuum.has_in_area(pos, "vacuum:atmos_thin", 2, 60) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                    -- elseif vacuum.near_powered_airpump(pos, 5) and vacuum.has_in_area(pos, "vacuum:atmos_thin", 2, 100) then
                    --    minetest.set_node(pos, {
                    --        name = "vacuum:atmos_thin"
                    --    })
                end
            end
        end)
    })

    -- ====================================================================================

    -- thin atmos propagation
    minetest.register_abm({
        label = "thick atmos -> thin replacement",
        nodenames = {"air"},
        neighbors = {"vacuum:atmos_thin"},
        interval = 5,
        chance = 2,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if not vacuum.near_powered_airpump(pos, 4) then
                local pos1, pos2, area, areaNodes = vacuum.get_area_nodes(pos, 1);

                if vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "vacuum:vacuum", 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thin"
                    })
                elseif vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "vacuum:atmos_thin", 7) then
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
        nodenames = {"air"},
        neighbors = {"vacuum:vacuum"},
        interval = 1,
        chance = 3, -- 3 ???
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
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
        nodenames = {"vacuum:atmos_thin", "vacuum:atmos_thick"}, -- , "technic:dummy_light_source"
        neighbors = {"air"},
        interval = 2,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_space(pos) then
                local spawn_particles = false;
                local pos1, pos2, area, areaNodes = vacuum.get_area_nodes(pos, 1);

                if vacuum.near_powered_airpump(pos, 5) then -- 12
                    if vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "air", 5) then
                        minetest.set_node(pos, {
                            name = "air"
                        })
                        spawn_particles = true;
                    elseif vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "vacuum:atmos_thin", 1) and
                        not vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "vacuum:vacuum", 3) then
                        minetest.set_node(pos, {
                            name = "air"
                        })
                        spawn_particles = true;
                    end
                end

                if vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "air", 11) then
                    minetest.set_node(pos, {
                        name = "air"
                    })
                    spawn_particles = true;
                end

                if node.name == "vacuum:atmos_thick" then -- or node.name == "technic:dummy_light_source"
                    minetest.set_node(pos, {
                        name = "air"
                    })
                    spawn_particles = true;
                end

                if spawn_particles then
                    if math.random(0, 2) == 0 then
                        vacuum.spawn_particle(pos, math.random(-0.001, 0.001), math.random(-0.001, 0.001),
                            math.random(-0.001, 0.001), math.random(-0.002, 0.002), math.random(-0.007, 0.007),
                            math.random(-0.002, 0.002), math.random(3.2, 4.8), 10)
                    end
                end
            end
        end)
    })

    -- this makes vacuum!
    -- thin atmos to vacuum
    minetest.register_abm({
        label = "thin atmos -> vacuum replacement",
        nodenames = {"vacuum:atmos_thin", "vacuum:atmos_thick", "air"},
        neighbors = {"vacuum:vacuum"},
        interval = 10,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.is_pos_in_space(pos) then
                local pos1, pos2, area, areaNodes = vacuum.get_area_nodes(pos, 1);

                local spawn_particles = false;
                if not vacuum.near_powered_airpump(pos, 5) and
                    vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "vacuum:vacuum", 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:vacuum"
                    })
                    spawn_particles = true;
                elseif not vacuum.near_powered_airpump(pos, 4) and
                    vacuum.has_in_area_data(pos1, pos2, area, areaNodes, "vacuum:vacuum", 10) then
                    minetest.set_node(pos, {
                        name = "vacuum:vacuum"
                    })
                    spawn_particles = true;
                elseif vacuum.has_in_area(pos, "vacuum:vacuum", 1, 25) then
                    minetest.set_node(pos, {
                        name = "vacuum:vacuum"
                    })
                    spawn_particles = true;
                end

                if spawn_particles then
                    if math.random(0, 2) == 0 then
                        vacuum.spawn_particle(pos, math.random(-0.001, 0.001), math.random(-0.001, 0.001),
                            math.random(-0.001, 0.001), math.random(-0.002, 0.002), math.random(-0.007, 0.007),
                            math.random(-0.002, 0.002), math.random(3.2, 4.8), 8)
                    end
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
        action = vacuum.throttle(2500, function(pos, node)

            if pos.y < height.start_height + 50 then
                return
            end
            if pos.y > height.end_height - 50 then
                return
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- update metrics
            if metric_space_vacuum_abm ~= nil then
                metric_space_vacuum_abm.inc()
            end

            if vacuum.near_powered_airpump(pos, 4) and vacuum.has_in_area(pos, "vacuum:atmos_thin", 1, 5) then
                minetest.set_node(pos, {
                    name = "air"
                })
            elseif vacuum.near_powered_airpump(pos, 2) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            end
        end)
    })

end
