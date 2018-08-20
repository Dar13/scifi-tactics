extends Node

# Base class for all equipment stats, as most equipment share certain characteristics
var equip_state = load("res://assets/scripts/equipment/equipment_state.gd")
var equip_instances = {
	equip_state.EquipNames.BASIC_HAT : load("res://assets/models/equipment/basic_hat/basic_hat.tscn"),
	equip_state.EquipNames.BASIC_VEST : load("res://assets/models/equipment/basic_vest/basic_vest.tscn")
}

var instance = null

func _ready():
	pass

func init(name):
	instance = equip_instances[name].instance()

func destroy():
	if instance:
		instance.destroy()
		instance.free()

func get_state():
	return instance.get_state()

func get_name():
	return instance.e_name
