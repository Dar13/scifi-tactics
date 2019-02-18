extends MeshInstance

const TILE_OFFSET = 0.65

var material = null
var color = Color(0.0, 0.0, 0.0, 1.0) setget set_color,get_color

var rigid_body = null

func _ready():
	# Initialization here
	
	material = self.get_surface_material(0)
	set_color(color)
	
	rigid_body = get_node("tile_body")
	conceal()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func display(new_pos, color):
	set_identity()
	global_translate(new_pos)
	set_color(color)
	# Enable collision layer 1
	rigid_body.set_collision_layer_bit(0, true)
	show()

func conceal():
	rigid_body.set_collision_layer_bit(0, false)
	hide()

func set_color(new_value):
	if material is SpatialMaterial:
		material.albedo_color = new_value
	else:
		material.set_shader_param("color_influence", Vector3(new_value.r, new_value.g, new_value.b))
		material.set_shader_param("alpha", new_value.a)
	
	pass

func get_color(new_value):
	var rv = Color(0, 0, 0, 1.0)
	if material is SpatialMaterial:
		rv = material.albedo_color
	else:
		print("%s Material isn't Spatial, gotta handle the other ones..." % [self])
	
	return rv
