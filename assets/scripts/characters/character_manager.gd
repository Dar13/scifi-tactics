extends Node

signal battlefield_updated
signal turn_done

var move_tile_scene = load("res://assets/scenes/move_tile.tscn")
var move_tile = load("res://assets/scripts/move_tile.gd")
var character = load("res://assets/scripts/characters/character.gd")
var character_dir = load("res://assets/scripts/characters/character_direction.gd")
var character_stats = load("res://assets/scenes/gui/character_stat_panel.tscn")
var character_action_menu = load("res://assets/scenes/character_action_gui.tscn")
var character_weapon_select_menu = load("res://assets/scenes/character_weapon_select_gui.tscn")
var character_ability_select_menu = load("res://assets/scenes/character_ability_select_gui.tscn")
var character_direction_arrows = load("res://assets/models/characters/character_direction_arrow/character_dir_arrows.tscn")
var attack_confirm_menu = load("res://assets/scenes/character_attack_gui.tscn")
var attack_preview_menu = load("res://assets/scenes/gui/character_attack_preview.tscn")
var attack_context_type = load("res://assets/scripts/battle/attack_context.gd")

var battle_characters = {}
var current_team = {}
var selected_character = null
var character_move_tiles = []

var selected_char_original_pos = Vector3(0,0,0)
var selected_char_original_direction = null
var selected_char_menu = null
var selected_char_wep_menu = null
var selected_char_abi_menu = null

var selected_char_weapon = null
var selected_char_ability = null

var attack_target = []
var attack_context = null

onready var selected_char_attack_confirm = attack_confirm_menu.instance()
onready var selected_char_attack_preview = attack_preview_menu.instance()
onready var char_dir_arrows = character_direction_arrows.instance()
onready var char_stats_menu = character_stats.instance()

onready var camera = get_viewport().get_camera()
onready var map = get_node("../map")

var perform_click_raycast = false

var mouse_pos = Vector2(0, 0)
var mouse_over_last = null
onready var mouse_last_moved = OS.get_ticks_msec()

func prepare_for_battle(all_characters):
	battle_characters = all_characters

func prepare_for_turn(new_characters):
	current_team = new_characters
	# Reset selection on team, check for dead characters
	for c in current_team.values():
		c.deselect(true)

		if c.state.health == 0:
			c.current_phase = character.Phases.Done

	camera.position.view_target = current_team.values().front().translation

func finalize_turn():
	# Per-turn increments and effect evaluations
	for c in current_team.values():
		c.state.evaluate_turn_end()

	emit_signal("turn_done")

# Initialize the character manager
func _ready():
	# Create some cached instances of move tiles so we don't keep recreating them
	# Max movement range is 5 for now(lol kinda), so make 10*10 tiles (i.e. [(-5, 0, -5) -> (5, 0, 5)])
	for i in range(20 * 20):
		character_move_tiles.append(move_tile_scene.instance())
		
		# The tiles will conceal themselves when their "_ready" is called
		add_child(character_move_tiles[i])
	
	selected_char_menu = character_action_menu.instance()
	selected_char_menu.visible = false
	selected_char_menu.get_attack_btn().connect("pressed", self, "handle_attack")
	selected_char_menu.get_ability_btn().connect("pressed", self, "handle_ability")
	selected_char_menu.get_cancel_btn().connect("pressed", self, "handle_cancel")
	selected_char_menu.get_standby_btn().connect("pressed", self, "handle_standby")
	call_deferred("add_child", selected_char_menu)
	
	selected_char_wep_menu = character_weapon_select_menu.instance()
	selected_char_wep_menu.visible = false
	selected_char_wep_menu.connect("weapon_selected", self, "handle_selected_weapon")
	add_child(selected_char_wep_menu)

	selected_char_abi_menu = character_ability_select_menu.instance()
	selected_char_abi_menu.visible = false
	selected_char_abi_menu.connect("ability_selected", self, "handle_selected_ability")
	add_child(selected_char_abi_menu)

	selected_char_attack_confirm.visible = false
	selected_char_attack_confirm.connect("cancelled", self, "handle_cancel")
	selected_char_attack_confirm.connect("confirmed", self, "handle_attack")
	add_child(selected_char_attack_confirm)
	
	selected_char_attack_preview.visible = false
	add_child(selected_char_attack_preview)
	
	add_child(char_stats_menu)

	add_child(char_dir_arrows)
	char_dir_arrows.hide()
	char_dir_arrows.connect("cancelled", self, "handle_cancel")
	char_dir_arrows.connect("confirmed", self, "handle_standby_confirmed")

	return

