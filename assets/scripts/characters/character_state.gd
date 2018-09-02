extends Node

# This is the data section of a character, containing the character class,
# combat stats, character stats, items held, abilities, learned, level, experience, etc.
#
# This persists between battles.

var attack_class = load("res://assets/scripts/battle/attack.gd")
var weapon_class = load("res://assets/scripts/characters/weapon.gd")
var equip_class = load("res://assets/scripts/characters/equipment.gd")

# Array of equipment on this character
var inventory = []
var active_weapon = null

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

var base_phys_attack = 0	# A base value for physical attacks, this varies depending on the class. Is the equivalent of attacking with fists
var base_tech_attack = 0	# A base value for physical attacks, this varies depending on the class. Is the equivalent of attacking with fists

func _ready():
	pass

func destroy():
	for i in inventory:
		i.destroy()
		i.free()

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

			base_phys_attack = 1
			base_tech_attack = 0
		_:
			print("unknown class, all your stats are zero!")

# Evaluates equipment, returning array with these contents:
#	- Total physical attack magnitude
#	- Total tech attack magnitude
#	- Total physical defense magnitude
#	- Total tech defense magnitude
func evaluate_equipment():
	var phys_atk_contrib = base_phys_attack
	var tech_atk_contrib = base_tech_attack

	# Set the base values
	var phys_atk = power
	var phys_def = armor

	var tech_atk = expertise
	var tech_def = disruption

	# Determine:
	#	* active weapon (if null)
	#	* character attack power
	#	* equipment defense bonus
	for e in inventory:
		if e is weapon_class:
			if active_weapon == null:
				active_weapon = e
				print("Setting active wep to %s" % e.get_name())

			if active_weapon == e:
				phys_atk_contrib = active_weapon.get_state().phys_attack_power
				tech_atk_contrib = active_weapon.get_state().tech_attack_power
		elif e is equip_class:
			phys_def += e.get_state().armor_value
			tech_def += e.get_state().disruption_value

	if phys_atk_contrib > 0:
		phys_atk += phys_atk_contrib
	else:
		phys_atk = 0

	if tech_atk_contrib > 0:
		tech_atk += tech_atk_contrib
	else:
		tech_atk = 0

	return [phys_atk, tech_atk, phys_def, tech_def]

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
		evaluate_equipment()
	
	return rv

func set_active_weapon(wep):
	var idx = inventory.find(wep)
	if idx == -1:
		print("Invalid weapon (%s) given to %s as active weapon!" % [wep, self])
	else:
		active_weapon = wep	# TODO: Or `active_weapon = inventory[idx]`?

func generate_attack():
	# Evaluate equipment to generate an attack object
	var stats = evaluate_equipment()
	var atk = attack_class.new(attack_class.AttackType.Physical, stats[0], stats[1], 1.0)
	return atk

func evaluate_attack(attack):
	var stats = evaluate_equipment()
	if attack.phys_attack_magnitude > 0:
		attack.phys_attack_magnitude -= stats[2]

	if attack.tech_attack_magnitude > 0:
		attack.tech_attack_magnitude -= stats[3]
	
