extends "res://assets/models/equipment/ability_base.gd"

func _init():
	e_name = "Laser"
	e_desc = """A high-powered laser, capable of burning through almost anything
		    if given enough time."""

	# TODO: This will likely break things, but it's time to fix them anyways
	state.ability_range = 10

	state.type = state.AbilityType.Missile
	state.category = state.AbilityCategory.Cybernetic

func _ready():
	pass

func _exit_tree():
	destroy()

func get_state():
	return state

func get_range_pattern(map_pos):
	var pattern = []
	for x in range(-state.ability_range, state.ability_range):
		for z in range(-state.ability_range, state.ability_range):
			if x == 0 and z == 0:
				continue

			var pos = map_pos + Vector3(x, 0, z)
			pattern.append(pos)
	
	return pattern

# Single square selection
func get_selection_pattern(map_pos):
	return map_pos
