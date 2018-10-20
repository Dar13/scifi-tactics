extends Object

var tile_type = load("res://assets/scripts/maps/tile.gd")

# TODO: Convert to bit-wise flags
# Attack types cause certain statuses
enum AttackType {
	Invalid		= 0x0,
	Physical 	= 0x1,	# The default type
	Tech		= 0x2,	# Technology-based
	Hybrid		= (Physical | Tech),
	Explosion	= 0x4,
	Freezing	= 0x8,
}

var type = AttackType.Invalid

# TODO: Convert this and TileStatus to bitwise flags
var causes_status = tile_type.TileStatus.Invalid

var phys_attack_magnitude = 0
var tech_attack_magnitude = 0

# Statuses cause specific types of additional damage, this is a scaling factor for
# that damage
var status_scaling = 0.0

func _init(atk_type, p_atk, t_atk, scale):
	phys_attack_magnitude = p_atk
	tech_attack_magnitude = t_atk

	if scale == 0.0:
		scale = 1.0

	status_scaling = scale
	type = atk_type

	match atk_type:
		_:
			# TODO: Re-think status application entirely
			#print("attack._init(): Type given(%s) is not valid!" % type)
			pass

func total():
	return phys_attack_magnitude + tech_attack_magnitude
