extends VBoxContainer

signal weapon_selected

const weapon_class = preload("res://assets/scripts/characters/weapon.gd")

var selected_weapon = null
onready var cancel_btn = get_node("cancel")

func _ready():
	cancel_btn.connect("pressed", self, "handle_click", [null])
	pass

func handle_click(weapon):
	selected_weapon = weapon
	emit_signal("weapon_selected")

func set_weapons(weapons):
	# Clear all children (aka old weapons) first
	for child in get_children():
		if child is Button && child.text == "Cancel":
			continue

		child.queue_free()

	for w in weapons:
		if w is weapon_class:
			var w_btn = Button.new()
			w_btn.text = w.get_name()
			w_btn.icon = w.get_thumbnail()
			w_btn.set("weapon_object", w)
			w_btn.connect("pressed", self, "handle_click", [w])
			add_child(w_btn, true)