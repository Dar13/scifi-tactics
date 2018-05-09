extends Panel

const character_class = preload("res://assets/scripts/characters/character.gd")

onready var level_num_label = get_node("container/level_div/level_div/level_number")
onready var experience_num_label = get_node("container/level_div/experience_div/experience_number")
onready var icon = get_node("container/name_div/icon")
onready var name_label = get_node("container/name_div/name")
onready var health_num_label = get_node("container/status_div/health_div/health_number")
onready var energy_num_label = get_node("container/status_div/energy_div/energy_number")
onready var armor_num_label = get_node("container/defense_div/armor_div/armor_number")
onready var disruption_num_label = get_node("container/defense_div/disruption_div/disruption_number")

func _ready():
	pass

func populate(character):
	if character is character_class:
		level_num_label.text = "%s" % character.state.level
		experience_num_label.text = "%s" % character.state.experience
		name_label.text = "Character %s" % character
		health_num_label.text = "%s / %s" % [character.state.health, character.state.max_health]
		energy_num_label.text = "%s / %s" % [character.state.energy, character.state.max_energy]
		armor_num_label.text = "%s" % character.state.armor
		disruption_num_label.text = "%s" % character.state.disruption
		
		