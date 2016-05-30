local mese_def = minetest.registered_nodes["default:mese"]

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

if (minetest.get_modpath("mesecons_extrawires")) then
	minetest.register_node("wireworld:mese_head_powered", {
		description = mese_def.description.." Head",
		tiles = {"default_mese_block.png^[colorize:blue:127"},
		paramtype = "light",
		groups = {cracky = 1, level = 2, not_in_creative_inventory=1, wireworld = 1, wireworldhead = 1, wireworldstop = 1},
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
			if puncher:get_wielded_item():get_name() == "default:torch" then
				minetest.swap_node(pos, {name = "wireworld:mese_tail_powered"})
			end
		end,
		after_place_node = function(pos)
			table.insert(wireworld_nodes, pos)
		end,
	})

	minetest.register_node("wireworld:mese_tail_powered", {
		description = mese_def.description.." Tail",
		tiles = {"default_mese_block.png^[colorize:red:127"},
		paramtype = "light",
		groups = {cracky = 1, level = 2, not_in_creative_inventory=1, wireworld = 1, wireworldstop = 1},
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
			if puncher:get_wielded_item():get_name() == "default:torch" then
				minetest.swap_node(pos, {name = "mesecons_extrawires:mese_powered"})
			end
		end,
		after_place_node = function(pos)
			table.insert(wireworld_nodes, pos)
		end,
	})

	minetest.override_item("mesecons_extrawires:mese_powered", {
		groups = {cracky = 1, level = 2, wireworld = 2, wireworldstop = 1},
		on_wireworld = function(pos)
			minetest.swap_node(pos, {name = "wireworld:mese_head_powered"})
		end,
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" then
				minetest.swap_node(pos, {name = "wireworld:mese_head_powered"})
			end
		end,
		after_place_node = function(pos)
			table.insert(wireworld_nodes, pos)
		end,
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
