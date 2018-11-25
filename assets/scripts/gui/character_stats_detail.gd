extends Panel

signal shrink

var char_state = load("res://assets/scripts/characters/character_state.gd")
var item_detail = load("res://assets/scenes/gui/character_detail_item.tscn")

onready var shrinko = get_node("shrink")

onready var icon = get_node("./overview/icon")
onready var c_name = get_node("overview/info_container/meta_col/name")
onready var c_class = get_node("overview/info_container/meta_col/class")
onready var level = get_node("overview/info_container/meta_col/level")
onready var experience = get_node("overview/info_container/meta_col/experience")
onready var health_numeric = get_node("overview/info_container/meta_col/health_numeric")
onready var energy_numeric = get_node("overview/info_container/meta_col/energy_numeric")
onready var health_bar = get_node("overview/info_container/meta_col/health_bar")
onready var energy_bar = get_node("overview/info_container/meta_col/energy_bar")

onready var strength_value = get_node("overview/info_container/meta_col2/attr_grid/strength_value")
onready var skill_value = get_node("overview/info_container/meta_col2/attr_grid/skill_value")
onready var expertise_value = get_node("overview/info_container/meta_col2/attr_grid/expertise_value")

onready var armor_value = get_node("overview/info_container/meta_col2/power_grid/phys_def_value")
onready var disruption_value = get_node("overview/info_container/meta_col2/power_grid/tech_def_value")

onready var inv_item_list = get_node("tabs/Inventory/item_container/items")
onready var inv_item_desc = get_node("tabs/Inventory/item_desc_panel/desc_layout/desc_content")

onready var abi_list = get_node("tabs/Abilities/ability_container/abilities")
onready var abi_desc = get_node("tabs/Abilities/abi_desc_panel/desc_layout/desc_content")

var curr_char = null

func _ready():
	shrinko.connect("pressed", self, "do_shrink")

func do_shrink():
	emit_signal("shrink")

func fill(c):
	c_name.text = "Darius Detailed <TEMP>"
	c_class.text = c.state.character_class_str
	level.text = "Level %s" % c.state.level
	experience.text = "Experience %s" % c.state.experience
	health_numeric.text = "Health  %s / %s" % [c.state.health, c.state.max_health]
	health_bar.max_value = c.state.max_health
	health_bar.value = c.state.health

	energy_numeric.text = "Energy  %s / %s" % [c.state.energy, c.state.max_energy]
	energy_bar.max_value = c.state.max_energy
	energy_bar.value = c.state.energy

	strength_value.text = "%s" % c.state.power
	skill_value.text = "%s" % c.state.skill
	expertise_value.text = "%s" % c.state.expertise

	armor_value.text = "%s" % c.state.armor
	disruption_value.text = "%s" % c.state.disruption

	inv_item_desc.text = ""

	# Clear out the existing items (if any)
	for child in inv_item_list.get_children():
		child.queue_free()

	# Add this character's items to the inventory list
	for item in c.state.inventory:
		var detail = item_detail.instance()
		detail.get_node("hbox/item_name").text = item.get_name()
		detail.get_node("hbox/icon").texture = item.get_thumbnail()
		inv_item_list.add_child(detail)
		detail.get_node("hbox/item_name").connect("pressed", self, "inv_set_desc", [item])

	# Add this character's abilities to the ability list
	for abi in c.state.abilities:
		var detail = item_detail.instance()
		detail.get_node("hbox/item_name").text = abi.get_name()
		detail.get_node("hbox/icon").texture = abi.get_thumbnail()
		abi_list.add_child(detail)
		detail.get_node("hbox/item_name").connect("pressed", self, "abi_set_desc", [abi])
	
	curr_char = c

func inv_set_desc(item):
	inv_item_desc.text = item.get_description()

func abi_set_desc(abi):
	abi_desc.text = abi.get_description()
