extends "res://assets/models/equipment/weapon_base.gd"

func _init():
	e_name = "Basic Weapon"

	state.attack_range = 1

	state.phys_attack_power = 2
	state.tech_attack_power = 0
	
	# If weapon boosts anything held in equipment_state, set it here
	state.tech_boost = 0
	
	setup_thumbnail("res://assets/gui/placeholder_black.png")

func _ready():
	pass

func _exit_tree():
	destroy()

func get_attack_pattern(map_pos):
	var pattern = [map_pos + Vector3(1, 0, 0), map_pos + Vector3(-1, 0, 0),
				   map_pos + Vector3(0, 0, 1), map_pos + Vector3(0, 0, -1)]
	return pattern

# Quick test of inheritance capabilities
func do_special_effect(character):
	print("derived do_special_effect called!")

func do_attack(object):
	var rv = false
	if object is character:
		print("attacking %s" % character)
		rv = true

	return rv
