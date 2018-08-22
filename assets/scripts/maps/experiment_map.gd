extends Spatial

onready var grid = get_node("./GridMap")

func _ready():
	for c in grid.get_used_cells():
		grid.set_cell_item(c.x, c.y, c.z, 1)
