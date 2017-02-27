wireworld = {}
wireworld.nodes = {}

local contains = function(table, element)
	local elementstring = minetest.pos_to_string(element)
	for _, value in pairs(table) do
		local valuestring = minetest.pos_to_string(value)
		if valuestring == elementstring then
			return true
		end
	end
	return false
end

minetest.register_node("wireworld:wireworld_on", {
	description = "Wireworld Switch",
	tiles = {{name = "default_mese_block.png", backface_culling = true}, {name = "default_steel_block.png", backface_culling = true}},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "wireworld_switch.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.1875, -0.25, -0.1875, 0.1875, -0.125, 0.1875}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.1875, -0.25, -0.1875, 0.1875, -0.125, 0.1875}
		}
	},
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, puncher)
		local nodes = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworldstop"})
		for i,v in ipairs(nodes) do
			local meta = minetest.get_meta(v)
			meta:set_string("wireworld", "stop")
		end
		for i,v in ipairs(nodes) do
			local find = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldstop"})
			for i,v in ipairs(find) do
				if not contains(nodes, v) then
					local meta = minetest.get_meta(v)
					meta:set_string("wireworld", "stop")
					nodes[#nodes+1] = v
				end
			end
		end
		minetest.swap_node(pos, {name = "wireworld:wireworld_off"})
	end
})

minetest.register_node("wireworld:wireworld_off", {
	description = "Wireworld Switch",
	tiles = {{name = "default_mese_block.png^[colorize:green:127", backface_culling = true}, {name = "default_steel_block.png", backface_culling = true}},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "wireworld_switch.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.1875, -0.25, -0.1875, 0.1875, -0.125, 0.1875}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
			{-0.1875, -0.25, -0.1875, 0.1875, -0.125, 0.1875}
		}
	},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = "wireworld:wireworld_on",
	on_rightclick = function(pos, node, puncher)
		local nodes = minetest.find_nodes_in_area({x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}, {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}, {"group:wireworld"})
		for i,v in ipairs(nodes) do
			local meta = minetest.get_meta(v)
			meta:set_string("wireworld", "nil")
		end
		for i,v in ipairs(nodes) do
			local find = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworld"})
			for i,v in ipairs(find) do
				if not contains(nodes, v) then
					local meta = minetest.get_meta(v)
					meta:set_string("wireworld", "nil")
					nodes[#nodes+1] = v
				end
			end
		end
		minetest.swap_node(pos, {name = "wireworld:wireworld_on"})
	end
})

minetest.register_craft({
	output = "wireworld:wireworld_on",
	recipe = {
		{"default:steel_ingot","default:mese","default:steel_ingot"}
	}
})

local mese_def = minetest.registered_nodes["default:mese"]

minetest.register_node("wireworld:mese_head", {
	description = mese_def.description.." Head",
	tiles = {"default_mese_block.png^[colorize:blue:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1, wireworld = 1, wireworldhead = 1, wireworldstop = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	drop = "default:mese",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_tail"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.swap_node(pos, {name = "wireworld:mese_tail"})
		end
	end,
	after_place_node = function(pos)
		table.insert(wireworld.nodes, pos)
	end
})

minetest.register_node("wireworld:mese_tail", {
	description = mese_def.description.." Tail",
	tiles = {"default_mese_block.png^[colorize:red:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1, wireworld = 1, wireworldstop = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	drop = "default:mese",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "default:mese"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.swap_node(pos, {name = "default:mese"})
		end
	end,
	after_place_node = function(pos)
		table.insert(wireworld.nodes, pos)
	end
})

minetest.override_item("default:mese", {
	groups = {cracky = 1, level = 2, wireworld = 2, wireworldstop = 1},
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_head"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.swap_node(pos, {name = "wireworld:mese_head"})
		end
	end,
	after_place_node = function(pos)
		table.insert(wireworld.nodes, pos)
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
			table.insert(wireworld.nodes, pos)
		end
	})
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.1 then
		for i,v in ipairs(wireworld.nodes) do
			local meta = minetest.get_meta(v)
			if meta:get_string("wireworld") ~= "stop" then
				local node = minetest.get_node(v)
				local g = minetest.get_item_group(node.name, "wireworld")
				if g == 1 then
					meta:set_string("wireworld", "next")
				elseif g == 2 then
					local table = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldhead"})
					local count = 0
					for _ in pairs(table) do count = count + 1 end
					if count == 1 or count == 2 then
						meta:set_string("wireworld", "next")
					end
				elseif g == 3 then
					local table = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldhead"})
					local count = 0
					for _ in pairs(table) do count = count + 1 end
					if count < 1 or count > 2 then
						meta:set_string("wireworld", "next")
					end
				else
					table.remove(wireworld.nodes, i)
				end
			end
		end
		timer = 0
	end
end)

local timer2 = 0.05
minetest.register_globalstep(function(dtime)
	timer2 = timer2 + dtime;
	if timer2 >= 0.1 then
		for _,v in ipairs(wireworld.nodes) do
			local meta = minetest.get_meta(v)
			if meta:get_string("wireworld") == "next" then
				local node = minetest.get_node(v)
				local node_def = minetest.registered_nodes[node.name]
				node_def.on_wireworld(v)
				meta:set_string("wireworld", "nil")
			end
		end
		timer2 = 0
	end
end)

minetest.register_lbm({
	name = "wireworld:index_nodes",
	nodenames = {"group:wireworld"},
	run_at_every_load = true,
	action = function(pos)
		if not contains(wireworld.nodes, pos) then
			table.insert(wireworld.nodes, pos)
		end
	end
})