func _exit_tree():
	for tile in character_move_tiles:
		tile.free()

	selected_char_menu.free()
	selected_char_wep_menu.free()
	selected_char_abi_menu.free()
	selected_char_attack_confirm.free()
	selected_char_attack_preview.free()
	char_stats_menu.free()
	char_dir_arrows.free()

	if attack_context:
		attack_context.free()

func _physics_process(delta):
	# Called every physics timestep. Delta is time since last frame.
	# Perform a raycast every timestep, used for mouse-over handling and will
	# be used for various other things I'm sure.
	var cast_origin = camera.project_ray_origin(mouse_pos)
	var cast_target = camera.project_ray_normal(mouse_pos) * 5000
	var phys_space = camera.get_world().get_direct_space_state()
	var cast_result = phys_space.intersect_ray(cast_origin, cast_target)

	# Click processing here
	if perform_click_raycast == true:
		perform_click_raycast = false
		if cast_result.empty() == false:
			handle_click(cast_result["collider"])
		else:
			handle_click(null)
	else:
		if cast_result.empty() == false:
			var collider_parent = cast_result["collider"].get_parent()
			if collider_parent != null:
				# Ensure the collider is a character (or part of the map??, haven't decided)
				if collider_parent is character:
					mouse_over_last = collider_parent

				# Check against the character direction arrows for highlighting purposes
				if char_dir_arrows.is_visible():
					char_dir_arrows.highlight_arrow(collider_parent)
	return

func _unhandled_input(event):
	if event.is_action("left_click") && event.pressed == false:
		perform_click_raycast = true

	if event is InputEventMouse:
		mouse_pos = event.global_position

	if event is InputEventMouseMotion:
		# TODO: Fuzz factor, in case someone has shaky hands or buggy mouse?
		mouse_last_moved = OS.get_ticks_msec()

	return

func click_character(ch):
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Selected:
				selected_character.deselect(true)
				select_character(ch)

			character.Phases.AttackWeapon, character.Phases.AttackAbility:
				var clicked_world_pos = ch.translation
				clicked_world_pos.y = floor(clicked_world_pos.y - ch.get_visual_bounds().size.y / 2)
				var clicked_map_coord = map.get_map_coords(clicked_world_pos)

				for tile in character_move_tiles:
					var world_pos = tile.translation
					world_pos.y = floor(world_pos.y)
					var tile_map_coord = map.get_map_coords(world_pos)
					if tile.visible == true && clicked_map_coord == tile_map_coord:
						update_attack(ch)
	else:
		select_character(ch)

func select_character(ch):
	selected_character = null

	char_stats_menu.set_character(ch)
	char_stats_menu.show()

	if ch.current_phase != character.Phases.Done:
		selected_character = ch
		selected_character.select()
		selected_char_original_direction = selected_character.facing

		camera.center_around_point(selected_character.translation, camera.SPEED_LO)

func handle_click(object):
	# 1) Get parent as the collider given to us is the collision shape
	# 2) Determine if parent is a selection tile, character, or just a map cell
	# 3) Based on selected character and its state (or lack of one) to
	#	a) Switch selection
	#	b) Move character to selected tile
	#	c) Attack character on selected tile
	#	d) Use item on character on selected tile
	if object != null:
		var parent = object.get_parent()
		if parent is character:
			if battle_characters.has(object.get_instance_id()):
				var clicked_character = battle_characters[object.get_instance_id()]
				click_character(clicked_character)
		elif parent is move_tile:
			var tile_idx = character_move_tiles.find(parent)
			if tile_idx > -1:
				var tile_world_pos = character_move_tiles[tile_idx].translation
				tile_world_pos.y = round(tile_world_pos.y)
				var tile_map_pos = map.get_map_coords(tile_world_pos)
				# Only process movement if the selected character is on the current team
				if selected_character && current_team.values().has(selected_character):
					match selected_character.current_phase:
						character.Phases.Selected:
							selected_char_original_pos = selected_character.translation
							selected_character.move(tile_map_pos)
							tile_world_pos.y += selected_character.get_visual_bounds().size.y / 2
							camera.center_around_point(tile_world_pos, camera.SPEED_LO)
						character.Phases.AttackAbility, character.Phases.AttackWeapon:
							update_attack(parent)
		elif char_dir_arrows.select_arrow(parent):
			# Nothing further needed here, response to this is handled in the signal
			# handler. However, wanted to keep the logic flow consistent here.
			pass	
		else:
			print("clicked was unhandled (potentially the map) Collider = %s" % parent)
	return

