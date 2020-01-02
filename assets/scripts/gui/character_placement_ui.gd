extends Control

signal selected(character)
signal finished()

var detail = load("res://assets/scenes/character_placement_detail.tscn")
onready var layout = get_node("./layout")
onready var ready_btn = get_node("./ready_btn")
onready var reset_options = get_node("./reset_option_btn")

var characters = []
var placed_characters = 0

func _ready():
	ready_btn.connect("pressed", self, "done")
	ready_btn.hide()

	reset_options.connect("pressed", self, "do_reset")
	reset_options.hide()

func done():
	print("placement done!")
	emit_signal("finished")

func do_reset():
	print("reset selections!")

func detail_picked(obj):
	emit_signal("selected", obj)

func character_pickedup(character):
	placed_characters -= 1
	eval_ready()

func character_placed(character):
	placed_characters += 1
	eval_ready()

func eval_ready():
	if placed_characters > 0:
		ready_btn.show()
		reset_options.show()

func set_characters(chars):
	for child in layout.get_children():
		child.queue_free()

	characters = chars
	for c in chars.values():
		var new_c = detail.instance()
		var char_name = "%s Lvl %d" % [c.state.character_name, c.state.level]
		new_c.get_node("layout/name").text = char_name
		new_c.connect("pressed", self, "detail_picked", [c])
		layout.add_child(new_c)
