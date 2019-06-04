extends CanvasLayer

onready var progress = get_node("./bg/progress")
onready var fade = get_node("./fade")

var loader
var cur_scene

var loading = 0

var fade_elapsed = 0
var fade_duration = 0.250 	# 250 ms
var fade_trans = Color(0, 0, 0, 0)
var fade_solid = Color(0, 0, 0, 1)

func _ready():
	# TODO: Check if file exists instead
	if global_state.next_scene == "":
		print("Next scene is not valid!")
	else:
		loader = ResourceLoader.load_interactive(global_state.next_scene)
	
	progress.max_value = loader.get_stage_count() - 1
	progress.value = loader.get_stage()
	loading = 0

func _physics_process(delta):
	match loading:
		0:
			fade.color = fade_solid.linear_interpolate(fade_trans, fade_elapsed / fade_duration)
			fade_elapsed += delta
		1:
			var status = loader.poll()
			progress.value = loader.get_stage()
			if status == ERR_FILE_EOF:
				loading += 1
			elif status != OK:
				print("Error! %s" % status)
		2:
			fade.color = fade_trans.linear_interpolate(fade_solid, fade_elapsed / fade_duration)
			fade_elapsed += delta
		3:
			Utils.handle_error(self, get_tree().change_scene_to(loader.get_resource()))

	if fade_elapsed > fade_duration:
		loading += 1
		fade_elapsed = 0
