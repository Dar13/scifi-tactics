extends Node

var abi_state = load("res://assets/scripts/equipment/ability_state.gd")
var abi_instances = {
	abi_state.AbilityNames.LASER : load("res://assets/models/equipment/abilities/laser/laser.tscn")
}

var instance = null

func _ready():
	pass

func _exit_tree():
	destroy()

func init(name):
	instance = abi_instances[name].instance()

func destroy():
	if instance:
		instance.destroy()
		instance.free()

func get_range_pattern(map_pos):
	return instance.get_range_pattern(map_pos)

# Used for AoE attacks, you select one square and that is used as the basis of the selection pattern.
# Visual:    | | | |	 | |x| |
#	     | |x| |  -> |x|x|x|
#            | | | |     | |x| |
func get_selection_pattern(map_pos):
	return instance.get_selection_pattern(map_pos)

func do_attack(object):
	return instance.do_attack(object)

func get_state():
	return instance.get_state()
