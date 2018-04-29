extends "res://assets/scripts/characters/equipment.gd"

# The various weapons
# TODO: is there a better way to do this?
const state_class = preload("res://assets/scripts/equipment/weapons/weapon_state.gd")
const basic = preload("res://assets/models/equipment/basic_weapon/basic_weapon.tscn")

# Weapon specialization of equipment
enum Name {
	BASIC,
}

var instance = null

func _ready():
	pass

func init(name):
	match name:
		Name.BASIC:
			instance = basic.instance()

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