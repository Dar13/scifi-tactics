extends Node

var tile_scene = load("res://assets/models/characters/selection_tile/move_tile.tscn")
var tile_class = load("res://assets/scripts/move_tile.gd")

var ui_scene = load("res://assets/scenes/character_placement.tscn")
var ui = null

onready var party = null
onready var mouse_pos = Vector2(0, 0)
onready var perform_click_raycast = false

onready var camera = get_viewport().get_camera()
onready var map = get_node("../map")

onready var selected_character = null
onready var selected_character_original_pos = Vector3(0, 0, 0)

var tiles = []
var tile_map_pos = []

func _ready():
	ui = ui_scene.instance()
	add_child(ui)
	ui.connect("selected", self, "ui_selected")

	var plr_placement_pos = map.get_player_placement_positions()
	for i in range(plr_placement_pos.size()):
		var tile_pos = plr_placement_pos[i]
		tiles.append(tile_scene.instance())
		tile_map_pos.append(map.get_map_coords(tile_pos))
		tile_pos.y += tile_class.TILE_OFFSET
		add_child(tiles[i])
		tiles[i].display(tile_pos, Color(0, 0, 1.0, 0.3))

func _physics_process(delta):
	var cast_origin = camera.project_ray_origin(mouse_pos)
	var cast_target = camera.project_ray_normal(mouse_pos) * 5000
	var phys_space = camera.get_world().get_direct_space_state()

	var exclusion = []
	if selected_character:
		exclusion.append(selected_character.get_collider())

	var cast_result = phys_space.intersect_ray(cast_origin, cast_target,
			exclusion)

	# Click processing here
	if perform_click_raycast == true:
		perform_click_raycast = false
		if cast_result.empty() == false:
			handle_click(cast_result["collider"])
	
	if selected_character && cast_result.empty() == false:
		var maybe_tile = cast_result["collider"].get_parent()
		if is_valid_tile(maybe_tile):
			set_selected_position(maybe_tile)

func _unhandled_input(event):
	if event.is_action("left_click") && event.pressed == false:
		perform_click_raycast = true
		change_char_collision(0, true)

	if event is InputEventMouse:
		mouse_pos = event.global_position

func set_party(p):
	party = p
	ui.set_characters(party)

func handle_click(collider):
	var parent = collider.get_parent()
	if party.has(collider.get_instance_id()):
		reset_selected(parent)

	if is_valid_tile(parent):
		set_selected_position(parent)
		clear_selected()

func is_valid_tile(obj):
	if obj is tile_class:
		var map_pos = map.get_map_coords(obj.translation)
		if map_pos in tile_map_pos:
			return true

	return false

func set_selected_position(tile):
	var selected_pos = tile.translation
	selected_pos.y -= tile_class.TILE_OFFSET
	selected_pos.y += 0.5 # TODO: selected_character.get_center_offset().y
	if selected_character:
		selected_character.set_position(selected_pos)

func change_char_collision(layer, val):
	for c in party.values():
		c.get_collider().set_collision_layer_bit(layer, val)

func clear_selected():
	if selected_character:
		selected_character.deselect(false)
		selected_character = null

func reset_selected(new):
	if selected_character:
		selected_character.deselect(false)
		selected_character.set_position(selected_character_original_pos)
		selected_character = null
	
	selected_character = new
	selected_character_original_pos = new.get_position()
	selected_character.select()
	change_char_collision(0, false)

func ui_selected(character):
	reset_selected(character)
