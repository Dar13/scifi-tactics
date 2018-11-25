extends Node

# class member variables go here, for example:
onready var camera = get_viewport().get_camera()
var map = null

onready var character_mgr = load("res://assets/scripts/characters/character_manager.gd").new()
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

var win_condition_class = load("res://assets/scripts/battle/win_condition.gd")
var battle_win_condition = null

var current_team = null
var player_team = {}
var enemy_team = {}

onready var num_turns = 0

onready var fps_label = get_node("../fps_label")

func _ready():
	# Load the battle's map, according to the 'Map' scene, and add it to the scene
	map = load(global_state.battle_map).instance()
	map.name = "map"	# We don't care what the scene we instanced calls itself
	add_child(map)

	add_child(character_mgr)
	character_mgr.connect("battlefield_updated", self, "evaluate_battlefield")
	character_mgr.connect("turn_done", self, "finish_turn")
	
	# Initialize the battle scene
	# For now this means, spawn the teams
	
	# Setup the 'player' team
	var test_positions = [Vector3(0, 2, 10), Vector3(2, 2, 8), Vector3(-2, 2, 8)]
	for i in range(3):
		var state = character_state.new()
		state.init(character_state.Classes.BASIC)
		state.level_up()

		var character = character_scene.instance()
		character.init(state, test_positions[i], true, character_dir.CharDirections.East)
		character.connect("update_phase", character_mgr, "update_character_phase")
		character.set_on_player_team()
		
		add_child(character)

		player_team[character.get_collider().get_instance_id()] = character

	# Setup the 'enemy' team
	test_positions = [Vector3(-4, 2, -8), Vector3(0, 2, -8), Vector3(-8, 4, -8)]
	for i in range(3):
		var state = character_state.new()
		state.init(character_state.Classes.BASIC)
		state.level_up()
		
		var character = character_scene.instance()
		character.init(state, test_positions[i], true, character_dir.CharDirections.West)
		character.connect("update_phase", character_mgr, "update_character_phase")
		add_child(character)

		enemy_team[character.get_collider().get_instance_id()] = character

	# Join the two teams together to pass to the character manager
	var battle_characters = {}
	for plr_key in player_team.keys():
		battle_characters[plr_key] = player_team[plr_key]

	for enem_key in enemy_team.keys():
		battle_characters[enem_key] = enemy_team[enem_key]

	character_mgr.prepare_for_battle(battle_characters)

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
	battle_win_condition = win_condition_class.new(win_condition_class.WinConditions.KILL_LEADER, enemy_team.values()[0], win_condition_class.LossConditions.LEADER_DEAD, player_team.values()[0])

	start_next_turn()
	return

# Assuming this is called after my children's are called...
func _exit_tree():
	if character_mgr:
		character_mgr.free()

	for c in enemy_team.values():
		c.free()

	for c in player_team.values():
		c.free()
	
	battle_win_condition.free()

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

	if battle_win_condition.evaluate_loss(player_team, num_turns):
		# TODO: Make this do things...
		print("Lost the battle!")

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
