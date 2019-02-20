extends Control

signal selected(character)

var detail = load("res://assets/scenes/character_placement_detail.tscn")
onready var layout = get_node("./layout")

var characters = []

func _ready():
	pass

func detail_picked(obj):
	emit_signal("selected", obj)

func set_characters(chars):
	for child in layout.get_children():
		child.queue_free()

	characters = chars
	for c in chars.values():
		var new_c = detail.instance()
		# TODO: "%s Lvl %d" % [c.state.name, c.state.level]
		var char_name = "Darius <TEMP> Lvl %d" % c.state.level
		new_c.get_node("layout/name").text = char_name
		new_c.connect("pressed", self, "detail_picked", [c])
		layout.add_child(new_c)
