extends PopupPanel

var character_class = load("res://assets/scripts/characters/character.gd")

onready var compact_layout = get_node("./compact")
onready var expanded_layout = get_node("./expanded")

func _ready():
	pass

func populate(character):
	if character is character_class:
		compact_layout.fill(character)
