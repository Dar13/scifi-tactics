extends Node

func _enter_tree():
	if global_state.quit_requested == 1:
		get_tree().quit()
