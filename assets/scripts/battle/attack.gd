extends Object

var tile_type = load("res://assets/scripts/maps/tile.gd")

# Attack types cause certain statuses
enum AttackType {
	Physical = 0,	# The default type
	Tech,		# Effectively electrical
	Explosion,
	Freezing,
	NumAttackTypes,
	Invalid
}

var causes_status = tile_type.TileStatus.Invalid

var phys_attack_magnitude = 0
var tech_attack_magnitude = 0

# Statuses cause specific types of additional damage, this is a scaling factor for
# that damage
var status_scaling = 0.0

func _init(type, p_atk, t_atk, scale):
	phys_attack_magnitude = p_atk
	tech_attack_magnitude = t_atk

	if scale == 0.0:
		scale = 1.0

	status_scaling = scale

	match type:
		AttackType.Physical:
			causes_status = tile_type.TileStatus.None
		AttackType.Tech:
			causes_status = tile_type.TileStatus.Electrified
		AttackType.Explosion:
			causes_status = tile_type.TileStatus.None
		AttackType.Freezing:
			causes_status = tile_type.TileStatus.Frozen
		_:
			print("attack._init(): Type given(%s) is not valid!" % type)

func total():
	return phys_attack_magnitude + tech_attack_magnitude