func update_attack(tgt):
	if selected_char_weapon and selected_char_weapon.check_target(tgt):
		attack_target = [tgt]
	elif selected_char_ability and selected_char_ability.check_target(tgt):
		# TODO: Evaluate selection pattern for targets
		var select_space = selected_char_ability.get_selection_pattern(map.get_map_coords(tgt.translation + Vector3(0, -2, 0)))
		prepare_for_target_selection(select_space)
		for s in select_space:
			for c in battle_characters.values():
				var map_coord = map.get_map_coords(c.translation + Vector3(0, -2, 0))
				if map_coord == s:
					attack_target.append(c)
	else:
		# TODO: Dunno if that's really an error case...
		#print("update_attack: No selected weapon/ability!")
		return

	update_character_phase(selected_character, character.Phases.AttackConfirm)

func handle_cancel():
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Action:
				restore_original()
				update_character_phase(selected_character, character.Phases.Selected)
			character.Phases.AttackWeapon, character.Phases.AttackAbility:
				hide_char_tiles()
				update_character_phase(selected_character, character.Phases.Action)
			character.Phases.AttackConfirm:
				selected_character.set_direction(selected_char_original_direction)
				if selected_char_weapon:
					update_character_phase(selected_character, character.Phases.AttackWeapon)
				elif selected_char_ability:
					update_character_phase(selected_character, character.Phases.AttackAbility)
				else:
					print("handle_cancel: How did you get here without a weapon/ability selected??")

			character.Phases.StandbyFacing:
				char_dir_arrows.hide()
				update_character_phase(selected_character, character.Phases.Action)

func handle_ability():
	if selected_character and selected_character.current_phase == character.Phases.Action:
		selected_char_abi_menu.set_abilities(selected_character.state.energy, selected_character.state.abilities)
		selected_char_menu.hide()
		selected_char_abi_menu.show()
	else:
		print("ERROR: Invalid call to handle_ability(), meant for ability button selection only!")

func handle_attack():
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Action:
				selected_char_wep_menu.set_weapons(selected_character.state.inventory)
				selected_char_menu.hide()
				selected_char_wep_menu.visible = true
			character.Phases.AttackConfirm:
				attack_context.evaluate_hit_chance()

				# TODO: Another location to properly handle multiple attack targets (and the apply_attack below)
				if selected_char_weapon:
					selected_char_weapon.do_attack(attack_target[0])
				elif selected_char_ability:
					selected_char_ability.do_attack(attack_target[0])
				else:
					print("handle_attack: Attack confirmed without a weapon/ability?!")

				# TODO: Counter-attack animation/effects (e.g. attack_target.do_attack() )

				attack_target[0].state.apply_attack(attack_context, false)
				selected_character.state.apply_attack(attack_context, true)

				attack_context.free()
				attack_context = null

				update_character_phase(selected_character, character.Phases.Done)

func handle_selected_ability():
	if selected_char_abi_menu.selected_ability == null:
		update_character_phase(selected_character, character.Phases.Action)
	else:
		selected_char_ability = selected_char_abi_menu.selected_ability
		update_character_phase(selected_character, character.Phases.AttackAbility)

func handle_selected_weapon():
	if selected_char_wep_menu.selected_weapon == null:
		update_character_phase(selected_character, character.Phases.Action)
	else:
		selected_char_weapon = selected_char_wep_menu.selected_weapon
		update_character_phase(selected_character, character.Phases.AttackWeapon)

func restore_original():
	if selected_character && selected_char_original_pos:
		selected_character.set_position(selected_char_original_pos)
		selected_character.set_direction(selected_char_original_direction)
		camera.center_around_point(selected_char_original_pos, camera.SPEED_LO)
		selected_char_original_pos = null

func handle_standby_confirmed():
	char_dir_arrows.hide()
	selected_character.set_direction(char_dir_arrows.selected_direction)
	update_character_phase(selected_character, character.Phases.Done)

func handle_standby():
	if selected_character:
		update_character_phase(selected_character, character.Phases.StandbyFacing)

