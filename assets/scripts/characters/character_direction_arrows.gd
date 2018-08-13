extends Node

signal cancelled
signal confirmed

var char_dir = load("res://assets/scripts/characters/character_direction.gd")

onready var arrows = get_node("./arrows")
onready var ui = get_node("./cancel")

var direction_arrows = {}
var selected_direction = char_dir.CharDirections.North

func _ready():
	ui.connect("pressed", self, "cancel")
	for c in arrows.get_children():
		var dir = char_dir.CharDirections.North
		if c.name == "north_arrow": dir = char_dir.CharDirections.North
		if c.name == "south_arrow": dir = char_dir.CharDirections.South
		if c.name == "west_arrow": dir = char_dir.CharDirections.West
		if c.name == "east_arrow": dir = char_dir.CharDirections.East
		direction_arrows[c.name] = dir
	
	print(direction_arrows)

func hide():
	ui.hide()
	arrows.hide()
	# TODO: Disable physics/raycasting?

func show():
	ui.show()
	arrows.show()
	# TODO: Enable physics/raycasting?

func is_visible():
	return arrows.visible

func cancel():
	emit_signal("cancelled")

func set_position(pos):
	arrows.translation = pos
	arrows.translation.y += 1

func select_arrow(obj):
	if is_visible() && direction_arrows.has(obj.name):
		selected_direction = direction_arrows[obj.name]
		print("selected %s = %s" % [obj.name, selected_direction])
		emit_signal("confirmed")
		return true
	else:
		return false

func highlight_arrow(obj):
	for o in arrows.get_children():
		var mat = o.get_surface_material(0)
		if o == obj:
			mat.albedo_color = Color(1.0, 1.0, 0.0, 1.0)
		else:
			mat.albedo_color = Color(0.0, 0.0, 0.0, 1.0)
