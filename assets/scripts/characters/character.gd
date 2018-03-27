extends Spatial

# This is the logical root of a character, managing all aspects
# of a character, from its state (class, stats, items, abilities, etc)
# and it's visual and physical representation via the 'instance'

enum Phases { Unselected, Selected, MoveStart, MoveEnd, Action, Attack, Use, Standby, Done }
onready var current_phase = Phases.Unselected

signal update_phase(character, new_phase)

const character_state = preload("res://assets/scripts/characters/character_state.gd")
var state = null

const class_instances = {
	character_state.Classes.BASIC : preload("res://assets/models/characters/basic_character.tscn"),
}

var instance = null

# Movement information
var movement_cells = []
var movement_path = []

func _ready():
	pass

func _process(delta):
	# Time to start movement, move towards the next path node at 1 m/s for now
	if current_phase == Phases.MoveStart:
		if movement_path.empty():
			emit_signal("update_phase", self, Phases.MoveEnd)
			emit_signal("update_phase", self, Phases.Action)
		else:
			var target_world_pos = movement_path.front().world_position
			target_world_pos.y += 2

			var direction = (target_world_pos - self.translation)

			direction = (direction.normalized() * 2) * delta
			translate(direction)

			var distance = self.translation.distance_to(target_world_pos)
			if distance <= 0.01:
				set_position(target_world_pos)
				movement_path.pop_front()

func init(char_state, initial_position, initial_show):
	state = char_state

	instance = class_instances[state.character_class].instance()
	set_position(initial_position)

	if initial_show:
		instance.show()
	else:
		instance.hide()

	add_child(instance)

func select():
	instance.select()
	emit_signal("update_phase", self, Phases.Selected)

func deselect(do_update):
	instance.deselect()

	if do_update:
		emit_signal("update_phase", self, Phases.Unselected)

func get_collider():
	return instance

func get_visual_bounds():
	return instance.visual_bounds()

func set_position(pos):
	set_identity()
	translate(pos)

func set_movement_space(cells):
	movement_cells = cells

func move(tgt_map_coord):
	for cell in movement_cells:
		if cell.map_position == tgt_map_coord:
			#print("Moving to %s" % [ cell.map_position ])
			emit_signal("update_phase", self, Phases.MoveStart)

			# The cell is of type MapCell, and the 'previous' field allows us to
			# walk backwards to find the shortest path to take from our target to us.
			# So let's walk back and generate a forward-looking path that's easier to think
			# about.
			var conductor = cell
			while conductor.previous != null:
				movement_path.push_front(conductor)
				conductor = conductor.previous