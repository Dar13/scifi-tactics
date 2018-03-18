extends Node

signal cancel

var character_scene = load("res://assets/models/characters/basic_character.tscn")
var move_tile_scene = load("res://assets/scenes/move_tile.tscn")
var character_state = load("res://assets/scripts/characters/character_state.gd")
var character_action_menu = load("res://assets/scenes/character_action_gui.tscn")

onready var cancel_btn = get_node("../cancel_button")

var characters = {}
var selected_character = null
var character_move_tiles = []
var selected_char_original_pos = Vector3(0,0,0)
var selected_char_menu = null

onready var camera = get_viewport().get_camera()
onready var map = get_node("../map_root")

var perform_raycast = false
var click_origin = Vector3(0, 0, 0)
var click_target = Vector3(0, 0, 0)

func add_character(position):
	print("Adding character at %s" % [ position ])
	var character = character_scene.instance()
	get_tree().get_root().call_deferred("add_child", character)
	character.set_position(position)
	character.map = map
	character.show()
	character.connect("update_state", self, "update_character_state")

	characters[character.get_instance_id()] = character

	return

# Called every time the node is added to the scene.
func _ready():
	# Initialization here

	# Create some cached instances of move tiles so we don't keep recreating them
	# Max movement range is 5 for now(lol kinda), so make 10*10 tiles (i.e. [(-5, 0, -5) -> (5, 0, 5)])
	for i in range(10 * 10):
		character_move_tiles.append(move_tile_scene.instance())
		
		get_tree().get_root().call_deferred("add_child", character_move_tiles[i])
		character_move_tiles[i].hide()
	
	cancel_btn.connect("cancel", self, "handle_cancel")
	
	selected_char_menu = character_action_menu.instance()
	selected_char_menu.visible = false
	selected_char_menu.get_standby_btn().connect("pressed", self, "handle_cancel")
	get_tree().get_root().call_deferred("add_child", selected_char_menu)
	
	# Super temporary
	add_character(Vector3(0.0, 2.0, 0.0))
	
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

func _input(event):
	if event.is_action("left_click") && event.pressed == false:
		click_origin = camera.project_ray_origin(event.position)
		click_target = click_origin + camera.project_ray_normal(event.position) * 5000
		perform_raycast = true

	return

func handle_click(object):
	if object != null:
		var tile_idx = character_move_tiles.find(object.get_parent())
		# Did we click on a displayed move tile?
		if tile_idx != -1 && object.get_parent().visible:
			var tile_pos = character_move_tiles[tile_idx].translation
			tile_pos.y = round(tile_pos.y) 			# Should round down
			var tile_map_pos = map.get_map_coords(tile_pos)
			selected_char_original_pos = selected_character.translation
			selected_character.move(tile_map_pos)
			camera.center_around_point(tile_pos)
		# Did we click on a character?
		elif characters.has(object.get_instance_id()) == true:
			# Deselect the current character
			var clicked_char = characters[object.get_instance_id()]
			
			if selected_character != clicked_char && selected_character != null:
				selected_character.deselect()
			# If we're clicking the selected character, just break out
			elif selected_character == clicked_char:
				return
			
			selected_character = clicked_char
			selected_character.select()

	pass

func handle_cancel():
	if selected_character:
		match selected_character.curr_phase:
			character_state.Phases.Action:
				selected_character.set_position(selected_char_original_pos)
				camera.center_around_point(selected_char_original_pos)
				update_character_state(selected_character, character_state.Phases.Selected)
	pass

func update_character_state(character, new_state):
	if character == null:
		return

	if selected_char_menu.visible:
		selected_char_menu.visible = false
	
	match new_state:
		character_state.Phases.Unselected:
			hide_char_move_tiles()
			
		character_state.Phases.Selected:
			display_char_move_tiles(character, character.movement_range)
		
		character_state.Phases.MoveStart:
			hide_char_move_tiles()
		
		character_state.Phases.Action:
			var menu_pos = camera.unproject_position(character.global_transform.origin)
			menu_pos.x -= selected_char_menu.get_global_rect().size.x / 2
			menu_pos.y -= 100
			selected_char_menu.rect_global_position = menu_pos
			selected_char_menu.visible = true
			
		character_state.Phases.Done:
			character.deselect()
			selected_character = null
			selected_char_original_pos = null
	
	character.curr_phase = new_state
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
		
		character_move_tiles[idx].set_identity()
		character_move_tiles[idx].global_translate(tile_world_pos)
		character_move_tiles[idx].set_color(Color(0.0, 0.0, 1.0, 1.0))
		character_move_tiles[idx].show()
		idx += 1
	
	character.set_movement_space(move_tiles)
	
	pass

func hide_char_move_tiles():
	for idx in range(10 * 10):
		character_move_tiles[idx].hide()

