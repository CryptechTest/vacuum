local has_monitoring = minetest.get_modpath("monitoring")
local has_mesecons_random = minetest.get_modpath("mesecons_random")
local has_technic = minetest.get_modpath("technic")

local metric_space_vacuum_leak_abm

if has_monitoring then
    metric_space_vacuum_leak_abm = monitoring.counter("vacuum_abm_leak_count", "number of space vacuum leak abm calls")
end

-- air leaking nodes
local leaky_nodes = {"group:soil", "group:sand", "group:pipe", "group:tube", "group:fence", "group:leaky"}

if has_mesecons_random then
    table.insert(leaky_nodes, "mesecons_random:ghoststone_active")
end

if has_technic then
    table.insert(leaky_nodes, "technic:lv_cable")
    table.insert(leaky_nodes, "technic:mv_cable")
    table.insert(leaky_nodes, "technic:hv_cable")
end

function register_physics_leakage(height)

    -- depressurize through leaky nodes
    minetest.register_abm({
        label = "space vacuum depressurize",
        nodenames = leaky_nodes,
        neighbors = {"vacuum:vacuum"},
        interval = 2,
        chance = 3,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)
            if metric_space_vacuum_leak_abm ~= nil then
                metric_space_vacuum_leak_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- local node = minetest.get_node(pos)

            if node.name == "pipeworks:entry_panel_empty" or node.name == "pipeworks:entry_panel_loaded" then
                -- air thight pipes
                return
            end

            if node.name == "vacuum:airpump" or node.name == "vacuum:airpump_wait" or node.name ==
                "vacuum:airpump_active" then
                -- pump is airtight
                return
            end

            -- in space: replace air with vacuum
            local surrounding_node = minetest.find_node_near(pos, 1, {"vacuum:atmos_thick"})

            if surrounding_node ~= nil then
                if vacuum.debug then
                    -- debug mode, set
                    minetest.set_node(surrounding_node, {
                        name = "default:cobble"
                    })
                else
                    -- normal case
                    -- minetest.set_node(surrounding_node, {name = "vacuum:atmos_thin"})
                    minetest.set_node(surrounding_node, {
                        name = "vacuum:vacuum"
                    })
                end
            end

            local surrounding_atmos = minetest.find_node_near(pos, 1, {"vacuum:atmos_thin"})

            if surrounding_atmos ~= nil then
                if vacuum.debug then
                    -- debug mode, set
                    minetest.set_node(surrounding_atmos, {
                        name = "default:cobble"
                    })
                else
                    -- normal case
                    -- minetest.set_node(surrounding_node, {name = "vacuum:atmos_thin"})
                    minetest.set_node(surrounding_atmos, {
                        name = "vacuum:vacuum"
                    })
                end
            end
        end)
    })

    --[[
    -- depressurize through leaky nodes
    minetest.register_abm({
        label = "space vacuum depressurize",
        nodenames = "group:soil",
        neighbors = {"vacuum:vacuum"},
        interval = 3,
        chance = 4, -- 3
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(250, function(pos, node)
            if metric_space_vacuum_leak_abm ~= nil then
                metric_space_vacuum_leak_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if not vacuum.is_pos_in_space(pos) then -- or vacuum.near_powered_airpump(pos) then
                -- on earth: TODO: replace vacuum with air
                return
            else
                -- local node = minetest.get_node(pos)

                if node.name == "pipeworks:entry_panel_empty" or node.name == "pipeworks:entry_panel_loaded" then
                    -- air thight pipes
                    return
                end

                if node.name == "vacuum:airpump" or node.name == "vacuum:airpump_wait" or node.name ==
                    "vacuum:airpump_active" then
                    -- pump is airtight
                    return
                end

                -- in space: replace air with vacuum
                local surrounding_node = minetest.find_node_near(pos, 1, {"vacuum:atmos_thick"})

                if surrounding_node ~= nil then
                    if vacuum.debug then
                        -- debug mode, set
                        minetest.set_node(surrounding_node, {
                            name = "default:cobble"
                        })
                    else
                        -- normal case
                        -- minetest.set_node(surrounding_node, {name = "vacuum:atmos_thin"})
                        minetest.set_node(surrounding_node, {
                            name = "vacuum:vacuum"
                        })
                    end
                end

                local surrounding_atmos = minetest.find_node_near(pos, 1, {"vacuum:atmos_thin"})

                if surrounding_atmos ~= nil then
                    if vacuum.debug then
                        -- debug mode, set
                        minetest.set_node(surrounding_atmos, {
                            name = "default:cobble"
                        })
                    else
                        -- normal case
                        -- minetest.set_node(surrounding_node, {name = "vacuum:atmos_thin"})
                        minetest.set_node(surrounding_atmos, {
                            name = "vacuum:vacuum"
                        })
                    end
                end
            end
        end)
    })--]]

    -- depressurize through door nodes
    minetest.register_abm({
        label = "space vacuum depressurize",
        nodenames = "group:door",
        neighbors = {"vacuum:vacuum", "vacuum:atmos_thin"},
        interval = 1,
        chance = 2,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(2500, function(pos, node)
            if metric_space_vacuum_leak_abm ~= nil then
                metric_space_vacuum_leak_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- local node = minetest.get_node(pos)

            local door = minetest.get_item_group(node.name, "door")

            -- in space: replace air with atmos_thin
            local surrounding_vac = minetest.find_node_near(pos, 1, {"vacuum:vacuum"})
            local surrounding_atmos = minetest.find_node_near(pos, 1, {"vacuum:atmos_thick"})

            if surrounding_vac ~= nil and surrounding_atmos ~= nil then
                if vacuum.debug then
                    -- debug mode, set
                    minetest.set_node(surrounding_vac, {
                        name = "default:cobble"
                    })
                else
                    -- normal case
                    -- minetest.set_node(surrounding_node, {name = "vacuum:atmos_thin"})
                    minetest.set_node(surrounding_vac, {
                        name = "vacuum:atmos_thin"
                    })
                end
            end

            -- if door is open
            if surrounding_vac ~= nil and surrounding_atmos == nil and door == 2 then
                minetest.set_node(surrounding_atmos, {
                    name = "vacuum:vacuum"
                })
            elseif surrounding_vac ~= nil and surrounding_vac ~= nil and door == 2 then
                minetest.set_node(surrounding_atmos, {
                    name = "vacuum:atmos_thin"
                })
            end
        end)
    })

end
