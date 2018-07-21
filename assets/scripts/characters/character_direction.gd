# North -> +X, South -> -X, East -> -Z, West -> +Z
enum CharDirections { North = 0, South = 1, East = 2, West = 3 }

const directions = {
	CharDirections.North : {"angle": PI * 1.5, "normal": Vector3(1, 0, 0) },
	CharDirections.South : {"angle": PI * 0.5, "normal": Vector3(-1, 0, 0) },
	CharDirections.East : {"angle": 0.0, "normal": Vector3(0, 0, -1) },
	CharDirections.West : {"angle": PI, "normal" : Vector3(0, 0, 1) }
}

# Returns angle on Y-axis in radians, assuming forward is -Z
static func get_abs_rotation(dir):
	return directions[dir]["angle"]

static func get_abs_normal(dir):
	return directions[dir]["normal"]

static func get_dir(base_dir, target_point):
	# This is a 2D rotation at the end of the day
	target_point.y = 0

	var curr = get_abs_normal(base_dir)
	var tgt = target_point.normalized()
	var angle = acos(curr.dot(tgt))

	angle = angle / PI 		# Get rid of PI
	angle = round(angle * 2) / 2	# Clamp value to some multiple of 0.5
	angle = angle * PI		# Convert to radians
	angle = fmod(angle, TAU)	# Make sure we're in 0 -> 2PI range

	if angle == directions[CharDirections.North]["angle"]:
		return CharDirections.North
	elif angle == directions[CharDirections.South]["angle"]:
		return CharDirections.South
	elif angle == directions[CharDirections.East]["angle"]:
		return CharDirections.East
	elif angle == directions[CharDirections.West]["angle"]:
		return CharDirections.West
	else:
		print("Invalid direction found, angle = %s" % angle)
		return CharDirections.North
