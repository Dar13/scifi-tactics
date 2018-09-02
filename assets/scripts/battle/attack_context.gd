extends Node

# Data about a particular attack

var attacker = null
var attacker_info = {}

var defender = null
var defender_info = {}

static func generate_context(atk_char, def_char):
	var ctx = new()

	# TODO: Properly calculate hit chances and damage for attacker

	var atk = atk_char.state.generate_attack()
	def_char.state.evaluate_attack(atk)

	ctx.attacker = atk_char
	ctx.attacker_info = {"name": "Darius",
			"damage": atk.total(),
			"health": ctx.attacker.state.health,
			"health_max": ctx.attacker.state.max_health,
			"energy": ctx.attacker.state.energy,
			"energy_max": ctx.attacker.state.max_energy,
			"hit_chance": 100.0}

	atk.free()

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
		var counter = def_char.state.generate_attack()
		atk_char.state.evaluate_attack(counter)

		ctx.defender_info["damage"] = counter.total()
		ctx.defender_info["hit_chance"] = 100.0

		counter.free()
	else:
		ctx.defender_info["damage"] = 0
		ctx.defender_info["hit_chance"] = 0.0

	return ctx
