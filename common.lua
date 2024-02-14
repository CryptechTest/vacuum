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

local check_pos_in_spawn = function(pos)
    local spawn_spoint = minetest.setting_get_pos("static_spawnpoint") or {
        x = 0,
        y = 4500,
        z = 0
    }

    local in_x = false
    local in_y = false
    local in_z = false
    if (pos.x <= spawn_spoint.x + 200 and pos.x >= spawn_spoint.x - 200) then
        in_x = true
    end
    if (pos.y <= spawn_spoint.y + 200 and pos.y >= spawn_spoint.y - 200) then
        in_y = true
    end
    if (pos.x <= spawn_spoint.z + 200 and pos.z >= spawn_spoint.z - 200) then
        in_z = true
    end
    return in_x and in_y and in_z
end

vacuum.is_pos_in_spawn = function(pos)
    return check_pos_in_spawn(pos)
end

-- returns true if the position is near a powered air pump
function vacuum.near_powered_airpump(pos, range)
    if range == nil then
        range = vacuum.air_pump_range
    end
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

function vacuum.near_air(pos, dist, c)
    local pos1 = vector.subtract(pos, {
        x = dist,
        y = dist,
        z = dist
    })
    local pos2 = vector.add(pos, {
        x = dist,
        y = dist,
        z = dist
    })

    local count = 0
    local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:atmos_thick"})
    for _, node in ipairs(nodes) do
        count = count + 1
    end

    return count >= c
end

function vacuum.near_vacuum(pos, dist, c)
    local pos1 = vector.subtract(pos, {
        x = dist,
        y = dist,
        z = dist
    })
    local pos2 = vector.add(pos, {
        x = dist,
        y = dist,
        z = dist
    })

    local count = 0
    local nodes = minetest.find_nodes_in_area(pos1, pos2, {"group:vacuum"})
    for _, node in ipairs(nodes) do
        count = count + 1
    end

    return count >= c
end

function vacuum.has_in_area(p, c_name, rng, thres)
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

    local manip = minetest.get_voxel_manip()
    local e1, e2 = manip:read_from_map(pos1, pos2)
    local area = VoxelArea:new({
        MinEdge = e1,
        MaxEdge = e2
    })
    local data = manip:get_data()

    local count = 0
    local total = 0

    local c_n = minetest.get_content_id(c_name)

    for y = pos1.y, pos2.y do
        for z = pos1.z, pos2.z do
            for x = pos1.x, pos2.x do
                local index = area:index(x, y, z)
                -- if data[index] == c_vacuum or data[index] == c_atmos or data[index] == c_air or data[index] == c_aer then
                -- if data[index] == c_id then
                --[[if minetest.get_node({
                        x = x,
                        y = y,
                        z = z
                    }).name == c_name then
                    count = count + 1
                end--]]

                if data[index] == c_n then
                    count = count + 1
                end
                total = total + 1
            end
        end
    end

    if total > 0 then
        local res = count >= thres
        -- minetest.log("Has " .. count .. " for " .. c_name .. "  Has: " .. tostring(res))
        return res
    end
    return false
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

-- get nodes in area
function vacuum.get_area_nodes(p, dist)
    local pos = {
        x = p.x,
        y = p.y,
        z = p.z
    }
    local range = {
        x = dist,
        y = dist,
        z = dist
    }
    local pos1 = vector.subtract(pos, range)
    local pos2 = vector.add(pos, range)
    -- get voxel area manip
    local manip = minetest.get_voxel_manip()
    local e1, e2 = manip:read_from_map(pos1, pos2)
    local area = VoxelArea:new({
        MinEdge = e1,
        MaxEdge = e2
    })
    return pos1, pos2, area, manip:get_data();
end

function vacuum.has_in_area_data(pos1, pos2, area, data, c_name, thres)
    local count = 0
    local total = 0
    local c_n = minetest.get_content_id(c_name)

    for y = pos1.y, pos2.y do
        for z = pos1.z, pos2.z do
            for x = pos1.x, pos2.x do
                local index = area:index(x, y, z)
                if data[index] == c_n then
                    count = count + 1
                end
                total = total + 1
            end
        end
    end

    if total > 0 then
        local result = count >= thres
        -- minetest.log("Has " .. count .. " for " .. c_name .. "  Has: " .. tostring(res))
        return result
    end
    return false
end

function vacuum.spawn_particle(pos, dir_x, dir_y, dir_z, acl_x, acl_y, acl_z, lvl, time)
    local texture = "vacuum_air_particle_1.png"
    if (math.random() > 0.5) then
        texture = "vacuum_air_particle_1.png^[transformR90]"
    end
    if (math.random() > 0.5) then
        texture = texture .. "^[colorize:#4aebf7:10"
    end
    local prt = {
        texture = texture,
        vel = 1,
        time = time or 6,
        size = 3 + (lvl or 1),
        glow = 3,
        cols = true
    }

    local v = vector.new()
    v.x = 0.0001
    v.y = 0.001
    v.z = 0.0001
    if math.random(1, 10) > 1 then
        local rx = dir_x * prt.vel * -math.random(0.3 * 100, 0.7 * 100) / 100
        local ry = dir_y * prt.vel * -math.random(0.3 * 100, 0.6 * 100) / 100
        local rz = dir_z * prt.vel * -math.random(0.3 * 100, 0.7 * 100) / 100
        minetest.add_particle({
            pos = pos,
            velocity = vector.add(v, {
                x = rx,
                y = ry,
                z = rz
            }),
            acceleration = {
                x = acl_x,
                y = acl_y + math.random(-0.008, 0.0001),
                z = acl_z
            },
            expirationtime = ((math.random() / 5) + 0.2) * prt.time,
            size = ((math.random(0.65, 0.90)) * 2 + 0.1) * prt.size,
            collisiondetection = prt.cols,
            vertical = false,
            texture = prt.texture,
            glow = prt.glow
        })
    end
end
