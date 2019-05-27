extends Node

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		global_state.quit_requested = 1
		Utils.handle_error(self, get_tree().change_scene("res://assets/scenes/shutdown.tscn"), true)
