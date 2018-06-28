extends Control

onready var atk_indicator = get_node("atk_indicator")
onready var counter_atk_indicator = get_node("counter_atk_indicator")

onready var atk_name = get_node("atk_panel/VBoxContainer/atk_name")
onready var atk_hp = get_node("atk_panel/VBoxContainer/atk_hp_container/atk_hp")
onready var atk_eng = get_node("atk_panel/VBoxContainer/atk_eng_container/atk_eng")
onready var atk_dmg = get_node("atk_panel/VBoxContainer/atk_dmg_container/atk_dmg_value")
onready var atk_hit = get_node("atk_panel/VBoxContainer/atk_hit_container/atk_hit_value")

onready var def_name = get_node("def_panel/VBoxContainer2/def_name")
onready var def_hp = get_node("def_panel/VBoxContainer2/def_hp_container/def_hp")
onready var def_eng = get_node("def_panel/VBoxContainer2/def_eng_container/def_eng")
onready var def_dmg = get_node("def_panel/VBoxContainer2/def_dmg_container/def_dmg_value")
onready var def_hit = get_node("def_panel/VBoxContainer2/def_hit_container/def_hit_value")

func _ready():
	counter_atk_indicator.hide()
	hide()

func populate(context):
	if(context.defender_info["damage"] != -1):
		counter_atk_indicator.show()

	atk_name.text = context.attacker_info["name"]
	atk_hp.value = context.attacker_info["health"]
	atk_hp.max_value = context.attacker_info["health_max"]
	atk_eng.value = context.attacker_info["energy"]
	atk_eng.max_value = context.attacker_info["energy_max"]
	atk_dmg.text = str(context.attacker_info["damage"])
	atk_hit.text = str(context.attacker_info["hit_chance"])

	def_name.text = context.defender_info["name"]
	def_hp.value = context.defender_info["health"]
	def_hp.max_value = context.defender_info["health_max"]
	def_eng.value = context.defender_info["energy"]
	def_eng.max_value = context.defender_info["energy_max"]
	# TODO: Special-case this based on value
	def_dmg.text = str(context.defender_info["damage"])
	def_hit.text = str(context.defender_info["hit_chance"])

	show()
