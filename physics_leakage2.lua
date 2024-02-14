local has_monitoring = minetest.get_modpath("monitoring")
local has_mesecons_random = minetest.get_modpath("mesecons_random")
local has_technic = minetest.get_modpath("technic")

local metric_space_vacuum_leak_abm

if has_monitoring then
    metric_space_vacuum_leak_abm = monitoring.counter("vacuum_abm_leak_count", "number of space vacuum leak abm calls")
end

-- air leaking nodes
local leaky_nodes = {"group:pipe", "group:tube"}

if has_mesecons_random then
    table.insert(leaky_nodes, "mesecons_random:ghoststone_active")
end

if has_technic then
    table.insert(leaky_nodes, "technic:lv_cable")
    table.insert(leaky_nodes, "technic:mv_cable")
    table.insert(leaky_nodes, "technic:hv_cable")
end

function register_physics_leakage2(height)

    -- depressurize through leaky nodes
    minetest.register_abm({
        label = "air vacuum depressurize",
        nodenames = leaky_nodes,
        neighbors = {"air", "vacuum:atmos_thick"},
        interval = 5,
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
                        name = "air"
                    })
                end
            end

            -- on ground: replace vacuum with atmos_thin
            local surrounding_node = minetest.find_node_near(pos, 9, {"vacuum:vacuum"})

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
                        name = "air"
                    })
                end
            end
        end)
    })

    -- depressurize through door nodes
    minetest.register_abm({
        label = "air space vacuum depressurize",
        nodenames = "group:door",
        neighbors = {"air", "vacuum:atmos_thick"},
        interval = 1,
        chance = 2,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(250, function(pos, node)
            if metric_space_vacuum_leak_abm ~= nil then
                metric_space_vacuum_leak_abm.inc()
            end

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            -- local node = minetest.get_node(pos)

            local door = minetest.get_item_group(node.name, "door")

            -- in space: replace air with atmos_thin
            local surrounding_vac = minetest.find_node_near(pos, 1, {"air"})
            local surrounding_atmos = minetest.find_node_near(pos, 1, {"vacuum:atmos_thin"})

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
                    name = "air"
                })
            elseif surrounding_vac ~= nil and surrounding_vac ~= nil and door == 2 then
                minetest.set_node(surrounding_atmos, {
                    name = "vacuum:atmos_thick"
                })
            end
        end)
    })

end
