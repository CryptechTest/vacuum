-- weird behaving nodes in vacuum
local drop_nodes = {"default:torch", "default:torch_wall", "default:torch_ceiling", "default:ladder_wood",
                    "default:dry_shrub", "default:papyrus", "default:cactus", "group:wool", "group:pillow",
                    "group:wood", "group:tree"}

local function get_node_drops(node)
    if node.name == "default:papyrus" then
        if math.random(3) == 1 then
            return {"default:paper"}
        end
        return {}
    end
    return minetest.get_node_drops(node)
end

function register_physics_drop(height)

    -- weird nodes in vacuum
    minetest.register_abm({
        label = "space drop nodes",
        nodenames = drop_nodes,
        neighbors = {"vacuum:vacuum"},
        interval = 1,
        chance = 1,
        max_y = height.end_height,
        min_y = height.start_height,
        action = vacuum.throttle(100, function(pos, node)

            if vacuum.is_pos_in_spawn(pos) then
                return
            end

            if not vacuum.is_pos_in_space(pos) or vacuum.near_powered_airpump(pos, 3) then
                return
            end

            -- local node = minetest.get_node(pos)
            -- minetest.set_node(pos, {name = "vacuum:vacuum"})
            minetest.set_node(pos, {
                name = "vacuum:atmos_thin"
            })

            for _, drop in pairs(get_node_drops(node)) do
                minetest.add_item(pos, ItemStack(drop))
            end
        end)
    })

end
