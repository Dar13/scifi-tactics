extends Node

# class member variables go here, for example:
onready var camera = get_viewport().get_camera()
onready var map = get_node("../map_root")

onready var character_mgr = load("res://assets/scripts/characters/character_manager.gd").new()
var character_scene = preload("res://assets/models/characters/basic_character.tscn")

var player_team = {}
var enemy_team = {}

func _ready():
	add_child(character_mgr)
	
	# Initialize the battle scene
	# For now this means, spawn the one team
	
	# Setup the 'player' team
	var test_positions = [Vector3(0, 2, 0), Vector3(2, 2, 0), Vector3(-2, 2, 0)]
	for i in range(3):
		var character = character_scene.instance()
		add_child(character)
		character.set_position(test_positions[i])
		character.map = map
		character.show()
		character.connect("update_state", character_mgr, "update_character_state")

		player_team[character.get_instance_id()] = character

	
	# Player team starts the battle
	character_mgr.prepare_for_turn(player_team)
	return

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
