extends Camera

# class member variables go here, for example:
var position = null
onready var tween = get_node("camera_tween")

class CameraPosition:
	var offset
	var view_target

	func _init():
		view_target = Vector3(0, 0, 0)
		offset = Vector3(8, 10, 8)

	func update(camera, delta_angle):
		self.offset = orbit_xz(delta_angle, offset)
		camera.set_identity()
		camera.translate(self.view_target + self.offset)
		camera.look_at(self.view_target, Vector3(0, 1, 0))

	func orbit_xz(angle, current):
		var translated = Vector2(current.x, current.z)
		# TODO: Cache sin/cos
		current.x = (translated.x * cos(angle)) - (translated.y * sin(angle))
		current.z = (translated.x * sin(angle)) + (translated.y * cos(angle))
		return current

func _init():
	position = CameraPosition.new()

func _ready():
	# Initialization here, when added to tree
	position.update(self, 0)
	pass

func center_around_point(point):
	tween.interpolate_property(position, "view_target", position.view_target, point, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	tween.start()
	position.update(self, 0)

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	position.update(self, 0)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("middle_click"):
			var x_angle = (event.relative.x / OS.window_size.x) * TAU
			position.update(self, x_angle)
	return