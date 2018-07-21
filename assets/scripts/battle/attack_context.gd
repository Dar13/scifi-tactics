extends Node

# Data about an attack

var attacker = null
var attacker_info = {}

var defender = null
var defender_info = {}

static func generate_context(atk_char, def_char):
	var ctx = new()

	# TODO: Properly calculate hit chances and damage for attacker

	ctx.attacker = atk_char
	ctx.attacker_info = {"name": "Darius",
			"damage": 5,
			"health": ctx.attacker.state.health,
			"health_max": ctx.attacker.state.max_health,
			"energy": ctx.attacker.state.energy,
			"energy_max": ctx.attacker.state.max_energy,
			"hit_chance": 100.0}

	# This may not be correct when using ranged combat.
	# But for now, it'll do.
	var counter_possible = (atk_char.facing != def_char.facing)

	ctx.defender = def_char
	ctx.defender_info = {"name": "Ellie",
			"health": ctx.defender.state.health,
			"health_max": ctx.defender.state.max_health,
			"energy": ctx.defender.state.energy,
			"energy_max": ctx.defender.state.max_energy}

	# TODO: Properly calculate hit chances and damage for defender's counter-attack
	if counter_possible:
		ctx.defender_info["damage"] = 3
		ctx.defender_info["hit_chance"] = 100.0
	else:
		ctx.defender_info["damage"] = 0
		ctx.defender_info["hit_chance"] = 0.0

	return ctx
