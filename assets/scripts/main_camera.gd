extends Camera

# class member variables go here, for example:
onready var position = CameraPosition.new()

class CameraPosition:
	var offset
	var view_target
	
	func update(camera, delta_angle):
		self.offset = orbit_xz(delta_angle, offset)
		camera.set_identity()
		camera.translate(self.view_target)
		camera.translate(self.offset)
		camera.look_at(self.view_target, Vector3(0, 1, 0))
		
	func orbit_xz(angle, current):
		var translated = Vector2(current.x, current.z)
		# TODO: Cache sin/cos
		current.x = (translated.x * cos(angle)) - (translated.y * sin(angle))
		current.z = (translated.x * sin(angle)) + (translated.y * cos(angle))
		
		return current


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	position.offset = Vector3(10, 12, 10)
	position.view_target = Vector3(0, 0, 0)
	position.update(self, 0)
	pass

func center_around_point(point):
	position.view_target = point
	position.update(self, 0)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func orbit_3d(angle, origin, current):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("middle_click"):
			var x_angle = (event.relative.x / OS.window_size.x) * TAU
			position.update(self, x_angle)
	return