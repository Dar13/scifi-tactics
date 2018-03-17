extends StaticBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal input_click(source, camera, event, click_pos, click_norm, shape_idx)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("input_event", self, "handle_input")
	pass

func handle_input(camera, event, click_pos, click_norm, shape_idx):
	emit_signal("input_click", self, camera, event, click_pos, click_norm, shape_idx)
	return

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
