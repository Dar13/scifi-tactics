extends "res://assets/scripts/equipment/equipment_state.gd"

# TODO: ?
enum Types {
	Sword = 0,
	Spear,
	Blunt
}

# TODO: Do we need to correlate these to a type?
enum Names {
	BASIC,
}

# The ability of this weapon to express damage physically (boosted by PWR)
var phys_attack_power = 0

# The ability of this weapon to express damage via tech (boosted by EPT)
var tech_attack_power = 0

# The range of the basic attack of this weapon
var attack_range = 0

# TODO: These might need to be promoted into equipment_state...
# The amount of armor provided by this weapon
var armor_value = 0

# The amount of disruption provided by this weapon
var disruption_value = 0

func _init():
	._init()

func _ready():
	pass
