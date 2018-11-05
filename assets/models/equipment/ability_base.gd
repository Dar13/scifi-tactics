extends Spatial

var state_class = load("res://assets/scripts/equipment/ability_state.gd")

var state = null
var e_name = "<null>"
var e_desc = "<null>"
var thumbnail = null

func _init():
	state = state_class.new()

func setup_thumbnail(thumb_path):
	thumbnail = ImageTexture.new()
	thumbnail.load(thumb_path)

func destroy():
	if state: 
		state.free()

func get_state():
	return state
