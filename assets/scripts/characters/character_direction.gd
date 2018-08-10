# North -> +X, South -> -X, East -> -Z, West -> +Z
enum CharDirections { North = 0, South = 1, East = 2, West = 3 }

# These are absolute directions/normals
const directions = {
	CharDirections.North : {"angle": PI * 1.5, "normal": Vector3(-1, 0, 0) },
	CharDirections.South : {"angle": PI * 0.5, "normal": Vector3(1, 0, 0) },
	CharDirections.East : {"angle": 0.0, "normal": Vector3(0, 0, -1) },
	CharDirections.West : {"angle": PI, "normal" : Vector3(0, 0, 1) }
}

# Returns angle on Y-axis in radians, assuming forward is -Z
static func get_abs_rotation(dir):
	return directions[dir]["angle"]

static func get_abs_normal(dir):
	return directions[dir]["normal"]

# Returns the appropriate CharacterDirection to use to 'look'
# at the target position. Both coordinates should be in world
# space.
static func look_at(current_pos, target_pos):
	# Convert into 2D coordinate (X,Z)
	current_pos.y = 0
	target_pos.y = 0

	var diff = target_pos - current_pos
	diff = diff.normalized()
	var abs_v = diff.abs()

	var s = Vector3(0, 0, 0)
	if abs_v.x != 0.0: s.x = diff.x / abs_v.x
	if abs_v.y != 0.0: s.y = diff.y / abs_v.y
	if abs_v.z != 0.0: s.z = diff.z / abs_v.z

	var axis = abs_v.max_axis()
	var v = Vector3(0,0,0)
	if axis == Vector3.AXIS_X:
		v = Vector3(1, 0, 0)
	elif axis == Vector3.AXIS_Y:
		v = Vector3(0, 1, 0)
	else:
		v = Vector3(0, 0, 1)
	
	v = v * s
	#print("T %s - C %s = N %s, Final: %s" % [target_pos, current_pos, diff, v])
	for d in directions.keys():
		if directions[d]["normal"] == v:
			return d
	
	print("Unable to find direction! v = %s" % v)
	return CharDirections.North
