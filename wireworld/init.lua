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

local check_stop = function(pos)
	for _,v in ipairs(minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworldstop"})) do
		local stop = minetest.get_meta(v):get_int("wireworld")
		if stop == 1 or stop == 3 then
			return true
		end
	end
	return false
end

function wireworld.after_place_node(pos, stopable)
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
	local forceload = minetest.forceload_block(pos, true)
	table.insert(wireworld_nodes, pos)
	if not forceload then
		minetest.log("info", "wireworld could not foreceload "..minetest.pos_to_string(pos))
	end
end

minetest.register_node("wireworld:wireworld_on", {
	description = "Wireworld Stopper",
	tiles = {{name = "wireworld_switch_on.png", backface_culling = true}, {name = "default_steel_block.png", backface_culling = true}},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "wireworld_switch.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.25, -0.25, -0.25, 0.25, -0.125, 0.25}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.25, -0.25, -0.25, 0.25, -0.125, 0.25}
		}
	},
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, puncher)
		local nodes = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworldstop"})
		local switches = {pos}
		for _,v in ipairs(nodes) do
			if not contains(wireworld_nodes, v) then
				minetest.chat_send_player(puncher:get_player_name(), "Could not pause wireworld, circuit not loaded.")
				return
			end
			for _,v in ipairs(minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldstop"})) do
				if not contains(nodes, v) then
					nodes[#nodes+1] = v
				end
			end
			for _,v in ipairs(minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"wireworld:wireworld_on"})) do
				if not contains(switches, v) then
					switches[#switches+1] = v
				end
			end
		end
		for _,v in ipairs(nodes) do
			local meta = minetest.get_meta(v)
			if meta:get_int("wireworld") <= 1 then
				meta:set_int("wireworld", 1)
			else
				meta:set_int("wireworld", 3)
			end
		end
		for _,v in ipairs(switches) do
			minetest.swap_node(v, {name = "wireworld:wireworld_off"})
		end
	end,
	after_place_node = function(pos)
		if check_stop(pos) then
			minetest.swap_node(pos, {name = "wireworld:wireworld_off"})
		end
	end
})

minetest.register_node("wireworld:wireworld_off", {
	description = "Wireworld Stopper",
	tiles = {{name = "wireworld_switch_off.png", backface_culling = true}, {name = "default_steel_block.png", backface_culling = true}},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "wireworld_switch.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.25, -0.25, -0.25, 0.25, -0.125, 0.25}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.25, -0.25, -0.25, 0.25, -0.125, 0.25}
		}
	},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults(),
	drop = "wireworld:wireworld_on",
	on_rightclick = function(pos, node, puncher)
		local nodes = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworldstop"})
		local switches = {pos}
		for _,v in ipairs(nodes) do
			if not contains(wireworld_nodes, v) then
				minetest.chat_send_player(puncher:get_player_name(), "Could not start wireworld, circuit not loaded.")
				return
			end
			for _,v in ipairs(minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldstop"})) do
				if not contains(nodes, v) then
					nodes[#nodes+1] = v
				end
			end
			for _,v in ipairs(minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"wireworld:wireworld_off"})) do
				if not contains(switches, v) then
					switches[#switches+1] = v
				end
			end
		end
		for _,v in ipairs(nodes) do
			local meta = minetest.get_meta(v)
			if meta:get_int("wireworld") > 1 then
				meta:set_int("wireworld", 2)
			else
				meta:set_int("wireworld", 0)
			end
		end
		for _,v in ipairs(switches) do
			minetest.swap_node(v, {name = "wireworld:wireworld_on"})
		end
	end
})

minetest.register_craft({
	output = "wireworld:wireworld_on",
	recipe = {
		{"default:flint", "default:mese_crystal", "default:flint"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

local mese_def = minetest.registered_nodes["default:mese"]

minetest.register_node("wireworld:mese_head", {
	description = mese_def.description.." Head",
	tiles = {"default_mese_block.png^[colorize:blue:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 1, wireworldhead = 1, wireworldstop = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	drop = "default:mese",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_tail"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" and not minetest.is_protected(pos, puncher:get_player_name()) then
			minetest.swap_node(pos, {name = "wireworld:mese_tail"})
		end
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

minetest.register_node("wireworld:mese_tail", {
	description = mese_def.description.." Tail",
	tiles = {"default_mese_block.png^[colorize:red:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 1, wireworldstop = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	drop = "default:mese",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "default:mese"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" and not minetest.is_protected(pos, puncher:get_player_name()) then
			minetest.swap_node(pos, {name = "default:mese"})
		end
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

minetest.override_item("default:mese", {
	groups = {cracky = 1, level = 2, wireworld = 2, wireworldstop = 1},
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_head"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" and not minetest.is_protected(pos, puncher:get_player_name()) then
			minetest.swap_node(pos, {name = "wireworld:mese_head"})
		end
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

if (minetest.get_modpath("mesecons")) then dofile(minetest.get_modpath("wireworld").."/mesecons.lua") end

if (minetest.get_modpath("tnt")) then
	minetest.override_item("tnt:tnt", {
		groups = {dig_immediate = 2, mesecon = 2, tnt = 1, wireworld = 2},
		on_wireworld = function(pos)
			minetest.set_node(pos, {name = "tnt:tnt_burning"})
		end,
		after_place_node = function(pos)
			wireworld.after_place_node(pos, false)
		end
	})
end

do
	local timer = 0
	local check = true
	local next = {}
	local speed = (minetest.setting_get("wireworld_generation_speed") or 14) / 200
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
