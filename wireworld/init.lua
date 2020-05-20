wireworld = {}

local wireworld_nodes = {}

local contains = function(t, pos)
	for _,v in ipairs(t) do
		if vector.equals(v, pos) then
			return true
		end
	end
	return false
end

function wireworld.in_circuit(pos)
	for _,v in ipairs(wireworld_nodes) do
		if vector.equals(v, pos) then
			return true
		end
	end
	return false
end

local check_stop = function(pos)
	for _,v in ipairs(minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworldstop"})) do
		local stop = minetest.get_meta(v):get_int("wireworld")
		if stop == 1 or stop == 3 then
			return true
		end
	end
	return false
end

function wireworld.circuit_add_node(pos, stopable)
	if stopable == nil then
		if minetest.get_item_group(minetest.get_node(pos).name, "wireworldstop") > 0 then
			stopable = true
		else
			stopable = false
		end
	end
	if stopable and check_stop(pos) then
		minetest.get_meta(pos):set_int("wireworld", 1)
	end
	if not contains(wireworld_nodes, pos) then
		local forceload = minetest.forceload_block(pos, true)
		table.insert(wireworld_nodes, pos)
		if not forceload then
			minetest.log("info", "wireworld could not foreceload "..minetest.pos_to_string(pos))
		end
	end
end

function wireworld.circuit_remove_node(pos)
	for i,v in ipairs(wireworld_nodes) do
		if vector.equals(pos, v) then
			minetest.forceload_free_block(v)
			table.remove(wireworld_nodes, i)
			return
		end
	end
end

function wireworld.after_place_node(pos, stopable)
	return wireworld.circuit_add_node(pos, stopable)
end

if (minetest.get_modpath("tnt")) then
	minetest.override_item("tnt:tnt", {
		groups = {dig_immediate = 2, mesecon = 2, tnt = 1, wireworld = 2},
		on_wireworld = function(pos)
			minetest.set_node(pos, {name = "tnt:tnt_burning"})
		end,
		on_construct = function(pos)
			wireworld.circuit_add_node(pos, false)
		end
	})
end

do
	local timer = 0
	local check = true
	local next = {}
	local speed = (minetest.settings:get("wireworld_generation_speed") or 14) / 200
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer >= speed then
			if check then
				check = false
				for i,v in ipairs(wireworld_nodes) do
					if minetest.get_meta(v):get_int("wireworld") == 0 then
						local node = minetest.get_node(v)
						local g = minetest.get_item_group(node.name, "wireworld")
						if g == 1 then
							next[#next+1] = v
						elseif g == 2 then
							local nodes = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldhead"})
							if #nodes == 1 or #nodes == 2 then
								next[#next+1] = v
							end
						elseif g == 3 then
							local nodes = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldhead"})
							if #nodes < 1 or #nodes > 2 then
								next[#next+1] = v
							end
						elseif g == 0 then
							minetest.forceload_free_block(v)
							table.remove(wireworld_nodes, i)
						end
					end
				end
			else
				check = true
				for _,v in ipairs(next) do
					if minetest.get_meta(v):get_int("wireworld") == 0 then
						local node = minetest.get_node(v)
						local node_def = minetest.registered_nodes[node.name]
						if node_def and node_def.on_wireworld then
							node_def.on_wireworld(v)
						end
					end
				end
				next = {}
			end
			timer = 0
		end
	end)
end

local recheck = {}

local remove = function(pos)
	for i,v in ipairs(recheck) do
		if vector.equals(v, pos) then
			table.remove(recheck, i)
			return
		end
	end
end

local load = function(pos)
	local insert = {}
	if not contains(wireworld_nodes, pos) then
		local ignore = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"ignore"})
		if ignore[1] then
			if not contains(recheck, pos) then
				table.insert(recheck, pos)
			end
			return
		end
		local nodes = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworld"})
		for _,v in ipairs(nodes) do
			if not contains(wireworld_nodes, v) then
				insert[#insert+1] = v
			end
		end
		for _,v in ipairs(nodes) do
			local ignore = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"ignore"})
			if ignore[1] then
				if not contains(recheck, pos) then
					table.insert(recheck, pos)
				end
				return
			end
			local find = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworld"})
			for _,v in ipairs(find) do
				if not contains(nodes, v) then
					if not contains(wireworld_nodes, v) then
						insert[#insert+1] = v
					end
					nodes[#nodes+1] = v
				end
			end
		end
	end
	remove(pos)
	for _,v in ipairs(insert) do
		local forceload = minetest.forceload_block(v, true)
		table.insert(wireworld_nodes, v)
		if not forceload then
			minetest.log("info", "wireworld could not foreceload "..minetest.pos_to_string(v))
		end
	end
end

minetest.register_lbm({
	name = "wireworld:index_nodes",
	nodenames = {"group:wireworld"},
	run_at_every_load = true,
	action = function(pos)
		load(pos)
	end
})

do
	local timer = 0
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer >= 8 then
			local check = table.copy(recheck)
			for _,v in ipairs(check) do
				load(v)
			end
			timer = 0
		end
	end)
end
