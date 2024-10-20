vacuum = {
    -- space_height = tonumber(minetest.settings:get("vacuum.space_height")) or 1000,
    vac_heights = {
        space = {
            enabled = true,
            end_height = tonumber(minetest.settings:get("vacuum.vac_heights.space.end_height")) or 31000,
            start_height = tonumber(minetest.settings:get("vacuum.vac_heights.space.start_height")) or 4000
        },
        atmos = {
            enabled = false,
            end_height = tonumber(minetest.settings:get("vacuum.vac_heights.atmos.end_height")) or 4000,
            start_height = tonumber(minetest.settings:get("vacuum.vac_heights.atmos.start_height")) or 2000
        },
        buffer = {
            enabled = true,
            end_height = tonumber(minetest.settings:get("vacuum.vac_heights.buffer.end_height")) or -11000,
            start_height = tonumber(minetest.settings:get("vacuum.vac_heights.buffer.start_height")) or -21000
        },
        void = {
            enabled = true,
            end_height = tonumber(minetest.settings:get("vacuum.vac_heights.void.end_height")) or -21000,
            start_height = tonumber(minetest.settings:get("vacuum.vac_heights.void.start_height")) or -31000
        }
    },
    air_heights = {
        planet = {
            enabled = true,
            end_height = tonumber(minetest.settings:get("vacuum.vac_heights.planet.end_height")) or 1000,
            start_height = tonumber(minetest.settings:get("vacuum.vac_heights.planet.start_height")) or -11000
        }
    },
    air_pump_range = tonumber(minetest.settings:get("vacuum.air_pump_range")) or 5,
    profile_mapgen = minetest.settings:get("vacuum.profile_mapgen"),
    flush_bottle_usage = 99,
    debug = minetest.settings:get("vacuum.debug"),
    disable_physics = minetest.settings:get("vacuum.disable_physics"),
    disable_mapgen = minetest.settings:get("vacuum.disable_mapgen")
}

local MP = minetest.get_modpath("vacuum")

if minetest.get_modpath("digilines") then
    dofile(MP .. "/digilines.lua")
end

dofile(MP .. "/util/throttle.lua")
dofile(MP .. "/vacuum.lua")
dofile(MP .. "/common.lua")
dofile(MP .. "/compat.lua")
dofile(MP .. "/airbottle.lua")
dofile(MP .. "/airpump_functions.lua")
dofile(MP .. "/airpump.lua")
dofile(MP .. "/airpump_abm.lua")
dofile(MP .. "/dignode.lua")

if not vacuum.disable_mapgen then
    dofile(MP .. "/mapgen.lua")
end

if not vacuum.disable_physics then
    dofile(MP .. "/physics_drop.lua")
    dofile(MP .. "/physics_leakage.lua")
    dofile(MP .. "/physics_leakage_air.lua")
    dofile(MP .. "/physics_plants.lua")
    dofile(MP .. "/physics_propagation.lua")
    dofile(MP .. "/physics_propagation_air.lua")
    dofile(MP .. "/physics_soil.lua")
    dofile(MP .. "/physics_sublimation.lua")

    for i, height in pairs(vacuum.vac_heights) do
        if height.enabled then
            register_physics_drop(height)
            register_physics_leakage(height)
            register_physics_plants(height)
            register_physics_propagation(height)
            register_physics_soil(height)
            register_physics_sublimation(height)
            minetest.log("action",
                "[vacuum] " .. "Registered Vacuum ABM on nodes at " .. height.start_height .. " to " ..
                    height.end_height)
        end
    end

    for i, height in pairs(vacuum.air_heights) do
        if height.enabled then
            register_physics_drop(height)
            register_physics_leakage2(height)
            register_physics_plants(height)
            register_physics_propagation2(height)
            register_physics_soil(height)
            register_physics_sublimation(height)
            minetest.log("action", "[vacuum] " .. "Registered Air ABM on nodes at " .. height.start_height .. " to " ..
                height.end_height)
        end
    end
end

if minetest.get_modpath("spacesuit") then
    dofile(MP .. "/spacesuit.lua")
end

if minetest.get_modpath("advtrains") then
    dofile(MP .. "/advtrains.lua")
end

print("[OK] Vacuum")
