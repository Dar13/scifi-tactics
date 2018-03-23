extends MeshInstance

var material = null
var color = Color(0.0, 0.0, 0.0, 1.0) setget set_color,get_color

func _ready():
	# Initialization here
	
	material = self.get_surface_material(0)
	set_color(color)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func display(new_pos, color):
	set_identity()
	global_translate(new_pos)
	set_color(color)
	show()

func set_color(new_value):
	if material is SpatialMaterial:
		material.albedo_color = new_value
	else:
		print("%s Material isn't Spatial, gotta handle the other ones..." % [self])
	
	pass

func get_color(new_value):
	var rv = Color(0, 0, 0, 1.0)
	if material is SpatialMaterial:
		rv = material.albedo_color
	else:
		print("%s Material isn't Spatial, gotta handle the other ones..." % [self])
	
	return rv