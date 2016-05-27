wireworld_nodes = {}
wireworld_go = true

local mese_def = minetest.registered_nodes["default:mese"]

minetest.register_node("wireworld:mese_head", {
	description = mese_def.description.." Head",
	tiles = {"default_mese_block.png^[colorize:blue:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1, wireworld = 1, wireworldhead = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_tail"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.swap_node(pos, {name = "wireworld:mese_tail"})
		end
	end,
	after_place_node = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})

minetest.register_node("wireworld:mese_tail", {
	description = mese_def.description.." Tail",
	tiles = {"default_mese_block.png^[colorize:red:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1, wireworld = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "default:mese"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.swap_node(pos, {name = "default:mese"})
		end
	end,
	after_place_node = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})

minetest.override_item("default:mese", {
	groups = {cracky = 1, level = 2, wireworld = 2},
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_head"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.swap_node(pos, {name = "wireworld:mese_head"})
		end
	end,
	after_place_node = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})

if (minetest.get_modpath("mesecons_button")) then
	local mesecons_button_def = minetest.registered_nodes["mesecons_button:button_off"]
	minetest.override_item("mesecons_button:button_off", {
		groups = {dig_immediate=2, mesecon_needs_receiver = 1, wireworld = 2},
		on_wireworld = function(pos)
			local node = minetest.get_node(pos)
			mesecons_button_def.on_rightclick(pos, node)
		end,
		after_place_node = function(pos)
			table.insert(wireworld_nodes, pos)
		end,
	})
end

if (minetest.get_modpath("tnt")) then
minetest.override_item("tnt:tnt", {
	groups = {dig_immediate = 2, mesecon = 2, tnt = 1, wireworld = 2},
	on_wireworld = function(pos)
		minetest.set_node(pos, {name = "tnt:tnt_burning"})
	end,
	after_place_node = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.1 then
		for k,v in pairs(wireworld_nodes) do
			local node = minetest.get_node(v)
			local wireworld = minetest.get_item_group(node.name, "wireworld")
			local meta = minetest.get_meta(v)
			if wireworld == 1 then
				meta:set_string("wireworldnext", "true")
			elseif wireworld == 2 then
				local table = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldhead"})
				local count = 0
				for _ in pairs(table) do count = count + 1 end
				if count == 1 or count == 2 then
					meta:set_string("wireworldnext", "true")
				end
			else
				table.remove(v)
			end
		end
		timer = 0
	end
end)

local timer2 = 0.05
minetest.register_globalstep(function(dtime)
	timer2 = timer2 + dtime;
	if timer2 >= 0.1 then
		for k,v in pairs(wireworld_nodes) do
			local node = minetest.get_node(v)
			local node_def = minetest.registered_nodes[node.name]
			local meta = minetest.get_meta(v)
			if meta:get_string("wireworldnext") == "true" then
				if wireworld_go then node_def.on_wireworld(v) end
				meta:set_string("wireworldnext", "false")
			end
		end
		timer2 = 0
	end
end)

minetest.register_privilege("wireworld", {
	description = "Allows player to start and stop wireworld.",
	give_to_singleplayer = false,
})

minetest.register_chatcommand("wwstart", {
	params = "",
	description = "Start Wireworld",
	privs = {wireworld = true},
	func = function()
		wireworld_go = true
		return true
	end,
})

minetest.register_chatcommand("wwstop", {
	params = "",
	description = "Stop Wireworld",
	privs = {wireworld = true},
	func = function()
		wireworld_go = false
		return true
	end,
})

minetest.register_lbm({
	name = "wireworld:register_nodes",
	nodenames = {"group:wireworld"},
	run_at_every_load = true,
	action = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})
