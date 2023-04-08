-- sublimate nodes in vacuum
minetest.register_abm({
    label = "space vacuum sublimate",
    nodenames = {"group:snowy", "group:leaves", "group:water"},
    neighbors = {"vacuum:vacuum"},
    interval = 1,
    chance = 1,
    min_y = vacuum.space_height,
    action = vacuum.throttle(100, function(pos)
        if not vacuum.is_pos_in_space(pos) or vacuum.near_powered_airpump(pos) then
            return
        end

        if (not vacuum.near_atmos(pos, 26)) and (not vacuum.near_air(pos, 25)) then
            -- minetest.set_node(pos, {name = "vacuum:vacuum"})
            -- minetest.set_node(pos, {name = "asteroid:atmos"})
            minetest.set_node(pos, {
                name = "vacuum:atmos_thin"
            })
        end
    end)
})
