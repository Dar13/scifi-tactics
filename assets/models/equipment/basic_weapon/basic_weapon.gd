extends Spatial

const state_class = preload("res://assets/scripts/equipment/weapons/weapon_state.gd")

var state = null

func _init():
	state = state_class.new()
	
	state.attack_power = 2
	state.attack_range = 1
	
	state.defense_power = 1
	
	# If weapon boosts anything held in equipment_state, set it hee
	state.tech_boost = 1

func _ready():
	pass

func get_state():
	return state

func get_attack_pattern(map_pos):
	var pattern = [map_pos + Vector3(1, 0, 0), map_pos + Vector3(-1, 0, 0),
				   map_pos + Vector3(0, 0, 1), map_pos + Vector3(0, 0, -1)]
	return pattern

# Quick test of inheritance capabilities
func do_special_effect(character):
	print("derived do_special_effect called!")