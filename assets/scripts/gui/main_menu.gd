extends CanvasLayer

onready var new_game = get_node("./menu_buttons/new")
onready var continue_game = get_node("./menu_buttons/continue")
onready var options = get_node("./menu_buttons/options")
onready var exit = get_node("./menu_buttons/exit")

export var new_game_scene = ""
export var continue_game_scene = ""
export var options_scene = ""

func _ready():
	new_game.connect("pressed", self, "start_new")
	continue_game.connect("pressed", self, "load_game")
	options.connect("pressed", self, "go_to_options")
	exit.connect("pressed", self, "exit_game")
	pass

func start_new():
	global_state.next_scene = new_game_scene
	Utils.handle_error(self, get_tree().change_scene("res://assets/scenes/loading.tscn"), true)

func load_game():
	Utils.handle_error(self, get_tree().change_scene(continue_game_scene), true)

func go_to_options():
	Utils.handle_error(self, get_tree().change_scene(options_scene), true)

func exit_game():
	propagate_notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	pass
