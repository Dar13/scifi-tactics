extends Control

onready var atk_indicator = get_node("atk_indicator")
onready var counter_atk_indicator = get_node("counter_atk_indicator")

onready var atk_name = get_node("atk_panel/VBoxContainer/atk_name")

onready var def_name = get_node("def_panel/VBoxContainer2/def_name")

func _ready():
	counter_atk_indicator.hide()
	hide()

func populate(attacker_info, defender_info):
	if(defender_info["damage"] != -1):
		counter_atk_indicator.show()
	
	atk_name.text = attacker_info["name"]
	def_name.text = defender_info["name"]
	
	show()