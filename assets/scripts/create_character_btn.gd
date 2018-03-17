extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("button_up", self, "handle_pressed")
	pass

func handle_pressed():
	var character_mgr = get_node("../character_manager")
	if character_mgr != null:
		character_mgr.add_character(Vector3(0.0, 2.0, 0.0))
		

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
