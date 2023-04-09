local has_monitoring = minetest.get_modpath("monitoring")

local metric_space_vacuum_abm

if has_monitoring then
    metric_space_vacuum_abm = monitoring.counter("vacuum_abm_count", "number of space vacuum abm calls")
end

-- ====================================================================================

-- thin atmos propagation
minetest.register_abm({
    label = "vacuum -> thin atmos replacement",
    nodenames = {"vacuum:vacuum"},
    neighbors = {"vacuum:atmos_thick"},
    interval = 1,
    chance = 1, -- this need to be 1..
    min_y = vacuum.space_height,
    action = vacuum.throttle(1250, function(pos)
        -- update metrics
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if vacuum.is_pos_in_space(pos) then
            if vacuum.near_powered_airpump(pos, 3) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            elseif vacuum.has_in_range(pos, "vacuum:atmos_thick", 1, 4) then
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
    interval = 1,
    chance = 3, -- higher chance of thin appears
    min_y = vacuum.space_height,
    action = vacuum.throttle(1250, function(pos)
        -- update metrics 
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if (vacuum.is_pos_in_space(pos)) then
            if vacuum.has_in_range(pos, "vacuum:atmos_thin", 2, 60) and vacuum.near_powered_airpump(pos, 6) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            elseif vacuum.has_in_range(pos, "vacuum:atmos_thin", 2, 100) and vacuum.near_powered_airpump(pos, 8) then
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
    interval = 1,
    chance = 1,
    action = vacuum.throttle(1000, function(pos)
        -- update metrics
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if not vacuum.is_pos_in_space(pos) then
            -- on earth
            minetest.set_node(pos, {
                name = "air"
            })
            -- not near a powered airpump
        elseif not vacuum.near_powered_airpump(pos, 8) then
            if vacuum.has_in_range(pos, "vacuum:vacuum", 1, 3) then
                minetest.set_node(pos, {
                    name = "vacuum:atmos_thin"
                })
            elseif vacuum.has_in_range(pos, "vacuum:atmos_thin", 1, 10) then
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
    interval = 1,
    chance = 1, -- 3 ???
    min_y = vacuum.space_height,
    action = vacuum.throttle(1000, function(pos)
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
    nodenames = {"vacuum:atmos_thin", "air", "technic:dummy_light_source"},
    neighbors = {"vacuum:atmos_thick"},
    interval = 1,
    chance = 2,
    min_y = vacuum.space_height,
    action = vacuum.throttle(600, function(pos)
        -- update metrics
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if vacuum.is_pos_in_space(pos) then
            if vacuum.near_powered_airpump(pos, 8) then -- 12
                if vacuum.has_in_range(pos, "vacuum:atmos_thick", 1, 5) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thick"
                    })
                elseif vacuum.has_in_range(pos, "vacuum:atmos_thin", 1, 1) and
                    not vacuum.has_in_range(pos, "vacuum:vacuum", 1, 3) then
                    minetest.set_node(pos, {
                        name = "vacuum:atmos_thick"
                    })
                end
            end
            local node = minetest.get_node(pos)
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
    interval = 1,
    chance = 1,
    min_y = vacuum.space_height,
    action = vacuum.throttle(2500, function(pos)
        -- update metrics
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if vacuum.is_pos_in_space(pos) then
            if vacuum.has_in_range(pos, "vacuum:vacuum", 1, 3) and not vacuum.near_powered_airpump(pos, 10) then
                minetest.set_node(pos, {
                    name = "vacuum:vacuum"
                })
            elseif vacuum.has_in_range(pos, "vacuum:vacuum", 1, 10) and not vacuum.near_powered_airpump(pos, 7) then
                minetest.set_node(pos, {
                    name = "vacuum:vacuum"
                })
            elseif vacuum.has_in_range(pos, "vacuum:vacuum", 1, 25) then
                minetest.set_node(pos, {
                    name = "vacuum:vacuum"
                })
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
    interval = 2,
    chance = 1,
    min_y = vacuum.space_height,
    action = vacuum.throttle(1000, function(pos)
        -- update metrics
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if vacuum.has_in_range(pos, "vacuum:atmos_thin", 1, 5) and vacuum.near_powered_airpump(pos, 10) then
            minetest.set_node(pos, {
                name = "vacuum:atmos_thick"
            })
        elseif vacuum.near_powered_airpump(pos, 5) then
            minetest.set_node(pos, {
                name = "vacuum:atmos_thin"
            })
        end
    end)
})

-- ====================================================================================
-- ====================================================================================

-- vacuum propagation in atmos
minetest.register_abm({
    label = "atmos -> vacuum replacement",
    nodenames = {"asteroid:atmos"},
    neighbors = {"vacuum:vacuum"},
    interval = 1,
    chance = 5,
    min_y = vacuum.space_height,
    action = vacuum.throttle(1000, function(pos)
        -- update metrics
        if metric_space_vacuum_abm ~= nil then
            metric_space_vacuum_abm.inc()
        end

        if vacuum.is_pos_in_space(pos) then
            -- in space, evacuate air
            if (vacuum.near_atmos(pos, 9) == false) and not vacuum.near_powered_airpump(pos) then
                minetest.set_node(pos, {
                    name = "vacuum:vacuum"
                })
            end
        end
    end)
})
