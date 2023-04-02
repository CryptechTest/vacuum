

minetest.register_abm({
	label = "airpump",
	nodenames = {"vacuum:airpump", "vacuum:airpump_wait", "vacuum:airpump_active"},
	interval = 5,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		if vacuum.airpump_enabled(meta) then

			local eu_input = meta:get_int("LV".."_EU_input")
			local powered = eu_input >= 100
			if not powered then
				return
			end

			-- The spacesuit mod must be loaded after this mod, so we can't check at the start.
			local has_spacesuit = minetest.get_modpath("spacesuit")
			local used
			local used_type = 0;
			if vacuum.is_pos_in_space(pos) then
				used = vacuum.do_empty_bottle(meta:get_inventory())
				used_type = 1
				if used and has_spacesuit then
					vacuum.do_repair_spacesuit(meta:get_inventory())
					used_type = 3
				end
			else
				if has_spacesuit then
					used = vacuum.do_repair_spacesuit(meta:get_inventory())
					used_type = 3
				end
				if not used then
					used = vacuum.do_fill_bottle(meta:get_inventory())
					used_type = 2
				end
			end

			if used then
				
				technic.swap_node(pos, "vacuum:airpump")
				
				if used_type == 1 then
					minetest.sound_play("vacuum_hiss", {pos = pos, gain = 0.5})
				elseif used_type == 2 then
					minetest.sound_play("vacuum_hiss_2", {pos = pos, gain = 0.5})
				elseif used_type == 3 then
					minetest.sound_play("vacuum_hiss_3", {pos = pos, gain = 0.5})
				elseif used_type == 4 then
					minetest.sound_play("vacuum_hiss_4", {pos = pos, gain = 0.5})
				end

				minetest.add_particlespawner({
					amount = 12,
					time = 4,
					minpos = vector.subtract(pos, 0.95),
					maxpos = vector.add(pos, 0.95),
					minvel = {x=-1.2, y=-1.2, z=-1.2},
					maxvel = {x=1.2, y=1.2, z=1.2},
					minacc = {x=0, y=0, z=0},
					maxacc = {x=0, y=0, z=0},
					minexptime = 0.5,
					maxexptime = 1,
					minsize = 1,
					maxsize = 2,
					vertical = false,
					texture = "bubble.png"
				})
			end
		end
	end
})


local function flush_area(pos)
	local range = {x=2,y=1,z=2}
	local pos1 = vector.subtract(pos, range)
	local pos2 = vector.add(pos, range)

	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
	local data = manip:get_data()

	for z=pos1.y, pos2.y do
	for y=pos1.z, pos2.z do
	for x=pos1.x, pos2.x do

		local index = area:index(x, y, z)
		--if data[index] == c_vacuum or data[index] == c_atmos or data[index] == c_air or data[index] == c_aer then
		if data[index] == c_vacuum then
			data[index] = c_aer
		--elseif data[index] == c_atmos
		--	data[index] = c_aeri
		elseif data[index] == c_aer then
			data[index] = c_aeri
		elseif data[index] == c_air then
			data[index] = c_aeri
		end

	end
	end
	end

	manip:set_data(data)
	manip:write_to_map()
end


-- initial airpump step
minetest.register_abm({
	label = "airpump seed",
	nodenames = {"vacuum:airpump", "vacuum:airpump_wait", "vacuum:airpump_active"},
	neighbors = {"vacuum:vacuum", "asteroid:atmos", "group:atmosphere"},
	--interval = 0.7,
	interval = 1,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		if vacuum.airpump_active(meta) then

			local eu_input = meta:get_int("LV".."_EU_input")
			local powered = eu_input >= 100
			if not powered then
				return
			end

			-- seed initial air
			--local count = 0;
			for j = 1, 7 do
				local count = 0;
				local sz = j
				local pos1 = vector.subtract(pos, {x=sz, y=sz, z=sz})
				local pos2 = vector.add(pos, {x=sz, y=sz, z=sz})

				local nodes = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:vacuum" })
				local nodes_thin = minetest.find_nodes_in_area(pos1, pos2, {"vacuum:atmos_thin", })

				for i, node in ipairs(nodes_thin) do
					if node ~= nil then						
						if (vacuum.has_in_range(pos, "vacuum:atmos_thin", 1, 7)) then
							minetest.set_node(node, {name = "vacuum:atmos_thick"})
						end
					end
				end

				for i, node in ipairs(nodes) do
					if node ~= nil then
						count = count + 1
						
						if (vacuum.has_in_range(pos, "vacuum:atmos_thin", 1, 8)) then
							minetest.set_node(node, {name = "vacuum:atmos_thin"})
							--vacuum.replace_nodes_at(pos, j, node.name, "vacuum:atmos_thick")
						end
						
						--flush_area(node)

						--flush_area({x=node.x, y=node.y, z=node.z}) -- doesn't work..
						if (math.random(0, 500) == 0) then
							minetest.sound_play("vacuum_hiss_4", {pos = pos, gain = 0.3})
						end
						--if (vacuum.has_in_range(pos, "vacuum:atmos_thin", 2, 3)) then
						--	if (node.name == "vacuum:atmos_thin") then
						--		minetest.set_node(node, {name = "vacuum:atmos_thick"})
						--		vacuum.replace_nodes_at(pos, 2, node.name, "vacuum:atmos_thick")
						--	else
						--		minetest.set_node(node, {name = "vacuum:atmos_thin"})
						--		vacuum.replace_nodes_at(pos, 2, node.name, "vacuum:atmos_thin")
						--	end
						--end
					end
				end
				if (count > 0 and #nodes > 0) then
					if count / #nodes  > 0.9 then
						--return
					end
					if count / #nodes  > 0.8 and j > 3 then
						return
					end
				end
			end
		end
	end
})
