extends Node

onready var party = null
onready var mouse_pos = Vector2(0, 0)
onready var perform_click_raycast = false

onready var camera = get_viewport().get_camera()
onready var map = get_node("../map")

onready var selected_character = null
onready var selected_character_original_pos = Vector3(0, 0, 0)

func _ready():
	pass

func _physics_process(delta):
	var cast_origin = camera.project_ray_origin(mouse_pos)
	var cast_target = camera.project_ray_normal(mouse_pos) * 5000
	var phys_space = camera.get_world().get_direct_space_state()
	var cast_result = phys_space.intersect_ray(cast_origin, cast_target)

	# Click processing here
	if perform_click_raycast == true:
		perform_click_raycast = false
		if cast_result.empty() == false:
			handle_click(cast_result["collider"])
	
	if selected_character && cast_result.empty() == false:
		# Determine the map tile the mouse is hovering over
		# Move the selected character to it
		# TODO: Make sure the map tile is within the placement area
		# TODO: Only do this is the cast result is a placement tile
		var map_coords = map.get_map_coords(cast_result["position"])
		selected_character.set_position(map.get_world_coords(map_coords))

func _unhandled_input(event):
	if event.is_action("left_click") && event.pressed == false:
		perform_click_raycast = true

	if event is InputEventMouse:
		mouse_pos = event.global_position

func set_party(p):
	party = p

func handle_click(collider):
	var parent = collider.get_parent()
	if party.has(collider.get_instance_id()):
		reset_selected(parent)

func reset_selected(new):
	if selected_character:
		selected_character.deselect(false)
		selected_character.set_position(selected_character_original_pos)
		selected_character = null
	
	selected_character = new
	selected_character_original_pos = new.get_position()
	selected_character.select()
