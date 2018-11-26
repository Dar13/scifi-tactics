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
