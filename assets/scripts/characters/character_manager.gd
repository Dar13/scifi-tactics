extends Node

signal battlefield_updated
signal turn_done

var move_tile_scene = load("res://assets/scenes/move_tile.tscn")
const character = preload("res://assets/scripts/characters/character.gd")
var character_action_menu = load("res://assets/scenes/character_action_gui.tscn")

var characters = {}
var selected_character = null
var character_move_tiles = []
var selected_char_original_pos = Vector3(0,0,0)
var selected_char_menu = null

onready var camera = get_viewport().get_camera()
onready var map = get_node("../../map_root")

var perform_raycast = false
var click_origin = Vector3(0, 0, 0)
var click_target = Vector3(0, 0, 0)

func prepare_for_turn(new_characters):
	characters = new_characters
	for c in characters.values():
		c.deselect(true)

	camera.position.view_target = characters.values().front().translation

func finalize_turn():
	emit_signal("turn_done")

# Called every time the node is added to the scene.
func _ready():
	# Initialization here

	# Create some cached instances of move tiles so we don't keep recreating them
	# Max movement range is 5 for now(lol kinda), so make 10*10 tiles (i.e. [(-5, 0, -5) -> (5, 0, 5)])
	for i in range(10 * 10):
		character_move_tiles.append(move_tile_scene.instance())
		
		get_tree().get_root().call_deferred("add_child", character_move_tiles[i])
		character_move_tiles[i].hide()
	
	selected_char_menu = character_action_menu.instance()
	selected_char_menu.visible = false
	selected_char_menu.get_attack_btn().connect("pressed", self, "handle_attack")
	selected_char_menu.get_cancel_btn().connect("pressed", self, "handle_cancel")
	selected_char_menu.get_standby_btn().connect("pressed", self, "handle_standby")
	call_deferred("add_child", selected_char_menu)

	return

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if perform_raycast == true:
		var space = camera.get_world().get_direct_space_state()
		var raycast_results = space.intersect_ray(click_origin, click_target)
		perform_raycast = false
		if raycast_results.empty() == false:
			handle_click(raycast_results["collider"])
		else:
			handle_click(null)

	pass

func _unhandled_input(event):
	if event.is_action("left_click") && event.pressed == false:
		click_origin = camera.project_ray_origin(event.position)
		click_target = click_origin + camera.project_ray_normal(event.position) * 5000
		perform_raycast = true

	return

func handle_click(object):
	if object != null:
		var parent = object.get_parent()
		var tile_idx = character_move_tiles.find(parent)
		# Did we click on a displayed move tile?
		if tile_idx != -1 && parent.visible:
			var tile_pos = character_move_tiles[tile_idx].translation
			tile_pos.y = round(tile_pos.y) 			# Should round down
			var tile_map_pos = map.get_map_coords(tile_pos)
			selected_char_original_pos = selected_character.translation
			selected_character.move(tile_map_pos)
			
			tile_pos.y += selected_character.get_visual_bounds().size.y / 2
			camera.center_around_point(tile_pos, camera.SPEED_LO)
		# Did we click on a character?
		elif characters.has(object.get_instance_id()) == true:
			# Deselect the current character
			var clicked_char = characters[object.get_instance_id()]
			
			if selected_character != clicked_char && selected_character != null:
				selected_character.deselect(true)
			# If we're clicking the selected character, just break out
			elif selected_character == clicked_char:
				return
			
			if clicked_char.current_phase != character.Phases.Done:
				selected_character = clicked_char
				selected_character.select()
				camera.center_around_point(selected_character.translation, camera.SPEED_LO)

	pass

func handle_cancel():
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Action:
				restore_original()
				update_character_phase(selected_character, character.Phases.Selected)

func handle_attack():
	if selected_character:
		match selected_character.current_phase:
			character.Phases.Action:
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

	if selected_char_menu.visible:
		selected_char_menu.visible = false

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
			selected_char_menu.visible = true

		character.Phases.AttackWeapon:
			# 1. Get attack pattern based on selected weapon/ability
			# TODO: Update to get selected weapon rather than first item
			var wep = character.state.inventory[0]
			var attack_space = wep.get_attack_pattern(map.get_map_coords(character.translation + Vector3(0, -2, 0)))

			# 2. Update it against real map geometry
			for idx in range(0, attack_space.size()):
				var space_pos = attack_space[idx]
				var height = map.get_cell_height_if_exists(space_pos)
				if height == null:
					space_pos.y = -101
				else:
					space_pos.y = height

				attack_space[idx] = space_pos

			# 3. Display
			display_char_attack_tiles(attack_space)

		character.Phases.Done:
			emit_signal("battlefield_updated")
			selected_character = null
			selected_char_original_pos = null
			character.deselect(false)

	character.current_phase = new_state

	# Check if all characters have finished their turn
	var all_done = true
	for c in characters.values():
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
		if space == null || space.y < -100: continue
		
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
		character_move_tiles[idx].hide()

