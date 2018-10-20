extends Node

# Data about a particular attack

var attacker = null
var attacker_info = {}

var defender = null
var defender_info = {}

static func generate_context(atk_char, def_char):
	var ctx = new()

	var atk = atk_char.state.generate_attack()
	def_char.state.evaluate_attack(atk)

	var atk_rates = atk_char.state.get_hit_rate(def_char)

	ctx.attacker = atk_char
	ctx.attacker_info = {"name": "Darius",
			"damage": atk.total(),
			"health": ctx.attacker.state.health,
			"health_max": ctx.attacker.state.max_health,
			"energy": ctx.attacker.state.energy,
			"energy_max": ctx.attacker.state.max_energy,
			"hit_chance": atk_rates[atk.type & atk.AttackType.Hybrid]}

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

	if counter_possible:
		var counter = def_char.state.generate_attack()
		atk_char.state.evaluate_attack(counter)

		var counter_rates = def_char.state.get_hit_rate(atk_char)

		ctx.defender_info["damage"] = counter.total()
		ctx.defender_info["hit_chance"] = counter_rates[(counter.type & counter.AttackType.Hybrid)]

		counter.free()
	else:
		ctx.defender_info["damage"] = 0
		ctx.defender_info["hit_chance"] = 0.0

	return ctx

func evaluate_hit_chance():
	randomize()
	var atk_sum = 0
	var counter_sum = 0
	for n in range(3):
		atk_sum += rand_range(0, 100)
		counter_sum += rand_range(0, 100)
	
	# Roll = Arithmetic mean
	var atk_roll = atk_sum / 3
	var counter_roll = counter_sum / 3
	print("Attack: Roll = %s, Sum = %s" % [atk_roll, atk_sum])
	print("Counter: Roll = %s, Sum = %s" % [counter_roll, counter_sum])

	if atk_roll <= self.attacker_info["hit_chance"]:
		self.attacker_info["success"] = true
	else:
		self.attacker_info["success"] = false

	self.defender_info["success"] = false
	if self.defender_info["damage"] > 0:
		if counter_roll <= self.defender_info["hit_chance"]:
			self.defender_info["success"] = true
