extends Spatial

var state_class = load("res://assets/scripts/equipment/weapons/weapon_state.gd")
var character = load("res://assets/scripts/characters/character.gd")

var state = null
var weapon_name = "Basic Weapon"
var thumbnail = null

func _init():
	state = state_class.new()
	
	state.attack_power = 2
	state.attack_range = 1
	
	state.defense_power = 1
	
	# If weapon boosts anything held in equipment_state, set it here
	state.tech_boost = 1
	
	thumbnail = ImageTexture.new()
	thumbnail.load("res://assets/gui/placeholder_black.png")

func _ready():
	pass

func _exit_tree():
	destroy()

func destroy():
	if state:
		state.free()

func get_state():
	return state

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