func update_character_phase(character, new_state):
	if character == null:
		return

	selected_char_menu.hide()
	selected_char_wep_menu.hide()
	selected_char_abi_menu.hide()
	selected_char_attack_confirm.hide()
	selected_char_attack_preview.hide()

	match new_state:
		character.Phases.Unselected:
			hide_char_tiles()
			if character.current_phase != character.Phases.Done:
				restore_original()

		character.Phases.Selected:
			display_char_move_tiles(character, character.state.movement_range)

		character.Phases.MoveStart:
			hide_char_tiles()

		character.Phases.Action:
			var menu_pos = camera.unproject_position(character.global_transform.origin)
			menu_pos.x -= selected_char_menu.get_global_rect().size.x / 2
			menu_pos.y += 75
			selected_char_menu.rect_global_position = menu_pos
			selected_char_menu.display(selected_character.state.abilities.size() > 0)

		character.Phases.AttackWeapon:
			var attack_space = selected_char_weapon.get_attack_pattern(map.get_map_coords(character.translation + Vector3(0, -2, 0)))
			prepare_for_target_selection(attack_space)

		character.Phases.AttackAbility:
			var attack_space = selected_char_ability.get_range_pattern(map.get_map_coords(character.translation + Vector3(0, -2, 0)))
			prepare_for_target_selection(attack_space)

		character.Phases.AttackConfirm:
			selected_char_attack_confirm.confirmation_mode(camera.unproject_position(attack_target[0].translation));
			selected_char_attack_confirm.show()

			# Rotate attacker towards the defender
			selected_char_original_direction = selected_character.facing
			var new_dir = character_dir.look_at(selected_character.translation, attack_target[0].translation)
			selected_character.set_direction(new_dir)

			# TODO: Handle multiple attack targets. Requires multiple attack contexts with relevant GUI modifications
			if character.current_phase == character.Phases.AttackAbility:
				attack_context = attack_context_type.generate_context(selected_character, attack_target[0], selected_char_ability)
			else:
				attack_context = attack_context_type.generate_context(selected_character, attack_target[0], selected_char_weapon)

			selected_char_attack_preview.populate(attack_context)
			selected_char_attack_preview.show()

		character.Phases.StandbyFacing:
			char_dir_arrows.set_position(character.translation)
			char_dir_arrows.show()

		character.Phases.Done:
			emit_signal("battlefield_updated")
			hide_char_tiles()
			selected_character = null
			selected_char_original_pos = null
			character.deselect(false)

	character.current_phase = new_state

	# Check if all characters have finished their turn
	var all_done = true
	for c in current_team.values():
		if c.current_phase != character.Phases.Done:
			all_done = false
			break

	if all_done:
		finalize_turn()

	return

func prepare_for_target_selection(attack_space):
	# Update locations against real map geometry
	for idx in range(0, attack_space.size()):
		var space_pos = attack_space[idx]
		var height = map.get_cell_height_if_exists(space_pos)
		if height == null:
			space_pos = null
		else:
			space_pos.y = height

		attack_space[idx] = space_pos

	# Display tiles
	display_char_attack_tiles(attack_space)

	# Display the confirm/cancel dialog
	selected_char_attack_confirm.selection_mode();
	selected_char_attack_confirm.show()


func display_char_attack_tiles(attack_space_locations):
	if character == null:
		print("Display attack tiles: null character!")
		return

	var idx = 0
	for space in attack_space_locations:
		if space == null: continue
		
		var real_pos = map.get_world_coords(space)
		real_pos.y += 1.1
		
		character_move_tiles[idx].display(real_pos, Color(1.0, 0.0, 0.0))
		idx += 1

func display_char_move_tiles(ch, distance):
	if ch == null || (ch is character) == false:
		return

	# Calculate the map coordinate the character is at
	var char_pos = ch.translation
	char_pos = char_pos + Vector3(0, -2, 0)
	var char_cell = map.get_map_coords(char_pos)
	# TODO: Raycast downwards to get precise Y-axis value?

	# Get the possible move tiles for this character
	var move_tiles = map.get_cells_in_range(char_pos, ch.state.movement_range, 2)
	var idx = 0
	for tile in move_tiles:
		var tile_world_pos = map.get_world_coords(tile.map_position)
		tile_world_pos.y += 1.1

		character_move_tiles[idx].display(tile_world_pos, Color(0, 0, 1.0, 1.0))
		idx += 1
	
	ch.set_movement_space(move_tiles)

func hide_char_tiles():
	for idx in range(0, character_move_tiles.size()):
		character_move_tiles[idx].conceal()

