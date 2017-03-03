local mese_def = minetest.registered_nodes["default:mese"]

local wireworld_converter_rules =
	{
		{x = 1, y = 0, z = 0},
		{x =-1, y = 0, z = 0},
		{x = 0, y = 1, z = 0},
		{x = 0, y =-1, z = 0},
		{x = 0, y = 0, z = 1},
		{x = 0, y = 0, z =-1}
	}

minetest.register_node("wireworld:converter", {
	description = "Wireworld Converter",
	tiles = {"mesecons_wire_off.png"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, wireworld = 2},
	sounds = mese_def.sounds,
	mesecons = {effector = {
		rules = wireworld_converter_rules,
		action_on = function (pos, node)
			minetest.swap_node(pos, {name = "wireworld:converter_in"})
		end
	}},
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:converter_out"})
		mesecon.receptor_on(pos, wireworld_converter_rules)
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, false)
	end
})

minetest.register_node("wireworld:converter_in", {
	description = "Wireworld Converter",
	tiles = {"mesecons_wire_on.png^[colorize:blue:127"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 4, wireworldhead = 1},
	sounds = mese_def.sounds,
	drop = "wireworld:converter",
	mesecons = {effector = {
		rules = wireworld_converter_rules,
		action_off = function (pos, node)
			minetest.swap_node(pos, {name = "wireworld:converter"})
		end
	}},
	after_place_node = function(pos)
		wireworld.after_place_node(pos, false)
	end
})

minetest.register_node("wireworld:converter_out", {
	description = "Wireworld Converter",
	tiles = {"mesecons_wire_on.png"},
	paramtype = "light",
	groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 3},
	sounds = mese_def.sounds,
	drop = "wireworld:converter",
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = wireworld_converter_rules
	}},
	on_wireworld = function(pos)
		minetest.swap_node(pos, {name = "wireworld:converter"})
		mesecon.receptor_off(pos, wireworld_converter_rules)
	end,
	after_place_node = function(pos)
		wireworld.after_place_node(pos, false)
	end
})

minetest.register_craft({
	output = "wireworld:converter",
	recipe = {
		{"mesecons:wire_00000000_off"},
		{"default:mese"}
	}
})

if (minetest.get_modpath("mesecons_extrawires")) then
	local mesewire_rules =
		{
			{x = 1, y = 0, z = 0},
			{x =-1, y = 0, z = 0},
			{x = 0, y = 1, z = 0},
			{x = 0, y =-1, z = 0},
			{x = 0, y = 0, z = 1},
			{x = 0, y = 0, z =-1}
		}
	minetest.register_node("wireworld:mese_head_powered", {
		description = mese_def.description.." Head",
		tiles = {"default_mese_block.png^[colorize:blue:127"},
		paramtype = "light",
		groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 1, wireworldhead = 1, wireworldstop = 1},
		sounds = mese_def.sounds,
		light_source = 5,
		drop = "default:mese",
		mesecons = {conductor = {
			state = mesecon.state.on,
			offstate = "wireworld:mese_head",
			rules = mesewire_rules
		}},
		on_wireworld = function(pos)
			minetest.swap_node(pos, {name = "wireworld:mese_tail_powered"})
		end,
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" and not minetest.is_protected(pos, puncher:get_player_name()) then
				minetest.swap_node(pos, {name = "wireworld:mese_tail_powered"})
			end
		end,
		after_place_node = function(pos)
			wireworld.after_place_node(pos, true)
		end
	})

	minetest.register_node("wireworld:mese_tail_powered", {
		description = mese_def.description.." Tail",
		tiles = {"default_mese_block.png^[colorize:red:127"},
		paramtype = "light",
		groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 1, wireworldstop = 1},
		sounds = mese_def.sounds,
		light_source = 5,
		drop = "default:mese",
		mesecons = {conductor = {
			state = mesecon.state.on,
			offstate = "wireworld:mese_tail",
			rules = mesewire_rules
		}},
		on_wireworld = function(pos)
			minetest.swap_node(pos, {name = "mesecons_extrawires:mese_powered"})
		end,
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" and not minetest.is_protected(pos, puncher:get_player_name()) then
				minetest.swap_node(pos, {name = "mesecons_extrawires:mese_powered"})
			end
		end,
		after_place_node = function(pos)
			wireworld.after_place_node(pos, true)
		end
	})

	minetest.override_item("mesecons_extrawires:mese_powered", {
		groups = {cracky = 1, level = 2, not_in_creative_inventory = 1, wireworld = 2, wireworldstop = 1},
		on_wireworld = function(pos)
			minetest.swap_node(pos, {name = "wireworld:mese_head_powered"})
		end,
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" and not minetest.is_protected(pos, puncher:get_player_name()) then
				minetest.swap_node(pos, {name = "wireworld:mese_head_powered"})
			end
		end,
		after_place_node = function(pos)
			wireworld.after_place_node(pos, true)
		end
	})

	minetest.override_item("wireworld:mese_head", {
		mesecons = {conductor = {
			state = mesecon.state.off,
			onstate = "wireworld:mese_head_powered",
			rules = mesewire_rules
		}}
	})

	minetest.override_item("wireworld:mese_tail", {
		mesecons = {conductor = {
			state = mesecon.state.off,
			onstate = "wireworld:mese_tail_powered",
			rules = mesewire_rules
		}}
	})
end
