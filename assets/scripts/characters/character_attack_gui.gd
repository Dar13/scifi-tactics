extends Control

signal confirmed
signal cancelled

onready var cancel_attack_btn = get_node("cancel_attack_btn")
onready var target_confirm_dlg = get_node("target_confirm_dlg")

func _ready():
	target_confirm_dlg.add_item("Attack", 1)
	target_confirm_dlg.add_item("Cancel", 2)
	target_confirm_dlg.connect("id_pressed", self, "handle_selection")

	cancel_attack_btn.connect("pressed", self, "handle_cancel_button")
	pass

func selection_mode():
	target_confirm_dlg.hide()
	cancel_attack_btn.show()

func confirmation_mode():
	cancel_attack_btn.hide()
	target_confirm_dlg.popup(Rect2(0, 0, 128, 128))

func handle_selection(selected_id):
	if selected_id == 1:
		emit_signal("confirmed")
	else:
		print("emit cancel (menu)")
		emit_signal("cancelled")

func handle_cancel_button():
	print("emit cancel (button)")
	emit_signal("cancelled")