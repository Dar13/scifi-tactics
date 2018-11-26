extends Spatial

# This is the logical root of a character, managing all aspects
# of a character, from its state (class, stats, items, abilities, etc)
# and it's visual and physical representation via the 'instance'

# This is only relevant in the context of a battle, and there are
# battle-specific data in here

enum Phases { Unselected, Selected, MoveStart, MoveEnd, Action, AttackWeapon, AttackAbility, AttackConfirm, Use, Standby, StandbyFacing, Done }
onready var current_phase = Phases.Unselected

signal update_phase(character, new_phase)

var character_state = load("res://assets/scripts/characters/character_state.gd")
var character_direction = load("res://assets/scripts/characters/character_direction.gd")

var state = null

var class_instances = {
	#character_state.Classes.BASIC : load("res://assets/models/characters/basic_character/basic_character.tscn"),
	character_state.Classes.BASIC : load("res://assets/models/characters/basic_human/basic_human.tscn"),
}

var instance = null
var facing = character_direction.CharDirections.North

# Movement information
var movement_cells = []
var movement_path = []

# Private vars (Don't use these unless you're in a method)
var _oriented = false
var _move_speed = 5

func _ready():
	pass

func _exit_tree():
	if state:
		state.destroy()

	if instance:
		instance.free()

func _process(delta):
	# Time to start movement, move towards the next path node at 1 m/s for now
	if current_phase == Phases.MoveStart:
		if movement_path.empty():
			emit_signal("update_phase", self, Phases.MoveEnd)
			emit_signal("update_phase", self, Phases.Action)
		else:
			# Rotate towards new target
			if _oriented == false:
				_oriented = true
				var tgt = movement_path.front().world_position
				tgt.y += get_visual_bounds().size.y / 2
				var new_dir = character_direction.look_at(self.translation, tgt)
				set_direction(new_dir)

			var target_world_pos = movement_path.front().world_position
			target_world_pos.y += 0.5 # The size of the grid map cell

			var direction = (target_world_pos - self.translation)
			direction = (direction.normalized() * _move_speed) * delta
			translate(direction)

			# Snap to the final position if we're close enough
			var distance = self.translation.distance_to(target_world_pos)
			if distance <= 0.01:
				set_position(target_world_pos)
				movement_path.pop_front()
				_oriented = false

func init(char_state, initial_position, initial_show, direction):
	state = char_state

	state.prepare()
	add_child(state)

	instance = class_instances[state.character_class].instance()
	set_position(initial_position)

	if initial_show:
		instance.show()
	else:
		instance.hide()

	add_child(instance)
	set_direction(direction)

func add_equipment(item):
	state.add_equipment(item)

func add_ability(abi):
	state.add_ability(abi)

# This name suuuuuuckss....
func set_on_player_team():
	instance.set_on_player_team()

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

func set_direction(direction):
	facing = direction
	instance.set_direction(direction)

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
