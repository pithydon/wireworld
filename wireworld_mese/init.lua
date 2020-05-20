minetest.register_node(":wireworld:mese_head", {
	description = "Mese Block Head",
	tiles = {"default_mese_block.png^[colorize:blue:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 1, wireworldhead = 1, wireworldstop = 1},
	sounds = default.node_sound_stone_defaults(),
	light_source = 3,
	drop = "default:mese",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:mese_tail"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:mese_crystal" and not minetest.is_protected(pos, puncher:get_player_name()) then
			minetest.swap_node(pos, {name = "wireworld:mese_tail"})
		end
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

minetest.register_node(":wireworld:mese_tail", {
	description = "Mese Block Tail",
	tiles = {"default_mese_block.png^[colorize:red:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 1, wireworldstop = 1},
	sounds = default.node_sound_stone_defaults(),
	light_source = 3,
	drop = "default:mese",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "default:mese"})
	end,
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:mese_crystal" and not minetest.is_protected(pos, puncher:get_player_name()) then
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
		if puncher:get_wielded_item():get_name() == "default:mese_crystal" and not minetest.is_protected(pos, puncher:get_player_name()) then
			minetest.swap_node(pos, {name = "wireworld:mese_head"})
		end
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

minetest.register_node(":wireworld:meselamp_dead", {
	description = "Mese Lamp",
	drawtype = "glasslike",
	tiles = {"default_meselamp.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, wireworld = 3},
	sounds = default.node_sound_glass_defaults(),
	drop = "default:meselamp",
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "default:meselamp"})
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

minetest.override_item("default:meselamp", {
	groups = {cracky = 3, oddly_breakable_by_hand = 3, wireworld = 2},
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:meselamp_dead"})
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, true)
	end
})

if (minetest.get_modpath("mesecons")) then dofile(minetest.get_modpath("wireworld_mese").."/mesecons.lua") end
