class_name Utils

# Generates array of 3D points that make a diamond shape
# Note: y-coordinate of 3D points will be zero
# center 	- Vector3
# clear_center  - boolean
# size 		- int
static func generate_diamond(center, clear_center, size):
	var pattern = []
	for x in range(0, size + 1):
		for z in range(x - size, size - x + 1):
			if x == 0 and z == 0 and clear_center == true:
				continue

			var pos = center + Vector3(x, 0, z)
			pattern.append(pos)

	for x in range(-1, -size - 1, -1):
		for z in range(size + x, -x - size - 1, -1):
			var pos = center + Vector3(x, 0, z)
			pattern.append(pos)

	return pattern

static func handle_error(obj: Node, error, do_stack_dump: bool = false):
	var err_dlg = null
	var stack = null

	if do_stack_dump:
		stack = get_stack()
		stack.pop_front()  # Get rid of the 'handle_error' stack entry

	# Try and handle a few different types of error objects/values.
	# 1. The global-scope Error enum:
	if (error is int && error != OK):
		err_dlg = global_state.error_popup.new(error, stack)
	# 2. An object of some sort:
	elif (error == null):
		err_dlg = global_state.error_popup.new("Null object!", stack)
	# 3. A string:
	elif (error is String):
		err_dlg = global_state.error_popup.new(error, stack)

	if err_dlg != null:
		obj.add_child(err_dlg)
