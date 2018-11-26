extends Camera

# class member variables go here, for example:
var position = null
onready var tween = get_node("camera_tween")

class CameraPosition:
	var offset
	var view_target

	func _init():
		view_target = Vector3(0, 0, 0)
		offset = Vector3(6, 6, 6)

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

const SPEED_LO = 0.50
const SPEED_HI = 0.25

func center_around_point(point, speed):
	tween.interpolate_property(position, "view_target", position.view_target, point, speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	tween.start()
	position.update(self, 0)

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	position.update(self, 0)
	pass

const DIR_UP = 0
const DIR_DOWN = 1
const DIR_RIGHT = 2
const DIR_LEFT = 3

func get_camera_dir_vec(dir, no_y):
	var vec = Vector3(0, 0, 0)
	match dir:
		DIR_UP:
			vec = -transform.basis.z
		DIR_DOWN:
			vec = transform.basis.z
		DIR_LEFT:
			vec = -transform.basis.x
		DIR_RIGHT:
			vec = transform.basis.x

	if no_y:
		vec.y = 0

	vec = vec.normalized()
	return vec

func _physics_process(delta):
	var movement_dir = Vector3(0, 0, 0)
	if Input.is_action_pressed("move_right"):
		movement_dir += get_camera_dir_vec(DIR_RIGHT, true)
	if Input.is_action_pressed("move_left"):
		movement_dir += get_camera_dir_vec(DIR_LEFT, true)
	if Input.is_action_pressed("move_up"):
		movement_dir += get_camera_dir_vec(DIR_UP, true)
	if Input.is_action_pressed("move_down"):
		movement_dir += get_camera_dir_vec(DIR_DOWN, true)

	# TODO: Fiddle about with the constant here, it's very much all about "feel"
	# TODO: MAKE SURE TO TEST THIS SHIT AT HIGH FRAMERATES (preferably on a 120/144hz panel as well)
	movement_dir = movement_dir.normalized() * 2
	if movement_dir.length_squared() != 0:
		center_around_point(position.view_target + movement_dir, SPEED_HI)

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("middle_click"):
			var x_angle = (event.relative.x / OS.window_size.x) * TAU
			position.update(self, x_angle)
	return
