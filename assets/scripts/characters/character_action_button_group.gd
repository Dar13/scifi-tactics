extends Node

func _ready():
	pass

func get_attack_btn():
	return get_node("attack")

func get_item_btn():
	return get_node("item")

func get_standby_btn():
	return get_node("standby")