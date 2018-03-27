extends Node

# This is the data section of a character, containing the character class,
# combat stats, character stats, items held, abilities, learned, level, experience, etc.

enum Classes {
	BASIC = 0,
}

var character_class = Classes.BASIC
var movement_range = 5

func _ready():
	pass
