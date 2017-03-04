minetest.register_node(":wireworld:button", {
	description = "Wireworld Button",
	tiles = {"wireworld_button.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_top = {-0.25, 0.25, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, -0.25, 0.25},
		wall_side = {-0.5, -0.25, -0.25, -0.25, 0.25, 0.25}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, attached_node = 1},
	sounds = default.node_sound_defaults(),
	on_rightclick = function(pos, node)
		local under = vector.add(pos, minetest.wallmounted_to_dir(node.param2))
		local node_def = minetest.registered_nodes[minetest.get_node(under).name]
		if node_def and node_def.on_wireworld then
			node_def.on_wireworld(under)
		end
	end
})

local get_touching = function(pos)
	return {
		{x = pos.x + 1, y = pos.y, z = pos.z},
		{x = pos.x, y = pos.y + 1, z = pos.z},
		{x = pos.x, y = pos.y, z = pos.z + 1},
		{x = pos.x - 1, y = pos.y, z = pos.z},
		{x = pos.x, y = pos.y - 1, z = pos.z},
		{x = pos.x, y = pos.y, z = pos.z - 1}
	}
end

minetest.register_node(":wireworld:switch_on", {
	description = "Wireworld Switch",
	tiles = {"wireworld_switch_on.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_top = {-0.25, 0.25, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, -0.25, 0.25},
		wall_side = {-0.5, -0.25, -0.25, -0.25, 0.25, 0.25}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, attached_node = 1},
	sounds = default.node_sound_defaults(),
	on_rightclick = function(pos, node)
		local under = vector.add(pos, minetest.wallmounted_to_dir(node.param2))
		local under_node = minetest.get_node(under)
		if minetest.get_item_group(under_node.name, "wireworldstop") > 0 then
			local meta = minetest.get_meta(under)
			local int = meta:get_int("wireworld")
			if int == 0 then
				meta:set_int("wireworld", 2)
			elseif int == 1 then
				meta:set_int("wireworld", 3)
			end
			if minetest.get_item_group(under_node.name, "wireworldhead") > 0 then
				local node_def = minetest.registered_nodes[under_node.name]
				if node_def and node_def.on_wireworld then
					node_def.on_wireworld(under)
				end
			end
			for _,v in ipairs(get_touching(under)) do
				local node = minetest.get_node(v)
				if node.name == "wireworld:switch_on" and vector.equals(vector.add(v, minetest.wallmounted_to_dir(node.param2)), under) then
					minetest.swap_node(v, {name = "wireworld:switch_off", param2 = node.param2})
				end
			end
		end
	end,
	after_place_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_meta(vector.add(pos, minetest.wallmounted_to_dir(node.param2))):get_int("wireworld") > 1 then
			minetest.swap_node(pos, {name = "wireworld:switch_off", param2 = node.param2})
		end
	end
})

minetest.register_node(":wireworld:switch_off", {
	description = "Wireworld Switch",
	tiles = {"wireworld_switch_off.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = {
		type = "wallmounted",
		wall_top = {-0.25, 0.25, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, -0.25, 0.25},
		wall_side = {-0.5, -0.25, -0.25, -0.25, 0.25, 0.25}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, attached_node = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_defaults(),
	drop = "wireworld:switch_on",
	on_rightclick = function(pos, node)
		local under = vector.add(pos, minetest.wallmounted_to_dir(node.param2))
		if minetest.get_item_group(minetest.get_node(under).name, "wireworldstop") > 0 then
			local meta = minetest.get_meta(under)
			local int = meta:get_int("wireworld")
			if int == 2 then
				meta:set_int("wireworld", 0)
			elseif int == 3 then
				meta:set_int("wireworld", 1)
			end
			for _,v in ipairs(get_touching(under)) do
				local node = minetest.get_node(v)
				if node.name == "wireworld:switch_off" and vector.equals(vector.add(v, minetest.wallmounted_to_dir(node.param2)), under) then
					minetest.swap_node(v, {name = "wireworld:switch_on", param2 = node.param2})
				end
			end
		end
	end,
	after_destruct = function(pos, oldnode)
		local under = vector.add(pos, minetest.wallmounted_to_dir(oldnode.param2))
		if minetest.get_item_group(minetest.get_node(under).name, "wireworldstop") > 0 then
			local swap = true
			for _,v in ipairs(get_touching(under)) do
				local node = minetest.get_node(v)
				if node.name == "wireworld:switch_off" and vector.equals(vector.add(v, minetest.wallmounted_to_dir(node.param2)), under) then
					swap = false
					break
				end
			end
			if swap then
				local meta = minetest.get_meta(under)
				local int = meta:get_int("wireworld")
				if int == 2 then
					meta:set_int("wireworld", 0)
				elseif int == 3 then
					meta:set_int("wireworld", 1)
				end
			end
		end
	end
})

minetest.register_craft({
	output = "wireworld:button",
	recipe = {{"default:mese_crystal"}, {"default:flint"}}
})

minetest.register_craft({
	output = "wireworld:switch_on",
	recipe = {{"default:flint", "default:mese_crystal", "default:flint"}}
})
