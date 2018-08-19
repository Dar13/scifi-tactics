extends Node

# Base class for all equipment, as most equipment share certain characteristics
var equip_state = load("res://assets/scripts/equipment/equipment_state.gd")

var instance = null

func _ready():
	pass

func get_state():
	return instance.get_state()
