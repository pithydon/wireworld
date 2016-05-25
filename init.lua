local wireworld_nodes = {}
local wireworld_go = true

if minetest.registered_nodes["default:mese"] then
local mese_def = minetest.registered_nodes["default:mese"]

minetest.register_node("wireworld:mese_head", {
	description = mese_def.description.." Head",
	tiles = {"default_mese_block.png^[colorize:blue:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, wireworld = 1, wireworldhead = 1},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	wireworld = "wireworld:mese_tail",
	on_rightclick = function(pos)
		minetest.set_node(pos, {name = "wireworld:mese_tail"})
	end,
	after_place_node = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})

minetest.register_node("wireworld:mese_tail", {
	description = mese_def.description.." Tail",
	tiles = {"default_mese_block.png^[colorize:red:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, wireworld = 2},
	sounds = mese_def.sounds,
	light_source = mese_def.light_source,
	wireworld = "default:mese",
	on_rightclick = function(pos)
		minetest.set_node(pos, {name = "default:mese"})
	end,
	after_place_node = function(pos)
		table.insert(wireworld_nodes, pos)
	end,
})

minetest.override_item("default:mese", {
	groups = {cracky = 1, level = 2, wireworld = 3},
	wireworld = "wireworld:mese_head",
	on_rightclick = function(pos)
		minetest.set_node(pos, {name = "wireworld:mese_head"})
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
			if wireworld == 3 then
				local table = minetest.find_nodes_in_area({x = v.x - 1, y = v.y - 1, z = v.z - 1}, {x = v.x + 1, y = v.y + 1, z = v.z + 1}, {"group:wireworldhead"})
				local count = 0
				for _ in pairs(table) do count = count + 1 end
				if count == 1 or count == 2 then
					meta:set_string("wireworldnext", "true")
				end
			elseif wireworld == 1 or wireworld == 2 then
				meta:set_string("wireworldnext", "true")
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
				if wireworld_go then minetest.set_node(v, {name = node_def.wireworld}) end
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
