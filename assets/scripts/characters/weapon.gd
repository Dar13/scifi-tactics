extends "res://assets/scripts/characters/equipment.gd"

# The various weapons
# TODO: is there a better way to do this?
var wep_state = load("res://assets/scripts/equipment/weapons/weapon_state.gd")
var weapon_instances = {
	wep_state.Names.BASIC : load("res://assets/models/equipment/basic_weapon/basic_weapon.tscn")
}

var instance = null

func _ready():
	pass

func _exit_tree():
	destroy()

func init(name):
	instance = weapon_instances[name].instance()

func destroy():
	if instance:
		instance.destroy()
		instance.free()

func get_attack_pattern(map_pos):
	return instance.get_attack_pattern(map_pos)

# If the weapon has a usable special effect, do it
func do_special_effect(character):
	instance.do_special_effect(character)	# Dispatch?
	pass

func do_attack(object):
	return instance.do_attack(object)

func get_name():
	return instance.weapon_name

func get_thumbnail():
	return instance.thumbnail

func get_state():
	return instance.get_state()
