vacuum.air_bottle_image = "vessels_steel_bottle.png^[colorize:#0028FF90^bottle_top.png"

local c_vacuum = minetest.get_content_id("vacuum:vacuum")
local c_atmos = minetest.get_content_id("asteroid:atmos")
local c_aeri = minetest.get_content_id("vacuum:atmos_thick")
local c_aer = minetest.get_content_id("vacuum:atmos_thin")
local c_air = minetest.get_content_id("air")

-- space pos checker
local check_pos_in_space = function(pos)
    for _, p in pairs(vacuum.vac_heights) do
        if p.enabled then
            local min = p.start_height
            local max = p.end_height
            if pos.y >= min and pos.y < max then
                return true
            end
        end
    end
    return false
end

vacuum.is_pos_in_space = function(pos)
    return check_pos_in_space(pos)
end

-- returns true if the position is near a powered air pump
function vacuum.near_powered_airpump(pos)
    return near_powered_airpump(pos, vacuum.air_pump_range)
end

function vacuum.near_powered_airpump(pos, range)
    local pos1 = vector.subtract(pos, {
        x = range,
        y = range,
        z = range
    })
    local pos2 = vector.add(pos, {
        x = range,
        y = range,
        z = range
    })

    local nodes = minetest.find_nodes_in_area(pos1, pos2,
        {"vacuum:airpump", "vacuum:airpump_wait", "vacuum:airpump_active"})
    for _, node in ipairs(nodes) do
        local meta = minetest.get_meta(node)
        if vacuum.airpump_active(meta) then
            return true
        end
    end

    return false
end

function vacuum.near_aeri(pos, c)
    local pos1 = vector.subtract(pos, {
        x = 1,
        y = 1,
        z = 1
    })
    local pos2 = vector.add(pos, {
        x = 1,
        y = 1,
        z = 1
    })

    local count = 0;
    -- local nodes = minetest.find_nodes_in_area(pos1, pos2, {"group:atmosphere"})
    local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:atmos_thick"})
    for _, node in ipairs(nodes) do
        count = count + 1
    end

    return count >= c
end

function vacuum.near_atmos(pos, c)
    local pos1 = vector.subtract(pos, {
        x = 1,
        y = 1,
        z = 1
    })
    local pos2 = vector.add(pos, {
        x = 1,
        y = 1,
        z = 1
    })

    local count = 0;
    local nodes = minetest.find_nodes_in_area(pos1, pos2, {"group:atmosphere"})
    -- local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:atmos_thick"})
    for _, node in ipairs(nodes) do
        count = count + 1
    end

    return count >= c
end

function vacuum.near_air(pos, c)
    local pos1 = vector.subtract(pos, {
        x = 1,
        y = 1,
        z = 1
    })
    local pos2 = vector.add(pos, {
        x = 1,
        y = 1,
        z = 1
    })

    local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:atmos_thick"})
    for _, node in ipairs(nodes) do
        count = count + 1
    end

    return count >= c
end

function vacuum.near_vacuum(pos, dist)
    local pos1 = vector.subtract(pos, {
        x = 1,
        y = 1,
        z = 1
    })
    local pos2 = vector.add(pos, {
        x = 1,
        y = 1,
        z = 1
    })

    local nodes = minetest.find_nodes_in_area(pos1, pos2, {"group:vacuum"})
    for _, node in ipairs(nodes) do
        count = count + 1
    end

    return count >= c
end

function vacuum.has_in_area(p, c_name, thres)
    local pos = {
        x = p.x,
        y = p.y,
        z = p.z
    }
    local range = {
        x = 2,
        y = 1,
        z = 2
    }
    local pos1 = vector.subtract(pos, range)
    local pos2 = vector.add(pos, range)

    local manip = minetest.get_voxel_manip()
    local e1, e2 = manip:read_from_map(pos1, pos2)
    local area = VoxelArea:new({
        MinEdge = e1,
        MaxEdge = e2
    })
    local data = manip:get_data()

    local count = 0
    local total = 0

    for z = pos1.y, pos2.y do
        for y = pos1.z, pos2.z do
            for x = pos1.x, pos2.x do

                local index = area:index(x, y, z)
                -- if data[index] == c_vacuum or data[index] == c_atmos or data[index] == c_air or data[index] == c_aer then
                -- if data[index] == c_id then
                if mintest.get_node({
                    x = x,
                    y = y,
                    z = z
                }).name == c_name then
                    count = count + 1
                end
                total = count + 1

            end
        end
    end

    if count > 0 then
        return (count / total) <= thres
    end
    return count > 0
end

function vacuum.has_in_range(p, c_name, rng, thres)
    local pos = {
        x = p.x,
        y = p.y,
        z = p.z
    }
    local range = {
        x = rng,
        y = rng,
        z = rng
    }
    local pos1 = vector.subtract(pos, range)
    local pos2 = vector.add(pos, range)

    local nodes = minetest.find_nodes_in_area(pos1, pos2, {c_name})
    return #nodes >= thres

end

function vacuum.replace_nodes_at(p, rad, c_name, c_replace)
    local pos = {
        x = p.x,
        y = p.y,
        z = p.z
    }

    local range = {
        x = rad,
        y = rad + 1,
        z = rad
    }
    local pos1 = vector.subtract(pos, range)
    local pos2 = vector.add(pos, range)

    local nodes = minetest.find_nodes_in_area(pos1, pos2, {c_name})

    for _, node in ipairs(nodes) do
        minetest.set_node(node, {
            name = c_replace
        })
        -- vacuum.replace_nodes_at(noce, rad - 1, c_name, c_replace)
    end

end
