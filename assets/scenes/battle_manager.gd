extends Node

# class member variables go here, for example:
onready var camera = get_viewport().get_camera()

func _ready():
	# Called every time the node is added to the scene.
	
	# Initialize the battle scene
	camera.center_around_point(Vector3(0, 0, 0))
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
