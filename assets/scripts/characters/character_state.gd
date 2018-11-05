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
var abilities = []
var active_weapon = null

enum Classes {
	BASIC = 0,
}

enum JumpType {
	NORMAL = 0,
}

var character_class = Classes.BASIC
var character_class_str = "Basic"

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
var stealth = 0				# Overall stealth value, influences other combat values (refer to GDD)
var jump_type = JumpType.NORMAL

# Hit rate is a per-attack calculated attribute and is subject to the context of that attack.
# NOTE: All attributes used are after equipment evaluation.
# The general formula is the following:
# For physical attacks, Attacker's SKL and Defender's SKL are used.
# For technological attacks, Attacker's EXP and Defender's EXP are used.
# For hybrid attacks, the sum of the SKL/EXP skills are used.
# Raw Odds = (1 + A) / ((1 + A) + (1 + D))
# Adjusted Hit Rate = 1 / (1 + (e ^ ((RawOdds * -11) + 3)))
# Steepness = -11, Offset = 5
# Reference: https://www.reddit.com/r/gamedev/comments/96f8jl/if_you_are_making_an_rpg_you_need_to_know_the/

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
			character_class_str = "Basic"
			health = level * 60
			max_health = health
			energy = level * 25
			max_energy = energy
			start_energy = 5
			energy_gain = 5
			armor = 4
			disruption = 3
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
#	- Attack Type
#	- TODO: Resistances
func evaluate_equipment():
	var phys_atk_contrib = base_phys_attack
	var tech_atk_contrib = base_tech_attack

	# Set the base values
	var phys_atk = power
	var phys_def = armor

	var tech_atk = expertise
	var tech_def = disruption

	var type = attack_class.AttackType.Invalid

	# Determine:
	#	* active weapon (if null)
	#	* character attack power
	#	* equipment defense bonus
	for e in inventory:
		if e is weapon_class:
			if active_weapon == null:
				active_weapon = e

			if active_weapon == e:
				phys_atk_contrib = active_weapon.get_state().phys_attack_power
				tech_atk_contrib = active_weapon.get_state().tech_attack_power
		elif e is equip_class:
			phys_def += e.get_state().armor_value
			tech_def += e.get_state().disruption_value

	if phys_atk_contrib > 0:
		phys_atk += phys_atk_contrib
		type = type | attack_class.AttackType.Physical
	else:
		phys_atk = 0

	if tech_atk_contrib > 0:
		tech_atk += tech_atk_contrib
		type = type | attack_class.AttackType.Tech
	else:
		tech_atk = 0

	return [phys_atk, tech_atk, phys_def, tech_def, type]

# Called after every turn, used for temporary effects (ENG increment, turn-based increases to PWR/SKL/EPT/etc)
func evaluate_turn_end():
	print("TODO: evaluate_turn_end()")

# Called when character defeats another, determines experience gain and performs level-up if appropriate
func increment_experience(enemy_level, enemy_class):
	print("TODO: Increment experience. Level: %s, Class %s" % [enemy_level, enemy_class])

func apply_attack(atk_ctx, counter):
	if counter:
		if atk_ctx.defender_info["success"]:
			print("Counter successful")
			self.health -= atk_ctx.defender_info["damage"]
		else:
			print("Counter failed")
	else:
		if atk_ctx.attacker_info["success"]:
			print("Attack successful")
			self.health -= atk_ctx.attacker_info["damage"]
		else:
			print("Attack failed")


func add_equipment(item):
	var rv = false
	if inventory.size() < 5:
		inventory.push_back(item)
		rv = true
		evaluate_equipment()
	
	return rv

func add_ability(abi):
	abilities.push_back(abi)

func set_active_weapon(wep):
	var idx = inventory.find(wep)
	if idx == -1:
		print("Invalid weapon (%s) given to %s as active weapon!" % [wep, self])
	else:
		active_weapon = wep	# TODO: Or `active_weapon = inventory[idx]`?

func generate_attack():
	# Evaluate equipment to generate an attack object
	# TODO: Replace these stats magic numbers with proper constants
	# TODO: Get status scaling from evaluate_equipment()?
	var stats = evaluate_equipment()
	var atk = attack_class.new(stats[4], stats[0], stats[1], 1.0)
	return atk

# Returns a triplet: [physical hit rate, tech hit rate, hybrid hit rate]
func get_hit_rate(defender):
	var phys_skill = self.skill
	var phys_diff = defender.state.skill
	var tech_skill = self.expertise
	var tech_diff = defender.state.expertise
	var hybr_skill = self.skill + self.expertise
	var hybr_diff = defender.state.skill + defender.state.expertise

	var output = {}
	output[attack_class.AttackType.Physical] = 0
	output[attack_class.AttackType.Tech] = 0
	output[attack_class.AttackType.Hybrid] = 0

	for type in output:
		var s = 0
		var d = 0
		var raw = 0
		var adjusted = 0
		match type:
			attack_class.AttackType.Physical:
				s = phys_skill
				d = phys_diff
			attack_class.AttackType.Tech:
				s = tech_skill
				d = tech_diff
			attack_class.AttackType.Hybrid:
				s = hybr_skill
				d = hybr_diff

		raw = (1.0 + s) / ((1.0 + s) + (1.0 + d))
		adjusted = 1.0 / (1.0 + exp((raw * -11.0) + 5.0))

		output[type] = floor(clamp(adjusted * 100.0, 1.0, 99.0))

	return output

func evaluate_attack(attack):
	var stats = evaluate_equipment()
	if attack.phys_attack_magnitude > 0:
		attack.phys_attack_magnitude -= stats[2]
		attack.phys_attack_magnitude = clamp(attack.phys_attack_magnitude, 1, 1000)

	if attack.tech_attack_magnitude > 0:
		attack.tech_attack_magnitude -= stats[3]
		attack.tech_attack_magnitude = clamp(attack.tech_attack_magnitude, 1, 1000)
