extends Control

onready var icon = get_node("VSplitContainer/HSplitContainer/icon")
onready var char_name = get_node("VSplitContainer/HSplitContainer/VBoxContainer/name")
onready var level = get_node("VSplitContainer/HSplitContainer/VBoxContainer/HSplitContainer/VSplitContainer/level")
onready var experience = get_node("VSplitContainer/HSplitContainer/VBoxContainer/HSplitContainer/VSplitContainer/experience")
onready var health_bar = get_node("VSplitContainer/VBoxContainer/health_bar")
onready var energy_bar = get_node("VSplitContainer/VBoxContainer/energy_bar")

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