extends Panel

signal shrink

var char_state = load("res://assets/scripts/characters/character_state.gd")

onready var shrinko = get_node("shrink")

onready var icon = get_node("./overview/icon")
onready var c_name = get_node("overview/info_container/meta_col/name")
onready var c_class = get_node("overview/info_container/meta_col/class")
onready var level = get_node("overview/info_container/meta_col/level")
onready var experience = get_node("overview/info_container/meta_col/experience")
onready var health_numeric = get_node("overview/info_container/meta_col/health_numeric")
onready var energy_numeric = get_node("overview/info_container/meta_col/energy_numeric")
onready var health_bar = get_node("overview/info_container/meta_col/health_bar")
onready var energy_bar = get_node("overview/info_container/meta_col/energy_bar")

func _ready():
	shrinko.connect("pressed", self, "do_shrink")

func do_shrink():
	emit_signal("shrink")

func fill(c):
	c_name.text = "Darius Detailed <TEMP>"
	c_class.text = c.state.character_class_str
	level.text = "Level %s" % c.state.level
	experience.text = "Experience %s" % c.state.experience
	health_numeric.text = "Health  %s / %s" % [c.state.health, c.state.max_health]
	health_bar.max_value = c.state.max_health
	health_bar.value = c.state.health

	energy_numeric.text = "Energy  %s / %s" % [c.state.energy, c.state.max_energy]
	energy_bar.max_value = c.state.max_energy
	energy_bar.value = c.state.energy
	pass
