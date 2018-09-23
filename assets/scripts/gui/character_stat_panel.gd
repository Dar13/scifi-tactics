extends CanvasLayer

onready var compact = get_node("./basic")
onready var expanded = get_node("./detailed")

var curr_character = null

var visible = true
var show_compact = true

func _ready():
	compact.hide()
	compact.connect("expand", self, "swap_mode")

	expanded.hide()
	expanded.connect("shrink", self, "swap_mode")

func set_character(c):
	curr_character = c
	compact.fill(curr_character)
	expanded.fill(curr_character)

func hide():
	compact.hide()
	expanded.hide()
	visible = false

func show():
	visible = true
	show_compact = true
	compact.show()
	expanded.hide()

func swap_mode():
	if show_compact:
		compact.hide()
		expanded.show()
		show_compact = false
	else:
		expanded.hide()
		compact.show()
		show_compact = true
