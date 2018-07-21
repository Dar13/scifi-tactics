extends Node

# This is the data section of a character, containing the character class,
# combat stats, character stats, items held, abilities, learned, level, experience, etc.
#
# This persists between battles.

# Array of equipment on this character
var inventory = []

enum Classes {
	BASIC = 0,
}

enum JumpType {
	NORMAL = 0,
}

var character_class = Classes.BASIC

# Progression attributes
var level = 1
var experience = 0		# Level up occurs at experience == 100

# Aggregate attributes
var health = 0				# Current hitpoints of character
var max_health = 0			# Maximum hitpoints of character
#var health_gain = 0		# TODO: Regenerating health?
var energy = 0				# Current energy of character, used by abilities and special weapons
var max_energy = 0			# Max energy of character
var start_energy = 0		# Starting energy of character at start of battle
var energy_gain = 0			# Energy gain per turn of character
var armor = 0				# Modifier on all physical damage taken
var disruption = 0			# Modifier on all tech damage taken, also has special ability (refer to GDD)
var physical_dodge = 0		# Overall dodge chance for all received physical attacks
var physical_hit = 0		# Overall hit chance for all attempted physical attacks
var tech_dodge = 0			# Overall dodge chance for all received tech attacks
var tech_hit = 0			# Overall hit chance for all attempted tech attacks
var stealth = 0				# Overall stealth value, influences other combat values (refer to GDD)
var jump_type = JumpType.NORMAL

# Movement/Terrain related
var movement_range = 5

# Character combat attributes
var power = 0				# Physical power/might of character, refer to GDD for effected attributes
var skill = 0				# Skill and speed of character, refer to GDD for effected attributes
var expertise = 0			# Technical expertise of character, refer to GDD for effected attributes

func _ready():
	pass

# Should be called when creating the character, recreates character stats based on class and equipment
# Relies on level being initialized already (TODO: pass it in?)
func evaluate_initial_stats():
	match character_class:
		Classes.BASIC:
			health = level * 60
			max_health = health
			energy = level * 25
			max_energy = energy
			start_energy = 5
			energy_gain = 5
			armor = 4
			disruption = 3
			physical_dodge = .5
			physical_hit = .5
			tech_dodge = .4
			tech_hit = .3
			stealth = 1
			
			jump_type = JumpType.NORMAL
			movement_range = 5
			
			power = (level * 4)
			skill = (level * 3)
			expertise = (level * 2)
		_:
			print("unknown class, all your stats are zero!")
	
	# Now evaluate equipment (includes weapons)

# Called after every turn, used for temporary effects (ENG increment, turn-based increases to PWR/SKL/EPT/etc)
func evaluate_turn_end():
	print("TODO: evaluate_turn_end()")

# Called when character defeats another, determines experience gain and performs level-up if appropriate
func increment_experience(enemy_level, enemy_class):
	print("TODO: Increment experience. Level: %s, Class %s" % [enemy_level, enemy_class])

func add_equipment(item):
	var rv = false
	if inventory.size() < 5:
		inventory.push_back(item)
		rv = true
	
	return rv
