extends "res://assets/models/equipment/ability_base.gd"

func _init():
	e_name = "Laser"
	e_desc = """A high-powered laser, capable of burning through almost anything
		    if given enough time."""

	# TODO: This will likely break things, but it's time to fix them anyways
	state.ability_range = 3

	state.type = state.AbilityType.Missile
	state.category = state.AbilityCategory.Cybernetic

	state.tech_attack_power = 0.5

func _ready():
	pass

func _exit_tree():
	destroy()

func get_state():
	return state

func get_range_pattern(map_pos):
	var pattern = []
	# This creates a diamond going out from center
	for x in range(0, state.ability_range + 1):
		for z in range(x - state.ability_range, state.ability_range - x + 1):
			if x == 0 and z == 0:
				continue

			var pos = map_pos + Vector3(x, 0, z)
			pattern.append(pos)

	for x in range(-1, -state.ability_range - 1, -1):
		for z in range(state.ability_range + x, -x - state.ability_range - 1, -1):
			var pos = map_pos + Vector3(x, 0, z)
			pattern.append(pos)

	return pattern

# Single square selection
func get_selection_pattern(map_pos):
	return [map_pos]

func do_attack(object):
	var rv = false
	# TODO: Laser animation starts here
	if object:
		print("Attacking %s with LAZOR" % object)
		rv = true

	return rv

func check_target(object):
	# Lasers don't care about what a target is...
	# TODO: Unless it's the floor?
	return true
