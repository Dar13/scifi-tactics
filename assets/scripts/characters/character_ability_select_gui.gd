extends VBoxContainer

signal ability_selected

# TODO: ability_class
#var weapon_class = load("res://assets/scripts/characters/weapon.gd")

var selected_ability = null
onready var cancel_btn = get_node("cancel")

func _ready():
	cancel_btn.connect("pressed", self, "handle_click", [null])
	pass

func handle_click(ability):
	selected_ability = ability
	emit_signal("ability_selected")

func set_abilities(abilities):
	# Clear all children (aka old abilities) first
	for child in get_children():
		if child is Button && child.text == "Cancel":
			continue

		child.queue_free()

	for a in abilities:
		#if a is ability_class:
		if a:
			var a_btn = Button.new()
			a_btn.text = a.get_name()
			a_btn.icon = a.get_thumbnail()
			a_btn.set("ability_object", a)
			a_btn.connect("pressed", self, "handle_click", [a])
			add_child(a_btn, true)
