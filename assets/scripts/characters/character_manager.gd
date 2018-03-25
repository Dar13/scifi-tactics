extends Node

signal battlefield_updated
signal turn_done

var character_scene = load("res://assets/models/characters/basic_character.tscn")
var move_tile_scene = load("res://assets/scenes/move_tile.tscn")
var character_state = load("res://assets/scripts/characters/character_state.gd")
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
			
			tile_pos.y += selected_character.character_mesh.get_aabb().size.y / 2
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
			
			if clicked_char.curr_phase != character_state.Phases.Done:
				selected_character = clicked_char
				selected_character.select()
				camera.center_around_point(selected_character.translation, camera.SPEED_LO)

	pass

func handle_cancel():
	if selected_character:
		match selected_character.curr_phase:
			character_state.Phases.Action:
				restore_original()
				update_character_state(selected_character, character_state.Phases.Selected)
	pass

func restore_original():
	if selected_character && selected_char_original_pos:
		selected_character.set_position(selected_char_original_pos)
		camera.center_around_point(selected_char_original_pos, camera.SPEED_LO)
		selected_char_original_pos = null

func handle_standby():
	if selected_character:
		update_character_state(selected_character, character_state.Phases.Done)

func update_character_state(character, new_state):
	if character == null:
		return

	if selected_char_menu.visible:
		selected_char_menu.visible = false
	
	match new_state:
		character_state.Phases.Unselected:
			hide_char_move_tiles()
			if character.curr_phase != character_state.Phases.Done:
				restore_original()

		character_state.Phases.Selected:
			display_char_move_tiles(character, character.movement_range)

		character_state.Phases.MoveStart:
			hide_char_move_tiles()

		character_state.Phases.Action:
			var menu_pos = camera.unproject_position(character.global_transform.origin)
			menu_pos.x -= selected_char_menu.get_global_rect().size.x / 2
			menu_pos.y += 75
			selected_char_menu.rect_global_position = menu_pos
			selected_char_menu.visible = true

		character_state.Phases.Done:
			emit_signal("battlefield_updated")
			selected_character = null
			selected_char_original_pos = null
			character.deselect(false)

	character.curr_phase = new_state

	# Check if all characters have finished their turn
	var all_done = true
	for c in characters.values():
		if c.curr_phase != character_state.Phases.Done:
			all_done = false
			break

	if all_done:
		finalize_turn()

	return

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
	var move_tiles = map.get_movement_space(char_pos, character.movement_range, 2)
	var idx = 0
	for tile in move_tiles:
		var tile_world_pos = map.get_world_coords(tile.map_position)
		tile_world_pos.y += 1.1
		
		character_move_tiles[idx].display(tile_world_pos, Color(0, 0, 1.0, 1.0))
		idx += 1
	
	character.set_movement_space(move_tiles)
	
	pass

func hide_char_move_tiles():
	for idx in range(10 * 10):
		character_move_tiles[idx].hide()

