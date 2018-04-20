extends Node

# Base class for all equipment, as most equipment share certain characteristics
const equip_state_class = preload("res://assets/scripts/equipment/equipment_state.gd")
var equip_state = null

func _ready():
	pass

func apply_to_state(state):
	print("TODO: apply equipment boosts to character state")