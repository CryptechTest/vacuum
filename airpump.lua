local has_pipeworks = minetest.get_modpath("pipeworks")

local tube_entry = ""

if has_pipeworks then
    tube_entry = "^pipeworks_tube_connection_metallic.png"
end

local connect_default = {"bottom", "back", "left", "right"}

local function round(v)
    return math.floor(v + 0.5)
end

local update_infotext = function(meta)
    local str = "Airpump: "

    if vacuum.airpump_enabled(meta) then
        str = str .. " (Enabled)"
    else
        str = str .. " (Disabled)"
    end

    meta:set_string("infotext", str)
end

-- update airpump formspec
local update_formspec = function(meta)
    local btnName = "State: "

    if meta:get_int("enabled") == 1 then
        btnName = btnName .. "<Enabled>"
    else
        btnName = btnName .. "<Disabled>"
    end

    meta:set_string("formspec",
        "size[8,7.2;]" .. "image[3,0;1,1;" .. vacuum.air_bottle_image .. "]" ..
            "image[4,0;1,1;vessels_steel_bottle.png]" .. "button[0,1;4,1;toggle;" .. btnName .. "]" ..
            "button[4,1;4,1;flush;Flush room]" .. "list[context;main;0,2;8,1;]" ..
            "list[current_player;main;0,3.2;8,4;]" .. "listring[]" .. "")

    update_infotext(meta)

end

local S = technic.getter
local tier = "LV"

local run = function(pos, node)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local eu_input = meta:get_int(tier .. "_EU_input")

    local machine_desc = S("%s Air Pump")
    local machine_desc_tier = machine_desc:format(tier)
    local machine_node = "vacuum:airpump"
    local machine_demand = 100

    -- Setup meta data if it does not exist.
    if not eu_input then
        meta:set_int(tier .. "_EU_demand", machine_demand)
        meta:set_int(tier .. "_EU_input", 0)
        return
    end

    local time = 20
    local speed = 2
    local EU_upgrade = 0
    local powered = eu_input >= machine_demand
    if powered then
        meta:set_int("src_time", meta:get_int("src_time") + round(speed * 10 * 1.0))
    end
    while true do
        if not vacuum.airpump_enabled(meta) then
            technic.swap_node(pos, machine_node)
            meta:set_string("infotext", machine_desc_tier .. S(" Idle"))
            meta:set_int(tier .. "_EU_demand", 0)
            meta:set_int("src_time", 0)
            return
        end
        if vacuum.is_pos_in_space(pos) then
            if not vacuum.has_full_air_bottle(meta:get_inventory()) then
                technic.swap_node(pos, machine_node)
                meta:set_string("infotext", machine_desc_tier .. S(" Idle"))
                meta:set_int(tier .. "_EU_demand", 0)
                meta:set_int("src_time", 0)
                return;
            end
        else
            if not vacuum.has_empty_air_bottle(meta:get_inventory()) then
                technic.swap_node(pos, machine_node)
                meta:set_string("infotext", machine_desc_tier .. S(" Idle"))
                meta:set_int(tier .. "_EU_demand", 0)
                meta:set_int("src_time", 0)
                return;
            end
        end

        meta:set_int(tier .. "_EU_demand", machine_demand)
        if (math.random(1, 3) > 1) then
            technic.swap_node(pos, machine_node .. "_wait")
        end
        meta:set_string("infotext", machine_desc_tier .. S(" Active"))
        if meta:get_int("src_time") < round(time * 10) then
            if not powered then
                technic.swap_node(pos, machine_node)
                meta:set_string("infotext", machine_desc_tier .. S("%s Unpowered"))
            end
            return
        end
        technic.swap_node(pos, machine_node .. "_active")
        meta:set_int("src_time", meta:get_int("src_time") - round(time * 10))
    end
end

minetest.register_node("vacuum:airpump", {
    description = "Air pump",
    tiles = {"vacuum_airpump_top.png", "vacuum_airpump_side.png" .. tube_entry, "vacuum_airpump_side.png" .. tube_entry,
             "vacuum_airpump_side.png" .. tube_entry, "vacuum_airpump_side.png" .. tube_entry,
             "vacuum_airpump_front.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    legacy_facedir_simple = true,
    groups = {
        cracky = 2,
        oddly_breakable_by_hand = 3,
        tubedevice = 1,
        tubedevice_receiver = 1,
        technic_machine = 1,
        ["technic_" .. 'lv'] = 1
    },
    sounds = default.node_sound_glass_defaults(),
    technic_run = run,
    technic_disabled_machine_name = "vacuum:airpump",
    after_dig_node = technic.machine_after_dig_node,

    mesecons = {
        effector = {
            action_on = function(pos, node)
                local meta = minetest.get_meta(pos)
                meta:set_int("enabled", 1)
                update_infotext(meta)
            end,
            action_off = function(pos, node)
                local meta = minetest.get_meta(pos)
                meta:set_int("enabled", 0)
                update_infotext(meta)
            end
        }
    },

    digiline = {
        receptor = {
            action = function()
            end
        },
        effector = {
            action = vacuum.airpump_digiline_effector
        }
    },

    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        meta:set_string("owner", placer:get_player_name() or "")
    end,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("enabled", 0)
        meta:set_int("tube_time", 0)

        local inv = meta:get_inventory()
        inv:set_size("main", 8)

        update_formspec(meta)
    end,

    can_dig = function(pos, player)
        if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
            -- protected
            return false
        end

        local meta = minetest.get_meta(pos);
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
            -- protected
            return 0
        end

        return stack:get_count()
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if player and player:is_player() and minetest.is_protected(pos, player:get_player_name()) then
            -- protected
            return 0
        end

        return stack:get_count()
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)

        if minetest.is_protected(pos, sender:get_player_name()) then
            -- not allowed
            return
        end

        if fields.flush then
            if not vacuum.airpump_powered(meta) then
                minetest.chat_send_player(sender:get_player_name(), "[airpump] Flush mode needs more power!")
            elseif not vacuum.can_flush_airpump(pos) then
                minetest.chat_send_player(sender:get_player_name(), "[airpump] Flush mode needs " ..
                    vacuum.flush_bottle_usage .. " full air bottles, aborting!")
            else
                vacuum.flush_airpump(pos)
            end
        end

        if fields.toggle then
            if meta:get_int("enabled") == 1 then
                meta:set_int("enabled", 0)
            else
                meta:set_int("enabled", 1)
            end
        end

        update_formspec(meta)
    end,

    tube = {
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return inv:add_item("main", stack)
        end,
        can_insert = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            stack = stack:peek_item(1)
            return inv:room_for_item("main", stack)
        end,
        input_inventory = "main",
        connect_sides = {
            left = 1,
            right = 1,
            back = 1,
            bottom = 1
        }
        -- connect_sides = connect_default
    }

})

