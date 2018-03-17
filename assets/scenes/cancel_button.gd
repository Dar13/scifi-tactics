extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal cancel

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("button_up", self, "handle_pressed")
	pass

func handle_pressed():
	emit_signal("cancel")
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
