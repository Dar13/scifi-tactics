extends Node

# class member variables go here, for example:
onready var camera = get_viewport().get_camera()
onready var map = get_node("../map_root")

onready var character_mgr = load("res://assets/scripts/characters/character_manager.gd").new()
const character_scene = preload("res://assets/scenes/character.tscn")
const character_state = preload("res://assets/scripts/characters/character_state.gd")
const character_class = preload("res://assets/scripts/characters/character.gd")
const character_dir = preload("res://assets/scripts/characters/character_direction.gd")

const weapon_scene = preload("res://assets/scenes/weapon.tscn")

var current_team = null
var player_team = {}
var enemy_team = {}

onready var fps_label = get_node("../fps_label")

func _ready():
	add_child(character_mgr)
	character_mgr.connect("battlefield_updated", self, "evaluate_battlefield")
	character_mgr.connect("turn_done", self, "finish_turn")
	
	# Initialize the battle scene
	# For now this means, spawn the teams
	
	# Setup the 'player' team
	var test_positions = [Vector3(0, 2, 0), Vector3(2, 2, 0), Vector3(-2, 2, 0)]
	for i in range(3):
		var state = character_state.new()
		state.character_class = character_state.Classes.BASIC
		
		var character = character_scene.instance()
		character.init(state, test_positions[i], true, character_dir.CharDirections.East)
		character.connect("update_phase", character_mgr, "update_character_phase")
		character.set_on_player_team()
		
		add_child(character)

		player_team[character.get_collider().get_instance_id()] = character

	# Setup the 'enemy' team
	test_positions = [Vector3(0, 6, -6), Vector3(2, 4, -6), Vector3(-2, 6, -6)]
	for i in range(3):
		var state = character_state.new()
		state.character_class = character_state.Classes.BASIC
		
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
	test_wep.init(test_wep.Name.BASIC)
	var test_ch = player_team.values()[0]
	test_ch.add_equipment(test_wep)
	
	# Player team starts the battle
	current_team = player_team
	start_next_turn()
	return

# Update and evaluate various pieces of information relevant to pathfinding, gameplay, etc.
func evaluate_battlefield():
	var obstacles = []
	
	for c in player_team.values():
		var char_pos = c.translation
		char_pos.y -= 2
		obstacles.append(map.get_map_coords(char_pos))

	for c in enemy_team.values():
		var char_pos = c.translation
		char_pos.y -= 2
		obstacles.append(map.get_map_coords(char_pos))

	map.obstacles = obstacles
	return

func start_next_turn():
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
