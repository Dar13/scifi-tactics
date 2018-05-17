extends Node

signal battlefield_updated
signal turn_done

var move_tile_scene = load("res://assets/scenes/move_tile.tscn")
const move_tile = preload("res://assets/scripts/move_tile.gd")
const character = preload("res://assets/scripts/characters/character.gd")
var character_stats_menu = load("res://assets/scenes/character_stats_gui.tscn")
var character_action_menu = load("res://assets/scenes/character_action_gui.tscn")
var character_weapon_select_menu = load("res://assets/scenes/character_weapon_select_gui.tscn")
var attack_confirm_menu = load("res://assets/scenes/character_attack_gui.tscn")

var battle_characters = {}
var current_team = {}
var selected_character = null
var character_move_tiles = []

var selected_char_original_pos = Vector3(0,0,0)
var selected_char_menu = null
var selected_char_wep_menu = null
var selected_char_weapon = null

var attack_target = null

onready var selected_char_attack_confirm = attack_confirm_menu.instance()

onready var char_stats_menu = character_stats_menu.instance()

onready var camera = get_viewport().get_camera()
onready var map = get_node("../../map_root")

var perform_click_raycast = false

var mouse_pos = Vector2(0, 0)
var mouse_over_last = null
onready var mouse_last_moved = OS.get_ticks_msec()

func prepare_for_battle(all_characters):
	battle_characters = all_characters

func prepare_for_turn(new_characters):
	current_team = new_characters
	for c in current_team.values():
		c.deselect(true)

	camera.position.view_target = current_team.values().front().translation

func finalize_turn():
	emit_signal("turn_done")

# Called every time the node is added to the scene.
func _ready():
	# Initialization here

	# Create some cached instances of move tiles so we don't keep recreating them
	# Max movement range is 5 for now(lol kinda), so make 10*10 tiles (i.e. [(-5, 0, -5) -> (5, 0, 5)])
	for i in range(10 * 10):
		character_move_tiles.append(move_tile_scene.instance())
		
		# The tiles will conceal themselves when their "_ready" is called
		add_child(character_move_tiles[i])
	
	selected_char_menu = character_action_menu.instance()
	selected_char_menu.visible = false
	selected_char_menu.get_attack_btn().connect("pressed", self, "handle_attack")
	selected_char_menu.get_cancel_btn().connect("pressed", self, "handle_cancel")
	selected_char_menu.get_standby_btn().connect("pressed", self, "handle_standby")
	call_deferred("add_child", selected_char_menu)
	
	selected_char_wep_menu = character_weapon_select_menu.instance()
	selected_char_wep_menu.visible = false
	selected_char_wep_menu.connect("weapon_selected", self, "handle_selected_weapon")
	add_child(selected_char_wep_menu)

	selected_char_attack_confirm.visible = false
	selected_char_attack_confirm.connect("cancelled", self, "handle_cancel")
	selected_char_attack_confirm.connect("confirmed", self, "handle_attack")
	add_child(selected_char_attack_confirm)
	
	char_stats_menu.visible = false
	add_child(char_stats_menu)

	return

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
				if collider_parent == mouse_over_last:
					var diff = (OS.get_ticks_msec() - mouse_last_moved) / 1000.0
					# If the difference is greater than a second, display the stats panel
					if diff > 1:
						char_stats_menu.populate(mouse_over_last)
						char_stats_menu.popup(Rect2(Vector2(mouse_pos.x + 1, mouse_pos.y + 1), Vector2(128, 196)))
						char_stats_menu.grab_click_focus()
				else:
					# Ensure the collider is a character (or part of the map??, haven't decided)
					if collider_parent is character:
						mouse_over_last = collider_parent
	return

func _unhandled_input(event):
	if event.is_action("left_click") && event.pressed == false:
		perform_click_raycast = true

	if event is InputEventMouse:
		mouse_pos = event.global_position

	if event is InputEventMouseMotion:
		# TODO: Fuzz factor, in case someone has shaky hands or buggy mouse?
		mouse_last_moved = OS.get_ticks_msec()
		if char_stats_menu.visible && char_stats_menu.get_global_rect().grow(1).has_point(mouse_pos) == false:
			char_stats_menu.hide()
			# Uncomment when expansion/shrink is implemented
			#char_stats_menu.shrink()

	return

