extends Spatial

var state_class = load("res://assets/scripts/equipment/equipment_state.gd")
var character = load("res://assets/scripts/characters/character.gd")

var state = null
var e_name = "<null>"
var e_desc = "<null>"
var thumbnail = null

func _init():
	state = state_class.new()

func setup_thumbnail(thumb_path):
	thumbnail = load(thumb_path)

func destroy():
	if state:
		state.free()

func get_state():
	return state
