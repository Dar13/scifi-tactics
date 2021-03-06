extends Node

enum AbilityType {
	None,
	Support,
	Missile,
	AreaOfEffect,
	Doomsday	# Maybe? Not sure this will actually exist
}

enum AbilityCategory {
	None,
	Mechanical,
	Cybernetic,	# Robotics and cybernetics are kinda similar in theme...
	Robotics,
	Hacking,
}

enum AbilityNames {
	LASER,
	RODS_OF_GOD,
	RESTORE,
}

var category = AbilityCategory.None
var type = AbilityCategory.None

var energy_requirement = 0
var ability_range = 0

# A scale factor for physical attack power from this ability
var phys_attack_power = 0.0

# A scale for tech attack power from this ability
var tech_attack_power = 0.0

func atk_power(char_state):
	return [phys_attack_power * char_state.expertise, tech_attack_power * char_state.expertise]

# =============================================================================
# Abilities in this game are incredibly specific and unique in almost every
# way from each other. Some are support only, meant to help the caster or the
# caster's teammates. Others are meant to inflict massive amounts of damage
# over a large area. And yet there are more that are every flavor in between!
# As such, there will be limited shared state/code between abilities.
# =============================================================================
