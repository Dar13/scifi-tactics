extends "res://assets/models/equipment/equipment_base.gd"

func _init():
	e_name = "Basic Hat"

	state.armor_value = 2
	state.disruption_value = 0

	setup_thumbnail("res://assets/gui/placeholder_black.png")

func _ready():
	pass

func _exit_tree():
	destroy()
