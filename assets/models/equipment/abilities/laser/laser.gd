extends "res://assets/models/equipment/ability_base.gd"

var utils = load("res://assets/scripts/utils/utils.gd")

func _init():
	e_name = "Laser"
	e_desc = "A high-powered laser, capable of burning through almost anything if given enough time."

	state.ability_range = 7

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
	return utils.generate_diamond(map_pos, true, state.ability_range)

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
