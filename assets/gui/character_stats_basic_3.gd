extends Control

onready var icon = get_node("VBoxContainer/HBoxContainer2/icon")
onready var char_name = get_node("VBoxContainer/HBoxContainer/name")
onready var level = get_node("VBoxContainer/HBoxContainer/VBoxContainer/level")
onready var experience = get_node("VBoxContainer/HBoxContainer/VBoxContainer/experience")
onready var health_bar = get_node("VBoxContainer/HBoxContainer2/VBoxContainer/health_bar")
onready var energy_bar = get_node("VBoxContainer/HBoxContainer2/VBoxContainer/energy_bar")

func _ready():
	pass

func fill(c):
	char_name.text = "Darius <TEMP>"
	level.text = "Lvl %s" % c.state.level
	experience.text = "Exp %s" % c.state.experience
	health_bar.max_value = c.state.max_health
	health_bar.value = c.state.health
	energy_bar.max_value = c.state.max_energy
	energy_bar.value = c.state.energy