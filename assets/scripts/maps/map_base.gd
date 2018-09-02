extends Spatial

onready var grid = get_node("map_grid")

var grid_graph = {}
var grid_min = Vector3(100, 100, 100)
var grid_max = Vector3(-100, -100, -100)

var obstacles = []

const grid_directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]

class MapCell:
	var map_position		# Map coordinate of this tile
	var world_position		# World coordinate of this tile
	var previous			# Previous MapTile in path
	var distance			# Number of MapTiles traveled to get to this point
	func _init(map_pos, world_pos, prev, dist):
		map_position = map_pos
		world_position = world_pos
		previous = prev
		distance = dist

func _ready():
	# Calculate grid extents for later use
	for cell in grid.get_used_cells():
		if grid_min.x > cell.x: grid_min.x = cell.x
		if grid_min.y > cell.y: grid_min.y = cell.y
		if grid_min.z > cell.z: grid_min.z = cell.z
		
		if grid_max.x < cell.x: grid_max.x = cell.x
		if grid_max.y < cell.y: grid_max.y = cell.y
		if grid_max.z < cell.z: grid_max.z = cell.z
	
	#print("Grid extents [%s,%s]" % [grid_min, grid_max])
	
	# Cache top layer of cell map coordinates so later lookups are easy
	for x in range(grid_min.x, grid_max.x + 1):
		for z in range(grid_min.z, grid_max.z + 1):
			var highest_y = grid_min.y
			for y in range(grid_min.y, grid_max.y + 1):
				if is_pos_in_grid(Vector3(x, y, z)) == true:
					highest_y = y

			grid_graph[Vector2(x, z)] = Vector3(x, highest_y, z)

	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func set_obstacles(arr):
	# This is a bit paranoid, but may need to iterate over this
	# in order to correctly manage memory
	if obstacles.empty() == false:
		obstacles.clear()
	
	obstacles = arr

# Returns y-height if cell exists at X and Z coordinate, else returns null
func get_cell_height_if_exists(map_pos):
	var xz = Vector2(map_pos.x, map_pos.z)
	if grid_graph.has(xz):
		return grid_graph[xz].y

	return null

func get_neighbors(map_pos, max_vertical):
	var neighbors = []
	for dir in grid_directions:
		var tmp = map_pos + dir
		# Working around not having tuples/other niceties
		var res = is_pos_top_level(tmp)
		if res.front() == false:
			continue

		tmp = res.back()
		var vert_dist = map_pos.y - tmp.y
		if vert_dist <= max_vertical && obstacles.find(tmp) == -1:
			neighbors.append(MapCell.new(tmp, get_world_coords(tmp), null, 0))
	
	return neighbors

# This is an implementation of BFS, this may need to be revisited for performance
# reasons later on.
func get_cells_in_range(world_pos, move_range, max_vertical):
	var start_grid_pos = get_map_coords(world_pos)

	if is_pos_in_grid(start_grid_pos) == false:
		return []

	var visited_cells = [ MapCell.new(start_grid_pos, get_world_coords(start_grid_pos), null, 0) ]
	var finished_cells = []

	while !visited_cells.empty():
		var min_dist = visited_cells[0].distance
		var min_idx = 0

		for i in range(1, visited_cells.size()):
			if visited_cells[i].distance < min_dist:
				min_dist = visited_cells[i].distance
				min_idx = i

		# Found our set of appropriate cells
		if min_dist > move_range:
			return finished_cells

		var cell = visited_cells[min_idx]
		var neighbors = get_neighbors(cell.map_position, max_vertical)
		finished_cells.append(cell)
		visited_cells.erase(cell)

		for n in neighbors:
			var contained = contains_cell(n, visited_cells)
			if contained == null:
				contained = contains_cell(n, finished_cells)

			# The real cost of the neighbor is the vertical distance + 1
			var real_cost = abs(n.map_position.y - cell.map_position.y) + 1

			if contained == null:
				n.distance = cell.distance + real_cost
				n.previous = cell
				visited_cells.append(n)
			elif contained.distance > cell.distance + real_cost:
				contained.previous = cell
				contained.distance = cell.distance + real_cost


	return finished_cells

func contains_cell(cell, container):
	for i in container:
		if cell.map_position == i.map_position:
			return i

	return null

func is_pos_top_level(pos):
	var v2 = Vector2(pos.x, pos.z)
	var res = []
	if grid_graph.has(v2):
		res = [true, grid_graph[v2]]
	else:
		res = [false, null]

	return res

func is_pos_in_grid(map_pos):
	return (grid.get_cell_item(map_pos.x, map_pos.y, map_pos.z) != -1)

func get_world_coords(map_pos):
	return grid.map_to_world(map_pos.x, map_pos.y, map_pos.z)

func get_map_coords(world_pos):
	return grid.world_to_map(world_pos)
