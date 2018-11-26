extends KinematicBody

# This is the root of the 'instance' of a character,
# managing the visual and physics aspects of a character

var character_class = load("res://assets/scripts/characters/character.gd")
var character_direction = load("res://assets/scripts/characters/character_direction.gd")
var base_color = Color(1.0, 0.0, 0.0, 1.0)
var character_material = null
# 'character_root' == self
onready var character_mesh = get_node("mesh")

func _ready():
	character_material = SpatialMaterial.new()
	character_material.albedo_color = base_color
	if character_mesh != null && character_mesh is MeshInstance:
		character_mesh.set_surface_material(0, character_material)

func _exit_tree():
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	pass

func set_on_player_team():
	base_color = Color(0.0, 0.0, 1.0, 1.0)
	return

func set_direction(dir):
	# Default rotation is facing towards -Z (aka -> (0,0,-1))
	# Store translation, do identity, rotate, then translate back to original
	var translation = self.translation
	self.set_identity()
	self.rotate_y(character_direction.get_abs_rotation(dir))
	self.translate(translation)

func visual_bounds():
	return character_mesh.get_aabb()

func select():
	if character_material is SpatialMaterial:
		character_material.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
	return

func deselect():
	if character_material is SpatialMaterial:
		character_material.albedo_color = base_color
	return
