extends Control

onready var icon = get_node("VBoxContainer/HBoxContainer/icon")
onready var char_name = get_node("VBoxContainer/HBoxContainer/VBoxContainer/name")
onready var level = get_node("VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level")
onready var experience = get_node("VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/experience")
onready var health_bar = get_node("VBoxContainer/HBoxContainer2/health_bar")
onready var energy_bar = get_node("VBoxContainer/HBoxContainer3/energy_bar")

func _ready():
	pass

func fill(c):
	char_name.text = "Darius <TEMP>"
	level.text = "Level %s" % c.state.level
	experience.text = "Experience %s" % c.state.experience
	health_bar.max_value = c.state.max_health
	health_bar.value = c.state.health
	energy_bar.max_value = c.state.max_energy
	energy_bar.value = c.state.energy