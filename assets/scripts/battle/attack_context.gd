extends Node

# Data about an attack

var attacker = null
var attacker_info = {}

var defender = null
var defender_info = {}

static func generate_context(atk_char, def_char):
	var ctx = new()
	
	ctx.attacker = atk_char
	ctx.attacker_info = {"name": "Darius",
			"damage": 5,
			"health": ctx.attacker.state.health,
			"health_max": ctx.attacker.state.max_health,
			"energy": ctx.attacker.state.energy,
			"energy_max": ctx.attacker.state.max_energy,
			"hit_chance": 100.0}

	ctx.defender = def_char
	ctx.defender_info = {"name": "Ellie",
			"damage": 3,
			"health": ctx.defender.state.health,
			"health_max": ctx.defender.state.max_health,
			"energy": ctx.defender.state.energy,
			"energy_max": ctx.defender.state.max_energy,
			"hit_chance": 100.0}

	return ctx
