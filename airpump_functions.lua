-- common airpump functions
vacuum.has_full_air_bottle = function(inv)
    return inv:contains_item("main", {
        name = "vacuum:air_bottle",
        count = 1
    })
end

vacuum.has_empty_air_bottle = function(inv)
    return inv:contains_item("main", {
        name = "vessels:steel_bottle",
        count = 1
    })
end

vacuum.do_empty_bottle = function(inv)
    if not vacuum.has_full_air_bottle(inv) then
        return false
    end

    local new_stack = ItemStack("vessels:steel_bottle")
    inv:remove_item("main", {
        name = "vacuum:air_bottle",
        count = 1
    })

    if inv:room_for_item("main", new_stack) then
        inv:add_item("main", new_stack)
        return true
    end

    return false
end

vacuum.do_fill_bottle = function(inv)
    if not vacuum.has_empty_air_bottle(inv) then
        return false
    end

    local new_stack = ItemStack("vacuum:air_bottle")
    inv:remove_item("main", {
        name = "vessels:steel_bottle",
        count = 1
    })

    if inv:room_for_item("main", new_stack) then
        inv:add_item("main", new_stack)
        return true
    end

    return false
end

vacuum.do_repair_spacesuit = function(inv)
    for i = 1, inv:get_size("main") do
        local stack = inv:get_stack("main", i)
        local item_def = minetest.registered_items[stack:get_name()]
        if item_def and item_def.wear_represents == "spacesuit_wear" and stack:get_wear() > 0 then
            stack:set_wear(0)
            inv:set_stack("main", i, stack)
            return true
        end
    end
    return false
end

-- just enabled
vacuum.airpump_enabled = function(meta)
    return meta:get_int("enabled") == 1
end

-- powered
vacuum.airpump_powered = function(meta)
    local eu_input = meta:get_int("LV" .. "_EU_input")
    local powered = eu_input > 0
    if powered then
        return true
    end
    return false
end

-- enabled and actively pumping
vacuum.airpump_active = function(meta)
    local inv = meta:get_inventory()
    return vacuum.airpump_enabled(meta) and vacuum.has_full_air_bottle(inv) and vacuum.airpump_powered(meta)
end

vacuum.can_flush_airpump = function(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    return inv:contains_item("main", {
        name = "vacuum:air_bottle",
        count = vacuum.flush_bottle_usage
    })
end

local c_vacuum = minetest.get_content_id("vacuum:vacuum")
local c_atmos = minetest.get_content_id("asteroid:atmos")
local c_aeri = minetest.get_content_id("vacuum:atmos_thick") -- thick atmos
local c_aer = minetest.get_content_id("vacuum:atmos_thin") -- thin atmos
local c_air = minetest.get_content_id("air")

-- flushes the room of the airpump with air
vacuum.flush_airpump = function(pos)
    minetest.sound_play("vacuum_hiss", {
        pos = pos,
        gain = 0.5
    })

    local total = 0
    for z = 2, 8 do
        local range = {
            x = z,
            y = z,
            z = z
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

        for z = pos1.z, pos2.z do
            for y = pos1.y, pos2.y do
                for x = pos1.x, pos2.x do

                    if count / #data > 0.8 then
                        break
                    end

                    local index = area:index(x, y, z)
                    if data[index] == c_vacuum or data[index] == c_atmos or data[index] == c_aer or data[index] == c_aeri then
                        data[index] = c_air
                        count = count + 1
                    end

                end
            end
        end

        total = total + count

        if (total > 500) then
            break
        end

        manip:set_data(data)
        manip:write_to_map()

        if (count > 256) then
            break
        end
    end

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:remove_item("main", {
        name = "vacuum:air_bottle",
        count = vacuum.flush_bottle_usage
    })
    inv:add_item("main", ItemStack("vessels:steel_bottle " .. vacuum.flush_bottle_usage))
end
