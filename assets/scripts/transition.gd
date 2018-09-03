extends Node

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		global_state.quit_requested = 1
		print_stats("quit")
		get_tree().change_scene("res://assets/scenes/shutdown_scene.tscn")

func _enter_tree():
	print_stats("creation")
	if global_state.quit_requested == 1:
		get_tree().quit()

func _exit_tree():
	print_stats("destruction")

func print_stats(phase):
	if global_state.debug_mode == 1:
		var dyn_mem_used = Performance.get_monitor(Performance.MEMORY_DYNAMIC)
		var static_mem_used = Performance.get_monitor(Performance.MEMORY_STATIC)
		var obj_count = Performance.get_monitor(Performance.OBJECT_COUNT)
		print("Statistics at %s:" % phase)
		print("  - Object count = %s" % obj_count)
		print("  - Static memory used = %s" % static_mem_used)
		print("  - Dynamic memory used = %s" % dyn_mem_used)
