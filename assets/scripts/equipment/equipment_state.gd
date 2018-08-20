extends Node

enum EquipNames {
	BASIC_HAT,
	BASIC_VEST,
}

var power_boost = 0
var skill_boost = 0
var expertise_boost = 0
var stealth_boost = 0
var tech_boost = 0

# The amount of armor provided by this piece of equipment
var armor_value = 0

# The amount of disruption provided by this piece of equipment
var disruption_value = 0

var physical_dodge_boost = 0
var physical_hit_boost = 0

var tech_dodge_boost = 0
var tech_hit_boost = 0

var health_boost = 0
var energy_boost = 0
var energy_gain_boost = 0

func _ready():
	pass
