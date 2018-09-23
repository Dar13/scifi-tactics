extends Panel

signal expand

onready var stat_container = get_node("control_container/stat_container")
onready var meta_container = stat_container.get_node("./meta_container")
onready var icon = get_node("./control_container/icon")
onready var char_name = meta_container.get_node("./info_container/name")
onready var level = meta_container.get_node("./info_container/level_container/level")
onready var experience = meta_container.get_node("./info_container/level_container/experience")
onready var health_bar = stat_container.get_node("./health_container/health_bar")
onready var energy_bar = stat_container.get_node("./energy_container/energy_bar")
onready var expando = get_node("./expando")

func _ready():
	expando.connect("pressed", self, "do_expand")

func do_expand():
	emit_signal("expand")

func fill(c):
	char_name.text = "Darius <TEMP>"
	level.text = "Level %s" % c.state.level
	experience.text = "Experience %s" % c.state.experience
	health_bar.max_value = c.state.max_health
	health_bar.value = c.state.health
	energy_bar.max_value = c.state.max_energy
	energy_bar.value = c.state.energy