minetest.register_node("vacuum:airpump_wait", {
    description = "Air pump",
    tiles = {"vacuum_airpump_top.png", "vacuum_airpump_side.png" .. tube_entry, "vacuum_airpump_side.png" .. tube_entry,
             "vacuum_airpump_side.png" .. tube_entry, "vacuum_airpump_side.png" .. tube_entry,
             "vacuum_airpump_front_wait.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    legacy_facedir_simple = true,
    groups = {
        cracky = 2,
        oddly_breakable_by_hand = 3,
        tubedevice = 1,
        tubedevice_receiver = 1,
        technic_machine = 1,
        ["technic_" .. 'lv'] = 1,
        not_in_creative_inventory = 1
    },
    sounds = default.node_sound_glass_defaults(),
    technic_run = run,
    technic_disabled_machine_name = "vacuum:airpump",
    after_place_node = function(pos, placer, itemstack, pointed_thing)

    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        return technic.machine_after_dig_node
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)

        if minetest.is_protected(pos, sender:get_player_name()) then
            -- not allowed
            return
        end

        if fields.flush then
            if not vacuum.airpump_powered(meta) then
                minetest.chat_send_player(sender:get_player_name(), "[airpump] Flush mode needs more power!")
            elseif not vacuum.can_flush_airpump(pos) then
                minetest.chat_send_player(sender:get_player_name(), "[airpump] Flush mode needs " ..
                    vacuum.flush_bottle_usage .. " full air bottles, aborting!")
            else
                vacuum.flush_airpump(pos)
            end
        end

        if fields.toggle then
            if meta:get_int("enabled") == 1 then
                meta:set_int("enabled", 0)
            else
                meta:set_int("enabled", 1)
            end
        end

        update_formspec(meta)
    end
})

minetest.register_node("vacuum:airpump_active", {
    description = "Air pump",
    tiles = {"vacuum_airpump_top.png", "vacuum_airpump_side.png" .. tube_entry, "vacuum_airpump_side.png" .. tube_entry,
             "vacuum_airpump_side.png" .. tube_entry, "vacuum_airpump_side.png" .. tube_entry,
             "vacuum_airpump_front_active.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    legacy_facedir_simple = true,
    groups = {
        cracky = 2,
        oddly_breakable_by_hand = 3,
        tubedevice = 1,
        tubedevice_receiver = 1,
        technic_machine = 1,
        ["technic_" .. 'lv'] = 1,
        not_in_creative_inventory = 1
    },
    sounds = default.node_sound_glass_defaults(),
    technic_run = run,
    technic_disabled_machine_name = "vacuum:airpump",
    after_place_node = function(pos, placer, itemstack, pointed_thing)

    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        return technic.machine_after_dig_node
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)

        if minetest.is_protected(pos, sender:get_player_name()) then
            -- not allowed
            return
        end

        if fields.flush then
            if not vacuum.airpump_powered(meta) then
                minetest.chat_send_player(sender:get_player_name(), "[airpump] Flush mode needs more power!")
            elseif not vacuum.can_flush_airpump(pos) then
                minetest.chat_send_player(sender:get_player_name(), "[airpump] Flush mode needs " ..
                    vacuum.flush_bottle_usage .. " full air bottles, aborting!")
            else
                vacuum.flush_airpump(pos)
            end
        end

        if fields.toggle then
            if meta:get_int("enabled") == 1 then
                meta:set_int("enabled", 0)
            else
                meta:set_int("enabled", 1)
            end
        end

        update_formspec(meta)
    end
})

minetest.register_craft({
    output = "vacuum:airpump",
    recipe = {{"default:steel_ingot", "default:mese_block", "default:steel_ingot"},
              {"default:diamond", "default:glass", "basic_materials:motor"},
              {"default:steel_ingot", "default:steelblock", "basic_materials:gold_wire"}}
})

technic.register_machine("LV", "vacuum:airpump", technic.receiver)
technic.register_machine("LV", "vacuum:airpump_wait", technic.receiver)
technic.register_machine("LV", "vacuum:airpump_active", technic.receiver)