func select_character(ch):
	if ch.current_phase != character.Phases.Done:
		selected_character = ch
		selected_character.select()
		
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
				var clicked_is_on_team = current_team.has(object.get_instance_id())

				if selected_character != null:
					match selected_character.current_phase:
						character.Phases.Selected:
							if clicked_is_on_team == true:
								if selected_character != clicked_character:
									selected_character.deselect(true)
								elif selected_character == clicked_character:
									return # Player clicked the selected character

								select_character(clicked_character)
							else:
								# Deselect? Clicked another team's character during movement selection
								pass
						character.Phases.AttackWeapon:
							var clicked_world_pos = clicked_character.translation
							clicked_world_pos.y = floor(clicked_world_pos.y - clicked_character.get_visual_bounds().size.y / 2)
							var clicked_map_coord = map.get_map_coords(clicked_world_pos)

							for tile in character_move_tiles:
								var world_pos = tile.translation
								world_pos.y = floor(world_pos.y)
								var tile_map_coord = map.get_map_coords(world_pos)
								if tile.visible == true && clicked_map_coord == tile_map_coord:
									attack_target = clicked_character
									update_character_phase(selected_character, character.Phases.AttackConfirm)
				elif clicked_is_on_team == true:
					select_character(clicked_character)

		elif parent is move_tile:
			var tile_idx = character_move_tiles.find(parent)
			if tile_idx > -1:
				var tile_world_pos = character_move_tiles[tile_idx].translation
				tile_world_pos.y = round(tile_world_pos.y)
				var tile_map_pos = map.get_map_coords(tile_world_pos)
				if selected_character != null:
					match selected_character.current_phase:
						character.Phases.Selected:
							selected_char_original_pos = selected_character.translation
							selected_character.move(tile_map_pos)
							tile_world_pos.y += selected_character.get_visual_bounds().size.y / 2
							camera.center_around_point(tile_world_pos, camera.SPEED_LO)
						character.Phases.AttackWeapon:
							attack_target = parent
							update_character_phase(selected_character, character.Phases.AttackConfirm)
		else:
			print("clicked was on the map")
	return

func handle_cancel():
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Action:
				restore_original()
				update_character_phase(selected_character, character.Phases.Selected)
			character.Phases.AttackWeapon:
				hide_char_tiles()
				update_character_phase(selected_character, character.Phases.Action)
			character.Phases.AttackConfirm:
				update_character_phase(selected_character, character.Phases.AttackWeapon)

func handle_attack():
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Action:
				selected_char_wep_menu.set_weapons(selected_character.state.inventory)
				selected_char_menu.visible = false
				selected_char_wep_menu.visible = true
			character.Phases.AttackConfirm:
				selected_char_weapon.do_attack(attack_target)
				update_character_phase(selected_character, character.Phases.Done)

func handle_selected_weapon():
	if selected_char_wep_menu.selected_weapon == null:
		update_character_phase(selected_character, character.Phases.Action)
	else:
		selected_char_weapon = selected_char_wep_menu.selected_weapon
		update_character_phase(selected_character, character.Phases.AttackWeapon)

func restore_original():
	if selected_character && selected_char_original_pos:
		selected_character.set_position(selected_char_original_pos)
		camera.center_around_point(selected_char_original_pos, camera.SPEED_LO)
		selected_char_original_pos = null

func handle_standby():
	if selected_character:
		update_character_phase(selected_character, character.Phases.Done)

func update_character_phase(character, new_state):
	if character == null:
		return

	selected_char_menu.hide()
	selected_char_wep_menu.hide()
	selected_char_attack_confirm.hide()

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
			selected_char_menu.show()

		character.Phases.AttackWeapon:
			# 1. Get attack pattern based on selected weapon/ability
			var attack_space = selected_char_weapon.get_attack_pattern(map.get_map_coords(character.translation + Vector3(0, -2, 0)))

			# 2. Update it against real map geometry
			for idx in range(0, attack_space.size()):
				var space_pos = attack_space[idx]
				var height = map.get_cell_height_if_exists(space_pos)
				if height == null:
					space_pos = null
				else:
					space_pos.y = height

				attack_space[idx] = space_pos

			# 3. Display
			display_char_attack_tiles(attack_space)

			# 4. Display the confirm/cancel dialog
			selected_char_attack_confirm.selection_mode();
			selected_char_attack_confirm.show()

		character.Phases.AttackConfirm:
			selected_char_attack_confirm.confirmation_mode(camera.unproject_position(attack_target.translation));
			selected_char_attack_confirm.show()

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

func display_char_move_tiles(object, distance):
	var character = null
	# TODO: Is there a way to verify it's a character??
	if object != null:
		character = object
	else:
		return

	# Calculate the map coordinate the character is at
	var char_pos = character.translation
	char_pos = char_pos + Vector3(0, -2, 0)
	var char_cell = map.get_map_coords(char_pos)
	# TODO: Raycast downwards to get precise Y-axis value?

	# Get the possible move tiles for this character
	var move_tiles = map.get_cells_in_range(char_pos, character.state.movement_range, 2)
	var idx = 0
	for tile in move_tiles:
		var tile_world_pos = map.get_world_coords(tile.map_position)
		tile_world_pos.y += 1.1

		character_move_tiles[idx].display(tile_world_pos, Color(0, 0, 1.0, 1.0))
		idx += 1
	
	character.set_movement_space(move_tiles)

func hide_char_tiles():
	for idx in range(10 * 10):
		character_move_tiles[idx].conceal()

