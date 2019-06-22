extends Node

enum BattlePhase {
	INIT = 0,
	CHARACTER_PLACEMENT,
	PRE_BATTLE,
	BATTLE,
	POST_BATTLE,
}

onready var camera = get_viewport().get_camera()
var map = null

onready var character_mgr = null
var character_scene = load("res://assets/scenes/character.tscn")
var character_state = load("res://assets/scripts/characters/character_state.gd")
var character_class = load("res://assets/scripts/characters/character.gd")
var character_dir = load("res://assets/scripts/characters/character_direction.gd")

var weapon_scene = load("res://assets/scenes/weapon.tscn")
var weapon_state = load("res://assets/scripts/equipment/weapons/weapon_state.gd")

var equipment_scene = load("res://assets/scenes/equipment.tscn")
var equipment_state = load("res://assets/scripts/equipment/equipment_state.gd")

var ability_scene = load("res://assets/scenes/ability.tscn")
var ability_state = load("res://assets/scripts/equipment/ability_state.gd")

var placement_mgr_class = load("res://assets/scripts/battle/character_placement.gd")
var placement_mgr = null

var win_condition_class = load("res://assets/scripts/battle/win_condition.gd")
var battle_win_condition = null

var party_class = load("res://assets/scripts/campaign/party.gd")
var player_party = null
var enemy_party = null

var current_team = null
var player_team = {}
var enemy_team = {}

onready var num_turns = 0

onready var phase = BattlePhase.INIT

onready var fps_label = get_node("../fps_label")

func _ready():
	# Load the battle's map, according to the 'Map' scene, and add it to the scene
	map = load(global_state.battle_map).instance()
	map.name = "map"	# We don't care what the scene we instanced calls itself
	add_child(map)

	# Initialize the battle scene
	# For now this means, create a player and enemy party and set them in some
	# default way.
	player_party = party_class.new()	# Eventually this will come from external source
	for i in range(3):
		var state = character_state.new()
		state.init(character_state.Classes.BASIC)
		state.level_up()

		player_party.add_character(state)

	enemy_party = party_class.new()	# Eventually this will come from external source
	for i in range(3):
		var state = character_state.new()
		state.init(character_state.Classes.BASIC)
		state.level_up()

		enemy_party.add_character(state)

	# Create the player team from the player party
	# Character default positions from the possible player placement positions
	var plr_placement_pos = map.get_player_placement_positions()
	for i in range(player_party.size()):
		var character = character_scene.instance()
		var pos = plr_placement_pos[i]
		pos.y += 0.5	# TODO: character.get_center_offset()
		character.init(player_party.get(i), pos,
				false, character_dir.CharDirections.East)
		character.set_on_player_team()
		
		add_child(character)

		player_team[character.get_collider().get_instance_id()] = character

	# Create the enemy team from the enemy party
	# TODO: Get positions/directions from character placement stage of battle
	#	(for enemies this is from the campaign scenario or the random
	#	battle information)
	var enem_placement_pos = map.get_enemy_placement_positions()
	for i in range(enemy_party.size()):
		var character = character_scene.instance()
		var pos = enem_placement_pos[i]
		pos.y += 0.5	# TODO: character.get_center_offset()
		character.init(enemy_party.get(i), pos,
				true, character_dir.CharDirections.West)
		add_child(character)

		enemy_team[character.get_collider().get_instance_id()] = character

	# Pick first player character for a weapon's test
	var test_wep = weapon_scene.instance()
	test_wep.init(weapon_state.WeaponNames.BASIC_PISTOL)
	var test_ch = player_team.values()[0]
	test_ch.add_equipment(test_wep)

	# Add a hat...
	var test_hat = equipment_scene.instance()
	test_hat.init(equipment_state.EquipNames.BASIC_HAT)
	test_ch.add_equipment(test_hat)

	# And a vest
	var test_vest = equipment_scene.instance()
	test_vest.init(equipment_state.EquipNames.BASIC_VEST)
	test_ch.add_equipment(test_vest)

	# And an ability
	var test_abi = ability_scene.instance()
	test_abi.init(ability_state.AbilityNames.LASER)
	test_ch.add_ability(test_abi)

	# Player team starts the battle
	current_team = player_team

	# TODO: Get this information from the Map Scene or a campaign file or something
	# Set up the win condition for the battle
	battle_win_condition = win_condition_class.new(win_condition_class.WinConditions.KILL_LEADER,
			enemy_team.values()[0], win_condition_class.LossConditions.LEADER_DEAD, player_team.values()[0])

	update_battle_phase(BattlePhase.CHARACTER_PLACEMENT)

	return

