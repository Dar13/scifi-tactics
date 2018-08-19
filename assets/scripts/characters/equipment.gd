extends Node

# Base class for all equipment, as most equipment share certain characteristics
var equip_state = load("res://assets/scripts/equipment/equipment_state.gd")
var equip_instances = {
	equip_state.EquipNames.BASIC_HAT : load("res://assets/models/equipment/basic_hat/basic_hat.tscn"),
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
