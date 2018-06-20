extends PopupPanel

const character_class = preload("res://assets/scripts/characters/character.gd")

onready var layout_root = get_node("./root")

func _ready():
	pass

func populate(character):
	if character is character_class:
		layout_root.fill(character)