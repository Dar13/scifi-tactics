extends "res://assets/models/equipment/equipment_base.gd"

func _init():
	e_name = "Basic Vest"
	e_desc = "A basic vest, not quite covering your torso but still getting all the important bits."

	state.armor_value = 1
	state.disruption_value = 2

	setup_thumbnail("res://assets/gui/placeholder_black.png")

func _ready():
	pass

func _exit_tree():
	destroy()
