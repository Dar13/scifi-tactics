extends "res://assets/models/equipment/weapon_base.gd"

func _init():
	e_name = "Basic Pistol"
	e_desc = "A pistol so basic it barely qualifies as a weapon..."

	state.attack_range = 5

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
	var pattern = []
	for x in range(-state.attack_range, state.attack_range):
		for z in range(-state.attack_range, state.attack_range):
			if x == 0 and z == 0:
				continue

			var pos = map_pos + Vector3(x, 0, z)
			pattern.append(pos)

	return pattern

func do_special_effect(character):
	print("derived do_special_effect called!")

func check_target(object):
	if object is character:
		return true
	else:
		return false

func do_attack(object):
	var rv = false
	if object is character:
		# In a "real" weapon, this would trigger an animation to run
		print("attacking %s" % character)
		rv = true

	return rv
