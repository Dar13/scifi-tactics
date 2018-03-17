extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal input_click(source, camera, event, click_pos, click_norm, shape_idx)

# Passes along the original
func handle_click(source, camera, event, click_pos, click_norm, shape_idx):
	emit_signal("input_click", source, camera, event, click_pos, click_norm, shape_idx)
	return

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	# Hook into child's 'input_click' signal
	var child_col = get_node("mesh/mesh_body")
	child_col.connect("input_click", self, "handle_click")
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass