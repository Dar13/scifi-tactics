extends KinematicBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var state = load("res://assets/scripts/characters/character_state.gd")

signal display_move_tiles(character, distance)

var curr_phase = state.Phases.Unselected
signal update_state(character, new_state)

export var movement_range = 5

var is_selected = false
var character_material = null
onready var character_mesh = get_node("mesh")

var movement_cell_list = []
var movement_target = null
var movement_path = []

var map = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	if character_mesh != null && character_mesh is MeshInstance:
		character_material = character_mesh.get_surface_material(0)
	
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.

	# Time to start movement, move towards the next path node at 1 m/s for now
	if curr_phase == state.Phases.MoveStart:
		if movement_path.empty():
			emit_signal("update_state", self, state.Phases.MoveEnd)
			emit_signal("update_state", self, state.Phases.Action)
		else:
			var target_world_pos = map.get_world_coords(movement_path.front().map_position)
			target_world_pos.y += 2
			
			var direction = (target_world_pos - self.translation)
			
			direction = (direction.normalized() * 2) * delta
			self.translate(direction)
			
			var distance = self.translation.distance_to(target_world_pos)
			if distance <= 0.01:
				set_position(target_world_pos)
				movement_path.pop_front()
	
	pass

func set_position(position):
	self.set_identity()
	self.global_translate(position)

func set_movement_space(cell_list):
	movement_cell_list = cell_list

func select():
	is_selected = true
	if character_material is SpatialMaterial:
		character_material.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
	
	emit_signal("update_state", self, state.Phases.Selected)
	
	return

func deselect():
	is_selected = false
	if character_material is SpatialMaterial:
		character_material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	
	emit_signal("update_state", self, state.Phases.Unselected)
	
	return

func move(tgt_map_coord):
	for cell in movement_cell_list:
		if cell.map_position == tgt_map_coord:
			print("Moving to %s" % [ cell.map_position ])
			emit_signal("update_state", self, state.Phases.MoveStart)
			
			movement_target = cell
			
			# The movement_target is of type MapCell, and the 'previous' field allows us to
			# walk backwards to find the shortest path to take from our target to us.
			# So let's walk back and generate a forward-looking path that's easier to think
			# about.
			var conductor = movement_target
			while conductor.previous != null:
				movement_path.push_front(conductor)
				conductor = conductor.previous