# Assuming this is called after my children's are called...
func _exit_tree():
	if character_mgr:
		character_mgr.free()

	for c in enemy_team.values():
		c.free()

	for c in player_team.values():
		c.free()

	if player_party:
		player_party.free()

	if enemy_party:
		enemy_party.free()
	
	battle_win_condition.free()

func update_battle_phase(new_phase):
	phase = new_phase

	# Reset phase-specific state here

	match new_phase:
		BattlePhase.INIT:
			print("WTF are you doing back here...")

		# Do character placement
		BattlePhase.CHARACTER_PLACEMENT:
			setup_character_placement()

		# TODO: Evaluate results of character placement into teams
		BattlePhase.PRE_BATTLE:
			pre_battle_setup()
			update_battle_phase(BattlePhase.BATTLE)

		BattlePhase.BATTLE:
			start_next_turn()

		# Do post-battle stuff like battle rewards, etc.
		BattlePhase.POST_BATTLE:
			print("Battle over, do stuff here...")
			pass

		_:
			print("Really, how did you get here?")

func setup_character_placement():
	placement_mgr = placement_mgr_class.new()
	add_child(placement_mgr)
	placement_mgr.set_party(player_team)
	placement_mgr.connect("finished", self, "placement_done_handler")

func placement_done_handler():
	print("placement phase done! Moving to BATTLE")
	cleanup_character_placement()
	update_battle_phase(BattlePhase.PRE_BATTLE)

func cleanup_character_placement():
	# Only placed members stay on the player team
	var placed = placement_mgr.get_placed()
	var to_remove = []
	for key in player_team.keys():
		if placed.has(player_team[key]) == false:
			to_remove.append(key)

	for k in to_remove:
		player_team.erase(k)

	remove_child(placement_mgr)
	placement_mgr.queue_free()

func pre_battle_setup():
	character_mgr = load("res://assets/scripts/characters/character_manager.gd").new()
	character_mgr.connect("battlefield_updated", self, "evaluate_battlefield")
	character_mgr.connect("turn_done", self, "finish_turn")
	add_child(character_mgr)

	# Join the two teams together to pass to the character manager and set up signals
	var battle_characters = {}
	for plr_key in player_team.keys():
		battle_characters[plr_key] = player_team[plr_key]
		player_team[plr_key].connect("update_phase", character_mgr, "update_character_phase")

	for enem_key in enemy_team.keys():
		battle_characters[enem_key] = enemy_team[enem_key]
		enemy_team[enem_key].connect("update_phase", character_mgr, "update_character_phase")

	character_mgr.prepare_for_battle(battle_characters)

# Update and evaluate various pieces of information relevant to pathfinding, gameplay, etc.
func evaluate_battlefield():
	var battle_obstacles = []
	
	for c in player_team.values():
		var char_pos = c.translation
		char_pos.y -= 2
		battle_obstacles.append(map.get_map_coords(char_pos))

	for c in enemy_team.values():
		var char_pos = c.translation
		char_pos.y -= 2
		battle_obstacles.append(map.get_map_coords(char_pos))

	map.set_obstacles(battle_obstacles)
	return

func start_next_turn():
	if battle_win_condition.evaluate_win(enemy_team, num_turns):
		# TODO: Make this do things...
		print("Won the battle!")
		update_battle_phase(BattlePhase.POST_BATTLE)

	if battle_win_condition.evaluate_loss(player_team, num_turns):
		# TODO: Make this do things...
		print("Lost the battle!")
		update_battle_phase(BattlePhase.POST_BATTLE)

	num_turns += 1

	evaluate_battlefield()
	character_mgr.prepare_for_turn(current_team)
	return

func finish_turn():
	# Move to next team
	if current_team == player_team:
		current_team = enemy_team
	else:
		current_team = player_team

	start_next_turn()
	return

func _process(delta):
	fps_label.text = "FPS: %s" % Engine.get_frames_per_second()
